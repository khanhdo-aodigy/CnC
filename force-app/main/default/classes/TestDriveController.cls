public without sharing class TestDriveController {

    List<Vehicle_Master__c> testvehimaster=new List<Vehicle_Master__c>();
    public List<testDriveWrap> theLists{get;set;}
    public String pdfId {get;set;}
    
    public String branchCode {get;set;}
    public String franchiseCode {get;set;}
    public String logo1{get;set;}
    public String logo2{get;set;}
    public String newWindow {get;set;}
    
    public String vehiId {
        get;
        set {
            vehiId = value;
        }
    }
    public String testId {
        get;
        set {
            testId = value;
        }
    }
    
    public class testDriveWrap{
        public List<Test_Drive__c> theTests{get;set;}
        public Vehicle_Master__c vehicle{get;set;}
        public String Comno{get;set;}
        public Boolean show{get;set;}
        public Boolean showQueue{get;set;}
        public testDriveWrap(Vehicle_Master__c test){
            Date today=date.today();
            vehicle=test;
            
            theTests=[select OwnerID,Sales_Rep_Mobile__c,Status__c,id,name,Branch_Code__c,Franchise_Code__c from Test_Drive__c where Model__c=:vehicle.id and Date__c=:today and Status__c<>'In' and Status__c<>'Cancel Queue' order by Status__c,name];
            if (theTests.size()>0){
                show=true;
                List<Test_Drive__c> temp=[select id,name,Branch_Code__c,Franchise_Code__c  from Test_Drive__c where Model__c=:vehicle.id and Date__c=:today and Status__c='Out'];
                if (temp.size()>0){
                    showQueue=true;
                }else{
                    showQueue=false;
                }
            }else{
                show=false;
            }
            
            if (vehicle.Comm_No__c==null || vehicle.Comm_No__c==''){
                if (vehicle.Registration_No__c==null || vehicle.Registration_No__c==''){
                    Comno='';
                }else{
                    Comno=vehicle.Registration_No__c;
                }
            }else{
                if (vehicle.Registration_No__c==null || vehicle.Registration_No__c==''){
                    Comno=vehicle.Comm_No__c;
                }else{
                    Comno=vehicle.Comm_No__c +'/'+vehicle.Registration_No__c;
                }
            }
        }
    }
    
    public TestDriveController(){
        //logo1='/resource/logo/CCLogo.jpg';
        //logo2='/resource/logo/KiaLogo.png';
        Id userId=UserInfo.getUserId();
        User a=[select Branch_Code__c,Franchise_Code__c from User where id=: userId ];
        branchCode=a.Branch_Code__c;
        franchiseCode=a.Franchise_Code__c;
        
        logo1=[select filename__c from Logo__c where Branch_Code__c='' and Franchise_Code__c='' limit 1].filename__c;
        logo2=[select filename__c from Logo__c where Branch_Code__c=:branchCode limit 1].filename__c;
        
        pdfId='';
        fillList();
        String getId=apexpages.currentpage().getparameters().get('gid');
        if (getId!=null && getId!=''){
            pdfId=getId;
        }
    }
    public void fillList(){
        theLists=new List<testDriveWrap>();
        
        testvehimaster=[select id,Name,Comm_No__c,Registration_No__c,Branch_Code__c,Franchise_Code__c  from Vehicle_Master__c where Status__c='Available' and Type__c='Test Drive' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        for (Vehicle_Master__c vehi:testvehimaster){
            theLists.add(new testDriveWrap(vehi));
        }
    }
    public pageReference bookClick(){
        return new Pagereference('/apex/BookJoinQueuePage?id='+vehiId);
    }
    public pageReference cancelClick(){
        Test_Drive__c temp=[select id,status__c,Branch_Code__c,Franchise_Code__c  from Test_Drive__c where id=:testid];
        temp.status__c='Cancel Queue';
        update temp;
        fillList();
        return null;
    }
    public pageReference outClick(){
        Test_Drive__c temp=[select id,status__c,Check_Out__c,Check_In__c,Trade_Plate__c,Trade_Plate__r.name,Branch_Code__c,Franchise_Code__c  
                            from Test_Drive__c where id=:testid];
        List<Test_Drive__c> theTests=new List<Test_Drive__c>();
        Date today=date.today();
  
        theTests=[select id,name,Branch_Code__c,Franchise_Code__c  from Test_Drive__c where Date__c=:today and Status__c<>'In' and Status__c<>'Cancel Queue' and Trade_Plate__c=:temp.Trade_Plate__c and ID!=:temp.id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        if (theTests.size()<=0 || temp.Trade_Plate__c==null){
                temp.status__c='Out';
                temp.Check_Out__c=DateTime.now();
                update temp;
                fillList();
        }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'This trade plate ('+temp.Trade_Plate__r.name+') already on used by other test drive now.'));
        }
        return null;
    }
    public pageReference inClick(){
        Date today=date.today();
        Test_Drive__c temp=[select id,status__c,Check_Out__c,Check_In__c,Branch_Code__c,Franchise_Code__c  from Test_Drive__c 
                            where id=:testid];
        temp.status__c='In';
        temp.Check_In__c=DateTime.now();
        update temp;
        fillList();
        return null;
    }
        
}
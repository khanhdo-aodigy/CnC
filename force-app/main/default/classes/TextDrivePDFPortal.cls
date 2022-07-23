public class TextDrivePDFPortal {

    public String branchCode {get;set;}
    public String franchiseCode {get;set;}
    public String testId {get;set;}
    
    public TextDrivePDFPortal(){
        //Id userId=UserInfo.getUserId();
        //User a=[select Branch_Code__c,Franchise_Code__c from User where id=: userId ];
        testid = ApexPages.currentPage().getParameters().get('id');
        Test_drive__c a=[select Branch_Code__c,Franchise_Code__c from Test_drive__c where id=: testid];
        branchCode=a.Branch_Code__c;
        franchiseCode=a.Franchise_Code__c;
        //system.debug('aaaaa' + branchCode);
        //system.debug('aaaab' + franchiseCode);
        //system.debug('aaaac' + testId);
    }
    
    public pageReference goNext(){
            //System.debug('aaaaa' + branchCode);
            //System.debug('bbbbb' + testid);
            String a = '';
            if(franchiseCode=='KIAPC'){
               a = '/apex/TestDrivePDF?id=';
            }
            if(franchiseCode=='CITPC'){
               a = '/apex/TestDrivePDF_citroen?id=';
            }
            return new Pagereference(a+testid);
        
    }
}
/** ******
 * Description: Extension Class for the following VFs that rendered as pdf
 *              VFs = TestDrivePDF. TestDrivePDF_Lead, TestDrivePDF_MIT, TestDrivePDF_MIT_Lead, TestDrivePDF_citroen, TestDrivePDF_citroen_Lead, TestDrivePDFImage
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * 20151118            Billy Cheng          Created Initial Version. 
 * 20200313			   HSaodigy				Refactored the code ; Added PA Migration Changes 
 * 20201111			   KD@aodigy			Added PA Phase 2 migration changes
 * 
** ******/
public without sharing class TestDrivePDFext {
    public Test_Drive__c theTest {get;set;}
    public String LeadName {get;set;} 
    public String LeadNRIC {get;set;} 
    public String LeadEmail {get;set;} 
    public String LeadMobile {get;set;} 
    public String contactName {get;set;}   
    public boolean agree {get;set;}
    public String theAdd {get;set;}
    public String logo1 {get;set;}
    public String logo2 {get;set;}
    public String logo3 {get;set;}
    
    public String theUrl {get;set;}
    public String photoUrl1 {get;set;}
    public String photoUrl2 {get;set;}
    public List<Document> listDocuments {get;set;}
    
    public String theString {get;set;}
    public List<String> listDocumentNames {get;set;}
    
    public List<Attachment> listAttachments {get;set;}
    
    public TestDrivePDFext(ApexPages.StandardController controller) {

        String hostUrl = URL.getSalesforceBaseUrl().getHost();
        theUrl = 'https://' + hostUrl;
        
        String newHostUrl = hostUrl.replace('.','#');
        String[] arrHostUrl = newHostUrl.split('#');    
        //cyclecarriage.my.salesforce.com
        
        Organization orgData =  [SELECT IsSandbox, InstanceName   
                                 FROM Organization 
                                 LIMIT 1];
        
        String inst    = orgData.InstanceName.toLowerCase();
        String arrHost = String.isNotBlank(arrHostUrl[0]) && arrHostUrl[0].contains('--c') ?  arrHostUrl[0].remove('--c') : arrHostUrl[0];
        String newUrl  = 'https://'+ arrHost +'--c.'+ inst  +'.content.force.com';
        String cid     = controller.getRecord().id;
        
        listAttachments = new List<Attachment>();
        listAttachments = [SELECT Id, Name FROM Attachment WHERE parentId=:cid AND Description=:cid ORDER BY Name];
        Integer theIndex = 0;
        
        
        String servDownStr = newUrl + '/servlet/servlet.FileDownload?file=';
        for(Attachment atth : listAttachments){
            theIndex++;
            
            if(theIndex == 1){
                photoUrl1 = servDownStr + atth.id;
            }
            else if(theIndex == 2){
                photoUrl2 = servDownStr + atth.id;
            }
        }
    
        List<Test_Drive__c> lstTestDrives = new List<Test_Drive__c>();

        lstTestDrives =[SELECT Id, Name, Model__r.Name, Trade_Plate__c, Trade_Plate__r.Name, Digital_Signature__c, Agree__c, Branch_Code__c, Franchise_Code__c, owner.Name, Date__c,
                            Opportunity__r.Make_Model__c, Opportunity__r.Date_of_Registration__c, Opportunity__r.Old_Car_No__c, NRIC__c,
                            Prospect__r.Name, Prospect__r.NRIC_Passport_No__c, Prospect__r.Address_Line_1__c, Prospect__r.Address_Line_2__c, Prospect__r.Address_Line_3__c,
                            Prospect__r.Country__c, Prospect__r.Unit_No_Floor__c, Prospect__r.Birthdate, Prospect__r.Postal_Code__r.Name, Prospect__r.Email, Prospect__r.MobilePhone,
                            Prospect__r.FirstName, Prospect__r.LastName, Prospect__r.Full_Name__c, Prospect__c,
                            Prospect__r.Account.RecordTypeId, Prospect__r.AccountId, Contactless_test_drive__c, Account__c
                        FROM Test_Drive__c 
                        WHERE Id = :cid ];
        
        theTest = (lstTestDrives<>null && !lstTestDrives.isEmpty()) ? lstTestDrives.get(0) : null;
        
        if( theTest <> null )
        {
            String branchcode = theTest.Branch_Code__c;
            theAdd = '';
            for( Logo__c lg : [ SELECT FileName__c, Branch_Code__c, Franchise_Code__c 
                                FROM Logo__c 
                                WHERE (Branch_Code__c='' and Franchise_Code__c='') OR (Branch_Code__c =:branchcode)] )
            {
                if( String.isBlank( lg.Branch_Code__c ) && String.isBlank( lg.Franchise_Code__c ) ) {
                    logo1 = lg.FileName__c;
                }
                else{
                    logo2 = lg.FileName__c;
                }
            }
            getData();
        }
    }

    public void getData()
    {
        if(theTest.Prospect__r != null){
            contactName = String.isNotBlank(theTest.Prospect__r.Full_Name__c) ? theTest.Prospect__r.Full_Name__c : theTest.Prospect__r.Name;
            
            if ( String.isNotBlank( theTest.Prospect__r.Address_Line_1__c ) ){
                theAdd = theTest.Prospect__r.Address_Line_1__c;
            }
            if ( String.isNotBlank( theTest.Prospect__r.Address_Line_2__c ) ){
                if ( theAdd != '' ){
                    theAdd = theAdd+', '+theTest.Prospect__r.Address_Line_2__c;
                }
                else{
                    theAdd = theTest.Prospect__r.Address_Line_2__c;
                }
            }
            if ( String.isNotBlank( theTest.Prospect__r.Address_Line_3__c ) ){
                if ( theAdd !='' ){
                    theAdd = theAdd+', '+theTest.Prospect__r.Address_Line_3__c;
                }
                else{
                    theAdd = theTest.Prospect__r.Address_Line_3__c;
                }
            }
            if ( String.isNotBlank( theTest.Prospect__r.Unit_No_Floor__c ) ){
                if (theAdd != ''){
                    theAdd = theAdd+', '+theTest.Prospect__r.Unit_No_Floor__c;
                }
                else{
                    theAdd = theTest.Prospect__r.Unit_No_Floor__c;
                }
            }
            if ( String.isNotBlank( theTest.Prospect__r.Country__c ) ){
                if (theAdd != ''){
                    theAdd = theAdd+', '+theTest.Prospect__r.Country__c;
                }
                else{
                    theAdd = theTest.Prospect__r.Country__c;
                }
            }
            if( AccountUtil.isProspect( theTest.Prospect__r.Account.RecordTypeId, null ) ){
                LeadName   = String.isNotBlank( theTest.Prospect__r.Full_Name__c ) ? theTest.Prospect__r.Full_Name__c : theTest.Prospect__r.Name;
                LeadNRIC   = theTest.NRIC__c;
                LeadEmail  = theTest.Prospect__r.Email;
                LeadMobile = theTest.Prospect__r.MobilePhone;   
            }
        }

        if (theTest.Agree__c =='Yes' && (theTest.Agree__c !='' || theTest.Agree__c !=null)){
            agree = true;
        }
    }

}
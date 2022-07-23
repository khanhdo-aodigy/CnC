@isTest
private class FileUploadControllerTest {
    
    private static String registrationNo = '74L100888';
    
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPerson(true, 'Test', 'Customer');
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id];
        
        Registered_Vehicle__c testVehicle = Test_DataFactory.createRegVehicle(true, 'testV123', 'CCI', 'MBP',registrationNo, personAcc.PersonContactId);
    }
    
    @isTest 
    private static void testCreateSFU() {
        User u = createUser();
        
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('SFU');
        Integer createdCaseNo = FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'SFU');                    
        System.assertEquals(1, createdCaseNo);
    }
    
    @isTest 
    private static void testCreateCLI() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('CLI');
        Integer createdCaseNo = FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CLI');                    
        System.assertEquals(1, createdCaseNo);        
    }
    
    @isTest 
    private static void testCreateCSI() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('CSI');
        Integer createdCaseNo = FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CSI');                    
        System.assertEquals(1, createdCaseNo);        
    }
    
    @isTest 
    private static void testCreateRA() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('RA');
        Integer createdCaseNo = FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'RA');
        System.assertEquals(1, createdCaseNo);        
    }
    
    @isTest 
    private static void testUploadWrongFormat_ExceptionThrown() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('ABC');
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'SFU');
        } catch (Exception e) {
            System.assertEquals('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.',
                                e.getMessage());
        }
        
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CLI');
        } catch (Exception e) {
            System.assertEquals('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.',
                                e.getMessage());
        }
        
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CSI');
        } catch (Exception e) {
            System.assertEquals('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.',
                                e.getMessage());
        }
        
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'RA');
        } catch (Exception e) {
            System.assertEquals('The columns are not properly formatted. Please ensure the number of columns is correct and comma is the List separator.',
                                e.getMessage());
        }            
    }
    
    @isTest 
    private static void testValidationException_AuraHandledExceptionThrown() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('CLI_AURAHANDLED_EXCEPTION');       
        
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CLI');
        } catch (AuraHandledException e) {
           
        }
    }
    
    @isTest 
    private static void testInputTooLong_ExceptionThrown() {
        User u = createUser();
        ID RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Surveys').getRecordTypeId();
        ContentDocument cd = createFile('CLI_LENGTH_EXCEPTION');       
        
        try {
            FileUploadController.createSurvey(cd.LatestPublishedVersionId, u.Id, 'CLI');
        } catch (AuraHandledException e) {}
    }
    
    @isTest
    private static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CAC Standard User Profile'];
        
        User testUser = New User(Alias = 'standt', Email='standarduser@testorg.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_SG', 
                        LocaleSidKey='en_SG', ProfileId = p.Id, 
                        TimeZoneSidKey='Asia/Singapore', UserName='standarduser@testorg.com');
        return testUser;

    }    
     
    private static ContentDocument createFile(String type){
        String path = type + '.csv';
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = type,   
            PathOnClient = path,
            VersionData = Blob.valueOf(getBlob(type)),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        return FileUploadController.getFileAfterUpload(contentVersionSelect.ContentDocumentId);
    }
    
   private static String getBlob(String type){
        switch on type{
            when 'SFU'{ return 'JOB ORDER (Running Order),JOB TYPE*,JOB ORDER / INVOICE DATE*(dd/mm/yy),TITLE*,CUSTOMER NAME/ COMPANY NAME*,REGISTRATION NUMBER*,HOUSE TEL NO.*,OFFICE TEL  NO.*,MOBILE PHONE NO.*,SERVICE ADVISOR NAME,DATE RANGE FROM,DATE RANGE TO,SERVICE CENTRE\n'
                			  +'33916,CASH,06/03/2019,Mr,Yeo,'+ registrationNo +',,,92470549,JG,04/03/2019,10/03/2019,PLSC'; }
            when 'CLI'{ return 'VEHMAGIC,CUSTMAGIC,FIRSTNAM,SURNAME,SALUTE,SOCIALID,SEX,DOB,PHONE001,PHONE002,PHONE003,PHONE004,PHONE005,EMAIL,ADDRESS001,ADDRESS002,ADDRESS003,ADDRESS004,ADDRESS005,NOMAIL,SENSITIV,CREATED,EDITED,EDUSERID,LASTMLG,CHASSIS,PRODYR,PRODMTH,DESC,MODEL,VARIANT,FRAN,REGNO,REGDATE,SALESREP,FROM,TO\n'
                			  +'358180,282788,Kok Leng,Ho,Ho Kok Leng,S1688207J,M,3/1/1965, , , ,96660316,96660316,ca2cl@yahoo.com.sg,Blk 36 Dakota Crescent,#18-05,Singapore 399937, , ,N,N,24/1/2019,12/3/2019,rahimah,0,WDD2130452A501089,2018,6,MB E 250 SEDAN EXCLUSIVE/EXCLUSIVE,MB ECLASS,21304522-SG4,P,'+ registrationNo +',12/3/2019,seemhp,12/3/2019,12/3/2019'; }
            when 'CSI'{ return 'REGDATE,NAME ,DESC ,SEX,EMAIL,S/REP,REGNO,PHONE005,SENSITIV,NOMAIL,CASHCARD ISSUE,ACK RECV,SMS SENT,FROM,TO\n'
                				+'02/26/2019,Mr Ong Hwa Tee,E 200 SEDAN EXCLUSIVE/EXCLUSIVE,M,cong1958@hotmail.com,ANG YE SOON,'+ registrationNo +',EE1299M,92965458,N,N,t,N,02/26/2019,03/12/2019'; }
            when 'ListException' { return 'a,b ,n , k, m \n a,b,n,k,m'; }
            when 'CLI_AURAHANDLED_EXCEPTION'{ return 'VEHMAGIC,CUSTMAGIC,FIRSTNAM,SURNAME,SALUTE,SOCIALID,SEX,DOB,PHONE001,PHONE002,PHONE003,PHONE004,PHONE005,EMAIL,ADDRESS001,ADDRESS002,ADDRESS003,ADDRESS004,ADDRESS005,NOMAIL,SENSITIV,CREATED,EDITED,EDUSERID,LASTMLG,CHASSIS,PRODYR,PRODMTH,DESC,MODEL,VARIANT,FRAN,REGNO,REGDATE,SALESREP,FROM,TO\n'
                			  						+'358180,282788,Kok Leng,Ho,Ho Kok Leng,S1688207J,M,3/1/1965, , , ,96660316,96660316,ca2cl@yahoo.com.sg,Blk 36 Dakota Crescent,#18-05,Singapore 399937, , ,N,MAYBE,24/1/2019,12/3/2019,rahimah,ABC,WDD2130452A501089,2018,6,MB E 250 SEDAN EXCLUSIVE/EXCLUSIVE,MB ECLASS,21304522-SG4,P,'+ registrationNo +',12/3/2019,seemhp,12/3/2019,12/3/2019'; }
            when 'CLI_LENGTH_EXCEPTION'{ return 'VEHMAGIC,CUSTMAGIC,FIRSTNAM,SURNAME,SALUTE,SOCIALID,SEX,DOB,PHONE001,PHONE002,PHONE003,PHONE004,PHONE005,EMAIL,ADDRESS001,ADDRESS002,ADDRESS003,ADDRESS004,ADDRESS005,NOMAIL,SENSITIV,CREATED,EDITED,EDUSERID,LASTMLG,CHASSIS,PRODYR,PRODMTH,DESC,MODEL,VARIANT,FRAN,REGNO,REGDATE,SALESREP,FROM,TO\n'
                			 					 +'358180,282788,Kok Leng,Ho,Ho Kok Leng,S1688207J,M,3/1/1965, , , ,96660316,96660316,ca2cl@yahoo.com.sg,Hoa De Village - Hoa Sim Communite - Doi Lim District - Mushroom City,#18-05,Singapore 399937, , ,N,N,24/1/2019,12/3/2019,rahimah,0,WDD2130452A501089,2018,6,MB E 250 SEDAN EXCLUSIVE/EXCLUSIVE,MB ECLASS,21304522-SG4,P,'+ registrationNo +',12/3/2019,seemhp,12/3/2019,12/3/2019'; }
            
            when else { return 'a,b ,n , k, m \n a,b,n,k,m'; }
        }
    }
}
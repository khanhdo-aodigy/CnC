@isTest 
private class OTPMatchControllerTest {
    private static String otp = '559660';
    
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPerson(false, 'lastName', 'Customer');
        personAcc.PersonEmail = 'test6235@gmail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);//Workaround to update Person Contact
        personCon.MobilePhone = '98799999';
        personCon.Account_Activation_OTP__c = Datetime.now();
        personCon.OTP__c = otp;
        update personCon;
    }
    
    @isTest
    private static void testOTPMatched() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        PageReference pageRef = Page.OTPGeneration;      
        pageRef.getParameters().put('id',personCon.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        
    	OTPMatch controller = new OTPMatch();
        String id = ApexPages.currentPage().getParameters().get('id');
        controller.OTP = otp; 
        controller.OTPMatched();
    }
    
    @isTest
    private static void testOTPMatched_otpNotMatched() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        PageReference pageRef = Page.OTPGeneration;      
        pageRef.getParameters().put('id',personCon.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        
    	OTPMatch controller = new OTPMatch();
        String id = ApexPages.currentPage().getParameters().get('id');
        controller.OTP = '123123'; 
        controller.OTPMatched();
    }
    
    @isTest
    private static void testSetMobile_MobileContainsAreaCode() {
        Account personAcc = Test_DataFactory.createPerson(false, 'lastName', 'Customer');
        personAcc.PersonEmail = 'pta7346@hotmail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAcc.Id LIMIT 1];
        Contact personCon = new Contact(Id = personAcc.PersonContactId);//Workaround to update Person Contact
        personCon.MobilePhone = '6598799999';
        personCon.Account_Activation_OTP__c = Datetime.now();
        personCon.OTP__c = otp;
        update personCon;
        
        PageReference pageRef = Page.OTPGeneration;      
        pageRef.getParameters().put('id',personCon.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        
    	OTPMatch controller = new OTPMatch();
        String id = ApexPages.currentPage().getParameters().get('id');
        controller.OTP = otp; 
        controller.OTPMatched();
    }

	@isTest
    private static void testResendOTP() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        PageReference pageRef = Page.OTPGeneration;      
        pageRef.getParameters().put('id',personCon.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        
    	OTPMatch controller = new OTPMatch();
        String id = ApexPages.currentPage().getParameters().get('id');
        controller.OTP = otp; 
        controller.ResendOTP();
    }
    
    @isTest
    private static void testPageUrlWebChannel() {
        Contact personCon = [SELECT Id FROM Contact WHERE IsPersonAccount = true LIMIT 1];
        PageReference pageRef = new PageReference('/apex/CreateAccount?event=Enter_Personal_Details&id='+ personCon.Id +'&channel=web');     
        pageRef.getParameters().put('id',personCon.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        
    	OTPMatch controller = new OTPMatch();
        String id = ApexPages.currentPage().getParameters().get('id');
        controller.OTP = otp; 
        controller.OTPMatched();
    }
}
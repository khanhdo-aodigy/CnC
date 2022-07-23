@isTest 
private class SearchNRICControllerTest {
    private static String regNo = 'REG001';    
    private static String mobilePhone = '99887766';
    @testSetUp
    private static void createData(){
                
        Account pa = Test_DataFactory.createPA(false, 'Bread', 'bread@mailinator.com', 'Customer');
        pa.Source__pc = 'DWH';
        pa.PersonMobilePhone = '6599887766';
        pa.NRIC_Passport_No__pc = 'NRIC12345';
        insert pa;
        
        pa = [Select PersonContactId From Account Where Id = :pa.Id];
        
        Profile userProfile = [select id from profile where name like '%End User%' limit 1];     
        User u = new User(
                            FirstName = 'reFN',
                            LastName = 'reLN',
                            Email = 'john@acme.com',
                            Username = 'john@acme.com',
                            Alias = 'TestPA', 
                            TimeZoneSidKey = 'GMT', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            ProfileId = userProfile.Id, 
                            LanguageLocaleKey = 'en_US',
                            ContactId = pa.PersonContactId,
                            Account_Activation_Random_Number__c = '504503'
        );
        insert u;
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false,'TestVehicle','CCA','MITPC', regNo, pa.PersonContactId); 
        rv.Account__c = pa.Id;
        insert rv;

        Id etID;
        List<EmailTemplate> ets = [Select Id, Subject, HtmlValue, Body From EmailTemplate];
        for(EmailTemplate et : ets){
            if(et.Subject != null && et.HtmlValue != null && et.Body != null){
                etID = et.Id;
            }
        }
        

        global_var__c jjcVal = Test_DataFactory.createGlobalOrfDefaults(false);
        jjcVal.Account_Activation_EmailId__c = etID;
        jjcVal.TriggeredSmsIdSignUp__c = 'NzM6Nzg6MA';
        insert jjcVal;
    }
    
    @isTest
    private static void testVehicleNumNotFound() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = '3414'; //Vehicle Registration No
            controller.Inputvalue = '84636354'; //MobilePhone
            PageReference pr = controller.nricMatch();
        Test.StopTest();
    }
    
    @isTest
    private static void testMobileNumNotFound() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = regNo; //Vehicle Registration No
            controller.Inputvalue = '96363545'; //MobilePhone
            PageReference pr = controller.nricMatch();
        Test.StopTest();
    }
    
    @isTest
    private static void testHappyPath() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = regNo; //Vehicle Registration No
            controller.Inputvalue = '96363545'; //MobilePhone
            PageReference pr = controller.nricMatch();
        Test.StopTest();
    }
    
    @isTest
    private static void testResendActivation() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = regNo; //Vehicle Registration No
            controller.Inputvalue = mobilePhone; //MobilePhone
        	controller.ResendActivation();
        Test.StopTest(); 
    }
    
    @isTest
    private static void testRegisterNew() {
        Account pa = Test_DataFactory.createPA(false, 'Bread', 'bread123@mailinator.com', 'Customer');
        pa.Source__pc = 'DWH';
        pa.PersonMobilePhone = '6566778899';
        pa.NRIC_Passport_No__pc = 'NRIC9999';
        insert pa;        
        pa = [Select PersonContactId From Account Where Id = :pa.Id];
        
        Registered_Vehicle__c rv = Test_DataFactory.createregVehicle(false,'TestVehicle','CCA','MITPC', 'VEH001', pa.PersonContactId); 
        rv.Account__c = pa.Id;
        insert rv;

        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = 'VEH001'; //Vehicle Registration No
            controller.Inputvalue = '66778899'; //MobilePhone
        	controller.nricMatch();
        Test.StopTest(); 
    }
    
    @isTest
    private static void testforwardRequest() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = regNo; //Vehicle Registration No
            controller.Inputvalue = mobilePhone; //MobilePhone
        controller.generateOTP();
        controller.forwardRequest();
        Test.StopTest(); 
    }
    
   @isTest
    private static void testForwardRequest_MobileBlank() {
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        
        Test.startTest();        
            Contact con = new Contact();
            ApexPages.StandardController sc = new ApexPages.StandardController(con);
            SearchNRIC controller = new SearchNRIC(sc);
            controller.Inputvalue2 = regNo; //Vehicle Registration No
            controller.Inputvalue = ''; //MobilePhone
        controller.generateOTP();
        controller.forwardRequest();
        Test.StopTest(); 
    }
    
        
    static testmethod void testforwardRequestToLogin() {
        // Instantiate a new controller with all parameters in the page
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        Test.startTest();
        Contact contact= new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SearchNRIC controller = new SearchNRIC(sc);
        controller.forwardRequestToLogin();
        Test.StopTest(); 
    }
    static testmethod void testforwardRequestToLogin1() {
        // Instantiate a new controller with all parameters in the page
        PageReference pref = Page.NRICMatch;      
        //pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        Test.startTest();
        Contact contact= new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SearchNRIC controller = new SearchNRIC(sc);
        controller.strBranch='CCI';
        controller.forwardRequestToLogin();
        Test.StopTest(); 
    }
    static testmethod void testforwardRequestToLogin2() {
        // Instantiate a new controller with all parameters in the page
        PageReference pref = Page.NRICMatch;      
        //pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        Test.startTest();
        Contact contact= new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SearchNRIC controller = new SearchNRIC(sc);
        //controller.strBranch='CCI';
        controller.forwardRequestToLogin();
        Test.StopTest(); 
    }
    
    static testmethod void testRefreshPage(){
        PageReference pref = Page.NRICMatch;      
        pref.getParameters().put('channel','web');
        Test.setCurrentPage(pref);
        Test.startTest();
        Contact contact= new Contact();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact);
        SearchNRIC controller = new SearchNRIC(sc);
        controller.refreshPage();
        Test.StopTest(); 
    }
}
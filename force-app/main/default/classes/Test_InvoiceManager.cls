/*
Test class coverage for InvoiceManger
						InvoiceEmail_ProcessbuilderTC
*/

@IsTest
public class Test_InvoiceManager {
    
    //PA MIGRATION: Newly added -- Start //
    @isTest
    private static void testUpsertInvoice_InvoiceNumberNotNull() 
    {
        Datetime dateTimeOfPurchase = Datetime.now();
        String countryCode = 'SG';
        String nric = '987654321';
        
        Account personAcc = Test_DataFactory.createPerson(false, 'name', 'Customer');
        personAcc.NRIC_Passport_No__pc = nric;
        personAcc.PersonEmail = 'test28472@gmail.com';
        insert personAcc;
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        
        //Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        //Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        TriggerExclusion.excludeTrigger('Invoice__c', true);
        Invoice__c invoiceToInsert = Test_DataFactory.createInvoice(true, personCon);  
		Invoice__c invoice = [SELECT Id, Invoice_Number__c FROM Invoice__c];
        
        String department = 'CCI';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        testCamp.Type = 'Promotions';
        testCamp.Promotion_Type__c = 'Merchandise';
        update testCamp;
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, KIASeqNum__c = 1);
        insert sn;
        
        invoiceToInsert.Campaign__c = testCamp.Id;
        update invoiceToInsert;
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice(invoice.Invoice_Number__c, 0.0 ,0.0 ,0.0 ,dateTimeOfPurchase , department, 0.0,'',0.0, '', nric,'','',0.0,'test_tid','processor_declined','',0.0,'','','', null, testCamp.Id, '', '', '', '', '', '', '', '', '');
		
		list<id> listInvId = new list<id> ();
		listInvId.add(invoice.Id);
		InvoiceEmail_ProcessbuilderTC.InsertRecords(listInvId);
        Test.stopTest();
    }

	@isTest
    private static void testUpsertInvoice_nullInvoiceNumber() 
    {
        //Account testAcc = Test_DataFactory.createAccount(true, 'accName');
        //Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', testAcc.Id);
        //Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Last', 'pa3643@hotmail.com', 'Customer');
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        
        Invoice__c invoiceToInsert = Test_DataFactory.createInvoice(true, personCon.Id, null);  
		Invoice__c invoice = [SELECT Id, Invoice_Number__c FROM Invoice__c];
        
        String department = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, testCamp.Id, 'TEST', 'Number', 20, Date.today().addDays(30));
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, KIASeqNum__c = 1);
        insert sn;
        
        invoiceToInsert.Campaign__c = testCamp.Id;
        update invoiceToInsert;
        
        Datetime dateTimeOfPurchase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,null , department,0.0,'',0.0,'',personCon.Id,'','',0.0,'test_tid','','',0.0,'','','', '', testCamp.Id, '', '', '', '', '', '', '', '', 'TEST');

        Test.stopTest();
    } 
    
    @isTest
    private static void testUpsertInvoice_nullInvoiceNumber_CreatePA() 
    {
        //Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Last', 'pa4364@gmail.com', 'Customer');
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        personCon.Email = 'test@gmail.com';
        personCon.MobilePhone = '82341235';
        update personCon;
        
        Registered_Vehicle__c vehicle = Test_DataFactory.createRegVehicle(true, 'SK12345F', 'CCA', 'MITPC', 'SK12345F', personCon.Id);
        
        String department = 'CCA';
        Campaign testCamp = Test_DataFactory.createCamp(false, 'CampName', 'Events', department);
        testCamp.Target_Audience__c = 'Public and Targeted';
        insert testCamp;
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, testCamp.Id, 'TEST', 'Number', 20, Date.today().addDays(30));
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, MITSeqNum__c = 1);
        insert sn;
        
        Datetime dateTimeOfPurchase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,null , department,0.0,'82341246',0.0,'','','','',0.0,'test_tid','', vehicle.Id ,0.0,'','','', '', testCamp.Id, 'abc@hotmail.com', 'Test', 'Customer', '', '', '', '', '', 'TEST');

        Test.stopTest();
    }    
    
    @isTest
    private static void testUpsertInvoice_nullInvoiceNumber_ExistingContact() 
    {
        //Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Last', 'pa83473@gmail.com', 'Customer');
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        personCon.Email = 'test@gmail.com';
        update personCon;
        
        Registered_Vehicle__c vehicle = Test_DataFactory.createRegVehicle(true, 'SK12345F', 'CCK', 'KIAPC', 'SK12345F', personCon.Id);
        
        String department = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, testCamp.Id, 'TEST', 'Number', 20, Date.today().addDays(30));
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, KIASeqNum__c = 1);
        insert sn;
        
        Datetime dateTimeOfPurchase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,null , department,0.0,'',0.0,'','','','',0.0,'test_tid','', vehicle.Registration_Number__c ,0.0,'','','', '', testCamp.Id, 'test@gmail.com', '', '', '', '', '', '', '', 'TEST');

        Test.stopTest();
    }    
    
     @isTest
    private static void testUpsertInvoice_nullInvoiceNumber_Exception() 
    {
        // Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Last', 'pa838473@gmail.com', 'Customer');
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        personCon.Email = 'test@gmail.com';
        update personCon;
        
        Registered_Vehicle__c vehicle = Test_DataFactory.createRegVehicle(true, 'SK12345F', 'CCK', 'KIAPC', 'SK12345F', personCon.Id);
        
        String department = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, testCamp.Id, 'TEST', 'Number', 20, Date.today().addDays(30));
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, KIASeqNum__c = 1);
        insert sn;
        
        Datetime dateTimeOfPurchase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,null , department,0.0,'',0.0,'','','','',0.0,'test_tid','', vehicle.Registration_Number__c ,0.0,'','','', '', testCamp.Id, 'test@gmail.com', '', '', '', '', '', '', '', 'TEST');

        Test.stopTest();
    }    
    
    @isTest
    private static void testUpsertInvoice_InvoiceNumberNotNullButNoExistingInvoice() 
    {
        Datetime dateTimeOfPurchase = Datetime.now();
        String countryCode = 'SG';
        String nric = '987654321';
        
        String department = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('SG-CCF-1808-00035011', 0.0 ,0.0 ,0.0 ,dateTimeOfPurchase , department, 0.0,'',0.0, '',nric,'','',0.0,'test_tid','','',0.0,'','','', countryCode, testCamp.Id, '', '', '', '', '', '', '', '', '');

        Test.stopTest();
    }
    //PA MIGRATION: Newly added -- End //
    
    @isTest
    private static void testUpsertInvoice_NullCampaignId() 
    {
        Datetime dateTimeOfPurchase = Datetime.now();
        String countryCode = 'SG';
        String nric = '987654321';
        
        String department = 'CCK';
        Campaign testCamp = Test_DataFactory.createCamp(true, 'CampName', 'Events', department);
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,dateTimeOfPurchase , department, 0.0,'',0.0, '',nric,'','',0.0,'test_tid','','',0.0,'','','', countryCode, null, '', '', '', '', '', '', '', '', '');

        Test.stopTest();
    }
    
     @isTest
    private static void testUpsertInvoice_nullInvoiceNumber_NullMobile() 
    {
        // Account personAcc = Test_DataFactory.createPerson(true, 'name', 'Customer');
        Account personAcc = Test_DataFactory.createPA(true, 'Last', 'pa5234@gmail.com', 'Customer');
        
        personAcc = [SELECT PersonContactId FROM Account LIMIT 1];        
        Contact personCon = [SELECT Id FROM Contact WHERE Id = :personAcc.PersonContactId];
        personCon.Email = 'test@gmail.com';
        update personCon;
        
        Registered_Vehicle__c vehicle = Test_DataFactory.createRegVehicle(true, 'SK12345F', 'CCA', 'MITPC', 'SK12345F', personCon.Id);
        
        String department = 'CCA';
        Campaign testCamp = Test_DataFactory.createCamp(false, 'CampName', 'Events', department);
        testCamp.Target_Audience__c = 'Public and Targeted';
        insert testCamp;
        Promo_Code_Master__c promoCode = Test_DataFactory.createPromoCode(true, testCamp.Id, 'TEST', 'Number', 20, Date.today().addDays(30));
        InvoiceSeqNum__c sn = new InvoiceSeqNum__c (Campaign__c = testCamp.Id, MITSeqNum__c = 1);
        insert sn;
        
        Datetime dateTimeOfPurchase;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='services/apexrest/Invoice/v1/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response ;
        Test.startTest();
        InvoiceManager.upsertInvoice('', 0.0 ,0.0 ,0.0 ,null , department,0.0,'',0.0,'','','','',0.0,'test_tid','', vehicle.Id ,0.0,'','','', '', testCamp.Id, 'abc@hotmail.com', 'Test', 'Customer', '', '', '', '', '', 'TEST');

        Test.stopTest();
    }    
}
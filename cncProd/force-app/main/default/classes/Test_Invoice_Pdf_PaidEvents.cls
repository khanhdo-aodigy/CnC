@isTest
public class Test_Invoice_Pdf_PaidEvents {
    //PA MIGRATION: To Remove -- Start //
    Static Account acct = Test_DataFactory.createAccount(true,'testRun');                   
    Static Contact testCon  = Test_DataFactory.createContact(true,'testRun','testRun',acct.Id);  
    Static Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);      
   
    
    /*public static testMethod void testPDFContollerWithLead()
    {   
        Test.startTest();      
        Campaign TestCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');   //Common Campaign Using TestFactory           
        TestCamp2.Description = 'testing the test event';
        TestCamp2.UnitPrice__c = 25;
        insert TestCamp2;
              
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false,TestCon.id, null);
        testInvoice.Campaign__c = TestCamp2.id;
        insert testInvoice;
               
        Lead testLead = Test_DataFactory.createLead(false,'testRun','testRun');
        testLead.country = 'Singapore';
        testLead.Address_Line_3__c = '560078';
        insert testLead;          
        
        Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(false,null,TestCamp2.id,null,oppt.id,Account.Id,null);
        tempInsertER1.Event_Reminder_Status__c=true;       
        tempInsertER1.PromoID__c = TestCamp2.id;
        tempInsertER1.NumberOfGuests__c = 2;
        tempInsertER1.payment__c =testInvoice.id;
        Insert tempInsertER1;   
        
        ApexPages.currentPage().getParameters().put('EventRegistrationId',tempInsertER1.id);    
        Invoice_Pdf_PaidEvents InvoiceObj = new Invoice_Pdf_PaidEvents();
       
        Test.stopTest();
    }
    
    Public static testMethod void testPDFContollerWithContact()
    {   
        Test.startTest();      
        Campaign TestCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');   //Common Campaign Using TestFactory           
        TestCamp2.Description = 'testing the test event';
        TestCamp2.UnitPrice__c = 25;
        insert TestCamp2;
              
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false,TestCon.id, null);
        testInvoice.Campaign__c = TestCamp2.id;
        insert testInvoice;
               
        Contact testCon  = Test_DataFactory.createContact(false,'testRun','testRun',acct.Id);    
        testCon.Country__c = 'Singapore';
        testCon.Address_Line_3__c = '560078';
        insert testCon;               
        
        Event_Registration__c tempInsertER1 = Test_DataFactory.createEventReg(false,testCon.Id,TestCamp2.id,null,oppt.id,null,null); // Insertion of Event_Registration__c using TestDataFactory
        tempInsertER1.Event_Reminder_Status__c=true;       
        tempInsertER1.PromoID__c = TestCamp2.id;
        tempInsertER1.NumberOfGuests__c = 2;
        tempInsertER1.payment__c =testInvoice.id;
        tempInsertER1.ContactId__c = testCon.id;
        Insert tempInsertER1;   
        
        ApexPages.currentPage().getParameters().put('EventRegistrationId',tempInsertER1.id);    
        Invoice_Pdf_PaidEvents InvoiceObj = new Invoice_Pdf_PaidEvents();
       
        Test.stopTest();
    }*/
    //PA MIGRATION: To Remove -- End //
    
    //PA MIGRATION: Newly Added -- Start //
    @isTest
    private static void TestInvoicePdfPaidEvents()
    {        
        Campaign dummyCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');      
        dummyCamp.Description = 'testing the test event';
        dummyCamp.UnitPrice__c = 25;
        insert dummyCamp;
              
        Invoice__c testInvoice = Test_DataFactory.createInvoice(true,TestCon.id, dummyCamp.Id);
        
        Account personAcc = Test_DataFactory.createPerson(false, 'Test Customer', 'Customer');
        personAcc.Address_Line_1__pc = 'thatNumber';
        personAcc.Address_Line_2__pc = 'thisStreet';
        personAcc.Address_Line_3__pc = 'thisDistrict';
        personAcc.Country__pc = 'Vietnam';
        insert personAcc;
        
        Event_Registration__c dummyEvtReg = Test_DataFactory.createPAEventReg(false, personAcc.Id, dummyCamp.Id, testInvoice.Id, oppt.Id, null);
        dummyEvtReg.Event_Reminder_Status__c = true;   
        dummyEvtReg.NumberOfGuests__c = 2;
        insert dummyEvtReg;   
        
        Test.startTest(); 
        ApexPages.currentPage().getParameters().put('EventRegistrationId', dummyEvtReg.Id);    
        Invoice_Pdf_PaidEvents invoiceObj = new Invoice_Pdf_PaidEvents();       
        Test.stopTest();
    }
    
    @isTest
    private static void TestInvoicePdfPaidEvents_AccounWithNullCountry()
    {        
        Campaign dummyCamp = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');      
        dummyCamp.Description = 'testing the test event';
        dummyCamp.UnitPrice__c = 25;
        insert dummyCamp;
              
        Invoice__c testInvoice = Test_DataFactory.createInvoice(true,TestCon.id, dummyCamp.Id);
        
        Account personAcc = Test_DataFactory.createPerson(false, 'Test Customer', 'Customer');
        personAcc.Address_Line_1__pc = 'thatNumber';
        personAcc.Address_Line_2__pc = 'thisStreet';
        personAcc.Address_Line_3__pc = 'thisDistrict';
        personAcc.Country__pc = null;
        insert personAcc;
        
        Event_Registration__c dummyEvtReg = Test_DataFactory.createPAEventReg(false, personAcc.Id, dummyCamp.Id, testInvoice.Id, oppt.Id, null);
        dummyEvtReg.Event_Reminder_Status__c = true;   
        dummyEvtReg.NumberOfGuests__c = 2;
        insert dummyEvtReg;   
        
        Test.startTest(); 
        ApexPages.currentPage().getParameters().put('EventRegistrationId', dummyEvtReg.Id);    
        Invoice_Pdf_PaidEvents invoiceObj = new Invoice_Pdf_PaidEvents();       
        Test.stopTest();
    }
    
    //PA MIGRATION: Newly Added -- End //

}
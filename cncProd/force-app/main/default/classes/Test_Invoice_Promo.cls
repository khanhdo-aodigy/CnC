//Test class for Controller: Invoice_Save_Copy_PDF_C
@isTest
public  with sharing class Test_Invoice_Promo {
    
    @isTest
    private static void testInvoiceSaveCopyPDFWithContact(){
        
        Account tempAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', tempAcc.Id); 
        Test.startTest();           
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false, testCon.Id, null);
        testInvoice.Account__c = tempAcc.Id;
        insert testInvoice;
        PageReference pageRef = Page.Invoice_Save_Copy_PDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Invoice_Id', testInvoice.Id);    
        Invoice_Save_Copy_PDF_C invoiceObj = new Invoice_Save_Copy_PDF_C();
        Test.stopTest();
    }
    
    @isTest
    private static void testInvoiceSaveCopyPDFWithPersonAccount(){
        
        Account personAcc = Test_DataFactory.createPerson(true, 'Test PA', 'Prospect');
        Test.startTest();           
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false, null, null);
        testInvoice.Account__c = personAcc.Id;
        insert testInvoice;
        PageReference pageRef = Page.Invoice_Save_Copy_PDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Invoice_Id', testInvoice.Id);    
        Invoice_Save_Copy_PDF_C invoiceObj = new Invoice_Save_Copy_PDF_C();
        Test.stopTest();
    }
    @isTest
    private static void testInvoiceSaveCopyPDFWithContactAddress(){
        
        Account tempAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', tempAcc.Id); 
        testCon.Address_Line_1__c = '123 Secret';
        testCon.Address_Line_2__c = 'Jurong';
        update testCon;
        Test.startTest();           
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false, testCon.Id, null);
        testInvoice.Account__c = tempAcc.Id;
        insert testInvoice;
        PageReference pageRef = Page.Invoice_Save_Copy_PDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Invoice_Id', testInvoice.Id);    
        Invoice_Save_Copy_PDF_C invoiceObj = new Invoice_Save_Copy_PDF_C();
        Test.stopTest();
    }
    @isTest
    private static void testInvoiceSaveCopyPDFWithInvoiceAddress(){
        
        Account tempAcc = Test_DataFactory.createAccount(true, 'accName');
        Contact testCon = Test_DataFactory.createContact(true, 'fname', 'lname', tempAcc.Id); 
        Test.startTest();           
        Invoice__c testInvoice = Test_DataFactory.createInvoice(false, testCon.Id, null);
        testInvoice.Account__c = tempAcc.Id;
        testInvoice.Billing_Street__c = '123 Secret Street';
        //testInvoice.Billing_City__c = 'Jurong';
        insert testInvoice;
        PageReference pageRef = Page.Invoice_Save_Copy_PDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Invoice_Id', testInvoice.Id);    
        Invoice_Save_Copy_PDF_C invoiceObj = new Invoice_Save_Copy_PDF_C();
        Test.stopTest();
    }
    
}
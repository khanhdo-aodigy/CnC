@isTest
public class Test_CustomQuoteManager {
    static String testRun = 'dummyData';
    static String branchCode = 'CCK';
    static String franchiseCode = 'KIAPC';
    static testMethod void testContact() {
        Test.startTest();
        Account acct =  Test_DataFactory.createPerson(false, testRun, 'Customer'); 
        acct.PersonEmail =  'test@yopmail.com';
        acct.FirstName = null;
		insert acct;
        
       	acct = [Select PersonContactId From Account Limit 1];
        
        Contact con = [Select Id, Email From Contact Where ID =:  acct.PersonContactId Limit 1];
        con.Email = 'test@yopmail.com';
        update con;
        
        Opportunity opp = Test_DataFactory.createOpportunity(false,testRun,acct.Id);
        opp.Contact_Person__c = con.Id;
        opp.Branch_Code__c = branchCode;
        opp.StageName = 'Open';
        insert opp;      
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);        
        Test_DataFactory.createReq('CustomQuote',null);         
        Map<String,String> itemlist = new Map<String,String>();
        Map<String,String> inneritemlist = new Map<String,String>();
        itemlist.put('SX model base price','5600');
        itemlist.put('In-House Finance & insurance subsidy','400');
        itemlist.put('Addon Title','800');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato promo','300');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato 1.6A promo','+400');
        inneritemlist.put('In-House Finance & insurance subsidy*pre launch','-800');
        string json = '{"modelid":"'+TestMod.Id+'","variantid":"'+TestVar.Id+'","firstname":"test","lastname":"","email":"test@yopmail.com","MobilePhone":"6599999999","tradeinregnumber":"","lastfournric":"","istestdrive":true,"isreceivepromotion":true,"itemlist":{"GT MODEL Base Price":"195999","Trade in Subsidy":"-5000"},"inneritemlist":{},"additionaltext":"test","isTradeIn":true,"imageURL":""}';        
        Test_DataFactory.createReq('CustomQuote',json);                 
        CustomQuoteManager.CustomQuoteManager();
        Test.stopTest();
    }

    // test method for blank fields
    static testMethod void testblankFields() {
        Test.startTest();       
        Test_DataFactory.createReq('CustomQuote',null);         
        Map<String,String> itemlist = new Map<String,String>();
        Map<String,String> inneritemlist = new Map<String,String>();
        itemlist.put('SX model base price','5600');
        itemlist.put('In-House Finance & insurance subsidy','400');
        itemlist.put('Addon Title','800');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato promo','300');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato 1.6A promo','+400');
        inneritemlist.put('In-House Finance & insurance subsidy*pre launch','-800');
        string json = '{"modelid":"","variantid":"","firstname":"test","lastname":"","email":"test@yopmail.com","MobilePhone":"6599999999","tradeinregnumber":"","lastfournric":"","istestdrive":true,"isreceivepromotion":true,"itemlist":{"GT MODEL Base Price":"195999","Trade in Subsidy":"-5000"},"inneritemlist":{},"additionaltext":"test","isTradeIn":true,"imageURL":""}';
        Test_DataFactory.createReq('CustomQuote',json);                 
        CustomQuoteManager.CustomQuoteManager();
        //System.assert(response.statusCode == 200);
        Test.stopTest();
    }

    @isTest
    private static void testPersonAccount() {
        String email = 'test@fakedomain.com';
        Test.startTest();
        Account acct =  Test_DataFactory.createPerson(false, testRun, 'Customer'); 
        acct.PersonEmail = email;
		insert acct;
        
        Opportunity opp = Test_DataFactory.createOpportunity(false,testRun,acct.Id);
        opp.Branch_Code__c = branchCode;
        opp.StageName = 'Open';
        insert opp; 
        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);        
        Test_DataFactory.createReq('CustomQuote',null);         
        Map<String,String> itemlist = new Map<String,String>();
        Map<String,String> inneritemlist = new Map<String,String>();
        itemlist.put('SX model base price','5600');
        itemlist.put('In-House Finance & insurance subsidy','400');
        itemlist.put('Addon Title','800');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato promo','300');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato 1.6A promo','+400');
        inneritemlist.put('In-House Finance & insurance subsidy*pre launch','-800');
        string json = '{"modelid":"'+TestMod.Id+'","variantid":"'+TestVar.Id+'","firstname":"","lastname":"test","email":"' + email + '","MobilePhone":"6599999999","tradeinregnumber":"","lastfournric":"","istestdrive":true,"isreceivepromotion":true,"itemlist":{"GT MODEL Base Price":"195999","Trade in Subsidy":"-5000"},"inneritemlist":{},"additionaltext":"test","isTradeIn":true,"imageURL":""}';        
        Test_DataFactory.createReq('CustomQuote',json);                 
        CustomQuoteManager.CustomQuoteManager();
        Test.stopTest();
    }
  
    static testMethod void testNoExistingContactHasNoAccount() {
        Test.startTest();
        Contact testCon = new Contact(LastName = 'fake');
        insert testCon;
        Lead testLead = Test_DataFactory.createLead(true,testRun,testRun);    
        testLead.Email = 'test@grazitti.com';
        update testLead;
        
        Model__c TestMod = Test_DataFactory.createmodelId(true,testRun,branchCode,franchiseCode);        
        Variant__c TestVar = Test_DataFactory.createVariant(true,testRun,TestMod.Id,branchCode);                                           
        Test_DataFactory.createReq('CustomQuote',null);                 
        Map<String,Object> itemlist = new Map<String,Object>();
        Map<String,Object> inneritemlist = new Map<String,Object>();
        itemlist.put('SX model base price','5600');
        itemlist.put('In-House Finance & insurance subsidy','+400');
        itemlist.put('Addon Title','-800');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato promo','300');
        inneritemlist.put('In-House Finance & insurance subsidy*cerato 1.6A promo','400');
        inneritemlist.put('In-House Finance & insurance subsidy*pre launch','800');
        string json = '{"modelid":"'+TestMod.Id+'","variantid":"'+TestVar.Id+'","firstname":"","lastname":"test","email":"other@grazitti.com","MobilePhone":"6599999999","tradeinregnumber":"","lastfournric":"","istestdrive":true,"isreceivepromotion":true,"itemlist":{"GT MODEL Base Price":"195999","Trade in Subsidy":"-5000"},"inneritemlist":{},"additionaltext":"test","isTradeIn":true,"imageURL":""}';        
        Test_DataFactory.createReq('CustomQuote',json);         
        CustomQuoteManager.CustomQuoteManager();
        Test.stopTest();
    }
    
}
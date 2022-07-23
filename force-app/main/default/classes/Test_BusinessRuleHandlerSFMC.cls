@isTest
public class Test_BusinessRuleHandlerSFMC {
    @testSetup static void setup() {
        user uc = Test_DataFactory.createUser(true, 'testuser', 'myusr');
        Account acc = Test_DataFactory.createAccount(true, 'testAccount');
        Contact con = Test_DataFactory.createContact(true,'testContactfname','testContactlname',acc.Id);
        Model_Master__c mm =  Test_DataFactory.createModelCode(true, 'Test Model');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV');          
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(true,mm.Id);
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', acc.id);
        op1.OwnerId = uc.Id;
        op1.Contact_Person__c   =con.Id;
        insert op1;        
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mm.id, cm.id, tm.id, mym.Id);        
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.OwnerId = uc.Id;
        insert sr1;      
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mm.Id,cm.Id,tm.Id,mym.id,'0916-5676682','KIAPC0920160375');
        vm.ProductionMonth__c = date.newInstance(2020, 9, 15);
        insert vm;
        Stock_Promotion__c sp = Test_DataFactory.createstockPromotion(false,'KIAPC0620160138','Others',vm.Id); 
        sp.Discounted_Price__c = 48.99;
        insert sp;
    }
    static testMethod void SFMCTest(){
        Stock_Reservation__c sr =[Select id from Stock_Reservation__c limit 1];
        string Id =String.valueof(sr.Id);
        String createdby='a0IO0000009a8qWMAQ';
        String dmlAction='insert';
        Boolean isFutureCall=true;
        Stock_Promotion__c sp=[Select id from Stock_Promotion__c limit 1];
        String Id2=String.valueof(sp.Id);
        map<String, String> mapObject= new map<String, String>();
        mapObject.put('stockReserveId',Id);
        mapObject.put('brand','CCK');
        mapObject.put('emailFor','Cust');
        mapObject.put('emailType','Refund');
        mapObject.put('stockPromoId',Id2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        BusinessRuleHandlerSFMC.sendEmail(mapObject);
        BusinessRuleHandlerSFMC.getMCAccessToken();
        BusinessRuleHandlerSFMC.sendEmailPreferredModel(mapObject);
        BusinessRuleHandlerSFMC.sendEventEmail(mapObject);
        BusinessRuleHandlerSFMC.sendReminderEventEmail(mapObject);
        BusinessRuleHandlerVSMS.createStocKVSMS(Id,createdby,isFutureCall);
        BusinessRuleHandlerVSMS.updateStocKVSMS(Id,createdby,isFutureCall);
        BusinessRuleHandlerVSMS.stockReservationCreateOrUpdateToVSMS(Id,createdby,dmlAction);
        BusinessRuleHandlerVSMS.updateStockVSMS_ASync(Id,createdby);      
        Test.stopTest();        
    }
    static testMethod void SFMCTest1(){
        Stock_Reservation__c sr =[Select id from Stock_Reservation__c limit 1];
        string Id =String.valueof(sr.Id);
        String createdby='a0IO0000009a8qWMAQ';
        String dmlAction='insert';
        Boolean isFutureCall=true;
        Stock_Promotion__c sp=[Select id from Stock_Promotion__c limit 1];
        String Id2=String.valueof(sp.Id);
        map<String, String> mapObject= new map<String, String>();
        mapObject.put('stockReserveId',Id);
        mapObject.put('brand','CCK');
        mapObject.put('emailFor','Cust');
        mapObject.put('emailType','Confirmation');
        mapObject.put('stockPromoId',Id2);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        BusinessRuleHandlerSFMC.sendEmail(mapObject);
        BusinessRuleHandlerSFMC.getMCAccessToken();
        BusinessRuleHandlerSFMC.sendEmailPreferredModel(mapObject);
        BusinessRuleHandlerVSMS.createStocKVSMS(Id,createdby,isFutureCall);
        BusinessRuleHandlerVSMS.updateStocKVSMS(Id,createdby,isFutureCall);
        BusinessRuleHandlerVSMS.stockReservationCreateOrUpdateToVSMS(Id,createdby,dmlAction);
        BusinessRuleHandlerVSMS.updateStockVSMS_ASync(Id,createdby);      
        Test.stopTest();        
    }
    static testMethod void SFMCTestForEventAndReminderEmail(){
        map<String, String> mapObject= new map<String, String>();
        mapObject.put('Brand','CCK');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,'{"accessToken": "Successful"}'));
        BusinessRuleHandlerSFMC.getMCAccessToken();
        BusinessRuleHandlerSFMC.sendEventEmail(mapObject);
        BusinessRuleHandlerSFMC.sendReminderEventEmail(mapObject);  
        BusinessRuleHandlerSFMC.sendPostTDFeedbackEmail(mapObject);
        Test.stopTest();        
    }
    
}
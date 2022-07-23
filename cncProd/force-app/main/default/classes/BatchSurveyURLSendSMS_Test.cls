@isTest
public class BatchSurveyURLSendSMS_Test {
    @testSetup
    public static void createData(){
        Account personAcct1 = Test_DataFactory.createPerson(false, 'TestUser', 'Customer');
        personAcct1.NRIC_Passport_No__pc = 'LLLNRICTEST';
        personAcct1.PDPA__pc = 'SMS';
        insert personAcct1;
        
        Contact personCont1 = [SELECT Id, Name FROM Contact WHERE AccountId = :personAcct1.Id ];
        
        Registered_Vehicle__c regVeh1 = Test_DataFactory.createregVehicle( false, 'LLL779911', 'CCK', 'KIAPC', 'LLL779911', personCont1.Id);
        regVeh1.Account__c = personAcct1.Id;
        regVeh1.DWH_Vehicle_ID__c = '07010901888';
        regVeh1.Chasis_Number__c  = 'DUMMYCHASSIS12345';
        regVeh1.MagicCustomer__c = '17763';
        insert regVeh1;
        
        Post_Service_Header__c psh = new Post_Service_Header__c();
        psh.Account__c = personAcct1.Id;
        psh.Registered_Vehicle__c = regVeh1.Id;
        psh.Chasis__c = 'DUMMYCHASSIS12345';
        psh.Magic_ID__c = '17763';
        psh.Service_Advisor__c = 'Matthew';
        psh.WDateOut__c = Date.today().addDays(-1);
        insert psh;
        
        Account personAcct2 = Test_DataFactory.createPerson(false, 'TestUser1', 'Customer');
        personAcct2.NRIC_Passport_No__pc = 'LLLNRICTESB';
        personAcct2.PDPA__pc = 'SMS';
        insert personAcct2;
        
        Contact personCont2 = [SELECT Id, Name FROM Contact WHERE AccountId = :personAcct2.Id ];
        
        Registered_Vehicle__c regVeh2 = Test_DataFactory.createregVehicle( false, 'LLL779912', 'CCK', 'KIAPC', 'LLL779912', personCont2.Id);
        regVeh2.Account__c = personAcct2.Id;
        regVeh2.DWH_Vehicle_ID__c = '07010901889';
        regVeh2.Chasis_Number__c  = 'DUMMYCHASSIS12349';
        regVeh2.MagicCustomer__c = '17769';
        insert regVeh2;
        
        Post_Service_Header__c sent1stPSH = new Post_Service_Header__c();
        sent1stPSH.Account__c = personAcct2.Id;
        sent1stPSH.Registered_Vehicle__c = regVeh2.Id;
        sent1stPSH.Chasis__c = 'DUMMYCHASSIS12349';
        sent1stPSH.Magic_ID__c = '17769';
        sent1stPSH.Service_Advisor__c = 'Matthew';
        sent1stPSH.Send_First_SMS__c = true;
        sent1stPSH.WDateOut__c = Date.today().addDays(-1);
        insert sent1stPSH;
    }
    
    @isTest
    public static void testSend1stSMS(){
        Test.startTest();
        Post_Service_Header__c psh = [Select Id, Send_First_SMS__c From Post_Service_Header__c WHere Magic_ID__c = '17763' Limit 1];
        BatchSurveyURLSend1stSMS batch = new BatchSurveyURLSend1stSMS(new Set<Id>{psh.Id});
        Database.executeBatch(batch);
        
        Test.stopTest();
        psh = [Select Id, Send_First_SMS__c From Post_Service_Header__c WHere Magic_ID__c = '17763' Limit 1];
        System.debug(psh);
        System.assertEquals(true, psh.Send_First_SMS__c);
    }
    
    @isTest
    public static void testSend2ndSMS(){
        Test.startTest();
        Post_Service_Header__c psh = [Select Id, Send_First_SMS__c, Send_Second_SMS__c From Post_Service_Header__c WHere Magic_ID__c = '17769' Limit 1];
        BatchSurveyURLSend2ndSMS batch = new BatchSurveyURLSend2ndSMS(new Set<Id>{psh.Id});
        Database.executeBatch(batch);
        
        Test.stopTest();
        psh = [Select Id, Send_Second_SMS__c From Post_Service_Header__c WHere Magic_ID__c = '17769' Limit 1];
        System.debug(psh);
        System.assertEquals(true, psh.Send_Second_SMS__c);
    }
    
    @isTest
    static void testBatchSchedule1() {
        System.Test.startTest();
        System.schedule('BatchAftersalesServiceHeader', '0 0 0 ? * * *', new BatchSurveyURLSend1stSMS());    
        System.Test.stopTest();
    }
    @isTest
    static void testBatchSchedule2() {
        System.Test.startTest();
        System.schedule('BatchAftersalesServiceHeader', '0 0 0 ? * * *', new BatchSurveyURLSend2ndSMS());    
        System.Test.stopTest();
    }

}
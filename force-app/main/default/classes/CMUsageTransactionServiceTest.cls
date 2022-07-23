/** ******
 * Description : Test class for CMUsageTransactionService.cls
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                      Description
 * 20200903             khanh.do@aodigy.com       Created Initial Version. 
 * 
** **** */
@isTest
private class CMUsageTransactionServiceTest {
    private static List<Reward__c> rewards = new List<Reward__c>();
    private static List<Reward_Usage__c> creditUsages = new List<Reward_Usage__c>();
    private static List<Reward_Usage__c> debitUsages = new List<Reward_Usage__c>();    
    private static List<Reward_Usage__c> eShopUsages = new List<Reward_Usage__c>();
    private static String autolineInvoiceNo = 'ABC123456';
    
    @testSetup
    private static void setup() {
        Account personAcc = Test_DataFactory.createPerson(true, 'Test Acc', 'Customer');
        
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE Id =: personAcc.Id];

        Registered_Vehicle__c regVeh = Test_DataFactory.createRegVehicle(false, 'Test-RV123', 'CCK', 'KIAPC', 'Test-RV123', personAcc.PersonContactId);
        regVeh.Account__c = personAcc.Id;
        insert regVeh;
        
        Order__c order = Test_DataFactory.createOrder(Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('C_C_E_Shop').getRecordTypeId());
        order.Shop__c = 'KIA';
        insert order;

        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(false, 'Individual', 'CCK', 'KIA', 'Accessories Credit');
        rewardProfile.Contact__c = personAcc.PersonContactId;
        insert rewardProfile;

        for(Integer i=0; i< 5; i++){            
            Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
            reward.Credit__c = 5000000;
            reward.Branch__c = 'CCK';
            reward.Brand__c  = 'KIA';
            reward.Registered_Vehicle__c = regVeh.Id;
            reward.Contact__c = personAcc.PersonContactId;            
            reward.COST__c = 'CENTER_NO_1';
            rewards.add(reward);
        }
        insert rewards;
        
        for(Reward__c reward: rewards) {
            Reward_Usage__c debitUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
            debitUsage.Order__c = order.Id;
            debitUsage.Credit_Amount__c = 100;
            debitUsage.Autoline_Invoice_Number__c = autolineInvoiceNo;
            debitUsage.Invoice_Amount__c = 1000;
            debitUsages.add(debitUsage);
            
            Reward_Usage__c creditUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Issued', 'Credit');
            creditUsage.Order__c = order.Id;
            creditUsage.Credit_Amount__c = 100;
            creditUsage.Autoline_Invoice_Number__c = autolineInvoiceNo;
            creditUsage.Invoice_Amount__c = 1000;
            creditUsage.Credit_Note__c = 'CN0001';
            creditUsages.add(creditUsage);
            
            Reward_Usage__c eShopUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Utilised', 'Debit');
            eShopUsage.Order__c = order.Id;
            eShopUsage.Credit_Amount__c = 100;
            eShopUsage.Autoline_Invoice_Number__c = autolineInvoiceNo;
            eShopUsage.Invoice_Amount__c = 1000;
            eShopUsage.Credit_Note__c = 'CN0001';
            eShopUsage.Channel__c = 'eShop';
            eShopUsage.e_Invoice__c = 'eINV001';
            eShopUsage.e_Invoice_Date__c = Date.today();
            
            eShopUsages.add(eShopUsage);
        }
        insert debitUsages;
        insert creditUsages;
        insert eShopUsages;
    }
    
    @isTest
    private static void testProcessDebitUsage() {
        Id debitRecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Debit').getRecordTypeId();
        debitUsages = [SELECT Id, RecordTypeId, Reward__c,
                       		  Autoline_Invoice_Number__c, Autoline_Invoice_Date__c,
                       		  Invoice_Amount__c, Credit_Amount__c,
                              Outstanding_Payment_Amount__c, Payment_Type__c,
                       		  COST__c, Location__c, Channel__c, Contact__c, Order__c,
                       		  e_Invoice__c, e_Invoice_Date__c
                       FROM Reward_Usage__c
                       WHERE RecordTypeId = :debitRecordTypeId
                       AND Channel__c != 'eShop'
                      ];
        Test.startTest();
        CMUsageTransactionService.processUsageTransaction(debitUsages);
        List<Usage_Transaction__c> usageTransactions = [SELECT Id FROM Usage_Transaction__c];
        System.assertEquals(1, usageTransactions.size());
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessCreditUsage() {
        Id creditRecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId();
        creditUsages = [SELECT Id, RecordTypeId, Reward__c,
                       		  Autoline_Invoice_Number__c, Autoline_Invoice_Date__c,
                       		  Invoice_Amount__c, Credit_Amount__c,
                              Credit_Note__c, Outstanding_Payment_Amount__c, Payment_Type__c,
                       		  COST__c, Location__c, Channel__c, Contact__c, Order__c,
                       		  e_Invoice__c, e_Invoice_Date__c
                       FROM Reward_Usage__c
                       WHERE RecordTypeId = :creditRecordTypeId
                      ];
        Test.startTest();
        CMUsageTransactionService.processUsageTransaction(creditUsages);
        List<Usage_Transaction__c> usageTransactions = [SELECT Id FROM Usage_Transaction__c];
        System.assertEquals(1, usageTransactions.size());
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessDebitUsageFromEShop() {
        Id debitRecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Debit').getRecordTypeId();
        eShopUsages = [SELECT Id, RecordTypeId, Reward__c,
                       		  Autoline_Invoice_Number__c, Autoline_Invoice_Date__c,
                       		  Invoice_Amount__c, Credit_Amount__c,
                              Outstanding_Payment_Amount__c, Payment_Type__c,
                       		  COST__c, Location__c, Channel__c, Contact__c, Order__c,
                       		  e_Invoice__c, e_Invoice_Date__c
                       FROM Reward_Usage__c
                       WHERE RecordTypeId = :debitRecordTypeId
                       AND Channel__c = 'eShop'
                      ];
        Test.startTest();
        CMUsageTransactionService.processUsageTransaction(eShopUsages);
        List<Usage_Transaction__c> usageTransactions = [SELECT Id FROM Usage_Transaction__c];
        System.assertEquals(1, usageTransactions.size());
        Test.stopTest();
    }
    
    
    /*@isTest
    private static void testProcessDebitUsage_DebitUsageTransactionWithSameInvoiceNumberAlreadyExist() {
        Id debitRecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Debit').getRecordTypeId();
        debitUsages = [SELECT Id, RecordTypeId, Reward__c,
                       		  Autoline_Invoice_Number__c, Autoline_Invoice_Date__c,
                       		  Invoice_Amount__c, Credit_Amount__c,
                              Outstanding_Payment_Amount__c, Payment_Type__c,
                       		  COST__c, Location__c, Channel__c, Contact__c, Order__c,
                       		  e_Invoice__c, e_Invoice_Date__c
                       FROM Reward_Usage__c
                       WHERE RecordTypeId = :debitRecordTypeId
                      ];
        Usage_Transaction__c usageTransaction = Test_DataFactory.createUsageTransaction(true, 'Debit', autolineInvoiceNo, 1000, 800);
        Test.startTest();
        CMUsageTransactionService.processUsageTransaction(debitUsages);
        List<Usage_Transaction__c> usageTransactions = [SELECT Id FROM Usage_Transaction__c];
        System.assertEquals(1, usageTransactions.size());
        Test.stopTest();
    }
    
    @isTest
    private static void testProcessCreditUsage_CreditUsageTransactionWithSameCreditNoteAlreadyExist() {
        Id creditRecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId();
        creditUsages = [SELECT Id, RecordTypeId, Reward__c,
                       		  Autoline_Invoice_Number__c, Autoline_Invoice_Date__c,
                       		  Invoice_Amount__c, Credit_Amount__c,
                              Credit_Note__c, Outstanding_Payment_Amount__c, Payment_Type__c,
                       		  COST__c, Location__c, Channel__c, Contact__c, Order__c,
                       		  e_Invoice__c, e_Invoice_Date__c
                       FROM Reward_Usage__c
                       WHERE RecordTypeId = :creditRecordTypeId
                      ];
        Usage_Transaction__c usageTransaction = Test_DataFactory.createUsageTransaction(true, 'Credit', autolineInvoiceNo, 1000, 800);
        
        Test.startTest();
        CMUsageTransactionService.processUsageTransaction(creditUsages);
        List<Usage_Transaction__c> usageTransactions = [SELECT Id FROM Usage_Transaction__c];
        System.assertEquals(1, usageTransactions.size());
        Test.stopTest();
    }*/
}
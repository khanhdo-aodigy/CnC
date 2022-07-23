/** *****
 * Description : Test Class for TransactionService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200707            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class TransactionServiceTest {

    @TestSetup
    static void makeData(){
        
        List<String> lstSourceCode = new List<String>{'AGS','ANC'};
        List<Account_Mapping__c> lstAcctMapping = new List<Account_Mapping__c>();
        String strDummyInput = 'A;MITCV::C;CITPC::F;CITCV::J;MITPC::K;KIAPC::S;KIACV';
        for( String srccode : lstSourceCode ){
            for( String dummy : strDummyInput.split('::') ){
                List<String> lstDummyValues = dummy.split(';');
                lstAcctMapping.add( Test_DataFactory.createAccountMapping( false, 'Accessories Credit', srccode, lstDummyValues.get(0), lstDummyValues.get(1) ) );
            }
        }
        if( !lstAcctMapping.isEmpty() ){
            insert lstAcctMapping;
            System.debug('Inserted Account Mapping, lstAcctMapping = ' + lstAcctMapping.size());
        }

        Integer count = 20;
        List<Account> lstPersonAcct = new List<Account>();
        for(Integer i = 0 ; i < count ; i++ ){
            Account personAcct = Test_DataFactory.createPerson(false, 'TestUser'+i, 'Customer');
            personAcct.NRIC_Passport_No__pc = 'DUMMY_NRIC_'+i;
            lstPersonAcct.add( personAcct );
        }
        if( !lstPersonAcct.isEmpty() ){
            insert lstPersonAcct;
            System.debug('Inserted Person Accounts, lstPersonAcct = ' + lstPersonAcct.size());
        }
        lstPersonAcct.clear();
        lstPersonAcct = [SELECT Id, Name, PersonContactId FROM Account];


        List<Registered_Vehicle__c> lstRegisteredVehicles = new List<Registered_Vehicle__c>();
        for(Integer i = 0 ; i < lstPersonAcct.size() ; i++ ){
            Registered_Vehicle__c regVeh = Test_DataFactory.createregVehicle( false, 'DUMMY_REGNO_'+i, 'CCK', 'KIAPC', 'DUMMY_REGNO_'+i, lstPersonAcct.get(i).PersonContactId);
            regVeh.Account__c        = lstPersonAcct.get(i).Id;
            regVeh.DWH_Vehicle_ID__c = '10020000'+i;
            regVeh.Chasis_Number__c  = 'DUMMY_CHASSIS_'+i;
            lstRegisteredVehicles.add( regVeh );
        }
        if( !lstRegisteredVehicles.isEmpty() ){
            insert lstRegisteredVehicles;            
            System.debug('Inserted Registered Vehicles, lstRegisteredVehicles = ' + lstRegisteredVehicles.size());
        }

        List<Transaction__c> lstDummyTrxns =new List<Transaction__c>();
        for(Integer i = 0 ; i < lstRegisteredVehicles.size() ; i++ ){
            lstDummyTrxns.add( Test_DataFactory.createTransaction( false, 'ANC', 'K', 'DUMMY_REGNO_'+i, 'DUMMY_CHASSIS_'+i, 'DUMMY_NRIC_'+i ) );
        }
        if( !lstDummyTrxns.isEmpty() ){
            insert lstDummyTrxns;
            System.debug('Setup: Inserted Transaction, lstDummyTSerxns = ' + lstDummyTrxns.size());            
        }
    }

    @isTest
    static void trxnServiceTM(){

        List<Registered_Vehicle__c> lstExistingRVs = [SELECT Id, Account__c, Contact__c FROM Registered_Vehicle__c];

        System.assertNotEquals(null, TransactionService.getTransactionRecordTypeId('External_SRC_Transaction_RT'));
        //System.assertEquals(null, TransactionService.getTransactionRecordTypeId('DUMMY'));
        //System.assertEquals(20, [SELECT ID FROM Reward_Profile__c].size() );
        //System.assertEquals(20, [SELECT ID FROM Reward__c].size());
        //System.assertEquals(20, [SELECT ID FROM Transaction__c WHERE Reward__c != null].size());

        System.Test.startTest();
            List<Transaction__c> lstDummyTrxns =new List<Transaction__c>();
            for(Integer j = 0 ; j < lstExistingRVs.size() ; j++ ){
            
                Transaction__c tempTrxn = Test_DataFactory.createTransaction( false, 'ANC', 'K', 'DUMMY_REGNO_'+j, 'DUMMY_CHASSIS_'+j, 'DUMMY_NRIC_'+j );    
                if( j == 0 ){ 
                    tempTrxn.Contact__c = null;
                }
                else if( j == 1){
                    tempTrxn.NRIC__c = '123456789';
                }
                else if( j == 2){
                    tempTrxn.Registered_Vehicle__c = null;
                }
                else if( j == 3 ){
                    tempTrxn.REGN__c = '987654321';
                }
                else if( j == 4 ){
                    tempTrxn.Branch__c = 'CCA';
                }
                else if( j == 5 ){
                    tempTrxn.Brand__c = 'MB';
                }
                else if( j == 6 ){
                    tempTrxn.Source__c = null;
                }
                else if( j == 7 ){
                    tempTrxn.Type__c = null;
                }
                    
                lstDummyTrxns.add( tempTrxn );
                
            }
            if( !lstDummyTrxns.isEmpty() ){
                insert lstDummyTrxns;                
            	System.debug('BODY: Inserted Transaction, lstDummyTSerxns = ' + lstDummyTrxns.size());  
            }
        System.Test.stopTest();

        List<Transaction__c> lstFailedTrxn = [SELECT ID, Error_Message__c FROM Transaction__c WHERE Is_Error__c = true];
        System.debug('testing---- lstFailedTrxn = ' + lstFailedTrxn.size() + ' --- ' + lstFailedTrxn);
        //System.assertEquals(20, [SELECT ID FROM Reward_Profile__c].size());
        //System.assertEquals(38, ([SELECT ID FROM Reward__c]).size());
        //System.assertEquals(38, ([SELECT ID FROM Transaction__c WHERE Reward__c != null]).size());
    }
    
    @isTest
    private static void testProcessTransactionCheck() {
        List<Transaction__c> trans = [SELECT Id, RecordTypeId, Is_Error__c, Reward__c, Account__c,Contact__c, Registered_Vehicle__c,
                                             Brand__c, Branch__c, Type__c, Source__c, NLCODE__c, COST__c
                                      FROM Transaction__c];
        TransactionService.processTransactionCheck(trans);
	}
    
    @isTest
    private static void testTransactionToReward() {
        List<Transaction__c> trans = [SELECT Id, RecordTypeId, Is_Error__c, Reward__c, Account__c,Contact__c, Registered_Vehicle__c,
                                             Brand__c, Branch__c, Type__c, Source__c, NLCODE__c, COST__c
                                      FROM Transaction__c];
        TransactionService.processTransactionCheck(trans);
	}
}
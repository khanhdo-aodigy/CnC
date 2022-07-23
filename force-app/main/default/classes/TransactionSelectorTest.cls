/** *****
 * Description : Test Class for TransactionSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200707            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class TransactionSelectorTest {
    
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
        }

        List<Transaction__c> lstDummyTrxns =new List<Transaction__c>();
        for( Integer i = 0 ; i < 50; i++  ){
            lstDummyTrxns.add( Test_DataFactory.createTransaction( false, 'ANC', 'K', 'DUMMYREGN_'+i, 'DUMMYCHASSIS_'+i, 'DUMMYNRIC_'+i ) );
        }
        if( !lstDummyTrxns.isEmpty() ){
            insert lstDummyTrxns;
        }
    }

    
    @isTest
    static void selectTransactionsByIdsTM(){
        Map<Id,Transaction__c> mapTrxns = new Map<Id,Transaction__c>([SELECT Id, Name FROM Transaction__c]);
        System.Test.startTest();
            TransactionSelector trxnSelector = new TransactionSelector();
            System.assert( (trxnSelector.selectTransactionsByIds( mapTrxns.keySet() )).size() == 50 );
        System.Test.stopTest();
    }
}
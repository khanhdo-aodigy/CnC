/** *****
 * Description : Test Class for AccountMappingService.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200707            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class AccountMappingServiceTest {
    
    @TestSetup
    static void makeData(){
        List<Account_Mapping__c> lstAcctMapping = new List<Account_Mapping__c>();
        String strDummyInput = 'A;MITCV::C;CITPC::F;CITCV::J;MITPC::K;KIAPC::S;KIACV';
        for( String dummy : strDummyInput.split('::') ){
            List<String> lstDummyValues = dummy.split(';');
            lstAcctMapping.add( Test_DataFactory.createAccountMapping( false, 'Accessories Credit', 'ANC', lstDummyValues.get(0), lstDummyValues.get(1) ) );
        }

        if( !lstAcctMapping.isEmpty() ){
            insert lstAcctMapping;
        }
    }

    @isTest
    static void getAcctMappingBySourceCodeTM(){
        System.Test.startTest();
            System.assert( !(AccountMappingService.getAcctMappingBySourceCode( new Set<String>{ 'ANC' } )).isEmpty() );
            System.assert( (AccountMappingService.getAcctMappingBySourceCode( new Set<String>{ 'CNA' } )).isEmpty() );
        System.Test.stopTest();
    }

    @isTest
    static void getAllAcctMappingTM(){
        System.Test.startTest();
            System.assert( AccountMappingService.getAllAcctMapping().size() == 6 );
        System.Test.stopTest();
    }
}
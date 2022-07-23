/** *****
 * Description : Test Class for AccountMappingSelector.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200707            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class AccountMappingSelectorTest {

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
    }

    @isTest
    static void selectAllRecordsTM(){
        System.Test.startTest();
            AccountMappingSelector actMapSelector = new AccountMappingSelector();
            System.assert( (actMapSelector.selectAllRecords()).size() == 12 );
        System.Test.stopTest();
    }

    @isTest
    static void selectBySourceCodeTM(){
        System.Test.startTest();
            AccountMappingSelector actMapSelector = new AccountMappingSelector();
            System.assert( (actMapSelector.selectBySourceCode( new Set<String>{'ANC'} )).size() == 6 );
            System.assert( (actMapSelector.selectBySourceCode( new Set<String>{'AGS'} )).size() == 6 );
            System.assert( (actMapSelector.selectBySourceCode( new Set<String>{'CNA'} )).isEmpty() );
        System.Test.stopTest();
    }

    @isTest
    static void selectByDivisionTM(){
        System.Test.startTest();
            AccountMappingSelector actMapSelector = new AccountMappingSelector();
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'KIACV'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'KIAPC'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'MITCV'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'MITPC'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'CITCV'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'CITPC'} )).size() == 2 );
            System.assert( (actMapSelector.selectByDivision( new Set<String>{'ABCDE'} )).isEmpty() );
        System.Test.stopTest();
    }
}
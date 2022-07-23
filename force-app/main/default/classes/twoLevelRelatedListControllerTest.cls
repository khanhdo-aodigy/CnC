/** *****
 * Description : Test Class for twoLevelRelatedListController.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200713            HS@aodigy            Created Initial Version 
 * 
** *****/
@isTest(seeAllData=false)
private class twoLevelRelatedListControllerTest {

    @TestSetup
    static void makeData(){
        Account tempAcct = Test_DataFactory.createAccount(false, 'DummyTestAccount');
        insert tempAcct;
        
        List<Contact> lstTempCnts = new List<Contact>();
        for(Integer index = 0 ; index < 10 ; index++ ){
            Contact tempCnt = Test_DataFactory.createContact(false, 'DummyContact'+index, 'Test', tempAcct.Id);
            tempCnt.Account__c = tempAcct.Id;
            lstTempCnts.add( tempCnt );
        }
        if( !lstTempCnts.isEmpty() ){
            insert lstTempCnts;
        }

        List<Case> lstTempCases = new List<Case>();
        for(Integer index = 0 ; index < lstTempCnts.size() ; index ++ ){
            lstTempCases.add( Test_DataFactory.createCase(false, lstTempCnts.get(index).Id ) );
        }
        if( !lstTempCases.isEmpty() ){
            insert lstTempCases;
        }
    }

    @isTest
    static void doGetInformationTM(){
        List<Account> lstDummyAct = [SELECT Id FROM Account];
        System.assert( lstDummyAct.size() == 1 );

        System.Test.startTest();
            twoLevelRelatedListController.ResponseWrapper objResponse = new twoLevelRelatedListController.ResponseWrapper();
            objResponse = twoLevelRelatedListController.doGetInformation( lstDummyAct.get(0).Id, 'Contact', 'Account__c', 'Case', 'ContactId', 'Name', ' CreatedDate' );
            System.assert( objResponse <> null );
            System.assert( !objResponse.FirstLevelRelatedList.isEmpty() && objResponse.FirstLevelRelatedList.size() == 10 );
            System.assert( !objResponse.SecondLevelRelatedList.isEmpty() && objResponse.SecondLevelRelatedList.size() == 10  );
        System.Test.stopTest();
    }
}
/*******************************************************
* Class Name: autoCheckInTest
* Description: Test Class for autoCheckin scheduler
* 
* Revision History:
* Developer Name		Date 			Description
* CGaylan				05-July-2019	Created
******************************************************/ 
@isTest
private class autoCheckInTest {
	//create initial data
    @testSetup
    static void createData(){
        Test.startTest();
        //Create ccount
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());
        
        //Create Opportunity
        Opportunity opp = Test_DataFactory.createOpportunity(true, UserInfo.getLastName(), acc.Id);
        
        //Create Test Drive
        Test_Drive__c td = Test_DataFactory.createTestDrive(false, opp.Id);
        td.Status__c = 'Out';
        td.Date__c = Date.today();
        insert td;
        Test.stopTest();
    }
    
    //Verify checkin
    static testMethod void testAutoCheckin(){
        Test.startTest();
        autoCheckIn aut = new autoCheckIn(); 
        System.schedule('aut checkin testc', '0 0 0 ? * * *', aut);
        //aut.autoCheck();
        Test.stopTest();
        
        //Verify car is checked in.
        System.assertEquals('In',[SELECT Status__c FROM Test_Drive__c ORDER BY CreatedDate DESC LIMIT 1].Status__c);
    }
}
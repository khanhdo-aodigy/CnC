/***********************************
 * Class Name: ToDoTestDriveTest
 * Description: Test class for
 * 				ToDoTestDrive controller
 ***********************************/ 
@isTest
private class ToDoTestDriveTest {
	//create initial test data
    @testSetup
    static void createData(){
        Test.startTest();
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getName() + 'Test');
        
        Contact cn = Test_DataFactory.createContact(true, 'FName', UserInfo.getName(), acc.Id);
        
        Opportunity opp = Test_DataFactory.createOpportunity(true, 'OppName', acc.Id);
        Test.stopTest();
    }
    
    /***********************************
    * Method Name: testToDo
    * Description: Test To=Do Creation
    ***********************************/     
    static testMethod void testToDo(){
        Test.startTest();
        String opp = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
        Test.setCurrentPage(Page.ToDoTestDrive);
        ApexPages.currentPage().getParameters().put('opp',opp); 
        
        ToDoTestDrive td = new ToDoTestDrive();
        td.createTask(); 
        Test.stopTest();
        
     	//Needs assert statement
    }
}
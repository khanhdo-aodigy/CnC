@isTest
private class FileRequirementsServiceTest {

    @TestSetup
    static void setUp(){
        Account acc = Test_DataFactory.createAccount(true, 'test');
    }	    
    
    @isTest
    static void Test_getConditionalFileRequirements() {
        FileRequirementsService.mockFileRequirements = new List<File_Requirements__mdt>{
            new File_Requirements__mdt(
                Condition_Field_API_Name__c = 'PersonDoNotCall'
            )
        };
            
		FileRequirementsService.getConditionalFileRequirements([Select Id, PersonDoNotCall From Account].Id);		            
    }
    
}
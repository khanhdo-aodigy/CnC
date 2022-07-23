@isTest
public class test_Trigger_FeedBack 
{
    public static testmethod void Test_sendpositive8digit() 
    {      
        Test.startTest();
    Feedback__c fbc = new Feedback__c(Name__c='Test Feedback',Email__c='et.sapient@sapient.com',Registration_Number__c='1234xx',Message__c='Hello comment',Category__c='Sales',Last_Visited_Service_Cent__c='Singapore',Mobile__c='12345678' );
    	insert fbc ;
        Test.stopTest();
       
    }
    
      public static testmethod void Test_sendpositive10digit() 
    {      
        Test.startTest();
    Feedback__c fbc = new Feedback__c(Name__c='Test Feedback',Email__c='et.sapient@sapient.com',Registration_Number__c='1234xx',Message__c='Hello comment',Category__c='Sales',Last_Visited_Service_Cent__c='Singapore',Mobile__c='1234567890' );
    	insert fbc ;
        Test.stopTest();
       
    }
}
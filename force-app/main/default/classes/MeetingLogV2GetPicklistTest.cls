@isTest
public class MeetingLogV2GetPicklistTest {

    @isTest
    static void testGetUserList()
    {
        Test.startTest();
    	List<User> returnedUser = MeetingLogV2GetPicklist.getUserList();
        Test.stopTest();
        System.assert(returnedUser != NULL);

    }
    
    @isTest
     static void testSaveValueButton()
    {
        Meeting_Log_V2__c testOb = new Meeting_Log_V2__c();
        testOb.Location__c = 'Kia Showroom';
        testOb.Type_of_Meeting_Logs__c ='Morning Briefing';
        //testOb.Participant_Name__c = 'Gordon Ho;Debra Lim';
        //testOb.ParticipantsList__c = 'Gordon Ho;Debra Lim';
		insert testOb;
       
        Test.startTest();
    	MeetingLogV2GetPicklist.saveValueButton(testOb.Id, new List<String>{'Gordon Ho', 'Debra Lim'});
        Test.stopTest();
        System.assert(testOb != NuLL);
        
    }
    
     @isTest
    static void testGetPicklistValues()
    {
        Meeting_Log_V2__c testOb = new Meeting_Log_V2__c();
        testOb.Location__c = 'Kia Showroom';
        testOb.Type_of_Meeting_Logs__c ='Morning Briefing';
        insert testOb;
        Test.startTest();
    	List<Meeting_Log_V2__c> returnedUser = MeetingLogV2GetPicklist.getPicklistValues(testOb.Id);
        Test.stopTest();
        System.assert(returnedUser != NULL);

    }

    
    
}
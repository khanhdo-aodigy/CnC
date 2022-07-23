@isTest
private class MultiselectMeetingLogControllerTest {
    static Meeting_Log_V2__c mMeet;
    static Meeting_Log_V2__c mLog;

    
    static testMethod void setupData()
    {
        mMeet = new Meeting_Log_V2__c();
        mMeet.Type_of_Meeting_Logs__c = 'Debrief';
        mMeet.Participants_Name_List__c = 'Alvin Ng;Kenny Tan';
        insert mMeet;
        
        mLog = new Meeting_Log_V2__c();
        mLog.Type_of_Meeting_Logs__c = 'Debrief';
        insert mLog;
    }
    
    static testMethod void testMeetingLog() 
    {
        setupData();
        
        PageReference pageRef = Page.MultiselectMeetingLogPage;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Id', String.valueOf(mLog.Id));

    	ApexPages.StandardController standardController = new ApexPages.StandardController(mLog);
        MultiselectMeetingLogController c = new MultiselectMeetingLogController(standardController);
    }
    
    static testMethod void testMultiselectMeetingLog() 
    {
    	// Create some test data
		setupData();
        
        PageReference pageRef = Page.MultiselectMeetingLogPage;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('Id', String.valueOf(mMeet.Id));

    	ApexPages.StandardController standardController = new ApexPages.StandardController(mMeet);
        MultiselectMeetingLogController c = new MultiselectMeetingLogController(standardController);
        
        c.currentRecordId = mMeet.Id;
        System.debug('currentRecordId : '+c.currentRecordId);
		c.selectedUser.add(new SelectOption('Alan Yeo', 'Alan Yeo'));
        c.selectedUser.add(new SelectOption('Alvin Ng', 'Alvin Ng'));
        System.debug('selectedUser : '+c.selectedUser);
        c.message = mMeet.Participants_Name_List__c;
        c.save();
                System.debug('message : '+c.Message);
    }
}
@isTest
private class CMWriteBackControllerTest {
    
    @testSetup
    private static void setupData() {
        Reward_Profile__c rewardProfile = Test_DataFactory.createRewardProfile(true, 'Fleet', 'CCK', 'KIA', 'Accessories Credit');
        Reward__c reward = Test_DataFactory.createReward(false, rewardProfile.Id, rewardProfile.Type__c, 'Valid', Date.today().addDays(5));
        reward.Credit__c = 20000;
        insert reward;
        Reward_Usage__c rewardUsage = Test_DataFactory.createRewardUsage(false, reward.Id, 'Hold', 'Debit');
        rewardUsage.Credit_Amount__c = 8000;
        insert rewardUsage;
    }
    
    @isTest
    private static void testWritebackExpiredList() {
        User writeBackUser = new User(
     	ProfileId = [SELECT Id FROM Profile WHERE Name = 'Credit Management - View Only'].Id,
     	LastName = 'last',
     	Email = 'puser000@amamama.com',
     	Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     	CompanyName = 'TEST',
     	Title = 'title',
     	Alias = 'alias',
     	TimeZoneSidKey = 'America/Los_Angeles',
     	EmailEncodingKey = 'UTF-8',
     	LanguageLocaleKey = 'en_US',
     	LocaleSidKey = 'en_US'
		);
        insert writeBackUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CM_Write_Back'];
		insert new PermissionSetAssignment(AssigneeId = writeBackUser.Id, PermissionSetId = ps.Id);
        
        List<PermissionSetAssignment> assignmentList = [SELECT AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CM_Write_Back'];        
        writeBackUser = [SELECT Id FROM User WHERE Id = :assignmentList[0].AssigneeId LIMIT 1];
        
        String listViewId = '00BO0000002MLSuMAO';
        String pageUrl = 'https://jccuat--partcopy.lightning.force.com/lightning/o/Reward_Usage__c/list?filterName=' + listViewId;
        
        PageReference pageRef = Page.CMWriteBack;
        pageRef.getParameters().put('vfRetURLInSFX', pageUrl);
        Test.setCurrentPage(pageRef);
        
        Reward_Usage__c rewardUsage = [SELECT Id FROM Reward_Usage__c LIMIT 1];
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(rewardUsage);
        CMWriteBackController controller = new CMWriteBackController(standardController);
        
        Test.startTest();
        System.runAs(writeBackUser){
            Test.setMock(HttpCalloutMock.class, new CalloutGetListViewQueryResponseMock());
        	controller.writeBack();
        }
        
        Test.stopTest();
    }
    
    @isTest
    private static void testWriteBackNonExpiredList() {
        User writeBackUser = new User(
     	ProfileId = [SELECT Id FROM Profile WHERE Name = 'Credit Management - View Only'].Id,
     	LastName = 'last',
     	Email = 'puser000@amamama.com',
     	Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     	CompanyName = 'TEST',
     	Title = 'title',
     	Alias = 'alias',
     	TimeZoneSidKey = 'America/Los_Angeles',
     	EmailEncodingKey = 'UTF-8',
     	LanguageLocaleKey = 'en_US',
     	LocaleSidKey = 'en_US'
		);
        insert writeBackUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CM_Write_Back'];
		insert new PermissionSetAssignment(AssigneeId = writeBackUser.Id, PermissionSetId = ps.Id);
        
        List<PermissionSetAssignment> assignmentList = [SELECT AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CM_Write_Back'];        
        writeBackUser = [SELECT Id FROM User WHERE Id = :assignmentList[0].AssigneeId LIMIT 1];
        String listViewId = '00BO0000002MLSuMAO';
        String pageUrl = 'https://jccuat--partcopy.lightning.force.com/lightning/o/Reward_Usage__c/list?filterName=' + listViewId;
        
        PageReference pageRef = Page.CMWriteBack;
        pageRef.getParameters().put('vfRetURLInSFX', pageUrl);
        Test.setCurrentPage(pageRef);
        
        Reward_Usage__c rewardUsage = [SELECT Id FROM Reward_Usage__c LIMIT 1];
        ApexPages.StandardController standardController = new ApexPages.StandardController(rewardUsage);
        CMWriteBackController controller = new CMWriteBackController(standardController);
        
        Test.startTest();
        System.runAs(writeBackUser){
        	String body = '{"query" : "SELECT Name, RecordType.Name, Reward__r.Name, Brand__c, Credit_Amount__c, toLabel(Status__c), toLabel(Channel__c), Source__c, Transaction_Date__c, CreatedBy.Name, COST__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Reward__c, CreatedBy.Id, CreatedById FROM Reward_Usage__c WHERE RecordTypeId = \'012O0000000TZz3\'AND Type__c = \'Expiry\' AND (Brand__c = null OR Brand__c = \'KIA\')" }';       
        	Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,body));
        	controller.writeBack();
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testUserNotHavePermission() {
                
        User nonPSUser = new User(
     	ProfileId = [SELECT Id FROM Profile WHERE Name = 'Credit Management - View Only'].Id,
     	LastName = 'last',
     	Email = 'puser000@amamama.com',
     	Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     	CompanyName = 'TEST',
     	Title = 'title',
     	Alias = 'alias',
     	TimeZoneSidKey = 'America/Los_Angeles',
     	EmailEncodingKey = 'UTF-8',
     	LanguageLocaleKey = 'en_US',
     	LocaleSidKey = 'en_US'
		);
        insert nonPSUser;
        
        //ListView listView = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Reward_Usage__c'];
        String listViewId = '00BO0000002MLSuMAO';
        String pageUrl = 'https://jccuat--partcopy.lightning.force.com/lightning/o/Reward_Usage__c/list?filterName=' + listViewId;
        
        PageReference pageRef = Page.CMWriteBack;
        pageRef.getParameters().put('vfRetURLInSFX', pageUrl);
        Test.setCurrentPage(pageRef);
        
        Reward_Usage__c rewardUsage = [SELECT Id FROM Reward_Usage__c LIMIT 1];
        ApexPages.StandardController standardController = new ApexPages.StandardController(rewardUsage);
        CMWriteBackController controller = new CMWriteBackController(standardController);
        
        List<Id> writeBackUserIds = new List<Id>();
        List<PermissionSetAssignment> assignmentList = [SELECT AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CM_Write_Back'];        
        for(PermissionSetAssignment assignment: assignmentList) {
            writeBackUserIds.add(assignment.AssigneeId);
        }
        User noPermissionUser = [SELECT Id FROM User WHERE Id NOT IN :writeBackUserIds LIMIT 1];        
        
        Test.startTest();
        System.runAs(noPermissionUser) {
            String body = '{"query" : "SELECT Name, RecordType.Name, Reward__r.Name, Brand__c, Credit_Amount__c, toLabel(Status__c), toLabel(Channel__c), Source__c, Transaction_Date__c, CreatedBy.Name, COST__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, Reward__c, CreatedBy.Id, CreatedById FROM Reward_Usage__c WHERE RecordTypeId = \'012O0000000TZz3\'AND Type__c = \'Expiry\' AND (Brand__c = null OR Brand__c = \'KIA\')" }';       
            Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,body));
            controller.writeBack();
        }
        Test.stopTest();
    }

}
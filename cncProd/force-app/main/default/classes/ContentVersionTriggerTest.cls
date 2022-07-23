@isTest
private class ContentVersionTriggerTest {
	
    @testSetUp
    private static void setUp() {
        // create 2 users of 2 different profiles
        Profile KIA_Profile = [SELECT Id FROM Profile WHERE Name = 'KIAPC Sales'];
        Profile MIT_Profile = [SELECT Id FROM Profile WHERE Name = 'MITPC Sales'];
        User salesConsultant_KIA = new User (FirstName = 'KIA', LastName = 'KIA', ProfileId = KIA_Profile.Id, Email = 'Test@Example.com', Alias='Test', Username='34q3u4kjdadu9asdasd@Example.com', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8');
        User salesConsultant_MIT = new User (FirstName = 'MIT', LastName = 'MIT', ProfileId = MIT_Profile.Id, Email = 'Test@Example.com', Alias='Test', Username='29q9euajfakjf90weoiqwen@Example.com', LocaleSidKey = 'en_US', TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8');
        insert salesConsultant_KIA;
        insert salesConsultant_MIT;
        
        // create new content version
        ContentVersion cv = new ContentVersion (Title = 'Test Title', PathOnClient = '/Test Title.pdf', VersionData = Blob.valueOf('Test Content'));
        
        // run as KIA Sales Consultant and insert new file
        system.runAs(salesConsultant_KIA) {
            insert cv;
        }
    }
    
    @isTest
    private static void test() {
        Id orgId = UserInfo.getOrganizationId();
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Title'];
        ContentDocumentLink cdl = [SELECT Visibility, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :orgId];
        system.assertEquals('AllUsers', cdl.Visibility);
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('ContentVersion', true);
        // create new content version
        ContentVersion cv = new ContentVersion (Title = 'Test Title', PathOnClient = '/Test Title.pdf', VersionData = Blob.valueOf('Test Content'));
        insert cv;
        TriggerExclusion.excludeTrigger('ContentVersion', false);
    }
}
/** ******
 * Description: Test class for ContentDocumentLinkTrigger
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20210312           TP@aodigy.com     Created Initial Version. 
** ******/

@isTest
private class ContentDocumentLinkTriggerTest 
{
    @isTest
    static void test_createCDLForNewChildCase()
    {
        Account acct = Test_DataFactory.createPerson(false, 'Test Account', 'Customer');
        acct.PersonEmail = 'test@gmail.com';
        insert acct;
        Contact con  = Test_DataFactory.createContact(true, 'Test', 'Contact', acct.Id);
        Case c       = Test_DataFactory.createCase(true, con.Id);
        Case c2      = Test_DataFactory.createCase(true, con.Id);
        
        EmailMessage emailMessage1 = new EmailMessage(FromAddress = 'test123@abc.org', Incoming = True, 
                                                    ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                                    Subject = 'Test email with att', TextBody = '23456', 
                                                    ParentId = c.Id);
        insert emailMessage1;
        
        EmailMessage emailMessage2 = new EmailMessage(FromAddress = 'test123@abc.org', Incoming = True, 
                                                    ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                                    Subject = 'Test email with att 2', TextBody = '2345678', 
                                                    ParentId = c2.Id, Is_it_dup_email__c = true,
                                                    Parent_Email_Message_ID__c = emailMessage1.Id);
        insert emailMessage2;

        ContentVersion contentVersion = new ContentVersion(Title = 'Penguins',
                                                           PathOnClient = 'Penguins.jpg',
                                                           VersionData = Blob.valueOf('Test Content'),
                                                           IsMajorVersion = true);
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = emailMessage1.id,
                                                          ContentDocumentId = documents[0].Id,
                                                          shareType = 'V',
                                                          Visibility = 'InternalUsers');
        
        insert cdl;
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('ContentDocumentLink', true);
        Account acct = Test_DataFactory.createPerson(false, 'Test Account', 'Customer');
        acct.PersonEmail = 'test@gmail.com';
        insert acct;
        Contact con  = Test_DataFactory.createContact(true, 'Test', 'Contact', acct.Id);
        Case c       = Test_DataFactory.createCase(true, con.Id);
        Case c2      = Test_DataFactory.createCase(true, con.Id);
        
        EmailMessage emailMessage1 = new EmailMessage(FromAddress = 'test123@abc.org', Incoming = True, 
                                                    ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                                    Subject = 'Test email with att', TextBody = '23456', 
                                                    ParentId = c.Id);
        insert emailMessage1;
        
        EmailMessage emailMessage2 = new EmailMessage(FromAddress = 'test123@abc.org', Incoming = True, 
                                                    ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                                    Subject = 'Test email with att 2', TextBody = '2345678', 
                                                    ParentId = c2.Id, Is_it_dup_email__c = true,
                                                    Parent_Email_Message_ID__c = emailMessage1.Id);
        insert emailMessage2;

        ContentVersion contentVersion = new ContentVersion(Title = 'Penguins',
                                                           PathOnClient = 'Penguins.jpg',
                                                           VersionData = Blob.valueOf('Test Content'),
                                                           IsMajorVersion = true);
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = emailMessage1.id,
                                                          ContentDocumentId = documents[0].Id,
                                                          shareType = 'V',
                                                          Visibility = 'InternalUsers');
        TriggerExclusion.excludeTrigger('ContentDocumentLink', false);
    }
}
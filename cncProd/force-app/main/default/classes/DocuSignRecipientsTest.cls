@isTest
private class DocuSignRecipientsTest {
	@testSetup
    private static void setUp() {
        // create testing signing group
        Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test', Branch_Code__c = 'CCK', Endorse_Group_ID__c = '123456', Endorse_Group_Name__c = 'Test', Approve_Group_ID__c = '123457', Approve_Group_Name__c = 'Test');
        insert testSigningGroup;

        // create 6 testing users
        User endorser = Test_DataFactory.createUser(true, 'Test Endorser', 'Test1');
        User approver = Test_DataFactory.createUser(true, 'Test Approver', 'Test2');
        User noRole = Test_DataFactory.createUser(true, 'Test No Role', 'Test3');
        

        // link users to signing group
        DocuSign_Recipient__c testEndorser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Endorser', User__c = endorser.ID);
        DocuSign_Recipient__c testApprover = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Approver', User__c = approver.ID);
        DocuSign_Recipient__c testNoRole = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = '', User__c = noRole.ID);
        
        insert testEndorser;
        insert testApprover;
        insert testNoRole;
    }
    
    @isTest
    private static void testHandleAfterInsert() {
        Signing_Group__c signingGroup = [SELECT ID FROM Signing_Group__c WHERE Endorse_Group_ID__c = '123456'];
        User newEndorser = Test_DataFactory.createUser(true, 'New Endorser', 'Test1');
        DocuSign_Recipient__c newRecipient1 = new DocuSign_Recipient__c(Signing_Group__c = signingGroup.ID, Signing_Role__c = 'Endorser', User__c = newEndorser.ID);
        insert newRecipient1;
        DocuSignRecipients domainInstance = new DocuSignRecipients(new List<DocuSign_Recipient__c> {newRecipient1});
        domainInstance.handleAfterInsert(new List<DocuSign_Recipient__c> {newRecipient1});
    }
    
    @isTest
    private static void testHandleAfterDelete() {
        DocuSign_Recipient__c recipientToDelete = [SELECT ID, Signing_Group__c, Signing_Role__c, Recipient_Name__c, Recipient_Email__c FROM DocuSign_Recipient__c WHERE Signing_Role__c = 'Endorser'];
        DocuSign_Recipient__c recipientToDeleteDuplicate = recipientToDelete.clone();
        delete recipientToDelete;
        DocuSignRecipients domainInstance = new DocuSignRecipients(new List<DocuSign_Recipient__c> {recipientToDeleteDuplicate});
        domainInstance.handleAfterDelete(new List<DocuSign_Recipient__c> {recipientToDeleteDuplicate});
    }
    
    @isTest
    private static void testHandleAfterUpdate_ChangeRole() {
        DocuSign_Recipient__c recipientToUpdate = [SELECT ID, Signing_Group__c, Signing_Role__c, Recipient_Name__c, Recipient_Email__c, User__c FROM DocuSign_Recipient__c WHERE Signing_Role__c = 'Endorser'];
        DocuSign_Recipient__c recipientToUpdateDuplicate = recipientToUpdate.clone();
        recipientToUpdate.Signing_Role__c = 'Approver';
        update recipientToUpdate;
        string oldRecordID = recipientToUpdate.ID;
        DocuSignRecipients domainInstance = new DocuSignRecipients(new List<DocuSign_Recipient__c> {recipientToUpdate});
        domainInstance.handleAfterUpdate(new List<DocuSign_Recipient__c> {recipientToUpdate}, new Map<ID, DocuSign_Recipient__c> {oldRecordID => recipientToUpdateDuplicate});
    }
    
    @isTest
    private static void testHandleAfterUpdate_ChangeUser() {
        DocuSign_Recipient__c recipientToUpdate = [SELECT ID, Signing_Group__c, Signing_Role__c, Recipient_Name__c, Recipient_Email__c, User__c FROM DocuSign_Recipient__c WHERE Signing_Role__c = 'Endorser'];
        DocuSign_Recipient__c recipientToUpdateDuplicate = recipientToUpdate.clone();
        User approver1 = [SELECT ID FROM User WHERE lastName = 'Test Approver'];
        recipientToUpdate.User__c = approver1.ID;
        update recipientToUpdate;
        string oldRecordID = recipientToUpdate.ID;
        DocuSignRecipients domainInstance = new DocuSignRecipients(new List<DocuSign_Recipient__c> {recipientToUpdate});
        domainInstance.handleAfterUpdate(new List<DocuSign_Recipient__c> {recipientToUpdate}, new Map<ID, DocuSign_Recipient__c> {oldRecordID => recipientToUpdateDuplicate});
    }
}
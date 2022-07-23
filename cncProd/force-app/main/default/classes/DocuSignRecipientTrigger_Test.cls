@isTest
public with sharing class DocuSignRecipientTrigger_Test {
    
    // set up the data for testing and also test insert trigger
    @testSetup
    static void makeData() {

        // create testing signing group
        Signing_Group__c testSigningGroup = new Signing_Group__c(Name = 'Test', Branch_Code__c = 'CCK', Endorse_Group_ID__c = '123456', Endorse_Group_Name__c = 'Test', Approve_Group_ID__c = '123457', Approve_Group_Name__c = 'Test');
        insert testSigningGroup;

        // create 6 testing users
        User endorser = Test_DataFactory.createUser(true, 'Test Endorser', 'Test1');
        User approver = Test_DataFactory.createUser(true, 'Test Approver', 'Test2');
        User noRole = Test_DataFactory.createUser(true, 'Test No Role', 'Test3');
        User endorser2 = Test_DataFactory.createUser(true, 'Endorser 2', 'Test1');
        User approver2 = Test_DataFactory.createUser(true, 'Approver 2', 'Test2');
        User noRole2 = Test_DataFactory.createUser(true, 'No Role 2', 'Test3');

        // link users to signing group
        DocuSign_Recipient__c testEndorser = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Endorser', User__c = endorser.ID);
        DocuSign_Recipient__c testApprover = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Approver', User__c = approver.ID);
        DocuSign_Recipient__c testNoRole = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = '', User__c = noRole.ID);
        DocuSign_Recipient__c testEndorser2 = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Endorser', User__c = endorser2.ID);
        DocuSign_Recipient__c testApprover2 = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = 'Approver', User__c = approver2.ID);
        DocuSign_Recipient__c testNoRole2 = new DocuSign_Recipient__c(Signing_Group__c = testSigningGroup.ID, Signing_Role__c = '', User__c = noRole2.ID);
        
        insert testEndorser;
        insert testApprover;
        insert testNoRole;
        insert testEndorser2;
        insert testApprover2;
        insert testNoRole2;
    }

    // test delete 1 user from group
    @isTest
    static void deleteUser() {
        DocuSign_Recipient__c endorser = [SELECT ID FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        system.debug(endorser);
        delete endorser;
    }

    // test delete several users from group
    @isTest
    static void deleteUsers() {
        List<DocuSign_Recipient__c> recipients = new List<DocuSign_Recipient__c>{};
        DocuSign_Recipient__c endorser = [SELECT ID FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        DocuSign_Recipient__c approver = [SELECT ID FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Approver%'];
        DocuSign_Recipient__c noRole = [SELECT ID FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test No Role%'];
        recipients.add(endorser);
        recipients.add(approver);
        recipients.add(noRole);
        delete recipients;
    }

    // test update endorser -> approver
    @isTest
    static void endorserToApprover() {
        DocuSign_Recipient__c endorser = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        endorser.Signing_Role__c = 'Approver';
        update endorser;
    }

    // test update approver -> endorser
    @isTest
    static void approverToEndorser() {
        DocuSign_Recipient__c approver = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Approver%'];
        approver.Signing_Role__c = 'Endorser';
        update approver;
    }

    // test update approver -> no role
    @isTest
    static void approverToNoRole() {
        DocuSign_Recipient__c approver = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Approver%'];
        approver.Signing_Role__c = '';
        update approver;
    }

    // test update endorser -> no role
    @isTest
    static void endorserToNoRole() {
        DocuSign_Recipient__c endorser = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        endorser.Signing_Role__c = '';
        update endorser;
    }

    // test update no role -> endorser
    @isTest
    static void noRoleToEndorser() {
        DocuSign_Recipient__c noRole = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test No Role%'];
        noRole.Signing_Role__c = 'Endorser';
        update noRole;
    }

    // test update no role -> aprrover
    @isTest
    static void noRoleToApprover() {
        DocuSign_Recipient__c noRole = [SELECT ID, Signing_Role__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test No Role%'];
        noRole.Signing_Role__c = 'Approver';
        update noRole;
    }

    // test switch endorser
    @isTest
    static void switchEndorser() {
        User newUser = Test_DataFactory.createUser(true, 'New Endorser', 'New');
        DocuSign_Recipient__c endorser = [SELECT ID, Signing_Role__c, User__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        endorser.User__c = newUser.ID;
        update endorser;
    }

    // test switch approver
    @isTest
    static void switchApprover() {
        User newUser = Test_DataFactory.createUser(true, 'New Approver', 'New');
        DocuSign_Recipient__c approver = [SELECT ID, Signing_Role__c, User__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Approver%'];
        approver.User__c = newUser.ID;
        update approver;
    }

    // test switch no role
    @isTest
    static void switchNoRole() {
        User newUser = Test_DataFactory.createUser(true, 'New No Role', 'New');
        DocuSign_Recipient__c noRole = [SELECT ID, Signing_Role__c, User__c FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test No Role%'];
        noRole.User__c = newUser.ID;
        update noRole;
    }

    @isTest
    private static void testBypassTrigger() {
        TriggerExclusion.excludeTrigger('DocuSign_Recipient__c', true);
        DocuSign_Recipient__c endorser = [SELECT ID FROM DocuSign_Recipient__c WHERE Recipient_Name__c LIKE '%Test Endorser%'];
        delete endorser;
        TriggerExclusion.excludeTrigger('DocuSign_Recipient__c', false);
    }
}
@isTest
public class LeadSelector_Test {
    @testSetup
    public static void createData(){
        Lead lead = Test_DataFactory.createLead(true, 'company', 'lName');
        lead.Identifier__c = 'LeadLead';
        update lead;
       
    }
    
    @isTest
    public static void test(){
        LeadSelector leadSelector = new LeadSelector();
        System.assertNotEquals(null, leadSelector.getSObjectType());
        System.assertNotEquals(0, leadSelector.getSObjectFieldList().size());
        System.assertNotEquals(null, leadSelector.getEditableLeadFields().size());
    }
    @isTest
    public static void testGetUnconvertedLead(){
        LeadSelector leadSelector = new LeadSelector();
        Lead lead = [Select Id From Lead LIMIT 1];
        
        System.assertNotEquals(null, leadSelector.getUnconvertedLead(new Set<Id>{lead.Id}));
    }
    
    @isTest
    public static void testGetSObjectLeadMap(){
        LeadSelector leadSelector = new LeadSelector();
        Lead lead = [Select Id From Lead LIMIT 1];
        
        Account acc = Test_DataFactory.createAccount(true, UserInfo.getLastName());

        Opportunity opp = Test_DataFactory.createOpportunity(false, 'Opp for ' + UserInfo.getLastName(), acc.Id);
        opp.Lead__c = lead.Id;
        insert opp;
        
        System.assertNotEquals(null, leadSelector.getSObjectLeadMap(new Set<String>{lead.Id} , 'Opportunity'));
    }
    
    @isTest
    public static void testGetLeadByIdentifier(){
        LeadSelector leadSelector = new LeadSelector();
        //Lead lead = [Select Id From Lead LIMIT 1];
        System.assertNotEquals(0, leadSelector.getLeadByIdentifier(new Set<String>{'LeadLead'}).size());
    }
    
    
}
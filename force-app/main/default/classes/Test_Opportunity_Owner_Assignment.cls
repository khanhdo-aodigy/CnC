@isTest
public class Test_Opportunity_Owner_Assignment {

    static testMethod void testInsertCCFTrigger()
    {
        Test.startTest();    
        Date OppExpectedCloseDate = date.today();
        Opportunity tempInsertOpp = new Opportunity();
        tempInsertOpp.Franchise_Code__c = 'CITPC';
        tempInsertOpp.Branch_Code__c = 'CCF';
        tempInsertOpp.StageName = 'Open';
        tempInsertOpp.LeadSource = 'PriceAlert';
        tempInsertOpp.Name = 'TestOpp'; 
        tempInsertOpp.Rating__c = 'Hot';
        tempInsertOpp.CloseDate = OppExpectedCloseDate;  
        insert tempInsertOpp;
        List<Opportunity> Opp = [Select Id, Name from Opportunity where Name =: 'TestOpp'];  
        system.assert(Opp.size()>0, true);
        Test.stopTest();
    }
    
    static testMethod void testInsertCCKTrigger()
    {
        Test.startTest();    
        Date OppExpectedCloseDate = date.today();
        Opportunity tempInsertOpp = new Opportunity();
        tempInsertOpp.Franchise_Code__c = 'KIAPC';
        tempInsertOpp.Branch_Code__c = 'CCK';
        tempInsertOpp.StageName = 'Open';
        tempInsertOpp.LeadSource = 'PriceAlert';
        tempInsertOpp.Name = 'TestOpp1'; 
        tempInsertOpp.Rating__c = 'Hot';
        tempInsertOpp.CloseDate = OppExpectedCloseDate;  
        insert tempInsertOpp;
        List<Opportunity> Opp = [Select Id, Name from Opportunity where Name =: 'TestOpp1'];  
        system.assert(Opp.size()>0, true);
        Test.stopTest();
    }
    
    static testMethod void testInsertCCATrigger()
    {
        Test.startTest();    
        Date OppExpectedCloseDate = date.today();
        Opportunity tempInsertOpp = new Opportunity();
        tempInsertOpp.Franchise_Code__c = 'MITPC';
        tempInsertOpp.Branch_Code__c = 'CCA';
        tempInsertOpp.StageName = 'Open';
        tempInsertOpp.LeadSource = 'PriceAlert';
        tempInsertOpp.Name = 'TestOpp2'; 
        tempInsertOpp.Rating__c = 'Hot';
        tempInsertOpp.CloseDate = OppExpectedCloseDate;  
        insert tempInsertOpp;
        List<Opportunity> Opp = [Select Id, Name from Opportunity where Name =: 'TestOpp2'];  
        system.assert(Opp.size()>0, true);
        Test.stopTest();
    }
    
    static testMethod void testInsertMBCTrigger()
    {
        Test.startTest();    
        Date OppExpectedCloseDate = date.today();
        Opportunity tempInsertOpp = new Opportunity();
        tempInsertOpp.Franchise_Code__c = 'MBC';
        tempInsertOpp.Branch_Code__c = 'CCI';
        tempInsertOpp.StageName = 'Open';
        tempInsertOpp.LeadSource = 'PriceAlert';
        tempInsertOpp.Name = 'TestOpp3'; 
        tempInsertOpp.Rating__c = 'Hot';
        tempInsertOpp.CloseDate = OppExpectedCloseDate;  
        insert tempInsertOpp;
        List<Opportunity> Opp = [Select Id, Name from Opportunity where Name =: 'TestOpp3'];  
        system.assert(Opp.size()>0, true);
        Test.stopTest();
    }
}
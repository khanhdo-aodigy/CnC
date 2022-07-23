/** *****
 * Description : Service Class for Sales Opportunity object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                Description
 * 20210104             HS@aodigy           Created Initial Version. 
 * 20210309             HS@aodigy           Added method upsertSalesOppByAccId. Get latest Open SalesOppo By Account, create it if not found.
 * 20210727             KD@aodigy           Person Account Merging: Remove linkage to Profiling. 
 * 
** *****/
public with sharing class SalesOpportunityService {
    
    private static SalesOpportunitySelector selector = new SalesOpportunitySelector();

    
    public static List<Sales_Opportunity__c> getAllSalesOpportunitiesByAccountIds( Set<Id> setAccountIds )
    {
        return selector.getSalesOpportunitiesByAccountIds( setAccountIds , null, null );
    }
    
    public static Sales_Opportunity__c getLatestOpenSalesOppoByAcctId( Id acctId )
    {
        List<Sales_Opportunity__c> lstSalesOppo = getLatestOpenSalesOppoListByAcctIds( new Set<Id>{acctId} );
        return !lstSalesOppo.isEmpty() ? lstSalesOppo.get(0) : null;
    }

    public static List<Sales_Opportunity__c> getLatestOpenSalesOppoListByAcctIds( Set<Id> setAccountIds )
    {
        return selector.getSalesOpportunitiesByAccountIds( setAccountIds, null, new Set<String>{'Open'} );
    }

    public static Sales_Opportunity__c getOpenSalesOppoByAcctIdAndScEmail( Id acctId , String scEmail )
    {
        List<Sales_Opportunity__c> lstSalesOppo = getOpenSalesOppoListByAcctIdsAndScEmails( new Set<Id>{acctId} , new Set<String>{scEmail} );
        return !lstSalesOppo.isEmpty() ? lstSalesOppo.get(0) : null;
    }

    public static List<Sales_Opportunity__c> getOpenSalesOppoListByAcctIdsAndScEmails( Set<Id> setAccountIds, Set<String> setScEmails ) 
    {
        return selector.getSalesOpportunitiesByAccountIds( setAccountIds , setSCemails, new Set<String>{'Open'} );
    }

    public static Sales_Opportunity__c upsertSalesOppByAccIdAndSCEmail(Account acct, String scEmail, String scName, String scMobile) 
    {
        return upsertSalesOppByAccIdAndSCEmail(acct, scEmail, scName, scMobile, null);
    }

    public static void updateSalesOpptListByIdsAndStatus(Set<Id> setOpptIds, String oppStatus) 
    {
        List<Sales_Opportunity__c> lstSalesOppo = new List<Sales_Opportunity__c>();
        for( Sales_Opportunity__c so : selector.getSalesOpportunitiesByIds( setOpptIds ) ){
            so.Status__c = oppStatus;
            lstSalesOppo.add( so );
        }

        if( !lstSalesOppo.isEmpty() ){
            update lstSalesOppo;
        }
    }


    //Driven by Account + SC Email
    public static Sales_Opportunity__c upsertSalesOppByAccIdAndSCEmail(Account acct, String scEmail, String scName, String scMobile, String oppStatus) 
    {
         
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{Sales_Opportunity__c.SObjectType} );

        Sales_Opportunity__c salesOpp = getOpenSalesOppoByAcctIdAndScEmail(acct.Id, scEmail);
        System.debug('@@@@DEBUG upsertSalesOppByAccIdAndSCEmail :: salesOpp = ' + salesOpp);
        //If not found Create a new One
        if( salesOpp == null ){
            salesOpp = new Sales_Opportunity__c();
            salesOpp.RecordTypeId       = Schema.SObjectType.Sales_Opportunity__c.getRecordTypeInfosByDeveloperName().get('RA_Sales_Opportunity_RT').getRecordTypeId();
            salesOpp.Close_Date__c      = String.isNotBlank( Label.RA_SalesOpportunity_LeadTime )  ? Date.today().addMonths( Integer.valueOf( Label.RA_SalesOpportunity_LeadTime ) ) : salesOpp.Close_Date__c;
            salesOpp.Account__c         = acct.Id;
            salesOpp.Contact__c         = acct.PersonContactId;
            salesOpp.Status__c          = String.isNotBlank(oppStatus) ? oppStatus : 'Open';
            salesOpp.Salesman_Name__c   = scName;
            salesOpp.Salesman_Email__c  = scEmail;
            salesOpp.Salesman_Mobile__c = scMobile;
            //salesOpp.Person_Account_Profiling__c = profilingId;
            uow.registerNew(salesOpp);
        }
        //If found reuse if the Opportunity is Open and the SC info is blank
        else if( salesOpp != null ){
            
            if(String.isNotBlank(oppStatus)) {
                salesOpp.Status__c = oppStatus;
            }
            
            if(String.isBlank(salesOpp.Salesman_Email__c)) {
                salesOpp.Salesman_Name__c   = scName;
                salesOpp.Salesman_Email__c  = scEmail;
                salesOpp.Salesman_Mobile__c = scMobile;
            }
            
            uow.registerDirty(salesOpp);
        } 
        //Else just return the opportunity found
        uow.commitWork();
        System.debug('@@@@DEBUG upsertSalesOppByAccIdAndSCEmail :: Stage = ' + salesOpp.Status__c);
        return salesOpp;
    }

    
    //Driven by Account
    public static Sales_Opportunity__c upsertSalesOppByAccId(Account acct, String oppStatus) 
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{Sales_Opportunity__c.SObjectType} );

        Sales_Opportunity__c salesOpp = getLatestOpenSalesOppoByAcctId(acct.Id);
        System.debug('@@@@DEBUG upsertSalesOppByAccIdAndSCEmail :: salesOpp = ' + salesOpp);
        //If not found Create a new One
        if( salesOpp == null ){
            salesOpp = new Sales_Opportunity__c();
            salesOpp.RecordTypeId       = Schema.SObjectType.Sales_Opportunity__c.getRecordTypeInfosByDeveloperName().get('RA_Sales_Opportunity_RT').getRecordTypeId();
            salesOpp.Close_Date__c      = String.isNotBlank( Label.RA_SalesOpportunity_LeadTime )  ? Date.today().addMonths( Integer.valueOf( Label.RA_SalesOpportunity_LeadTime ) ) : salesOpp.Close_Date__c;
            salesOpp.Account__c         = acct.Id;
            salesOpp.Contact__c         = acct.PersonContactId;
            salesOpp.Status__c          = String.isNotBlank(oppStatus) ? oppStatus : 'Open';
            //salesOpp.Person_Account_Profiling__c = profilingId;
            uow.registerNew(salesOpp);
        }
        uow.commitWork();
        //Else just return the opportunity found
        return salesOpp;
    }
    
}
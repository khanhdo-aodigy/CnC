/** *****
 * Class Name: ClashOpportunityQueueable
 * Description: Create a ClashDeal__c record to be
 * 				fetch by a daily report.
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20190404            Christian Gaylan              Created Initial Version. 
 * 20200921            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 
** *****/
public without sharing class ClashOpportunityQueueable implements Queueable{
    
    public List<Opportunity> oppToWrap {get; set;}    
    
    //constructor
    public ClashOpportunityQueueable( List<Opportunity> oppVals ) {

        if(oppVals!=null && !oppVals.isEmpty())
        {
            Set<Id> relatedCons = new Set<Id>();
            Set<Id> relatedPA = new Set<Id>(); 		
            Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>();
            
            for(Opportunity opp : [SELECT Id, Contact_Person__c, //Lead__c
                                          Account__c, OwnerId, Owner.Name,
                                          CreatedDate, StageName, Branch_Code__c, Franchise_Code__c
                                   FROM Opportunity 
                                   WHERE Id IN: oppVals ])
            {            
                if(opp.Contact_Person__c != null)
                {
                    relatedCons.add(opp.Contact_Person__c);
                }
                 
            }
            
            if(!relatedCons.isEmpty())
            {
                for(Opportunity oppVar : [SELECT Id, Contact_Person__c, 
                                                 OwnerId, Owner.Name, CreatedDate,
                                                 StageName, Branch_Code__c, Franchise_Code__c, Account__c
                                          FROM Opportunity 
                                          WHERE Contact_Person__c IN: relatedCons AND isClosed = false])
                {
                    if(!oppMap.containsKey(oppVar.Id))
                    {
                        oppMap.put(oppVar.Id, oppVar );
                    }
                }
            }
            
            
            if( oppMap!=null && !oppMap.isEmpty() && oppMap.values() != null && !oppMap.values().isEmpty())
            {
                oppToWrap = oppMap.values();
            }
        }
    }
    
    public void execute(QueueableContext con)
    {
        List<ClashDeal__c> lstClashDeals = new List<ClashDeal__c>();
        
        if(oppToWrap!=null && !oppToWrap.isEmpty())
        {
            List<Models_Interested__c> modList = new List<Models_Interested__c>();
            Map<Id, String> oppIdToModels = new Map<Id, String>(); //Opp Id to Model Name
            for(Models_Interested__c modelInt : [SELECT Id, Opportunity__c, Model__c, Model__r.Name 
                                                 FROM Models_Interested__c 
                                                 WHERE Opportunity__c IN: oppToWrap])
            {
                if(oppIdToModels.containsKey( modelInt.Opportunity__c )){
                    String oppMods = oppIdToModels.get( modelInt.Opportunity__c );
                    String newVal  = '';
                    if( String.isBlank(oppMods) ){
						newVal = modelInt.Model__r.Name;                         
                    }
                    else{
                        newVal = oppMods + ', ' + modelInt.Model__r.Name;
                    }
                    oppIdToModels.put( modelInt.Opportunity__c, newVal );
                }
                else{
                    oppIdToModels.put( modelInt.Opportunity__c, modelInt.Model__r.Name );
                }
            }
            
            for(Opportunity opp : oppToWrap){
                String modelsInterested = oppIdToModels.containsKey( opp.Id ) ? oppIdToModels.get( opp.Id ) : '';
                lstClashDeals.add(
                    new ClashDeal__c(
                        Opportunity__c = opp.Id,
                        Status__c = opp.StageName,
                        Contact__c = opp.Contact_Person__c,
                        SalesConsultant__c = opp.OwnerId,
                        OpportunityCreationDate__c = Date.valueOf(opp.CreatedDate),
                        Models_Interested_In__c = modelsInterested,
                        BranchCode__c = opp.Branch_Code__c,
                        FranchiseCode__c = opp.Franchise_Code__c,
                        Account__c = opp.Account__c		 	
                    ) 
                );
            }
        }
        
        Database.insert( lstClashDeals , false );
    }
}
/** *****
 * Description : ClashOpportunityController for ClashOpportunityComponent.component
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20190319            Mohd Rizvan                   Created Initial Version. 
 * 20200921            khanh.do@aodigy.com           Added PA - Phase 2 Changes
 * 
** *****/
public without sharing class ClashOpportunityController{

    public Id oppId {get;set;}
    public Opportunity getoppfield(){
        Opportunity opp = new Opportunity();
        
        for( Opportunity oppo : [SELECT Id, Name, Clash_Opportunity__c, Stagename, Owner.Name,CreatedDate, 
                                        Contact_Person__c, Contact_Person__r.Name,
                                        Account__c, Account__r.Name     //PA MIGRATION
                                 FROM Opportunity 
                                 WHERE Id =: oppId] )
        {
            opp = oppo;
        }
        return opp;
    }

    public List<OpptyModelWrapper> getoppList(){
        
        List<Opportunity> oppty;
        List<OpptyModelWrapper> oppWrapList = new List<OpptyModelWrapper>();
        
        List<Opportunity> lstOppo = [ SELECT Id, Name, //Lead__c,
                                             Contact_Person__c, Clash_Opportunity__c,
                                             Stagename, Owner.Name, Branch_Code__c, Account__c
                                      FROM Opportunity
                                      WHERE Id =: oppId];
        Opportunity opp = (lstOppo<>null && !lstOppo.isEmpty()) ? lstOppo.get(0) : null;

        if( opp <> null )
        {
            
            if( opp.Account__c != null ){
                Account acc = [SELECT Id, name, 
                                      ( SELECT Id, Name, Clash_Opportunity__c, Contact_Person__c, Contact_Person__r.Name,
                                               Stagename, OwnerId, Owner.Name, 
                                               CreatedDate, Franchise_Code__c, Branch_Code__c, Account__c, Account__r.Name 
                                        FROM Opportunities__r 
                                        WHERE IsClosed = false
                                        AND Branch_Code__c = :opp.Branch_Code__c
                                      ) 
                                FROM Account 
                                WHERE Id = :opp.Account__c];

                oppty = acc.Opportunities__r;
            }
            else if( opp.Contact_Person__c != null )
            {
                Contact con = [SELECT Id, Name, 
                                     ( SELECT Id, Name, Clash_Opportunity__c, Contact_Person__c, Contact_Person__r.Name,
                                              Stagename, OwnerId, Owner.Name, 
                                              CreatedDate, Franchise_Code__c, Branch_Code__c, Account__c, Account__r.Name 
                                       FROM Opportunities__r 
                                       WHERE IsClosed = false 
                                       AND Branch_Code__c = :opp.Branch_Code__c
                                     ) 
                                FROM Contact 
                                WHERE Id = :opp.Contact_Person__c];
                
                oppty = con.Opportunities__r;
            }
            
            
            if( oppty!=null && !oppty.isEmpty() ){
                //get Models Interested on each Opportunity
                List<Models_Interested__c> modList = new List<Models_Interested__c>();
                Map<Id, String> oppIdToModels = new Map<Id, String>(); //Opp Id to Model Name
                for(Models_Interested__c mc : [SELECT Id, Opportunity__c, Model__c, Model__r.Name 
                                            FROM Models_Interested__c 
                                            WHERE Opportunity__c IN: oppty])
                {
                    if( oppIdToModels.containsKey( mc.Opportunity__c ) )
                    {
                        String oppMods = oppIdToModels.get( mc.Opportunity__c );
                        String newVal = '';
                        if( String.isBlank( oppMods ) )
                        {
                            newVal = mc.Model__r.Name;                         
                        }
                        else
                        {
                            newVal = oppMods + ', ' + mc.Model__r.Name;
                        }
                        oppIdToModels.put( mc.Opportunity__c, newVal );
                    }
                    else
                    {
                        oppIdToModels.put( mc.Opportunity__c, mc.Model__r.Name );
                    }
                }
                
                for(Opportunity opvar : oppty)
                {
                    String conName = null;
                    String paName  = null;	 
                    String modelsInterested = oppIdToModels.containsKey( opvar.Id) ? oppIdToModels.get(opvar.Id) : '';
                    
                    
                    if(String.isNotBlank(opvar.Account__c)){
                        paName = opvar.Account__r.Name;
                    }
                    
                    if(String.isNotBlank(opvar.Contact_Person__c)){
                        conName = opvar.Contact_Person__r.Name;
                    }
                    
                    //add to wrapper class
                    oppWrapList.add(
                        new OpptyModelWrapper( opvar.Id, opvar.Name, opvar.Clash_Opportunity__c, opvar.StageName,
                                            opvar.Contact_Person__c, conName, opvar.Account__c, paName,
                                            opvar.OwnerId, opvar.Owner.Name, opvar.CreatedDate, modelsInterested,
                                            opvar.Franchise_Code__c, opvar.Branch_Code__c )
                    );
                }
            }
        }
        
        return oppWrapList;
    }
    
    public String getBaseURL(){
        return System.URL.getSalesforceBaseUrl().toExternalForm(); 
    }
    
    //Wrapper class to get the Models Interested
    public class OpptyModelWrapper 
    {
        public String oppId {get; set;}
        public String name {get; set;}
        public Boolean isCLash {get; set;}
        public String status {get; set;}
        public String conId {get; set;}
        public String conName {get; set;}
        public String paId {get; set;}		 
        public String paName {get; set;}
        public String ownerId {get; set;}
        public String ownerName {get; set;}
        public DateTime oppDate {get; set;}
        public String modelsInterested {get; set;}
        public String franchiseCode {get; set;}
        public String branchCode {get; set;}
        
        public OpptyModelWrapper( String vOpp, String vName, Boolean vClash, String vStat, 
                                  String vCon, String vConName,
                                  String vPA, String vPAName,  
                                  String vOwnerId, String vOwnName, 
                                  DateTime vOppDate, String vModels,
                                  String vFranchiseCode, String vBranchCode)
        {
            oppId    = vOpp; 
            name     = vName;
            isCLash  = vClash;
            status   = vStat;
            conId    = vCon;
            conName  = vConName;
            paId     = vPA;	 
            paName   = vPAName;
            ownerId  = vOwnerId;
            ownerName = vOwnName;
            oppDate  = vOppDate;
            modelsInterested = vModels;
            franchiseCode = vFranchiseCode;
            branchCode = vBranchCode;
        }    
    }
}
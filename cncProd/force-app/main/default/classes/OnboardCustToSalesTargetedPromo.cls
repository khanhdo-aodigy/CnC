/** *****
 * Description : Batch class to onboard customer to campaign that starts after the DSA signed date - Sales Targeted Promo Project.
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * 20220510            tphan@aodigy.com      Created initial version
 ** *****/

global class OnboardCustToSalesTargetedPromo implements Schedulable, Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  
{
    private Set<Id> idsOfCampaign = new Set<Id>();

    public OnboardCustToSalesTargetedPromo() {}

    public OnboardCustToSalesTargetedPromo(Set<Id> campaignIds)
    {
        idsOfCampaign = campaignIds;

        System.debug('@@@@DEBUG OnboardCustToSalesTargetedPromo :: idsOfCampaign ' + idsOfCampaign);
    }

    global void execute (SchedulableContext ctx)
    {
        System.debug('@@@@DEBUG schc.exe :: idsOfCampaign ' + idsOfCampaign);
        
        Database.executebatch(new OnboardCustToSalesTargetedPromo(idsOfCampaign), 200);
    }
    
    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        ID vrecordTypeID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('C_C_Campaign_RT_Sales_Targeted_Promo').getRecordTypeId();
        String strSOQL = 'SELECT Id, Branch_Code__c, Model_Master__c FROM Campaign WHERE IsActive = true AND Type = \'Sales Targeted Promo\' AND RecordTypeId =: vrecordTypeID AND StartDate = TODAY';
        
        if( idsOfCampaign <> null && !idsOfCampaign.isEmpty() )
        {
            strSOQL += ' AND ID IN : idsOfCampaign ';
        }

        return Database.query( strSOQL );
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        System.debug('@@@@DEBUG OnboardCustToSalesTargetedPromo :: batch.execute :: scope.size - ' + scope.size() );
        
        try 
        {   
            if (scope.size() > 0 && scope <> null)
            {
                Map<Id, List<Sales_Agreement__c>> modelMasterAndSAMap = new Map<Id, List<Sales_Agreement__c>>();
                Set<Id> campaignIds                                   = new Set<Id>();
                Set<Id> contactIds                                    = new Set<Id>();
                Set<Id> modelMasterIds                                = new Set<Id>();
                Set<String> brandCodes                                = new Set<String>();

                for (Campaign c : (List<Campaign>) scope)
                {
                    campaignIds.add(c.Id);
                    brandCodes.add(c.Branch_Code__c);
                    modelMasterIds.add(c.Model_Master__c);
                }

                Map<Id, Sales_Agreement__c> sAs = new Map<Id, Sales_Agreement__c> ([SELECT Id, Contact__c, 
                                                                                            Account__c, Stock_Reservation__r.Model_Code__c 
                                                                                    FROM Sales_Agreement__c 
                                                                                    WHERE (Stage__c = 'Confirmation of Sale' OR Stage__c = 'Request Registration')
                                                                                    AND Branch_Code__c IN: brandCodes
                                                                                    AND Stock_Reservation__r.Model_Code__c IN: modelMasterIds]);
                
                if (sAs <> null && sAs.size() > 0)
                {
                    List<Sales_Agreement__c> sAList;

                    for (Sales_Agreement__c sA: sAs.values())
                    {
                        contactIds.add(sA.Contact__c);

                        if (modelMasterAndSAMap.containsKey(sA.Stock_Reservation__r.Model_Code__c))
                        {
                            sAList = modelMasterAndSAMap.get(sA.Stock_Reservation__r.Model_Code__c);
                            sAList.add(sA);
                            modelMasterAndSAMap.put(sA.Stock_Reservation__r.Model_Code__c, sAList);
                        }
                        else 
                        {
                            modelMasterAndSAMap.put(sA.Stock_Reservation__r.Model_Code__c, new List<Sales_Agreement__c>{sA});    
                        }
                    }

                    List<Campaign_Member_Vehicle__c> memberAndVehicles = [SELECT Id FROM Campaign_Member_Vehicle__c WHERE Campaign__c IN: campaignIds AND Sales_Agreement__c IN: sAs.keySet() AND Contact__c IN: contactIds];
                    
                    if (memberAndVehicles == null || memberAndVehicles.isEmpty())
                    {
                        List<Campaign_Member_Vehicle__c> newCampaignMemVehicles = new List<Campaign_Member_Vehicle__c>();
    
                        for (Campaign c : (List<Campaign>) scope)
                        {
                            sAList = modelMasterAndSAMap.get(c.Model_Master__c);

                            if (sAList.size() > 1)
                            {
                                for (Sales_Agreement__c sA : sAList)
                                {                                  
                                    newCampaignMemVehicles.add(new Campaign_Member_Vehicle__c(Campaign__c        = c.Id,
                                                                                              Sales_Agreement__c = sA.Id,
                                                                                              Contact__c         = sA.Contact__c,
                                                                                              Account__c         = sA.Account__c));                        
                                }
                            }
                            else 
                            {
                                newCampaignMemVehicles.add(new Campaign_Member_Vehicle__c(Campaign__c        = c.Id,
                                                                                          Sales_Agreement__c = sAList[0].Id,
                                                                                          Contact__c         = sAList[0].Contact__c,
                                                                                          Account__c         = sAList[0].Account__c));
                            }
                        }

                        Database.SaveResult[] srList = Database.insert(newCampaignMemVehicles, false);
                        for (Database.SaveResult sr : srList) 
                        {
                            if (sr.isSuccess()) 
                            {
                                System.debug('Successfully inserted Campaign Member And Vehicle. Campaign Member And Vehicle ID: ' + sr.getId());
                            }
                            else 
                            {       
                                for(Database.Error err : sr.getErrors()) 
                                {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Campaign Member And Vehicle fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                }      
            }      
        }
        catch (Exception e)
        {
            System.debug('ERROR: ' + e.getMessage() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('OnboardCustToSalesTargetedPromo', e);
        }       
    }

    //Batch End
    public void finish(Database.BatchableContext info){}

    public static void OnboardCustToSalesTargetedPromo()
    {   
        Database.executebatch(new OnboardCustToSalesTargetedPromo(null), 200);
    }
}
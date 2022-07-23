/** *****
 * Description : Bacth class to offboard customer when the campaign ends even though the SA's balance payment is not done yet - Sales Targeted Promo Project
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer               Details
 * 20220510            tphan@aodigy.com      Created initial version
 ** *****/

global class OffboardCustFromSalesTargetedPromo implements Schedulable, Database.Batchable<sObject>, Database.Stateful  
{
    private Set<Id> idsOfCampaign = new Set<Id>();

    public OffboardCustFromSalesTargetedPromo() {}

    public OffboardCustFromSalesTargetedPromo(Set<Id> campaignIds)
    {
        idsOfCampaign = campaignIds;

        System.debug('@@@@DEBUG OffboardCustomerFromSalesTargetedPromoBatch :: idsOfCampaign ' + idsOfCampaign);
    }

    
    global void execute (SchedulableContext ctx)
    {
        System.debug('@@@@DEBUG schc.exe :: idsOfCampaign ' + idsOfCampaign);
        
        Database.executebatch(new OffboardCustFromSalesTargetedPromo(idsOfCampaign), 200);
    }    

    public Iterable<sObject> start(Database.Batchablecontext BC)
    {
        ID vrecordTypeID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('C_C_Campaign_RT_Sales_Targeted_Promo').getRecordTypeId();
        String strSOQL = 'SELECT Id FROM Campaign WHERE IsActive = true AND Type = \'Sales Targeted Promo\' AND RecordTypeId =: vrecordTypeID AND EndDate < TODAY';
        
        if( idsOfCampaign <> null && !idsOfCampaign.isEmpty() )
        {
            strSOQL += ' AND ID IN : idsOfCampaign ';
        }

        return Database.query( strSOQL );
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {  
        System.debug('@@@@DEBUG OffboardCustomerFromSalesTargetedPromoBatch :: batch.execute :: scope.size - ' + scope.size() );
        
        try 
        {   
            if (scope.size() > 0 && scope <> null)
            {
                Set<Id> campaignIds = new Set<Id>();

                for (Campaign c : (List<Campaign>) scope)
                {
                    campaignIds.add(c.Id);
                }

                List<Campaign_Member_Vehicle__c> campaignMembers = [SELECT Id, Offboarded__c, Offboard_Date__c, Contact__c FROM Campaign_Member_Vehicle__c WHERE Campaign__c IN: campaignIds];

                if (campaignMembers <> null && !campaignMembers.isEmpty())
                {
                    for (Campaign_Member_Vehicle__c member : campaignMembers)
                    {
                        member.Offboarded__c    = true;
                        member.Offboard_Date__c = Date.today();
                    }

                    Database.SaveResult[] results = Database.update(campaignMembers, false);
                    for (Integer index = 0, size = results.size(); index < size; index++) 
                    {
                        if(!results[index].isSuccess())
                        {
                            System.debug(campaignMembers[index] + ' has error ' + results[index].getErrors());
                        }
                        else 
                        {
                            System.debug('Successfully updated campaign member with ID: ' + results[index].getId());
                        }
                    }
                }
            }       
        }
        catch (Exception e)
        {
            System.debug('ERROR: ' + e.getMessage() + ' ' + e.getLineNumber());
            loggerDataPool.buildLogDataPool('OffboardCustomerFromSalesTargetedPromoBatch', e);
        }       
    }

    //Batch End
    public void finish(Database.BatchableContext info){}

    public static void OffboardCustomerFromSalesTargetedPromoBatch()
    {   
        Database.executebatch(new OffboardCustFromSalesTargetedPromo(null), 200);
    }
}
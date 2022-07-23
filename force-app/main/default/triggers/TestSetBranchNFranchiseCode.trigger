/** ******
 * Description: Trigger for set branch code and franchise code
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion
 * 
** ******/
trigger TestSetBranchNFranchiseCode on Trade_Plate__c (after insert) {

    //Trigger exclusion check
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
        
    if( TriggerExclusion.isTriggerExclude('Trade_Plate__c') 
        || TriggerExclusion.isBypassTriggerExecution('Trade_Plate__c') 
            || automationSetting.Bypass_Triggers__c
    )
    {
        return;
    }

    List<Trade_Plate__c> plateToInsert = new List<Trade_Plate__c>();
    if(trigger.isInsert && trigger.isAfter)
    {
            for(Trade_Plate__c c : trigger.new)
            {   
                system.debug('tata  '+ c.Branch_Code__c + '  '+ c.Franchise_Code__c);
                if(c.Branch_Code__c == null || c.Franchise_Code__c == null)
                {
                    Trade_Plate__c a=[select id, ownerId from Trade_Plate__c where id =:c.id];
                    User b =[select id, Branch_Code__c, Franchise_Code__c from User where id =: c.ownerId];
                    a.Branch_Code__c= b.Branch_Code__c;
                    a.Franchise_Code__c= b.Franchise_Code__c;
                    plateToInsert.add(a);
                }
            }
            if(plateToInsert.size()>0)
            {
                update plateToInsert;
            }
    }
    
}
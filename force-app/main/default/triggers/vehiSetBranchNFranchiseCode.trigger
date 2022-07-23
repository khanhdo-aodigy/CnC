/** ******
 * Description: Trigger for set branch code and franchise code
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion check
 * 
** ******/ 
trigger vehiSetBranchNFranchiseCode on Vehicle_Master__c (after insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();

    if(TriggerExclusion.isTriggerExclude('Vehicle_Master__c') 
        || TriggerExclusion.isBypassTriggerExecution('Vehicle_Master__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    List<Vehicle_Master__c> vehiToInsert = new List<Vehicle_Master__c>();
    if(trigger.isInsert && trigger.isAfter)
    {
            for(Vehicle_Master__c c : trigger.new)
            {   
                system.debug('tata  '+ c.Branch_Code__c + '  '+ c.Franchise_Code__c);
                if(c.Branch_Code__c == null || c.Franchise_Code__c == null)
                {
                    Vehicle_Master__c a=[select id, ownerId from Vehicle_Master__c where id =:c.id];
                    User b =[select id, Branch_Code__c, Franchise_Code__c from User where id =: c.ownerId];
                    a.Branch_Code__c= b.Branch_Code__c;
                    a.Franchise_Code__c= b.Franchise_Code__c;
                    vehiToInsert.add(a);
                }
            }
            if(vehiToInsert.size()>0)
            {
                update vehiToInsert;
            }
    }
    
}
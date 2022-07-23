/** ******
 * Description : Contact Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)   Name        			Description
 * 20180728         Cycle & Carriage        Created Initial Version. 
 * 20200221			HS@aodigy			    Added isTriggerExclude & isBypassTriggerExecution method which perform additional check based on mdt data setup to bypass Trigger execution
 * 20200925         HS@aodigy               Removed default AccountId to JCC Account upon Business Contact creation
 * 20210706         KD@aodigy               Added bypass trigger via custom setting
 * 
****** **/
trigger updateNricAutomationTrigger on Contact (after update, before insert, before update) 
{    
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    //Trigger exclusion check
    if( TriggerExclusion.isTriggerExclude('Contact')
        || TriggerExclusion.isBypassTriggerExecution('Contact') 
          || automationSetting.Bypass_Triggers__c
    ){
        System.debug('By Pass Contact updateNricAutomationTrigger.trig !!!');
        return;
    }
    
    System.debug('Testing Contact !!!');

    if (Trigger.isUpdate && Trigger.isAfter)
    {   
        //Skip execution of trigger if call is coming from DWH update or from LeadConverter.    
        if(DWH_GetCustomer_Data.CallFromDWH == true || DWH_GetAllCustomer_Data.CallFromDWH || DWH_GetSingleCustomer_Data.CallFromDWH )
        {
            System.debug('CallFromDWH or isRunningTest is true');
            return;                       
        }
        else
        {   
            if(!Test.isRunningTest()){
                CallUpdateNricAutomation.makeHTTPXMLPost();
            }
            
            for(Contact con: trigger.new)
            {
                if(Trigger.oldMap.get(con.Id).MobilePhone != con.MobilePhone && con.Contact_Update_Source__c == 'API')
                {
                    String name;
                    if(con.FirstName!=null && con.LastName !=null)
                    {
                        name = con.FirstName+' '+con.LastName;
                    }
                    else if(con.FirstName!=null && con.LastName ==null)
                    {
                        name = con.FirstName;
                    }
                    else if(con.FirstName ==null && con.LastName !=null)
                    {
                        name = con.LastName;
                    }
                    if(!Test.isRunningTest()){
                        UpdateMobileNumber.sendEmail(name,con.MobilePhone,con.Email);
                    }
                }
            }
        }

        //ContactTriggerHandler.runAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        Date currTime= system.today();
        for(Contact itr : trigger.new){
            Contact oldCon = trigger.oldMap.get(itr.id);
            if(itr.NRIC_Passport_No__c != oldCon.NRIC_Passport_No__c ){
                itr.LastNRICUpdated__c = currTime;
            }            
        }

       // ContactTriggerHandler.runBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

}
/** ******
 * Description: Test_Drive__c Trigger
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		    Description
 * YYYYMMDD            C&C			        Created Initial Version.
 * 20210706            khanh.do             Added Custom Setting bypass Trigger
 * 
** ******/
trigger CreateAttcPDFTrigger on Test_Drive__c (after insert) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    
    //Exclude this trigger
    if( TriggerExclusion.isTriggerExclude('TestDrive') 
        || TriggerExclusion.isTriggerExclude('Test_Drive__c') 
            || TriggerExclusion.isBypassTriggerExecution('Test_Drive__c')
                || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    if(trigger.isInsert && trigger.isAfter)
    {
            for(Test_Drive__c c : trigger.new)
            {
            
             if (!Test.isRunningTest()) { Helper_Class.AttachPDF(c.Id); }        

            }   
            
    }
}
/** ******
 * Description : TriggerHandler class for Lead
 * 
 * Date(YYYYMMDD)      Name             Description
 * 20200221            huynh.hung       Created Initial Version. 
 * 
 ** ******/
public without sharing class LeadTriggerHandler {
    //Recursive Trigger flags.
    public static Boolean isRunAfterUpdate = false;
    public static Boolean isRunBeforeInsert = true;
    public static Boolean isRunAfterInsert = true;
    
    public static void isRunAfterUpdate(List<Lead> leadList,  Map<Id,Lead> oldMap){
        if(!isRunAfterUpdate){
            System.debug('@@@@DEBUG LeadTriggerHandler >>> isRunAfterUpdate !!! ');
            LeadBL.leadChange(leadList, oldMap);
            isRunAfterUpdate = true;
        }        
    }

    public static void handleAfterInsert(List<Lead> leadList){
        if(isRunAfterInsert){
            System.debug('@@@@DEBUG LeadTriggerHandler >>> handleAfterInsert !!! ');
            LeadBL.createProspectPersonAccount(leadList);
            isRunAfterInsert = false;
        }        
    }
}
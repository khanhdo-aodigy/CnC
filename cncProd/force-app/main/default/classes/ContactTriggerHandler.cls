/* *******
 * Description : Batch class to create/Link PA based on the corresponding Contact's info
 * 
 * Date(YYYYMMDD)      Name             Description
 * 20200219            huynh.hung       Created Initial Version. 
 * 20200923            Khanh Do         Added PA Phase 2 Migration Changes
 * ******/
public without sharing class ContactTriggerHandler {
    
    //Recursive Trigger flags.
    public static Boolean isRunAfterUpdate = false;
    
    public static void isRunAfterUpdate(List<Contact> conList,  Map<Id,Contact> oldMap){
        if(!isRunAfterUpdate){
            //ContactBL.contactChange(conList, oldMap); //PA Phase 2: Removed calling to contactChange()
            isRunAfterUpdate = true;
        }        
    }

}
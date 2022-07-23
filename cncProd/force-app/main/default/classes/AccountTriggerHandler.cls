/** ******
 * Description: Account Trigger Handler
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * 20200228             nguyen.tho              Created Initial Version. 
 * 20200424             HS                      Added IsPersonAccount Check 
** ******/
public with sharing class AccountTriggerHandler {

    //Recursive Trigger flags.
    private static Boolean isRunAfterUpsert = false;

    public static void updatePortalUser(Map<Id,Account> newMap){
        if(!isRunAfterUpsert){
            System.enqueueJob( new UpdatePortalUserQueueable( newMap.keySet() ) );            
            isRunAfterUpsert = true;
        }        
    }


}
/** *****
 *  Class Name: BatchUpdateUserNRIC
 *  Description: Populates NRIC on User record based on Contact NRIC update date
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer Name          Description
 * 20190731             Savita                  Created.
 * 20200318             HS                      Added PA Migration - Phase 1 changes
 * 20200831             khanh.do                Added PA Migration - Phase 2 Changes
 * 
** *****/
global class BatchUpdateUserNRIC implements Database.Batchable<sObject>, Schedulable
{
    public String queryString = '';
    public String batchForDataPool = '';
      
    public BatchUpdateUserNRIC (){  
        batchForDataPool = 'BatchUpdateUserNRIC'; 
        queryString = 'SELECT Id, Name, NRIC_Passport_No__c, IsPersonAccount FROM Contact WHERE LastNRICUpdated__c = TODAY';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(queryString);
    }
    
    global void Execute(Database.BatchableContext bc, List<Contact> Contactlist){
        try{
            //List<User> userList = new List<User>();
            Map<Id,User> mapUserToUpdate = new Map<Id,User>();
            Map<Id,String> ConIdToNricMap = new Map<Id,String>();
            Map<Id,String> mapPAcontactNRIC = new Map<Id,String>();  
            System.debug('Contactlst: ' + Contactlist);
            for(Contact conRec : Contactlist){
                if( conRec.IsPersonAccount == false ) {          
                    ConIdToNricMap.put( conRec.Id, conRec.NRIC_Passport_No__c ); 
                }
                else {
                    mapPAcontactNRIC.put( conRec.Id, conRec.NRIC_Passport_No__c );  
                }
            }
            
            
            if(!ConIdToNricMap.IsEmpty())
            {
                //for(User uRec : [SELECT Id /*, ContactId__c, NRIC__c*/ FROM User WHERE ContactId__c IN : ConIdToNricMap.KeySet() AND isPortalEnabled = true]){
                    // if(ConIdToNricMap.ContainsKey(uRec.ContactId__c)) {
                    //     //uRec.NRIC__c  = ConIdToNricMap.get( uRec.ContactId__c );
                    //     //userList.add( uRec );
                    //     mapUserToUpdate.put( uRec.Id , uRec );
                    //     //System.debug(uRec.NRIC__c);
                    //}
                //}
            }

            
            if(!mapPAcontactNRIC.IsEmpty()){
                for(User usr : [SELECT Id, ContactId/*, NRIC__c*/ FROM User WHERE ContactId IN: mapPAcontactNRIC.keySet() AND isPortalEnabled = true]){
                    //usr.NRIC__c = mapPAcontactNRIC.get( usr.ContactId );
                    //userList.add( usr );
                    mapUserToUpdate.put( usr.Id , usr );
                }
            }

			
            if( mapUserToUpdate<>null && !mapUserToUpdate.isEmpty()) {
                update (mapUserToUpdate.values());
            }

            /** PA MIGRATION : Commented */
            /*
            if(!userList.isEmpty()){
                update userList;         
            }
            */
        }       
        catch(Exception e){
            loggerDataPool.buildLogDataPool('BatchUpdateUserNRIC',e);
        } 
    }
    
    global void finish(Database.BatchableContext bc){
         batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());
    }    
     
    global void execute(SchedulableContext sc){
        new BatchManager('BatchUpdateUserNRIC', null);
    }  
}
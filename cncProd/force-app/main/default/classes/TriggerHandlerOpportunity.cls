/** *******
 * 
 * Class Name: TriggerHandlerOpportunity
 * Description: Opportunity Trigger Handler
 * Note:
 *      without sharing is used so that this batch will run on System mode.
 * 
 * Revision History
 * Date (YYYYMMDD)      Developer Name          Description
 * 20190322             Christian Gaylan        Created.
 * 20201128             HS@aodigy               Added beforeInsert & beforeUpdate context, and getChangedRecords method
 * 
 ** *******/ 
public without sharing class TriggerHandlerOpportunity {
    
    //Recursive Trigger prevention
    public static Boolean isBeforeInsertRun = false;
    public static Boolean isBeforeUpdateRun = false;
    public static Boolean isAfterUpdateRun = false;
    public static Boolean isAfterInsertRun = false;


    public static void beforeInsert( List<Opportunity> oppList ){
        if(!isBeforeInsertRun){
            OpportunityBL.checkIsFleetOwner( oppList );
            isBeforeInsertRun = true;
        }
    }

    public static void beforeUpdate( List<Opportunity> oppList, Map<Id,Opportunity> oldMap ){
        if(!isBeforeUpdateRun){
            oppList = getChangedRecords( new Set<String>{'OwnerId'}, oppList, oldMap );
            OpportunityBL.checkIsFleetOwner( oppList );
			OpportunityBL.forceUpdateListOfContact(oppList);
            isBeforeUpdateRun = true; 
        }
    }

    /** 
     * Method Name: afterInsert 
     * Description: Consolidates all after insert logic.
     * Parameters: 
     *   oppList - Trigger.new 
     * Return : 
     *    N/A
    **/
    public static void afterInsert(List<Opportunity> oppList){
        if(!isAfterInsertRun){
            System.debug(oppList);

            /*
            if( !TriggerExclusion.skipRR )
            {
                OpportunityRoundRobinAsgmt.assignOppotunityOwner( oppList );
            }
            */
            OpportunityBL.setClashOpportunity(oppList,null);
            OpportunityBL.setBranchCode(oppList);
            //OpportunityBL.setClashOppEmails(oppList);
            isAfterInsertRun = true; 
            
           // if(TriggerExclusion.skipRR==false){
              // OpportunityBL.setOwner(oppList);
           // }
        }
    }
    
    
    /**
     * Method Name: afterUpdate
     * Description: Consolidates all after update logic.
     * Parameters:
     *   oppList - Trigger.new
     *   oldMap - Trigger.oldMap
     * Return:
     *   N/A
    **/ 
    public static void afterUpdate(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
        if(!isAfterUpdateRun){
            OpportunityBL.createTaskOnOwnerReassign(oppList, oldMap);
            OpportunityBL.setClashOpportunity(oppList,oldMap);
            OpportunityBL.setSharing(oppList, oldMap);
            isAfterUpdateRun = true; 
        }
    }


    private static List<Opportunity> getChangedRecords(Set<String> setTrackFields , List<Opportunity> lstNewRecords, Map<Id,Opportunity> mapOldRecords ) 
    {
        
        List<Opportunity> changedRecords = new List<Opportunity>();

        for(Opportunity newRecord : lstNewRecords) {

			Id recordId = (Id) newRecord.get('Id');
            
            if(mapOldRecords == null || !mapOldRecords.containsKey(recordId)) 
                continue;
            
            Opportunity oldRecord = mapOldRecords.get(recordId);

            for(String fieldName : setTrackFields) {
                if(oldRecord.get(fieldName) != newRecord.get(fieldName)) {
                    changedRecords.add(newRecord);
                }
			}
        }
		return changedRecords;
    }
}
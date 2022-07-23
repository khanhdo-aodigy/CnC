/** ******
 * Description : Logic class to check if to bypass/ignore the Trigger execution
 * 
 * Change History:
 * Date(YYYYMMDD)  	 	Name        				Description
 * 20190314          	Hari Panneerselvam          Created Initial Version. 
 * 20200221				HS							Added isBypassTriggerExecution method which perform additional check based on mdt data setup to bypass Trigger execution
 * 
** ******/
public class TriggerExclusion{

	public static Map<String, String> mapExcludeTrigger = new map<String, String>();
	public static Boolean skipRR = false;
	
	public static void excludeTrigger(String objectName, Boolean isExclude){
		if(isExclude){
			mapExcludeTrigger.put(objectName, 'Trigger Exclusion');
		}
		else {
			mapExcludeTrigger.clear();
		}
	}
	
    public static Boolean isTriggerExclude(String objectName){
    	if(mapExcludeTrigger != null && mapExcludeTrigger.get(objectName) != null){
    		System.debug('Trigger Excluded for Object (' +objectName +')');
    		return true;
    	}
    	return false;
	}
	
	public static Boolean isBypassTriggerExecution( String strObjectAPI ){
		Boolean status = false;
		List<Trigger_Exclusion_Setup__mdt> lstTriggerExclusion = new List<Trigger_Exclusion_Setup__mdt>();
		lstTriggerExclusion = [ SELECT Id, Targeted_User_Ids__c, Bypass_Trigger_Execution__c
								FROM Trigger_Exclusion_Setup__mdt 
								WHERE MasterLabel = :strObjectAPI  ];
		
		if( !lstTriggerExclusion.isEmpty() ) {
			//BYPASS TRIGGER EXECUTION BY USER
			if( lstTriggerExclusion.get(0).Targeted_User_Ids__c <> null ) { 
				Set<String> setUserIds = new Set<String>();
				for( String userId : lstTriggerExclusion.get(0).Targeted_User_Ids__c.split(';') ) {
					setUserIds.add( userId.trim() );
				}
				System.debug('@@@@DEBUG isBypassTriggerExecution :: setUserIds = ' + setUserIds );
				status = setUserIds.contains( UserInfo.getUserId() );
			}
			
			//BYPASS TRIGGER EXECUTION BY OBJECT
			if( !status && lstTriggerExclusion.get(0).Bypass_Trigger_Execution__c == true ){
				status = true;
			}
		}
		System.debug('isBypassTriggerExecution = ' +status );
		return status;
	}

}
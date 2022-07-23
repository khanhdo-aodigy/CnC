/** ******
 * Description: Person Account Profiling Business Logic Class
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * 20210622             khanh.do               Created Initial Version.
** ******/
public without sharing class PersonAccountProfilingBL {
    
    private final static Map<String,String> mapTypeNameToPicklistValues = new Map<String, String>{
                                        'CCL Person Account Profiling RT' => 'CCL',
                                        'CCS Person Account Profiling RT' => 'CCS',
                                        'MB Person Account Profiling RT' => 'MB' ,
                                        'E-Shop Person Account Profiling RT' => 'E-Shop' ,
                                        'RA Person Account Profiling RT' => 'RA'    
                                    }; //Map<Profiling RecordType Name => PiclistValue on Account >


    public static void deleteDupProfiles(List<Id> dupProfilingIds) {
        if(dupProfilingIds != null && dupProfilingIds.size() > 0) {
            List<Person_Account_Profiling__c> dupProfilings = [SELECT Id FROM Person_Account_Profiling__c WHERE Id IN :dupProfilingIds];
            System.debug('dupProfilings to remove ::' + dupProfilings.size());
            TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
            delete dupProfilings;
            TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', false);
        }

    }

    public static List<Id> preventDuplicateProfiling(String event, List<Person_Account_Profiling__c> profilingList){
        List<Id> dupProfilingIds = new List<Id>();        
        Set<Id> accIds = new Set<Id>();

        for(Person_Account_Profiling__c profiling: profilingList) {
            if(profiling.Account__c != null) {
                accIds.add(profiling.Account__c);
            }
        }

        List<Account> accList;
        if(accIds.size() > 0){
            accList = [ SELECT Id, (SELECT Id, RecordTypeId FROM Person_Account_Profilings__r)
                        FROM Account
                        WHERE Id IN :accIds
                       ];
        }

        Map<String, Set<String>> mapAccIdProfilingTypes = new Map<String, Set<String>>(); //Map<accId, Set<profileRecTypeId>>
        if(accList != null && accList.size() > 0) {
            for(Account acc: accList){
                Set<String> accProfilingIds = new Set<String>();
                for(Person_Account_Profiling__c profiling: acc.Person_Account_Profilings__r) {
                    accProfilingIds.add(profiling.RecordTypeId);
                }
                mapAccIdProfilingTypes.put(acc.Id, accProfilingIds);
            }
        }

        for(Person_Account_Profiling__c profiling: profilingList) {
            String accId = profiling.Account__c;
            if(mapAccIdProfilingTypes.containsKey(accId)) {
                if( mapAccIdProfilingTypes.get(accId).contains(profiling.RecordTypeId) ) { //if the Account alr had this profile type
                    dupProfilingIds.add(profiling.Id);
                    if(event.equalsIgnoreCase('insert')) {
                        profiling.addError('Profiling already exists for this Account');                        
                    }
                }
            }
        }
        return dupProfilingIds;
    }

    public static void updateAccounts(List<Person_Account_Profiling__c> profilingList){

        List<RecordType> profilingRTs = [SELECT Id, Name FROM RecordType WHERE SobjectType='Person_Account_Profiling__c'];
        Map<Id, String> profilingRecTypeMap = new Map<Id, String>();
        if(profilingRTs != null && profilingRTs.size() > 0) {
            for(RecordType recType: profilingRTs) {
                profilingRecTypeMap.put(recType.Id, recType.Name);
            }
        }        
        
        Map<Id, Set<String>> mapAccountProfileTypes = new Map<Id,Set<String>>(); //Map<AccountId, Set<picklistValues>>
        for(Person_Account_Profiling__c profiling: profilingList) {
            System.debug('profiling = ' + profiling);
            if(profiling.Account__c != null) {
                String recTypeName = profilingRecTypeMap.get(profiling.RecordTypeId);
                String picklistValue = mapTypeNameToPicklistValues.get(recTypeName);
                System.debug('picklistValue = ' + picklistValue);

                // This will take care of multiple Profilings being associated with one account
                if (!mapAccountProfileTypes.containsKey(profiling.Account__c)) {
                    mapAccountProfileTypes.put(profiling.Account__c, new Set<String>{picklistValue} );
                } else {
                    mapAccountProfileTypes.get(profiling.Account__c).add(picklistValue); //set contains unique values
                }
            }
        }
        System.debug('mapAccountProfileTypes = ' + mapAccountProfileTypes);

        List<Account> listAccToUpdate = [ SELECT Id, Person_Account_Profilings__pc
                                          FROM Account
                                          WHERE Id IN: mapAccountProfileTypes.keySet()
                                       ];
        System.debug('listAccToUpdate = ' + listAccToUpdate);

        for(Account acc: listAccToUpdate) {

            Set<String> profileTypes = mapAccountProfileTypes.get(acc.Id);
            if( String.isNotBlank(acc.Person_Account_Profilings__pc) ) {
                profileTypes.addAll(acc.Person_Account_Profilings__pc.split(';')); // Add existing profile types on account so that they are not lost.
            }
                
            List<String> profileTypesList = new List<String>(profileTypes); //set cannot use with String.join() => convert to List
            acc.Person_Account_Profilings__pc = String.join(profileTypesList, ';');
        }
        System.debug('listAccToUpdate = ' + listAccToUpdate);
        TriggerExclusion.excludeTrigger('Account', true);
        TriggerExclusion.excludeTrigger('Contact', true);
        update listAccToUpdate;
        TriggerExclusion.excludeTrigger('Account', false);        
        TriggerExclusion.excludeTrigger('Contact', false);
    } 
}
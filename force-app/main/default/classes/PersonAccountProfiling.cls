public without sharing class PersonAccountProfiling extends ADGLIB_SObjectDomain {

    public PersonAccountProfiling(List<Person_Account_Profiling__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new PersonAccountProfiling(sObjectList);
		}
	}

    public override void onBeforeInsert() {
        List<Person_Account_Profiling__c> profilingList = (List<Person_Account_Profiling__c>)Records;
        preventDuplicateProfiling('insert' , profilingList);
    }

    public override void onAfterInsert() {
        List<Person_Account_Profiling__c> profilingList = (List<Person_Account_Profiling__c>)Records;
        updateParentAccounts(profilingList);

    }

    private static List<Id> dupProfileIds = new List<Id>();
    public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
        List<Person_Account_Profiling__c> profilingList = (List<Person_Account_Profiling__c>)Records;
        dupProfileIds = preventDuplicateProfiling('update' , profilingList);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<Person_Account_Profiling__c> profilingList = (List<Person_Account_Profiling__c>)Records;
        updateParentAccounts(profilingList);        
        deleteDupProfiles(dupProfileIds);
    }

    public static List<Id> preventDuplicateProfiling(String event, List<Person_Account_Profiling__c> profilingList){        
        List<Id> dupProfilingIds = new List<Id>();        
        try{
            System.debug('profilingList ::' + profilingList.size() + ' :: ' + profilingList);
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
            System.debug('accList :: ' + accList);
            Map<String, Set<String>> mapAccIdProfilingTypes = new Map<String, Set<String>>(); //Map<accId, Set<profileRecTypeId>>
            if(accList != null && accList.size() > 0) {
                for(Account acc: accList){
                    Set<String> accProfilingIds = new Set<String>();
                    for(Person_Account_Profiling__c profiling: acc.Person_Account_Profilings__r) {
                        accProfilingIds.add(profiling.RecordTypeId);
                    }
                    System.debug('accId ::' + acc.Id +  ' ==> accProfilingIds :: ' + accProfilingIds);
                    mapAccIdProfilingTypes.put(acc.Id, accProfilingIds);
                }
            }
    
            for(Person_Account_Profiling__c profiling: profilingList) {
                System.debug('profiling :: ' + profiling);
                String accId = profiling.Account__c;
                if(mapAccIdProfilingTypes.containsKey(accId)) {
                    if( mapAccIdProfilingTypes.get(accId).contains(profiling.RecordTypeId) ) { //if the Account alr had this profile type
                        
                        System.debug('event ::' + event);
                        if(event.equalsIgnoreCase('insert')) {                        
                            profiling.Account__c.addError('Profiling already exists for this Account'); //prevent creation on insert                
                        } else if(event.equalsIgnoreCase('update')) {
                            dupProfilingIds.add(profiling.Id); //allow update then delete later
                        }
                    }
                }
            }
        } catch(Exception ex) {
            System.debug(ex);
            loggerDataPool.buildLogDataPool('PersonAccountProfiling', ex);
        }
        
        return dupProfilingIds;
    }

    public static void updateParentAccounts(List<Person_Account_Profiling__c> profilingList){

        Map<Id, String> profilingRecTypeMap = getProfilingRTMap();

        Set<Id> accIds = new Set<Id>();
        Map<Id, Set<String>> newProfilingsByAccId = new Map<Id,Set<String>>(); //Map<AccountId, Set<picklistValues>>
        for(Person_Account_Profiling__c profiling: profilingList) {
            
            String accId = profiling.Account__c;
            if(String.isNotBlank(accId)) {
                accIds.add(accId);
                String recTypeName = profilingRecTypeMap.get(profiling.RecordTypeId);
                String picklistValue = getCorrespondingPickVal(recTypeName);
                //This will take care of multiple Profilings being associated with one account
                if (!newProfilingsByAccId.containsKey( accId )) {
                    newProfilingsByAccId.put( accId , new Set<String>{picklistValue} );
                } else {
                    newProfilingsByAccId.get( accId ).add(picklistValue); //set contains unique values
                }
            }

            
        }

        if(accIds != null && accIds.size() > 0) {
            List<Account> listAccToUpdate = [ SELECT Id, Person_Account_Profilings__pc
                                          FROM Account
                                          WHERE Id IN :accIds
                                          ORDER BY Id
                                       ];
            System.debug('listAccToUpdate = ' + listAccToUpdate);

            for(Account acc: listAccToUpdate) {

                Set<String> profileTypes = newProfilingsByAccId.get(acc.Id);
                if( String.isNotBlank(acc.Person_Account_Profilings__pc) ) {
                    profileTypes.addAll(acc.Person_Account_Profilings__pc.split(';')); // Add existing profile types on account so that they are not lost.
                }
                            
                List<String> profileTypesList = new List<String>(profileTypes); //set cannot use with String.join() => convert to List
                acc.Person_Account_Profilings__pc = String.join(profileTypesList, ';');
            }
            
            System.debug('listAccToUpdate = ' + listAccToUpdate);
            TriggerExclusion.excludeTrigger('Account', true);
            update listAccToUpdate;
            TriggerExclusion.excludeTrigger('Account', false);
        }       
        
    } 

    private static Map<Id, String> getProfilingRTMap() {
        List<RecordType> profilingRTs = [ SELECT Id, Name, DeveloperName 
                                          FROM RecordType
                                          WHERE SobjectType='Person_Account_Profiling__c'
                                        ];

        Map<Id, String> profilingRecTypeMap = new Map<Id, String>();
        if(profilingRTs != null && profilingRTs.size() > 0) {
            for(RecordType recType: profilingRTs) {
                profilingRecTypeMap.put(recType.Id, recType.DeveloperName);
                System.debug(recType.Id + ' <=> ' +  recType.DeveloperName);
            }
        }
        return profilingRecTypeMap;
    }


    private static List<String> getPickListValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Person_Account_Profilings__pc.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
        System.debug(' pickListValuesList ' +  pickListValuesList);
        return pickListValuesList;
    }

    private static String getCorrespondingPickVal(String recTypeName){
        List<String> values = getPickListValues();
        for(String pickListValue: values) {
            if( recTypeName.contains(pickListValue) ) {
                System.debug('pickListValue :: ' + pickListValue);
                return pickListValue;
            }
        }
        return null;
    }

    public static void deleteDupProfiles(List<Id> dupProfilingIds) {
        if(dupProfilingIds != null && dupProfilingIds.size() > 0) {
            List<Person_Account_Profiling__c> dupProfilings = [SELECT Id FROM Person_Account_Profiling__c WHERE Id IN :dupProfilingIds];
            System.debug('dupProfilings to remove ::' + dupProfilings.size());
            TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', true);
            delete dupProfilings;
            TriggerExclusion.excludeTrigger('Person_Account_Profiling__c', false);
        }

    }

}
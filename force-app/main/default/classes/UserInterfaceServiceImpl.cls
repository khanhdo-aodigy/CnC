public with sharing class UserInterfaceServiceImpl {


    @AuraEnabled(cacheable=true)
    public static LIST< MAP<String, String>> getPickListValueOfObject(String objectName, String fieldAPIName){
        LIST< MAP<String, String>> options = new LIST< MAP<String, String>>();
        
        Schema.DescribeSObjectResult pickListSObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult picklistFieldResult = pickListSObjectResult.fields.getMap().get(fieldAPIName).getDescribe();

       List<Schema.PicklistEntry> ple = picklistFieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
           options.add(new map<String, String>{ 'label'=>f.getLabel(), 'value'=>f.getValue()});
             
       }     
        system.debug(options);
       return options;

    }


}
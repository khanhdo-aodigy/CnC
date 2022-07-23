global class UpdatePrefCarName implements Schedulable{

global void execute(SchedulableContext ctx)
{GetData();}


public static void GetData()            
{
    List<Registered_Vehicle__c> regVehList = [Select id, Preferred_Car_Name__c, Variant__r.Variant_Display_Name__c from Registered_Vehicle__c where Preferred_Car_Name__c = null LIMIT 10000];
    for(Registered_Vehicle__c regVeh : regVehList) {
        if(regVeh.Variant__r != null && regVeh.Variant__r.Variant_Display_Name__c != null) {
        regVeh.Preferred_Car_Name__c = regVeh.Variant__r.Variant_Display_Name__c;
        }
    }
    update regVehList;    
} 

}
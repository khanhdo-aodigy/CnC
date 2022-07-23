/** *****
 * Description : Selector Class for Used Car Vehicle Stock object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20210105             khanh.do@aodigy        Created Initial Version. 
 * 20210121				hung.huynh@aodigy	   added getVehicleStockMapByStockNumbers method
** *****/
public with sharing class UsedCarVehicleStockSelector extends ADGLIB_SObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return Used_Car_Vehicle_Stock__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Used_Car_Vehicle_Stock__c');
    }

    public List<Used_Car_Vehicle_Stock__c> getVehicleStockListByStockNumbers( Set<String> stockNumbers ){
        List<Used_Car_Vehicle_Stock__c> stockList = new List<Used_Car_Vehicle_Stock__c>();

        if( !stockNumbers.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Stock_Number__c IN :stockNumbers '; 
            query.setCondition( str_filter );
            stockList = Database.query( query.toSOQL() );
        }
        return stockList;
    }
    
    public Map<String, Used_Car_Vehicle_Stock__c> getVehicleStockMapByStockNumbers( Set<String> stockNumbers ){
        Map<String, Used_Car_Vehicle_Stock__c>  stockMap = new Map<String, Used_Car_Vehicle_Stock__c>();
        List<Used_Car_Vehicle_Stock__c>  stockList = new List<Used_Car_Vehicle_Stock__c>();

        if( !stockNumbers.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Stock_Number__c IN :stockNumbers '; 
            query.setCondition( str_filter );
            stockList = Database.query( query.toSOQL() );
            for(Used_Car_Vehicle_Stock__c car : stockList){
                stockMap.put(car.Stock_Number__c, car);
            }
        }
        return stockMap;
    }

}
/** *****
 * Description : Selector Class for Used Car Vehicle Sizing object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211013           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public class UsedCarVehicleSizingSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType() 
    {
        return Used_Car_Vehicle_Sizing__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Used_Car_Vehicle_Sizing__c');
    }

    public List<Used_Car_Vehicle_Sizing__c> selectUsedCarSizingsByNames(Set<String> names)
    {
        adglib_QueryFactory query = newQueryFactory();    
        query.setCondition('Name IN: names');

        return Database.query(query.toSOQL());
    }
}
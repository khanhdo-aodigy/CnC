/** *****
 * Description : Selector Class for MB Test Drive Daily Log object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211019           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public class MBTestDriveDailyLogSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType() 
    {
        return MB_Test_Drive_Daily_Log__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('MB_Test_Drive_Daily_Log__c');
    }

    public List<MB_Test_Drive_Daily_Log__c> selectMBTDDailyLogsByCreatedDateAndStatusAndVehicles (String queryDate, String status, Set<Id> courtesyVehIds,
                                                                                                  String dateComparator, String fieldOrdering, Boolean orderingDESC)
    {
        adglib_QueryFactory query = newQueryFactory();    
        String str_filter = '';
        
        if (String.isNotBlank(queryDate))
        {
            Date createdDate = Date.valueOf(queryDate);
            str_filter += ' DAY_ONLY(CreatedDate) ' + dateComparator + ' : createdDate ';
        }

        if (String.isNotBlank(status))
        {
            str_filter += String.isNotBlank(str_filter) ? ' AND Status__c =: status ' : ' Status__c =: status '; 
        }

        if (courtesyVehIds <> null && courtesyVehIds.size() > 0)
        {
            str_filter += String.isNotBlank(str_filter) ? ' AND Courtesy_Vehicle__c IN: courtesyVehIds ' : ' Courtesy_Vehicle__c IN: courtesyVehIds '; 
        }

        System.debug('@@@MBTestDriveDailyLogSelector Query : ' + str_filter);

        query.setCondition(str_filter);
        if (orderingDESC <> null)
        {
            if (orderingDESC)
            {
                query.setOrdering(fieldOrdering, ADGLIB_QueryFactory.SortOrder.DESCENDING);
            }
            else
            {
                query.setOrdering(fieldOrdering, ADGLIB_QueryFactory.SortOrder.ASCENDING);
            }
        }

        return Database.query(query.toSOQL());
    }
}
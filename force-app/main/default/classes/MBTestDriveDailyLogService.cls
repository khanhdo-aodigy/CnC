/** *****
 * Description : Service Class for MB Test Drive Daily Log object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211019           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public with sharing class MBTestDriveDailyLogService 
{
    private static MBTestDriveDailyLogSelector sel = new MBTestDriveDailyLogSelector();

    public static List<MB_Test_Drive_Daily_Log__c> getMBTDDailyLogsByCreatedDateAndStatusAndVehicles(String queryDate, String status, Set<Id> courtesyVehIds,
                                                                                                     String dateComparator, String fieldOrdering, Boolean orderingDESC)
    {
        return sel.selectMBTDDailyLogsByCreatedDateAndStatusAndVehicles(queryDate, status, courtesyVehIds, dateComparator, fieldOrdering, orderingDESC);
    }
}
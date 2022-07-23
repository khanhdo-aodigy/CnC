/** *****
 * Description : Service Class for Courtesy Vehicle object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211018           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public with sharing class CourtesyVehicleService 
{
    private static CourtesyVehicleSelector sel = new CourtesyVehicleSelector();

    public static List<Courtesy_Vehicle__c> getCourtesyVehiclesByStatusAndBranchCode(String recordType, String status, String branchCode, String franchiseCode)
    {
        return sel.selectCourtesyVehiclesByStatusAndBranchCode(recordType, status, branchCode, franchiseCode);
    }
}
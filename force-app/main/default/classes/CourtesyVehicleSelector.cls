/** *****
 * Description : Selector Class for Courtesy Vehicle object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                   Description
 * 20211018           TPhan@aodigy        Created Initial Version. 
 * ** *****/

public class CourtesyVehicleSelector extends ADGLIB_SObjectSelector
{
    public Schema.SObjectType getSObjectType() 
    {
        return Courtesy_Vehicle__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Courtesy_Vehicle__c');
    }

    public List<Courtesy_Vehicle__c> selectCourtesyVehiclesByStatusAndBranchCode(String recordType, String status, String branchCode, String franchiseCode)
    {     
        adglib_QueryFactory query = newQueryFactory();    
        String str_filter = '';
        
        if (String.isNotBlank(recordType))
        {
            if (Schema.SObjectType.Courtesy_Vehicle__c.getRecordTypeInfosByDeveloperName().containsKey(recordType))
            {
                ID recordTypeId = Schema.SObjectType.Courtesy_Vehicle__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
                str_filter += ' RecordTypeId =: recordTypeId '; 
            }     
        }

        if (String.isNotBlank(status))
        {
            str_filter += String.isNotBlank(str_filter) ? ' AND Status__c =: status ' : ' Status__c =: status '; 
        }

        if (String.isNotBlank(branchCode))
        {
            str_filter += String.isNotBlank(str_filter) ? ' AND Branch_Code__c =: branchCode ' : ' Branch_Code__c =: branchCode ';
        }

        if (String.isNotBlank(franchiseCode))
        {
            str_filter += String.isNotBlank(str_filter) ? ' AND Franchise_Code__c =: franchiseCode ' : ' Franchise_Code__c =: franchiseCode ';
        }

        System.debug('@@@CourtesyVehicleSelector Query : ' + str_filter);

        query.setCondition(str_filter);

        return Database.query(query.toSOQL());
    }
}
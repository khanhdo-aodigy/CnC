/** *****
 * Description : Selector Class for Vehicle Request object
 * 
 * Change History
 * Date(YYYYMMDD)     Name                           Description
 * 20211020           thieudang.vu@aodigy.com        Created Initial Version. 
 * ** *****/
public without sharing class VehicleRequestSelector extends ADGLIB_SObjectSelector 
{
    public Schema.SObjectType getSObjectType() 
    {
        return Vehicle_Request__c.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return new List<Schema.SObjectField> {
            Vehicle_Request__c.Id,
            Vehicle_Request__c.Name,
            Vehicle_Request__c.Branch_Code__c,
            Vehicle_Request__c.Franchise_Code__c,
            Vehicle_Request__c.Test_Drive_Type__c,
            Vehicle_Request__c.Status__c,
            Vehicle_Request__c.Check_Out__c,
            Vehicle_Request__c.Check_In__c,
            Vehicle_Request__c.Remarks__c,
            Vehicle_Request__c.PDPA_Agreed__c,
            Vehicle_Request__c.Courtesy_Vehicle__c,
            Vehicle_Request__c.Current_Own_Car__c,
            Vehicle_Request__c.Current_Own_Car_Registration_No__c,
            Vehicle_Request__c.Year_of_Ownership__c,
            Vehicle_Request__c.Customer_Signature__c,
            Vehicle_Request__c.Sales_Rep_Mobile__c,
            Vehicle_Request__c.CreatedDate
		};
    }

    public List<Vehicle_Request__c> selectById(Id requestId)
    {
        adglib_QueryFactory query = newQueryFactory();
        query.selectFields(new Set<String>{'Owner.Name', 'Courtesy_Vehicle__r.Name', 'Account__r.Full_Name__pc', 'Account__r.PersonMobilePhone', 
                                            'Account__r.PersonEmail', 'Account__r.FirstName', 'Account__r.LastName', 'Account__r.Unit_No_Floor__pc',
                                            'Account__r.Address_Line_1__pc', 'Account__r.Address_Line_2__pc', 'Account__r.Address_Line_3__pc', 'Account__r.Address_Line_4__pc',
                                            'Account__r.Unit_No_Floor__pc', 'Account__r.Country__pc', 'Account__r.PersonBirthdate','Account__r.NRIC__pc'});
        query.setCondition('Id = :requestId');

        return Database.query(query.toSOQL());
    }

    public List<Vehicle_Request__c> selectTodayReqsByConditions(Set<Id> vehicleIds, Id ownerId, Id paId, String status, String type, String branchCode, String franchiseCode,
                                                                   String recordType, String moreCondition, String fieldOrdering, Boolean orderingDESC, Boolean limitOne)
    {
        Date today = Date.valueOf(String.valueOfGmt(Date.today()));

        adglib_QueryFactory query = newQueryFactory();
        query.selectFields(new Set<String>{'Courtesy_Vehicle__r.Name', 'Owner.Name'});

        String str_filter = '';
        if (vehicleIds <> null && vehicleIds.size() > 0)
        {
            str_filter += 'Courtesy_Vehicle__c IN :vehicleIds AND ';
        }

        if (String.isNotBlank(ownerId))
        {
            str_filter += 'OwnerId = :ownerId AND ';
        }

        if (String.isNotBlank(paId))
        {
            str_filter += 'Account__c = :paId AND ';
        }

        if (String.isNotBlank(status))
        {
            str_filter += 'Status__c = :status AND ';
        }

        if (String.isNotBlank(type))
        {
            str_filter += 'Test_Drive_Type__c = :type AND ';
        }

        if (String.isNotBlank(branchCode))
        {
            str_filter += 'Branch_Code__c = :branchCode AND ';
        }

        if (String.isNotBlank(franchiseCode))
        {
            str_filter += 'Franchise_Code__c = :franchiseCode AND ';
        }

        if (String.isNotBlank(recordType))
        {
            str_filter += 'RecordType.Name = :recordType AND ';
        }

        if (String.isNotBlank(moreCondition))
        {
            str_filter += moreCondition + ' AND ';
        }

        str_filter += 'DAY_ONLY(CreatedDate) = :today';
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

        if (limitOne) query.setLimit(1);

        return Database.query(query.toSOQL());
    }
}
/** *****
 * Description : Selector class for Used Car Quote object
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20220524             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
public with sharing class UsedCarQuoteSelector extends ADGLIB_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Used_Car_Quote__c.Id,
            Used_Car_Quote__c.Name,
            Used_Car_Quote__c.Status__c,
            Used_Car_Quote__c.recordTypeId,
            //Customer Details
            Used_Car_Quote__c.Customer_ID_Type__c,
            Used_Car_Quote__c.Customer_NRIC__c,
            //Vehicle Details
            Used_Car_Quote__c.Vehicle_No__c,
            Used_Car_Quote__c.Vehicle_to_be_Exported__c,
            Used_Car_Quote__c.Intended_Deregistration_Date__c,
            Used_Car_Quote__c.Vehicle_Make__c,
            Used_Car_Quote__c.Vehicle_Model__c,
            Used_Car_Quote__c.Primary_Color__c,
            Used_Car_Quote__c.Manufacturing_Year__c,
            Used_Car_Quote__c.Engine_No__c,
            Used_Car_Quote__c.Chassis_No__c,
            Used_Car_Quote__c.Maximum_Power_Output__c,
            Used_Car_Quote__c.Open_Market_Value__c,
            Used_Car_Quote__c.Original_Registration_Date__c,
            Used_Car_Quote__c.First_Registration_Date__c,
            Used_Car_Quote__c.Transfer_Count__c,
            Used_Car_Quote__c.Actual_ARF_Paid__c,
            Used_Car_Quote__c.PARF_Eligibility__c,
            Used_Car_Quote__c.PARF_Eligibility_Expiry_Date__c,
            Used_Car_Quote__c.PARF_Rebate_Amount__c,
            Used_Car_Quote__c.COE_Expiry_Date__c,
            Used_Car_Quote__c.COE_Category__c,
            Used_Car_Quote__c.COE_Period_Years__c,
            Used_Car_Quote__c.QP_Paid__c,
            Used_Car_Quote__c.COE_Rebate_Amount__c,
            Used_Car_Quote__c.Total_Rebate_Amount__c,
            Used_Car_Quote__c.OPC_Cash_Rebate_Eligibility__c,
            Used_Car_Quote__c.OPC_Cash_Rebate_Eligibility_Expiry_Date__c,
            Used_Car_Quote__c.OPC_Cash_Rebate_Amount__c,
            Used_Car_Quote__c.Mileage__c,
            Used_Car_Quote__c.Sales_Consultant__c,

            //Machine Details
            Used_Car_Quote__c.Machine_Quote__c,
            Used_Car_Quote__c.Machine_Depreciation__c,
            Used_Car_Quote__c.Machine_Error__c,
            //Transaction Details
            Used_Car_Quote__c.Purchase_Price__c,
            Used_Car_Quote__c.Purchase_Date__c,
            Used_Car_Quote__c.Car_Handover_Date__c,
            Used_Car_Quote__c.Doc_No__c
		};

    }

    public Schema.SObjectType getSObjectType() {
        return Used_Car_Quote__c.sObjectType;
    }

    public List<Used_Car_Quote__c> getQuotesBySetIds(Set<Id> setQuoteIds){
        List<Used_Car_Quote__c> quotes = new List<Used_Car_Quote__c>();

        if( !setQuoteIds.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String filter = ' Id IN: setQuoteIds ';
            query.setCondition( filter )
                 .selectFields(new Set<String>{ 'Owner.Name', 'Sales_Consultant__r.Name'});
        
            quotes = Database.query( query.toSOQL() );
        }
        return quotes;
    }

    public List<Used_Car_Quote__c> getOpenQuotesByChassisNoAndVehicleNo(String chassisNo, String vehicleNo, String additionalConditions){
        List<Used_Car_Quote__c> quotes = new List<Used_Car_Quote__c>();

        if( String.isNotBlank(chassisNo) && String.isNotBlank(vehicleNo) ) {
            adglib_QueryFactory query = newQueryFactory();    
            String filter = ' Status__c = \'Open\' AND Chassis_No__c =: chassisNo AND Vehicle_No__c =: vehicleNo ';
            if(String.isNotBlank(additionalConditions)) {
                filter += additionalConditions;
            }
            query.setCondition( filter );
            quotes = Database.query( query.toSOQL() );
        }
        return quotes;
    }

}
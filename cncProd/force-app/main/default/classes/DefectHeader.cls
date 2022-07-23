public with sharing class DefectHeader extends ADGLIB_SObjectDomain {
    public DefectHeader(List<Defect_Header__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new DefectHeader(sObjectList);
		}
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        List<Defect_Header__c> changedDHs = new List<Defect_Header__c>();
        for (Defect_Header__c dh : (List<Defect_Header__c>)records) {
            Defect_Header__c oldRecord = (Defect_Header__c)existingRecords.get(dh.Id);
            if (dh.Rectified_Date_Time__c == null) {
                dh.Time_taken_to_rectify__c = 0;
            } else if (dh.Rectified_Date_Time__c != oldRecord.Rectified_Date_Time__c) {
                dh.Time_taken_to_rectify__c = (BusinessHoursUtility.GetBusinessHrs(dh.CreatedDate, dh.Rectified_Date_Time__c) / 3600000);
            }
            if (dh.Customer_Acknowledgement_Date__c != null && 
                (dh.Customer_Acknowledgement_Date__c != oldRecord.Customer_Acknowledgement_Date__c)) {
                dh.SLA_Hours__c = (BusinessHoursUtility.GetBusinessHrs(dh.CreatedDate, dh.Customer_Acknowledgement_Date__c) / 3600000);
            }
        }
    }
}
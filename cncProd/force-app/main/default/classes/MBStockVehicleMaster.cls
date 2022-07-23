public with sharing class MBStockVehicleMaster extends ADGLIB_SObjectDomain {
    public MBStockVehicleMaster(List<MB_Stock_Vehicle_Master__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new MBStockVehicleMaster(sObjectList);
		}
    }

    public override void onBeforeInsert() {
        populateVariantDescription((List<MB_Stock_Vehicle_Master__c>)records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        checkDuplicateWHParkingLot(existingRecords);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        populateVehicleMovement (existingRecords);
    }

    private void populateVariantDescription(List<MB_Stock_Vehicle_Master__c> mbSVMs) {
        Set<Id> variantIds = new Set<Id>();
        for (MB_Stock_Vehicle_Master__c svm : mbSVMs) {
            variantIds.add(svm.Variant__c);
        }
        Map<Id, Variant__c> variants = new Map<Id, Variant__c>([SELECT Id, Description__c
                                                                FROM Variant__c
                                                                WHERE Id in :variantIds]);
        
        for (MB_Stock_Vehicle_Master__c svm : (List<MB_Stock_Vehicle_Master__c>)records) {
            if (!String.isBlank(svm.Variant__c)) {
                String description = variants.get(svm.Variant__c).Description__c;
                svm.VariantDescription__c = description;
            }      
        }
    }

    private void checkDuplicateWHParkingLot(Map<Id, SObject> existingRecords) {
        Map<String, MB_Stock_Vehicle_Master__c> mbSVMByWHParkingLotIds = new Map<String, MB_Stock_Vehicle_Master__c>();
        for (MB_Stock_Vehicle_Master__c svm : (List<MB_Stock_Vehicle_Master__c>)records) {
            MB_Stock_Vehicle_Master__c oldRecord = (MB_Stock_Vehicle_Master__c)existingRecords.get(svm.Id);
            if (svm.Warehouse_Parking_Lot__c != oldRecord.Warehouse_Parking_Lot__c && !String.isBlank(svm.Warehouse_Parking_Lot__c)) {
                if (mbSVMByWHParkingLotIds.containsKey(svm.Warehouse_Parking_Lot__c)) {
                    svm.addError('Many Stock Vehicle Masters being assigned to the same Warehouse Parking Lot. Please check again!');
                }  else {
                    mbSVMByWHParkingLotIds.put(svm.Warehouse_Parking_Lot__c, svm);
                }
            }
            // If Duty Payment Date is filled
            // Then set Warehouse Parking Lot lookup field to NULL
            if (svm.Duty_Payment_Date__c != oldRecord.Duty_Payment_Date__c && svm.Duty_Payment_Date__c != null) {
                svm.Warehouse_Parking_Lot__c = null;
            }
        }
    
        if (!mbSVMByWHParkingLotIds.isEmpty()) {
            WHParkingLotService.checkDuplicateWHParkingLot(mbSVMByWHParkingLotIds, null);
        }
    }

    // Added on 24/09/2021 to update Vehicle Movement Completed checkbox on MB Sales Agreement when related MB Stock Vehicle Master's Vehicle Movement Location field is updated to 'NCC-QCOK'
    private void populateVehicleMovement (Map<Id,SObject> existingRecords)
    {
        Delivery_Bay_Configuration__c DBConfig = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        String location = '';
        if(DBConfig != null){
            location = DBConfig.Location_QC_Complete__c;
        }
        if(String.isNotBlank(location)){

            Set<Id> MBStockVehicleMasters = new Set<Id>();

            for (MB_Stock_Vehicle_Master__c MBSvm : (List<MB_Stock_Vehicle_Master__c>)Records)
            {
                MB_Stock_Vehicle_Master__c oldMBSvm = (MB_Stock_Vehicle_Master__c)existingRecords.get(MBSvm.Id);
                if(oldMBSvm.Vehicle_Movement_Location__c != MBSvm.Vehicle_Movement_Location__c && MBSvm.Vehicle_Movement_Location__c == location){
                    MBStockVehicleMasters.add(MBSvm.Id);
                }
            }   
            MB_Sales_Agreement__c[] relatedMBSA = [SELECT Id, Vehicle_Movement_Completed__c 
                                                FROM MB_Sales_Agreement__c 
                                                WHERE Status__c != 'Cancelled' 
                                                AND MB_Stock_Vehicle_Master__r.Id IN :MBStockVehicleMasters
                                                ];
            
            if (!relatedMBSA.isEmpty())
            {
                for(MB_Sales_Agreement__c curr : relatedMBSA)
                {
                    curr.Vehicle_Movement_Completed__c = true;
                }
                update relatedMBSA;
            }
        }   
    }   
}
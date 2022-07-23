public inherited sharing class MBSalesAgreement extends ADGLIB_SObjectDomain {
    // public static List<String> DebugLogsListSuccess   = new List<String>();
    // public static List<String> DebugLogsListError     = new List<String>();
    public static final List<String> TARGET_FILE_DESCRIPTION = new List<String>{'Release Letter - F&I','NRIC/FIN (front) - SE','NRIC/FIN (back) - SE',
                                                                                'Driving License (front) - SE','Driving License (back) - SE'};

    public MBSalesAgreement(List<MB_Sales_Agreement__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new MBSalesAgreement(sObjectList);
		}
	}

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        for (MB_Sales_Agreement__c record : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldRecord = (MB_Sales_Agreement__c)existingRecords.get(record.Id);
            /** Will be deloyed after COE Management go live -- BEGIN */
            // if (record.COE__c != oldRecord.COE__c) {
            //     record.COE_Unique_ID__c = record.COE__c;
            // }
            /** Will be deloyed after COE Management go live -- END */

            /* -------- MODIFIED BY THIEU DANG VU - Sep 14th Nov 2021 - MB CR - START --------*/
            if (record.Deposit_Collected__c != oldRecord.Deposit_Collected__c && record.Deposit_Collected__c) {
                record.Deposit_Collected_Timestamp__c = System.now();
            }
            /* -------- MODIFIED BY THIEU DANG VU - Sep 14th Nov 2021 - MB CR - END --------*/
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        // Added on 08/03/2021
        // If there's a change on COE lookup field
        // Then find correposding COE to update to be de-linked to MBSA
        // updateCOEToMBSA(existingRecords);

        //Added on 13/07/2021 - DeliveryBay [Thang]
        updateDeliveryBayBooking(existingRecords);
        sendEmailForBookingDeliveryBaySlot(existingRecords);
        createVehicleMovementTracker(existingRecords); //Added on 24/08/2021

        //Added on 30/07/2021 [Vu] - Convert Prospect PA to Customer when Car Collected
        convertPA(existingRecords);

        //Added on 23/09/2021 [Vu] - Process Stock when SA is Cancelled
        processCancelledSA(existingRecords);

        //Added on 30/03/2022 [Vu] - Delete sensitive documents when SA is Cancelled/Car Collected
        deleteSensitiveDocs(existingRecords);
    }

    /**
     * This method to update corresponding COE to be de-linked back to MBSA
     * Will be deployed after COE Management go live
     */
    /* private void updateCOEToMBSA(Map<Id, sObject> existingRecords) {
        Map<Id, String> changedMBSAByCOEId = new Map<Id, String>();
        for (MB_Sales_Agreement__c sa : (List<MB_Sales_Agreement__c>)Records) {
            if (existingRecords.get(sa.Id).get('COE__c') != sa.COE__c) {
                changedMBSAByCOEId.put(sa.Id, sa.COE__c);
            }
        }

        if (changedMBSAByCOEId.isEmpty()) {
            return;
        }

        Map<Id, COE__c> coeById =  new Map<Id, COE__c>([SELECT Id, MB_Sales_Agreement__c
                                                        FROM COE__c
                                                        WHERE Id IN :changedMBSAByCOEId.values()]);

        Map<Id, MB_Sales_Agreement__c> mbSAs = new Map<Id, MB_Sales_Agreement__c>((List<MB_Sales_Agreement__c>)Records);
        for (Id mbSAId : changedMBSAByCOEId.keySet()) {
            MB_Sales_Agreement__c mbSA = mbSAs.get(mbSAId);
            COE__c coe = coeById.get(mbSA.COE__c);
            if (coe != null) {
                coe.MB_Sales_Agreement__c = mbSA.Id;
            }
        }

        Database.SaveResult[] srList = Database.update(coeById.values(), false);
        for (Integer i = 0; i < srList.size(); i++) {
            Id mbSAId = coeById.values().get(i).MB_Sales_Agreement__c;
            if (!srList[i].isSuccess()) {
                MB_Sales_Agreement__c mbSA = mbSAs.get(mbSAId);
                String errorMsg = '';
                for (Database.Error err : srList[i].getErrors()) {
                    errorMsg += err.getMessage();
                    mbSA.addError(errorMsg);
                }
                // mbSA.addError('Current COE has been linked to this MB Sales Agreement. Please remove MB Sales Agreement from current COE and update again!');
            }
        }
    } */


    /**
    * This method to update DeliveryBayBooking when stage = 'Car Collected'
    */
    private void updateDeliveryBayBooking(Map<Id, SObject> existingRecords){  
        Set<Id> mbSalesAgreements = new Set<Id>();
        for (MB_Sales_Agreement__c mbSalesAgreement : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldMBSalesAgreement = (MB_Sales_Agreement__c)existingRecords.get(mbSalesAgreement.Id);
                if (mbSalesAgreement.Status__c  != oldMBSalesAgreement.Status__c  && mbSalesAgreement.Status__c  == 'Car Collected') {  
					mbSalesAgreements.add(mbSalesAgreement.Id);
                }
        }

        if (mbSalesAgreements.size() > 0) { // ADDED BY THIEU DANG VU - To reduce SOQL queries
            List<Delivery_Bay_Booking__c > dbbs = [Select Id, Status__c, MB_Sales_Agreement__c from Delivery_Bay_Booking__c where MB_Sales_Agreement__c IN: mbSalesAgreements And Status__c ='Booked'];
            for (Delivery_Bay_Booking__c dbb: dbbs) {
                dbb.Status__c = 'Completed';
            }
            if (!dbbs.isEmpty()) {
                update dbbs;
            }
        }
    }

    /**
    * This method to create Vehicle Movement Tracker when stage = 'Car Collected'
    */
    private void createVehicleMovementTracker(Map<Id, SObject> existingRecords){  
        Set<Id> vehicleMasters = new Set<Id>();
        for (MB_Sales_Agreement__c mbSalesAgreement : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldMBSalesAgreement = (MB_Sales_Agreement__c)existingRecords.get(mbSalesAgreement.Id);
            if (mbSalesAgreement.Status__c  != oldMBSalesAgreement.Status__c  && mbSalesAgreement.Status__c  == 'Car Collected') {
                vehicleMasters.add(mbSalesAgreement.MB_Stock_Vehicle_Master__c);
            }
        }

        Delivery_Bay_Configuration__c dbbCf = Delivery_Bay_Configuration__c.getOrgDefaults();
        //get Location Delivery Complete from Custom Setting
        String nameLocation = '';
        if (dbbCf != Null){
            nameLocation = dbbCf.Location_Delivery_Complete__c;
        }
        if (String.isNotBlank(nameLocation) && !vehicleMasters.isEmpty()){
            List<Location__c> locations = [SELECT ID FROM Location__c Where Name = :nameLocation LIMIT 1];
            List<Vehicle_Movement_Tracker__c> vehicleMovementTrackers = new List<Vehicle_Movement_Tracker__c>();
            if (!locations.isEmpty()) {
                for (Id vehicleMasterId: vehicleMasters){
                    Vehicle_Movement_Tracker__c vmt = new Vehicle_Movement_Tracker__c(MB_Stock_Vehicle_Master__c = vehicleMasterId, Location__c = locations[0].Id, Action_Taken_Time__c = System.now());
                    vehicleMovementTrackers.add(vmt);
                }
                if (!vehicleMovementTrackers.isEmpty()) {
                    insert vehicleMovementTrackers;
                }
            }
        }
    }
    
    /**
    * This method to send email to book DeliveryBay when stage = 'Ready for Delivery'
    */
    private void sendEmailForBookingDeliveryBaySlot(Map<Id, SObject> existingRecords){  
        Set<Id> mbSalesAgreements = new Set<Id>();
        for(MB_Sales_Agreement__c mbSalesAgreement : (List<MB_Sales_Agreement__c>)Records) {  
            MB_Sales_Agreement__c oldMBSalesAgreement = (MB_Sales_Agreement__c)existingRecords.get(mbSalesAgreement.Id);
                if(mbSalesAgreement.Status__c  != oldMBSalesAgreement.Status__c  && mbSalesAgreement.Status__c  == 'Ready for Delivery' && mBSalesAgreement.Vehicle_Movement_Completed__c == true ||
                (mbSalesAgreement.Status__c == 'Ready for Delivery' && mbSalesAgreement.Vehicle_Movement_Completed__c == true && mbSalesAgreement.Vehicle_Movement_Completed__c != oldMBSalesAgreement.Vehicle_Movement_Completed__c)){  
					mbSalesAgreements.add(mbSalesAgreement.Id);
                }
        }

        if (mbSalesAgreements.size() == 0) return; // ADDED BY THIEU DANG VU - To reduce SOQL queries

        try {
            DeliveryBayBookings.sendingEmailForBookingNewSlot(null, mbSalesAgreements);
        } catch (EmailException e) {
            loggerDataPool.buildLogDataPool('MBSalesAgreement.sendEmailForBookingDeliveryBaySlot', e);
        }
    }

    /**
     * Method to convert Prospect PA to Customer PA when Car Collected
     */
    private void convertPA(Map<Id, SObject> existingRecords) {
        Id prosRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        Set<Id> paIds = new Set<Id>();
        for (MB_Sales_Agreement__c mbSA : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldMBSA = (MB_Sales_Agreement__c)existingRecords.get(mbSA.Id);
            if (mbSA.Status__c  != oldMBSA.Status__c  && mbSA.Status__c  == 'Allocated' && String.isNotBlank(mbSA.Account__c)) {
                paIds.add(mbSA.Account__c);
            }
        }

        if (paIds.size() == 0) return;

        // Get PA
        List<Account> pas = [ SELECT Id, PersonEmail, RecordTypeId, Type__pc
                              FROM Account 
                              WHERE IsPersonAccount = true 
                              AND Id IN :paIds ];
        for (Account pa : pas) {
            if (pa.RecordTypeId != prosRecTypeId) continue;

            pa.RecordTypeId = custRecTypeId;
            pa.Type__pc = 'Customer';
        }

        System.debug('-------- Begin Update PA --------- ' + pas);
        TriggerExclusion.excludeTrigger('Account', true);
        Database.update(pas, false);
        System.debug('-------- End Update PA --------- ');
    }

    /**
     * Method to update status of Stock after SA is Cancelled
     * If Processed_by_Sales_Admin__c = TRUE => Status = 'Pending'
     * Else Status = 'Open'
     */
    private void processCancelledSA(Map<Id, SObject> existingRecords) {
        Set<Id> mbSVMIds = new Set<Id>();
        for (MB_Sales_Agreement__c mbSA : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldMBSA = (MB_Sales_Agreement__c)existingRecords.get(mbSA.Id);
            if (mbSA.Status__c  != oldMBSA.Status__c  && mbSA.Status__c  == 'Cancelled') {  
                mbSVMIds.add(mbSA.MB_Stock_Vehicle_Master__c);
            }
        }

        if (mbSVMIds.size() == 0) return;

        Map<Id, MB_Stock_Vehicle_Master__c> mbSVMs = new Map<Id, MB_Stock_Vehicle_Master__c>([SELECT Id, Status__c FROM MB_Stock_Vehicle_Master__c WHERE Id IN :mbSVMIds]);

        for (MB_Sales_Agreement__c mbSA : (List<MB_Sales_Agreement__c>)Records) {
            MB_Stock_Vehicle_Master__c mbSVM = mbSVMs.get(mbSA.MB_Stock_Vehicle_Master__c);
            if (mbSVM.Status__c != 'Reserved') continue;

            mbSVM.Status__c = mbSA.Processed_by_Sales_Admin__c ? 'Pending' : 'Open';
        }

        Database.update(mbSVMs.values(), false);
    }

    /**
     * Method to delete sensitive document when SA is at 'Cancelled' or 'Car Collected'
     */
    private void deleteSensitiveDocs(Map<Id, sObject> existingRecords) {
        List<Id> mbSAIds = new List<Id>();
        for (MB_Sales_Agreement__c mbSA : (List<MB_Sales_Agreement__c>)Records) {
            MB_Sales_Agreement__c oldMBSA = (MB_Sales_Agreement__c)existingRecords.get(mbSA.Id);
            if (mbSA.Status__c  != oldMBSA.Status__c  && (mbSA.Status__c  == 'Cancelled' || mbSA.Status__c == 'Car Collected')) {
                mbSAIds.add(mbSA.Id);
            }
        }

        if (mbSAIds.size() == 0) return;

        AttachmentService.deleteFiles(mbSAIds, TARGET_FILE_DESCRIPTION);
    }
}
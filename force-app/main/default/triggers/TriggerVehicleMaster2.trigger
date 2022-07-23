/** ******
 * Description: Trigger for Vehicle_Master2__c
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                 Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion check
 * 20210924            kautham & Thang      Added trigger for Vehicle Movement Location field change on Stock Vehicle Master
** ******/
trigger TriggerVehicleMaster2 on Vehicle_Master2__c (before insert, before update, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Vehicle_Master2__c') 
        || TriggerExclusion.isBypassTriggerExecution('Vehicle_Master2__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }

    //ProductionMonth is a date, need to update Production_Month(string) with format MM/YYYY
    if(Trigger.IsBefore && Trigger.IsInsert) {
        for(Vehicle_Master2__c fVM: Trigger.New) {
            Date dd = fVM.ProductionMonth__c;
            String ss = '';
            ss = ((dd.Month()<10) ? '0'+String.ValueOf(dd.Month()) : String.ValueOf(dd.Month()));
            ss = ss + '/' + String.ValueOf(dd.Year());
            fVM.Production_Month__c = ss;
        }
    } else if(Trigger.IsBefore && Trigger.IsUpdate) {
        Map<String, Vehicle_Master2__c> mfSVMByWHParkingLotIds = new Map<String, Vehicle_Master2__c>();
        for(Vehicle_Master2__c fVM: Trigger.New) {
            if(fVM.ProductionMonth__c <> Trigger.OldMap.get(fVM.Id).ProductionMonth__c) {
                Date dd = fVM.ProductionMonth__c;
                String ss = '';
                ss = ((dd.Month()<10) ? '0'+String.ValueOf(dd.Month()) : String.ValueOf(dd.Month()));
                ss = ss + '/' + String.ValueOf(dd.Year());
                fVM.Production_Month__c = ss;
            }
            if (fVM.Warehouse_Parking_Lot__c <> Trigger.OldMap.get(fVM.Id).Warehouse_Parking_Lot__c && !String.isBlank(fVM.Warehouse_Parking_Lot__c)) {
                if (mfSVMByWHParkingLotIds.containsKey(fVM.Warehouse_Parking_Lot__c)) {
                    fVM.addError('Many Stock Vehicle Masters being assigned to the same Warehouse Parking Lot. Please check again!');
                } else {
                    mfSVMByWHParkingLotIds.put(fVM.Warehouse_Parking_Lot__c, fVM);
                }
            }

            // Added on May 2020: make callout updating vehicle condition in VSMS
            string afterCondition = fVM.Vehicle_Condition__c;
            string beforeCondition = Trigger.oldMap.get(fVM.ID).Vehicle_Condition__c;

            integer afterMileage = (integer) fVM.Mileage__c;
            integer beforeMileage = (integer) Trigger.oldMap.get(fVM.ID).Mileage__c;

            string afterLocation = fVM.Location__c;
            string beforeLocation = Trigger.oldMap.get(fVM.ID).Location__c;

            string VEM_CCNO = fVM.System_Commcase__c;

            if (beforeCondition != afterCondition || beforeMileage != afterMileage || beforeLocation != afterLocation) {
                VSMS_VDCUpdate.updateVehicleCondition(VEM_CCNO, afterCondition, afterMileage, afterLocation);
            }
        }
        // ADDED ON 15/04/2021 - To check duplicate Warehouse Parking Lot on Stock Vehicle Master
        if (!mfSVMByWHParkingLotIds.isEmpty()) {
            WHParkingLotService.checkDuplicateWHParkingLot(null, mfSVMByWHParkingLotIds);
        }
    }
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        Delivery_Bay_Configuration__c DBConfig = Delivery_Bay_Configuration__c.getValues('Delivery Bay Booking Config');
        String location = '';
        if(DBConfig != null){
            location = DBConfig.Location_QC_Complete__c;
        }
        if(String.isNotBlank(location)){
            Set<Id> vehicleMasters = new Set<Id>();

            for(Vehicle_Master2__c vm: Trigger.new){
                Vehicle_Master2__c oldVM = (Vehicle_Master2__c) Trigger.oldMap.get(vm.id);
                if(oldVM.Vehicle_Movement_Location__c != vm.Vehicle_Movement_Location__c && vm.Vehicle_Movement_Location__c == location){
                    vehicleMasters.add(vm.Id);
                }
            }

            Sales_Agreement__c[] relatedSA = [SELECT id, Vehicle_Movement_Completed__c from Sales_Agreement__c WHERE Stock_Reservation__r.Vehicle_Master__c IN: vehicleMasters AND stage__c != 'Cancelled'];
            if(!relatedSA.isEmpty()){
                for(Sales_Agreement__c curr : relatedSA){
                    curr.Vehicle_Movement_Completed__c = true;
                }
                update relatedSA;
            }
        }
    }
}
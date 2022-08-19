/** ******
 * Description: Trigger for Vehicle_Master2__c
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                 Description
 * YYYYMMDD            C&C                  Created Initial Version.
 * 20210706            khanh.do             Added trigger exclusion check
 * 20210924            kautham & Thang      Added trigger for Vehicle Movement Location field change on Stock Vehicle Master
 * 22020726            Thanh Ly             Added After Update Trigger when populating Duty Payment Date by SA
** ******/
trigger TriggerVehicleMaster2 on Vehicle_Master2__c (before insert, before update, after update) {
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Vehicle_Master2__c') 
        || TriggerExclusion.isBypassTriggerExecution('Vehicle_Master2__c')
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    // ProductionMonth is a date, need to update Production_Month(string) with format MM/YYYY
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

         // Added 27/07/2022 [Thanh] - Send Email when Duty Payment Date is updated
         try{
            List<Profile> editProfiles = [SELECT Id FROM Profile WHERE Name = 'KIAPC Sales Admin' OR Name = 'CITPC Marketing'];
            List<Id> editProfileIds = new List<Id>();
            for (Profile editProfile : editProfiles){
                editProfileIds.add(editProfile.Id);
            }
            
            List<User> users = [SELECT Id, Name FROM User WHERE ProfileId IN :editProfileIds AND isActive = true];
            Map<Id, User> userMap = new Map<Id, User>();
            if (users.size() > 0){
                for (User user : users){
                    userMap.put(user.Id, user);
                }
            }
            
            List<Messaging.SingleEmailmessage> mails = new List<Messaging.SingleEmailmessage>();
            Profile mailReceiverProfile = [SELECT Id FROM Profile WHERE Name = 'New Car Logistic']; 
            List<User> mailReceivers = [SELECT Id, Email FROM User WHERE ProfileId = :mailReceiverProfile.Id AND isActive = true];
            List<String> emails = new List<String>();
            if (mailReceivers.size() > 0){
                for (User mailReceiver : mailReceivers){
                    emails.add(mailReceiver.Email);
                }
                emails.add('thanh.ly@aodigy.com');
                emails.add('thieudang.vu@aodigy.com');
            }
            System.debug('Emails ::' + emails);
            
            for (Vehicle_Master2__c newRecord : Trigger.new){
                // System.debug('New Duty Payment Date: ' + newRecord.Duty_Payment_Date__c + 'Old Duty Payment Date: ' + Trigger.oldMap.get(newRecord.Id).Duty_Payment_Date__c);
                if (newRecord.Duty_Payment_Date__c <> Trigger.oldMap.get(newRecord.Id).Duty_Payment_Date__c
                    && userMap.containsKey(newRecord.LastModifiedById))
                {
                    System.debug('Start here !');
                    Messaging.SingleEmailmessage mail = new Messaging.SingleEmailmessage();
                    mail.setToAddresses(emails);
                    String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Vehicle_Master2__c/' + newRecord.Id + '/view';
                    mail.setSubject('Update Sales Duty Request Date on Stock Vehicle Master By ' + userMap.get(newRecord.LastModifiedById).Name);
                    mail.setHtmlBody(URL);
                    
                    System.debug('Email Address :' + mail.getToAddresses());
                    mails.add(mail);
                }
            }
            
            if (mails.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
                for (Messaging.SendEmailResult rs : results) 
                {
                    if (!rs.isSuccess()) 
                    {
                        for (Messaging.SendEmailError err : rs.getErrors()) 
                        {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                    else
                    {
                        System.debug('Successfull send email to NCL');  
                    }
                }  
            }
        }catch(Exception e){
            System.debug('Error on Vehicle Master: ' + e.getMessage() + e.getLineNumber());
            System.debug('Error Stack Trace on Vehicle Master: ' + e.getStackTraceString());
        }
     }



     //Check to confirm that SVM and Shipment Line Item have 1-1 relationship
     if(Trigger.IsBefore && Trigger.isUpdate)
     {
        // from updating vehicle master, get all parent shipment line items

        // from parent shipment line items, get all current vehicle master (include updating vehicle master)

        // loop on parent shipment line items:
            Integer count = 0;
            set<id> shipmentLineItemsId = new set<id>();
            for (Vehicle_Master2__c fVM : trigger.new) {
                // TODO: check if Shipment_Line_Item__c is changed
                shipmentLineItemsId.add(fVM.Shipment_Line_Item__c);
                Vehicle_Master2__c oldVehicleMaster = Trigger.oldMap.get(fVM.Id);

                if (oldVehicleMaster.Shipment_Line_Item__c != fVM.Shipment_Line_Item__c) {
                    
                    Map<id,Shipment_Line_Item__c> shipmentLineItems = new map<id,Shipment_Line_Item__c>([SELECT id, (SELECT id,Shipment_Line_Item__c 
                    FROM Stock_Vehicle_Masters__r)
                    FROM Shipment_Line_Item__c WHERE Id IN: shipmentLineItemsId ]);
                    if(shipmentLineItems.size()>0){
                        for (Shipment_Line_Item__c sli : shipmentLineItems.values()) {
                            if(sli.Stock_Vehicle_Masters__r.size()>0){
                                count +=1;
                            }
                    if (count>0) {
                        fVM.addError('SVM and Shipment Line Item have 1-1 relationship');
                    }

                }
            }
                }
                
            }
            
            

     }
     
            
}
    

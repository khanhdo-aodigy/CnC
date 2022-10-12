/*==========================================================================================================================================================================
 * Domain class for Stock Vehicle Master entity
 * Created By: Aodigy Team
 * Create Date: July 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          23 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000013                                      init
 *          19 Aug 2022                         nhung.cao@aodigy.com                US-TMS-000013                                       Add sendEmailToTMSMaker/ prepareEmail method
 *          16 Sep 2022                         thieudang.vu@aodigy.com             DSA-US-0024                                         Add allocateSVMForIndentSRs()
 * ========================================================================================================================================================================== 
 */
public inherited sharing class StockVehicleMaster extends ADGLIB_SObjectDomain
{
    public StockVehicleMaster(List<Vehicle_Master2__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new StockVehicleMaster(sObjectList);
		}
	}

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Vehicle_Master2__c> beforeUpdateVehicles = (Map<Id, Vehicle_Master2__c>) existingRecords;
        
        Map<Id, Vehicle_Master2__c> afterUpdateVehicles = (Map<Id, Vehicle_Master2__c>) Trigger.newMap;

        onVehicleShipmentMatching(beforeUpdateVehicles, afterUpdateVehicles);
    }

    public override void onBeforeInsert()
    {
        List<Vehicle_Master2__c> insertingVehicles = (List<Vehicle_Master2__c>) Trigger.new;

        onVehicleShipmentMatching(insertingVehicles);
    }

    public override void onAfterInsert()
    {
        List<Vehicle_Master2__c> insertingVehicles = (List<Vehicle_Master2__c>) Trigger.new;

        // allocateSVMForIndentSRs(insertingVehicles, null);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        Map<Id, Vehicle_Master2__c> beforeUpdateVehicles = (Map<Id, Vehicle_Master2__c>) existingRecords;

        List<Vehicle_Master2__c> afterUpdateVehicles = (List<Vehicle_Master2__c>) Trigger.new;

        sendEmail(beforeUpdateVehicles, afterUpdateVehicles);
        // updateJITStatusOnSA(afterUpdateVehicles);
        sendEmailToTMSMaker(afterUpdateVehicles, beforeUpdateVehicles);

        // allocateSVMForIndentSRs(afterUpdateVehicles, beforeUpdateVehicles);
    }

    /**
     * ==================================================================================================================
     * Ensure a Shipment Line Item can have only one Stock Vehicle Master link to it.This method is invoked before update
     * @param beforeUpdateVehicles: values of records before update
     * @param afterUpdateVehicles: values of records after update
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ==================================================================================================================
     */
    private void onVehicleShipmentMatching(Map<Id, Vehicle_Master2__c> beforeUpdateVehicles, Map<Id, Vehicle_Master2__c> afterUpdateVehicles)
    {
        // get vehicles with Shipment_Line_Item__c field changed
        Map<Id, Vehicle_Master2__c> applicableVehicles = new Map<Id, Vehicle_Master2__c>();

        for (Id vehicleId : afterUpdateVehicles.keySet())
        {
            if (beforeUpdateVehicles.get(vehicleId).Shipment_Line_Item__c != afterUpdateVehicles.get(vehicleId).Shipment_Line_Item__c)
            {
                applicableVehicles.put(vehicleId, afterUpdateVehicles.get(vehicleId));
            }
        }

        if (applicableVehicles.size() == 0)
        {
            return;
        }

        // get parent shipment line item ids
        Set<Id> shipmentLineItemIds = new Set<Id>();

        for (Vehicle_Master2__c vehicle : applicableVehicles.values())
        {
            if (String.isNotBlank(vehicle.Shipment_Line_Item__c))
            {
                shipmentLineItemIds.add(vehicle.Shipment_Line_Item__c);
            }
        }

        // get all stock vehicle master link to @shipmentLineItemIds
        Map<Id, Vehicle_Master2__c> matchedVehicles = new Map<Id, Vehicle_Master2__c> ([SELECT Id, Name, Shipment_Line_Item__c FROM Vehicle_Master2__c WHERE Shipment_Line_Item__c IN :shipmentLineItemIds]);

        // System.debug('matchedVehicle before ::' + JSON.serialize(matchedVehicles));

        // store the latest content for assessing
        List<Vehicle_Master2__c> updatedVehicles = new List<Vehicle_Master2__c>();

        // loop @matchedVehicles and get latest content from @afterUpdateVehicles
        for (Vehicle_Master2__c matchedVehicle : matchedVehicles.values())
        {
            Vehicle_Master2__c afterUpdateVehicle = afterUpdateVehicles.get(matchedVehicle.Id);

            if (afterUpdateVehicle != null)
            {
                matchedVehicle = afterUpdateVehicle.clone(true, false, true, true);
            }

            updatedVehicles.add(matchedVehicle);
        }

        // loop @afterUpdateVehicles to add new content (if any)
        for (Vehicle_Master2__c afterUpdateVehicle : afterUpdateVehicles.values())
        {
            if (!matchedVehicles.keySet().contains(afterUpdateVehicle.Id))
            {
                updatedVehicles.add(afterUpdateVehicle);
            }
        }

        // System.debug('matchedVehicle after ::' + JSON.serialize(matchedVehicles));

        // arrange the updated vehicles into a map by Shipment_Line_Item__c and start assessing
        Map<Id, List<Vehicle_Master2__c>> updatedVehiclesByShipmentLineItemId = this.groupVehiclesByParent(updatedVehicles, 'Shipment_Line_Item__c');

        for (List<Vehicle_Master2__c> vehicles : updatedVehiclesByShipmentLineItemId.values())
        {
            if (vehicles != null && vehicles.size() > 1)
            {
                for (Vehicle_Master2__c errorVehicle : vehicles)
                {
                    afterUpdateVehicles.get(errorVehicle.Id)?.addError(Vehicle_Master2__c.Shipment_Line_Item__c,'This shipment line item already have a linked vehicle');
                }
            }
        }
    }

    /**
     * ==================================================================================================================
     * Ensure a Shipment Line Item can have only one Stock Vehicle Master link to it.This method is invoked before insert
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ==================================================================================================================
     */
    private void onVehicleShipmentMatching(List<Vehicle_Master2__c> insertingVehicles)
    {
        // get vehicles with Shipment_Line_Item__c populated
        Map<Id, Vehicle_Master2__c> applicableVehicles = new Map<Id, Vehicle_Master2__c>();

        for (Vehicle_Master2__c insertingVehicle: insertingVehicles)
        {
            if (String.isNotBlank(insertingVehicle.Shipment_Line_Item__c))
            {
                applicableVehicles.put(insertingVehicle.Id, insertingVehicle);
            }
        }

        if (applicableVehicles.size() == 0)
        {
            return;
        }

        // arrange matching stock by shipment line item id
        Map<Id, List<Vehicle_Master2__c>> matchingStocksByShipmentLineItemId = this.groupVehiclesByParent(applicableVehicles.values(), 'Shipment_Line_Item__c');

        // check if there are any 2 inserting stocks link to same shipment line item
        for (List<Vehicle_Master2__c> matchingStocks : matchingStocksByShipmentLineItemId.values())
        {
            if (matchingStocks.size() > 1)
            {
                this.addErrorToMultipleVehicles(matchingStocks, Vehicle_Master2__c.Shipment_Line_Item__c, 'This shipment line item already have a linked vehicle');
            }
        }

        // check if inserting stock link to a matched shipment line item
        List<Shipment_Line_Item__c> matchingShipmentLineItems = [   SELECT Id, (SELECT Id FROM Stock_Vehicle_Masters__r)
                                                                    FROM Shipment_Line_Item__c
                                                                    WHERE Id IN :matchingStocksByShipmentLineItemId.keySet()
                                                                ];

        for (Shipment_Line_Item__c matchingShipmentLineItem : matchingShipmentLineItems)
        {
            // currently matched stocks
            List<Vehicle_Master2__c> matchedStocks = matchingShipmentLineItem.Stock_Vehicle_Masters__r;

            // matching new stocks
            List<Vehicle_Master2__c> matchingStocks = matchingStocksByShipmentLineItemId.get(matchingShipmentLineItem.Id);

            // if @matchedStocks already exist, add error to @matchingStocks
            if (matchedStocks != null && matchedStocks.size() > 0)
            {
                if (matchingStocks != null && matchingStocks.size() > 0)
                {
                    this.addErrorToMultipleVehicles(matchingStocks, Vehicle_Master2__c.Shipment_Line_Item__c, 'This shipment line item already have a linked vehicle');
                }
            }
        }
    }

    /**
     * ==============================================================================================================================================
     * Group @stocks by a @groupingField
     * @param stocks: stock vehicle master for grouping
     * @param groupingField: key field for grouping. Developer should make sure this is a lookup field. This method do not check for that assumption
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private Map<Id, List<Vehicle_Master2__c>> groupVehiclesByParent(List<Vehicle_Master2__c> stocks, String groupingField)
    {
        Map<Id, List<Vehicle_Master2__c>> result = new Map<Id, List<Vehicle_Master2__c>>();

        for (Vehicle_Master2__c stock : stocks)
        {
            Object groupingFieldValueAsObject = stock.get(groupingField);
            
            if (groupingFieldValueAsObject == null)
            {
                continue;
            }

            String key = String.valueOf(groupingFieldValueAsObject);
            
            if (String.isNotBlank(key))
            {
                if (result.keySet().contains(key))
                {
                    result.get(key).add(stock);
                }
                else
                {
                    result.put(key, new List<Vehicle_Master2__c> { stock });
                }
            }
        }

        return result;
    }

    /**
     * ==============================================================================================================================================
     * Add @error to @stocks
     * @param stocks: stock vehicle master for error adding
     * @param error: error message
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private void addErrorToMultipleVehicles(List<Vehicle_Master2__c> stocks, String error)
    {
        for (Vehicle_Master2__c stock : stocks)
        {
            stock.addError(error);
        }
    }

    /**
     * ==============================================================================================================================================
     * Add @error to @stocks at @field
     * @param stocks: stock vehicle master for error adding
     * @param error: error message
     * Created By: dangphap.mai@aodigy.com
     * Created Date: Aug 2022
     * ===============================================================================================================================================
     */
    private void addErrorToMultipleVehicles(List<Vehicle_Master2__c> stocks, Schema.SObjectField field, String error)
    {
        for (Vehicle_Master2__c stock : stocks)
        {
            stock.addError(field, error);
        }
    }

    /**
     * ==============================================================================================================================================
     * Add method send email on After Update
     * @param beforeUpdateVehicles: values of records before update
     * @param afterUpdateVehicles: values of records after update
     * Created By: thanh.ly@aodigy.com
     * Created Date: Jul 27 2022
     * ===============================================================================================================================================
     */
     private void sendEmail(Map<Id, Vehicle_Master2__c> beforeUpdateVehicles, List<Vehicle_Master2__c> afterUpdateVehicles){
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
                emails.add('trung822299@gmail.com');
            }
            System.debug('Emails ::' + emails);
        
            for (Vehicle_Master2__c newRecord : afterUpdateVehicles){
                // System.debug('New Duty Payment Date: ' + newRecord.Duty_Payment_Date__c + 'Old Duty Payment Date: ' + Trigger.oldMap.get(newRecord.Id).Duty_Payment_Date__c);
                if (newRecord.Duty_Payment_Date__c <> beforeUpdateVehicles.get(newRecord.Id).Duty_Payment_Date__c
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

                if (newRecord.Duty_Payment_Date__c <> beforeUpdateVehicles.get(newRecord.Id).Duty_Payment_Date__c
                    && newRecord.Duty_Payment_Date__c == Date.today())
                    {
                        Messaging.SingleEmailmessage mail = new Messaging.SingleEmailmessage();
                        mail.setToAddresses(emails);
                        String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Vehicle_Master2__c/' + newRecord.Id + '/view';
                        mail.setSubject('Duty Payment Date on Stock Vehicle Master By Today');
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
    
    /**
     * ==============================================================================================================================================
     * Add method update JIT Status on SA on After Update
     * @param afterUpdateVehicles: values of records after update
     * Created By: thanh.ly@aodigy.com
     * Created Date: Sep 15 2022
     * ===============================================================================================================================================
     */
    /*private void updateJITStatusOnSA(List<Vehicle_Master2__c> afterUpdateVehicles){
        try{
            List<Id> vehicleMasterIds = new List<Id>();
            for(Vehicle_Master2__c vm : afterUpdateVehicles){
                vehicleMasterIds.add(vm.Id);
            }

            List<Sales_Agreement__c> salesAgreements = [SELECT Id, JIT_Status__c, Stock_Reservation__r.Vehicle_Master__r.Vehicle_Movement_Location__c
                                                        FROM Sales_Agreement__c
                                                        WHERE Stock_Reservation__r.Vehicle_Master__c IN :vehicleMasterIds];

            List<Sales_Agreement__c> updatedSAList = new List<Sales_Agreement__c>();
            if(salesAgreements.size() > 0 && salesAgreements != null){
                System.debug('Sales Agreement :: ' + salesAgreements);
                for(Sales_Agreement__c sa : salesAgreements){
                    if(sa.Stock_Reservation__r.Vehicle_Master__r.Vehicle_Movement_Location__c == 'PDI'){
                        sa.JIT_Status__c = 'Started';
                    }
                    if(sa.Stock_Reservation__r.Vehicle_Master__r.Vehicle_Movement_Location__c == 'Delivery Bay'){
                        sa.JIT_Status__c = 'Completed';
                    }
                    if(sa.Stock_Reservation__r.Vehicle_Master__r.Vehicle_Movement_Location__c == null){
                        sa.JIT_Status__c = null;
                    }
                    updatedSAList.add(sa);
                }
            }

            if(updatedSAList.size() > 0 && updatedSAList != null){
                update updatedSAList;
            }
        }catch(Exception e){
            System.debug('Error on Vehicle Master: ' + e.getMessage() + e.getLineNumber());
            System.debug('Error Stack Trace on Vehicle Master: ' + e.getStackTraceString());
        }
    }*/

    /**
     * ==============================================================================================================================================
     * Add method send email on  After Updated SVM status == canclled => send email to TMS Makers   
     * @param beforeUpdateVehicles: values of records before update
     * @param afterUpdateVehicles: values of records after update
     * Created By: nhung.cao@aodigy.com
     * Created Date: 19/08/2022
     * ===============================================================================================================================================
     */
    @TestVisible
    private void sendEmailToTMSMaker(List<Vehicle_Master2__c> afterUpdateVehicles, Map<Id, Vehicle_Master2__c> beforeUpdateVehicles){
        try 
        {
            List<Vehicle_Master2__c> svmToBeCancelled = new List<Vehicle_Master2__c>();

            for (Vehicle_Master2__c newRecord : afterUpdateVehicles)
            {
                System.debug('Vehicle Master ::' + newRecord);
                System.debug('Status :: ' + newRecord.Vehicle_Purchase_Status__c + ' Purchase Order :: ' + newRecord.Purchase_Order__c + ' Vehicle Purchase :: ' + newRecord.Vehicle_Purchase_Order__c);
                if (newRecord.Vehicle_Purchase_Status__c <> beforeUpdateVehicles.get(newRecord.Id).Vehicle_Purchase_Status__c && newRecord.Vehicle_Purchase_Status__c == 'SCL_Cancel' && newRecord.Purchase_Order__c != null && newRecord.Vehicle_Purchase_Order__c != null)
                {   
                    svmToBeCancelled.add(newRecord);
                }
            }

            System.debug('svmToBeCancelled' + svmToBeCancelled);

            if(svmToBeCancelled.size()>0)
            {
                List<Messaging.SingleEmailMessage> mailsToBeSend = prepareEmail(svmToBeCancelled);
                System.debug('mailsToBeSend' + mailsToBeSend); 
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsToBeSend, false);      
                System.debug('results'); 
                for (Messaging.SendEmailResult rs : results) 
                {System.debug('results in looppppp'); 
                    if (!rs.isSuccess()) 
                    {
                        for(Messaging.SendEmailError err : rs.getErrors()) 
                        {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                        }
                    }
                    else
                    {
                        System.debug('Successfull send email to TMS Makers');  
                    }
                }
            }            
        }    
        catch(Exception e)
        {
            System.debug('Error on Vehicle Master: ' + e.getMessage() + e.getLineNumber());
            System.debug('Error Stack Trace on Vehicle Master: ' + e.getStackTraceString());
        }
    }
    
    @TestVisible
    private static List<Messaging.SingleEmailMessage> prepareEmail(List<Vehicle_Master2__c> svmToBeCancelled)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        try 
        {
            OrgWideEmailAddress orgWideEmail    = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName ='Customer Contact Centre'];

            List<PermissionSetAssignment> assignmentList = [SELECT PermissionSetId, AssigneeId
                                                            FROM PermissionSetAssignment
                                                            WHERE PermissionSet.Name = 'TMS_Makers_Permission_Set'];
                                                            System.debug('assignmentList: '  + assignmentList);
            List<Id> userIds = new List<Id>();

            for(PermissionSetAssignment assignment: assignmentList) 
            {
                userIds.add(assignment.AssigneeId);
            }
            List<User> tmsMakerUsers = [SELECT Id, Email FROM User WHERE Id IN :userIds AND IsActive = true];  
            
            List<String> emailAddress = new List<String>();

            if (tmsMakerUsers.size()>0)
            {
                for (User tmsMakerUser : tmsMakerUsers)
                {
                    if(string.isNotBlank(tmsMakerUser.Email))
                    {
                        emailAddress.add(tmsMakerUser.Email);
                    }
                }
                System.debug('emailAddress' + emailAddress);
                emailAddress.add('caohongnhung296@gmail.com');            
            }

            Set<Id> vpoIDss = new Set<Id>();
            Set<Id> tmsPOIds = new Set<Id>();

            for(Vehicle_Master2__c svm: svmToBeCancelled)
            {
                vpoIDss.add(svm.Vehicle_Purchase_Order__c);
                tmsPOIds.add(svm.Purchase_Order__c);
            }
            System.debug('svmIds: '  + vpoIDss);
            List<Purchase_Order__c> relatedTMSPO = new TMSPurchaseOrderSelector().getRecordsBySVMIds(tmsPOIds);
            System.debug('relatedVPTMSPO: '  + relatedTMSPO.size());

            Map<Vehicle_Master2__c,Purchase_Order__c> tmspoSendEmail = new Map<Vehicle_Master2__c,Purchase_Order__c>();
            System.debug('tmspoSendEmail: '  + tmspoSendEmail.size());
            Set<Id> poIds = new Set<Id>();

            for(Vehicle_Master2__c svm: svmToBeCancelled)
            {
                for(Purchase_Order__c tmsPO: relatedTMSPO)
                {
                    if(tmsPO.Id == svm.Purchase_Order__c)
                    {
                        tmspoSendEmail.put(svm,tmsPO);    
                        poIds.add(tmsPO.Id);                
                    }
                }
            }

            System.debug('tmspoSendEmail: '  +tmspoSendEmail.size());
            System.debug('poIds: '  +poIds.size());

            List<Vehicle_Purchase_Order__c> relatedVPO = new List<Vehicle_Purchase_Order__c>([SELECT Id, TMS_Purchase_Order__c FROM Vehicle_Purchase_Order__c WHERE Id IN: vpoIDss]);
            System.debug('relatedVPO: '  +relatedVPO.size());

            Map<Vehicle_Master2__c,Vehicle_Purchase_Order__c> vpoToSendEmail = new Map<Vehicle_Master2__c,Vehicle_Purchase_Order__c>();
            System.debug('vpoToSendEmail1: '  + vpoToSendEmail);
            Set<Id> vpoIds = new Set<Id>();

            for(Vehicle_Master2__c svm: svmToBeCancelled)
            {
                for(Vehicle_Purchase_Order__c vpo: relatedVPO)
                {
                    if(vpo.Id == svm.Vehicle_Purchase_Order__c )
                    {
                        vpoToSendEmail.put(svm,vpo);
                        
                        vpoIds.add(vpo.TMS_Purchase_Order__c);
                    }
                }
            }
            System.debug('vpoToSendEmail2: '  + vpoToSendEmail.size());

            Map<Vehicle_Master2__c,Forward_FOB_Contract__c> fobCtrSendEmail = new Map<Vehicle_Master2__c,Forward_FOB_Contract__c>();
            
            for(Vehicle_Master2__c svm: tmspoSendEmail.keySet())
            {
                for(Forward_FOB_Contract__c fobCtr: tmspoSendEmail.get(svm).Forward_Contracts_FOB__r)
                {
                    System.debug('fobCtr.Status__c: '  + fobCtr.Status__c);
                    
                    if(fobCtr.Status__c == 'Active')
                    {
                        fobCtrSendEmail.put(svm,fobCtr);
                    }
                }
            }
            System.debug('fobCtrSendEmail: '  +fobCtrSendEmail.size());

            Map<Vehicle_Master2__c,Forward_Duty_Contract__c> dutyCtrSendEmail = new Map<Vehicle_Master2__c,Forward_Duty_Contract__c>();

            for(Vehicle_Master2__c svm: tmspoSendEmail.keySet())
            {
                for(Forward_Duty_Contract__c duty: tmspoSendEmail.get(svm).Forward_Duty_Contracts__r)
                {
                    System.debug('duty.Status__c'  + duty.Status__c);
                    
                    if(duty.Status__c == 'Active')
                    {
                        dutyCtrSendEmail.put(svm,duty);
                    }
                }
            }

            System.debug('dutyCtrSendEmail: '  +dutyCtrSendEmail.size());            

            for(Vehicle_Master2__c svm: svmToBeCancelled)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   

                String linkToSVM            = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Vehicle_Master2__c/' + svm.Id + '/view';
                String linkToVPO            = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Vehicle_Purchase_Order__c/' + vpoToSendEmail.get(svm).Id + '/view';
                String linkToFFOBContract, linkToFDutyContract;
                if(fobCtrSendEmail.size()>0)
                {
                    linkToFFOBContract   = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Forward_FOB_Contract__c/' + fobCtrSendEmail.get(svm).Id + '/view';
                }else 
                {
                    linkToFFOBContract   = 'No record on Forward FOB Contract';
                }

                if(dutyCtrSendEmail.size()>0)
                {
                    linkToFDutyContract  = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Forward_Duty_Contract__c/' + dutyCtrSendEmail.get(svm).Id + '/view';
                }else 
                {
                    linkToFDutyContract   = 'No record on Forward Duty Contract';
                }

                mail.setToAddresses(emailAddress);        
                mail.setSubject('Stock Vehicle Master '+ svm.Name +' has been cancelled');
                mail.setPlainTextBody('Dear TMS Maker \n\nStock Vehicle Master ' + svm.Name + ' has been cancelled. \n'
                                        +'\n- Stock Vehicle Master: ' + linkToSVM
                                        +'\n- Vehicle Purchase Order: ' + linkToVPO
                                        +'\n- Forward FOB Contract: ' + linkToFFOBContract
                                        +'\n- Forward Duty Contract: ' + linkToFDutyContract
                                        );
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
                System.debug('Send to Email Address :' + mail.getToAddresses());

                mails.add(mail);
                System.debug('mail: '  +mail);
            }
        } 
        catch(Exception e)
        {
            System.debug('Error on Vehicle Master: ' + e.getMessage() + e.getLineNumber());
            System.debug('Error Stack Trace on Vehicle Master: ' + e.getStackTraceString());
        }
        return mails;
    }

    /**
     * ==================================================================================================================
     * To find Indent SR based on matching Model, Color, Trim & Year Code and allocate SVM into SR.
     * Allocating will be based on FIFO logic.
     * @param beforeUpdateVehicles: values of records before update
     * @param afterUpdateVehicles: values of records after update
     * Created By: thieudang.vu@aodigy.com
     * Created Date: 15th Sep 2022
     * ==================================================================================================================
     */
    // private void allocateSVMForIndentSRs(List<Vehicle_Master2__c> afterInsertOrUpdateVehicles, Map<Id, Vehicle_Master2__c> beforeUpdateVehicles)
    // {
    //     List<Id> svmIds = new List<Id>();
    //     // Construct map vehicle master by Model, Color, Trim, Model Year code and order by CreatedDate
    //     Map<String, Vehicle_Master2__c> svmByModelColorTrim = new Map<String, Vehicle_Master2__c>();
    //     for (Vehicle_Master2__c svm : afterInsertOrUpdateVehicles) 
    //     {            
    //         if (beforeUpdateVehicles != null) 
    //         {
    //             Vehicle_Master2__c beforeUpdateSVM = (Vehicle_Master2__c)beforeUpdateVehicles.get(svm.Id);
    //             if (svm.Vehicle_Status__c != beforeUpdateSVM.Vehicle_Status__c && svm.Vehicle_Status__c == 'FREE')
    //             {
    //                 svmIds.add(svm.Id);
    //             }
    //         }
    //         else
    //         {
    //             svmIds.add(svm.Id);
    //         }
    //     }

    //     for (Vehicle_Master2__c svm : [SELECT Id, Model_Code__c, Trim_Code__c, Color_Code__c, Model_Year_Code__c, CreatedDate
    //                                    FROM Vehicle_Master2__c
    //                                    WHERE Id IN :svmIds
    //                                    ORDER BY CreatedDate ASC])
    //     {
    //         String modelColorTrimKey = String.valueOf(svm.Model_Code__c) + String.valueOf(svm.Color_Code__c) + String.valueOf(svm.Trim_Code__c);

    //         svmByModelColorTrim.put(modelColorTrimKey, svm);
    //     }

    //     // Query Indent SR and order by Created Date and construct map Indent SR by Model, Color, Trim, Model Year code
    //     Map<String, Stock_Reservation__c> srByModelColorTrim = new Map<String, Stock_Reservation__c>();

    //     for (Stock_Reservation__c sr : [SELECT Id, Color_Code__c, Model_Code__c, Model_Year_Code__c, Trim_Code__c, Vehicle_Master__c, CreatedDate
    //                                     FROM Stock_Reservation__c
    //                                     WHERE Reservation_Status__c = 'Indent'
    //                                      AND  Vehicle_Master__c = null
    //                                     ORDER BY CreatedDate ASC])
    //     {
    //         String modelColorTrimKey = String.valueOf(sr.Model_Code__c) + String.valueOf(sr.Color_Code__c) + String.valueOf(sr.Trim_Code__c);

    //         srByModelColorTrim.put(modelColorTrimKey, sr);
    //     }

    //     // Loop to allocate SVM for Indent SR by FIFO logic
    //     for (String modelColorTrimCode : srByModelColorTrim.keySet())
    //     {
    //         Vehicle_Master2__c svm = svmByModelColorTrim.get(modelColorTrimCode);

    //         Stock_Reservation__c sr = srByModelColorTrim.get(modelColorTrimCode);
    //         sr.Vehicle_Master__c = svm.Id;
    //     }

    //     // Update
    //     Database.update(srByModelColorTrim.values(), false);
    // }
}
public inherited sharing class VehicleMovementTracker extends ADGLIB_SObjectDomain {
    public VehicleMovementTracker(List<Vehicle_Movement_Tracker__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new VehicleMovementTracker(sObjectList);
		}
    }

    public override void onBeforeInsert() {
        Map<Id, List<Vehicle_Movement_Tracker__c>> vmtBySVMId = new Map<Id, List<Vehicle_Movement_Tracker__c>>();
        Map<Id, List<Vehicle_Movement_Tracker__c>> vmtByMBSVMId = new Map<Id, List<Vehicle_Movement_Tracker__c>>();
        for (Vehicle_Movement_Tracker__c vmt : (List<Vehicle_Movement_Tracker__c>)Records) {
            if (String.isNotBlank(vmt.Stock_Vehicle_Master__c)) {
                if (vmtBySVMId.containsKey(vmt.Stock_Vehicle_Master__c)) {
                    vmtBySVMId.get(vmt.Stock_Vehicle_Master__c).add(vmt);
                } else {
                    vmtBySVMId.put(vmt.Stock_Vehicle_Master__c, new List<Vehicle_Movement_Tracker__c>{vmt});
                }
            } else if (String.isNotBlank(vmt.MB_Stock_Vehicle_Master__c)) {
                if (vmtByMBSVMId.containsKey(vmt.MB_Stock_Vehicle_Master__c)) {
                    vmtByMBSVMId.get(vmt.MB_Stock_Vehicle_Master__c).add(vmt);
                } else {
                    vmtByMBSVMId.put(vmt.MB_Stock_Vehicle_Master__c, new List<Vehicle_Movement_Tracker__c>{vmt});
                }
            }
        }

        if (vmtBySVMId.isEmpty() && vmtByMBSVMId.isEmpty()) return;

        List<sObject> svms;
        List<sObject> mbSVMs;
        Set<String> stockFields = new Set<String>{'Id', 'Name', 'Vehicle_Movement_Location__c','Vehicle_Movement_Action_Time__c'};
        Set<String> vmtFields = new Set<String>{'Id', 'Location__c'};
        if (!vmtBySVMId.isEmpty()) {
            svms = getRecords('Vehicle_Master2__c', 'Id', vmtBySVMId.keySet(), stockFields, 
                              'Vehicle_Movement_Tracker__c', vmtFields, null, 'CreatedDate', true);
            processVehMovementTracker(svms, vmtBySVMId);
        }
        if (!vmtByMBSVMId.isEmpty()) {
            mbSVMs = getRecords('MB_Stock_Vehicle_Master__c', 'Id', vmtByMBSVMId.keySet(), stockFields, 
                                'Vehicle_Movement_Tracker__c', vmtFields, null, 'CreatedDate', true);
            processVehMovementTracker(mbSVMs, vmtByMBSVMId);
        }
    }

    public override void onAfterInsert() {
        Map<Id, List<Vehicle_Movement_Tracker__c>> vmtBySVMId = new Map<Id, List<Vehicle_Movement_Tracker__c>>();
        Map<Id, List<Vehicle_Movement_Tracker__c>> vmtByMBSVMId = new Map<Id, List<Vehicle_Movement_Tracker__c>>();
        Set<Id> locationIds = new Set<Id>();
        for (Vehicle_Movement_Tracker__c vmt : (List<Vehicle_Movement_Tracker__c>)Records) {
            locationIds.add(vmt.Location__c);
            if (String.isNotBlank(vmt.Stock_Vehicle_Master__c)) {
                if (vmtBySVMId.containsKey(vmt.Stock_Vehicle_Master__c)) {
                    vmtBySVMId.get(vmt.Stock_Vehicle_Master__c).add(vmt);
                } else {
                    vmtBySVMId.put(vmt.Stock_Vehicle_Master__c, new List<Vehicle_Movement_Tracker__c>{vmt});
                }
            } else if (String.isNotBlank(vmt.MB_Stock_Vehicle_Master__c)) {
                if (vmtByMBSVMId.containsKey(vmt.MB_Stock_Vehicle_Master__c)) {
                    vmtByMBSVMId.get(vmt.MB_Stock_Vehicle_Master__c).add(vmt);
                } else {
                    vmtByMBSVMId.put(vmt.MB_Stock_Vehicle_Master__c, new List<Vehicle_Movement_Tracker__c>{vmt});
                }
            }
        }

        if (vmtBySVMId.isEmpty() && vmtByMBSVMId.isEmpty()) return;

        Map<Id, Location__c> locationById = new Map<Id, Location__c>();
        Set<String> locationFields = new Set<String>{'Id', 'Name', 'Email_Communication_Vehicle_Movement__c', 'Email_Subject__c', 'Email_Body__c'};
        List<Location__c> locations = (List<Location__c>)getRecords('Location__c', 'Id', locationIds, locationFields, null, null, null, null, null);
        for (Location__c location : locations) {
            locationById.put(location.Id, location);
        }

        List<sObject> stocksToBeUpdated = new List<sObject>();
        Map<Id, Vehicle_Master2__c> svmBySRId;
        Set<String> stockFields = new Set<String>{'Id', 'Vehicle_Movement_Location__c','Vehicle_Movement_Action_Time__c'};
        if (!vmtBySVMId.isEmpty()) {
            svmBySRId = new Map<Id, Vehicle_Master2__c>();
            List<Vehicle_Master2__c> svms = (List<Vehicle_Master2__c>)getRecords('Vehicle_Master2__c', 'Id', vmtBySVMId.keySet(), stockFields,
                                                                                 'Stock_Reservation__c', new Set<String>{'Id'}, 'Reservation_Status__c != \'Cancel\'', null, true);

            for (Vehicle_Master2__c svm : svms) {
                Vehicle_Movement_Tracker__c vmt = getLastVMT(svm.Id, vmtBySVMId);
                svm.Vehicle_Movement_Action_Time__c = vmt.Action_Taken_Time__c;
                Location__c location = locationById.get(vmt.Location__c);
                svm.Vehicle_Movement_Location__c = location.Name;
                stocksToBeUpdated.add(svm);

                if (!location.Email_Communication_Vehicle_Movement__c) continue;
                if (svm.Stock_Reservations__r != null && svm.Stock_Reservations__r.size() > 0) {
                    for (Stock_Reservation__c sr : svm.Stock_Reservations__r) {
                        svmBySRId.put(sr.Id, svm);
                    }
                }
            }
                                        
        }

        Map<Id, MB_Stock_Vehicle_Master__c> svmByMBSAId;
        if (!vmtByMBSVMId.isEmpty()) {
            svmByMBSAId = new Map<Id, MB_Stock_Vehicle_Master__c>();
            List<MB_Stock_Vehicle_Master__c> mbSVMs = (List<MB_Stock_Vehicle_Master__c>)getRecords('MB_Stock_Vehicle_Master__c', 'Id', vmtByMBSVMId.keySet(), stockFields,
                                                                                                   'MB_Sales_Agreement__c', new Set<String>{'Id'}, 'Status__c != \'Cancelled\'', null, true);
            for (MB_Stock_Vehicle_Master__c mbSVM : mbSVMs) {
                Vehicle_Movement_Tracker__c vmt = getLastVMT(mbSVM.Id, vmtByMBSVMId);
                mbSVM.Vehicle_Movement_Action_Time__c = vmt.Action_Taken_Time__c;
                Location__c location = locationById.get(vmt.Location__c);
                mbSVM.Vehicle_Movement_Location__c = location.Name;
                stocksToBeUpdated.add(mbSVM);

                if (!location.Email_Communication_Vehicle_Movement__c) continue;
                if (mbSVM.MB_Sales_Agreements__r != null && mbSVM.MB_Sales_Agreements__r.size() > 0) {
                    for (MB_Sales_Agreement__c mbSA : mbSVM.MB_Sales_Agreements__r) {
                        svmByMBSAId.put(mbSA.Id, mbSVM);
                    }
                }
            }
        }
        system.debug('stocks to be updated:: ' + stocksToBeUpdated);

        List<Logger_Data_Pool__c> logs = new List<Logger_Data_Pool__c>();
        Set<String> updateErrorMsgs = new Set<String>();
        List<Database.SaveResult> updateResults = Database.update(stocksToBeUpdated, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            if (!updateResults[i].isSuccess()) {
                for(Database.Error err : updateResults[i].getErrors()) {
                    updateErrorMsgs.add(updateResults[i].Id + ' ' + err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        if (updateErrorMsgs.size() > 0) {
            logs.add(new Logger_Data_Pool__c(Instance__c = 'Vehicle_Movement_Update_SVM', 
                                             Message__c = JSON.serialize(updateErrorMsgs)));
        }

        if ((svmBySRId == null || svmBySRId.isEmpty()) &&
            (svmByMBSAId == null || svmByMBSAId.isEmpty())) return;

        OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'do-not-reply@ccc.cyclecarriage.com.sg' LIMIT 1];
        List<Messaging.SingleEmailMessage> emailMsgs = new List<Messaging.SingleEmailMessage>();
        if (svmBySRId != null && !svmBySRId.isEmpty()) {
            Set<String> saObjFields = getAllFieldsObject('Sales_Agreement__c');
            List<Sales_Agreement__c> sas = (List<Sales_Agreement__c>)getRecords('Sales_Agreement__c', 'Stock_Reservation__c', svmBySRId.keySet(), saObjFields, null, null, null, null, null);
            for (Sales_Agreement__c sa : sas) {
                Vehicle_Master2__c svm = svmBySRId.get(sa.Stock_Reservation__c);
                Vehicle_Movement_Tracker__c vmt = getLastVMT(svm.Id, vmtBySVMId);
                List<String> toAddresses = new List<String>{sa.Owner.Email};
                Messaging.SingleEmailMessage mail = constructEmail(vmt, owa.Id, toAddresses, locationById, svm.Id, sa, saObjFields);
                if (mail != null) emailMsgs.add(mail);
            }
        }
        if (svmByMBSAId != null && !svmByMBSAId.isEmpty()) {
            Set<String> mbSAObjFields = getAllFieldsObject('MB_Sales_Agreement__c');
            List<MB_Sales_Agreement__c> mbSAs = (List<MB_Sales_Agreement__c>)getRecords('MB_Sales_Agreement__c', 'Id', svmByMBSAId.keySet(), mbSAObjFields, null, null, null, null, null);
            for (MB_Sales_Agreement__c mbSA : mbSAs) {
                MB_Stock_Vehicle_Master__c mbSVM = svmByMBSAId.get(mbSA.Id);
                Vehicle_Movement_Tracker__c vmt = getLastVMT(mbSVM.Id, vmtByMBSVMId);
                List<String> toAddresses = new List<String>{mbSA.Owner.Email};
                Messaging.SingleEmailMessage mail = constructEmail(vmt, owa.Id, toAddresses, locationById, mbSVM.Id, mbSA, mbSAObjFields);
                if (mail != null) emailMsgs.add(mail);
            }
        }

        if (emailMsgs.size() > 0) {
            Messaging.SendEmailResult[] emailSentResults = Messaging.sendEmail(emailMsgs, false);
            system.debug('results:: ' + emailSentResults);
            Set<String> sendingErrors = new Set<String>();
            for (Messaging.SendEmailResult result : emailSentResults) {
                if (!result.isSuccess()) {
                    for (Messaging.SendEmailError e : result.getErrors()) {
                        sendingErrors.add(e.getMessage());
                    }
                }
            }
            if (sendingErrors.size() > 0) {
                logs.add(new Logger_Data_Pool__c(Instance__c = 'Vehicle_Movement_Email_Notification', 
                                                 Message__c = JSON.serialize(sendingErrors) + ' <<<< |||| >>>> ' + JSON.serialize(vmtBySVMId.keySet())));
                try {
                    if (logs.size() > 0) insert logs;
                } catch (Exception e) {

                }
            }
        }
    }

    /**
     * Method to get last Vehicle Movement Tracker in inserted Vehicle Movement Tracker records
     */
    private static Vehicle_Movement_Tracker__c getLastVMT(Id stockId, Map<Id, List<Vehicle_Movement_Tracker__c>> vmtByStockId) {
        List<Vehicle_Movement_Tracker__c> vmtList = vmtByStockId.get(stockId);
        Vehicle_Movement_Tracker__c vhMovementTracker = vmtList.get(vmtList.size() - 1);

        return vhMovementTracker;
    }

    /**
     * Method to process Vehicle Movement Tracker record
     * Check if Vehicle moved to the same Location
     * Populate Previous Location and Previous Action Taken Time for Vehicle Movement Tracker
     */
    private static void processVehMovementTracker(List<sObject> records, Map<Id, List<Vehicle_Movement_Tracker__c>> vmtByStockId) {
        for (sObject record : records) {
            List<Vehicle_Movement_Tracker__c> vhMovementTrackers = vmtByStockId.get((Id)record.get('Id'));
            Vehicle_Movement_Tracker__c latestVHMovementTracker;
            if (record.getSObjects('Vehicle_Movement_Trackers__r') != null && record.getSObjects('Vehicle_Movement_Trackers__r').size() > 0) {
                latestVHMovementTracker = (Vehicle_Movement_Tracker__c)record.getSObjects('Vehicle_Movement_Trackers__r')[0];
                for (Vehicle_Movement_Tracker__c vmt : vhMovementTrackers) {
                    if (vmt.Location__c == latestVHMovementTracker.Location__c) {
                        vmt.addError('Vehicle ' + record.get('Name') + ' has already been moved to this Location. Please check again!');
                    }
                    vmt.Previous_Location__c = (String)record.get('Vehicle_Movement_Location__c');
                    vmt.Previous_Action_Taken_Time__c = (DateTime)record.get('Vehicle_Movement_Action_Time__c');
                }
            }
        }
    }

    /**
     * Construct Email 
     */
    private static Messaging.SingleEmailMessage constructEmail(Vehicle_Movement_Tracker__c vmt, Id orgWideEmailId, List<String> toAddresses,
                                                               Map<Id, Location__c> locationById, Id whatId, sObject recordInfo, Set<String> sObjectFields) {
        Location__c location = locationById.get(vmt.Location__c);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setToAddresses(toAddresses);
        String subject = String.isNotBlank(location.Email_Subject__c) ? finaliseContent(location.Email_Subject__c, recordInfo, sObjectFields) : '';
        mail.setSubject(subject);
        String body = String.isNotBlank(location.Email_Subject__c) ? finaliseContent(location.Email_Body__c, recordInfo, sObjectFields) : '';
        mail.setPlainTextBody(body);
        mail.setWhatId(whatId);
        mail.setSaveAsActivity(true);

        return mail;
    }

    /**
     * Method to replace field placeholders with actual values from record
     */
    private static String finaliseContent(String content, sObject record, Set<String> sObjectFields) {
        String regex = '\\{!(.*?)\\}';
        Pattern p = Pattern.compile(regex);
        Matcher mo = p.matcher(content);
        if (mo != null) {
            while (mo.find()) {
                String mergeField = mo.group().substring(2, mo.group().length() - 1);
                if (sObjectFields.contains(mergeField)) {
                //    String mergeFieldVal = (String)record.get(mergeField); 25/08/2021 [Thang] updated as below
                    String mergeFieldVal = String.valueOf(record.get(mergeField));
                    if (String.isNotBlank(mergeFieldVal)) {
                        switch on (mergeFieldVal) {
                            when 'KIAPC' { mergeFieldVal = 'Kia'; }
                            when 'MITPC' { mergeFieldVal = 'Mitsubishi'; }
                            when 'CITPC' { mergeFieldVal = 'Citroen'; }
                        }
                        content = content.replace(mo.group(), mergeFieldVal);
                    }
                }
            }
        }

        return content;
    }

    /**
     * Method to format query condition
     */
    private static List<String> addQuotationMark(List<String> lstr) {
        List<String> results = new List<String>();
        for (String str : lstr) {
            results.add('\'' + str + '\'');
        }
        return results;
    }

    /**
     * Method to query sObject records
     */
    private static List<sObject> getRecords(String parentObjNm, String parentObjFieldRef, Set<Id> parentObjFieldValues, Set<String> parentObjFields,
                                            String childObjRelNm, Set<String> childObjFields, String childObjCond, String childObjFieldOrder, Boolean onlyOneChildRec) {

        Schema.SObjectType parentObjectType = getObjectType(parentObjNm);
        if (parentObjNm == 'Sales_Agreement__c' || parentObjNm == 'MB_Sales_Agreement__c') {
            parentObjFields.add('Owner.Email');
        }
        ADGLIB_QueryFactory factory;
        ADGLIB_QueryFactory childQueryFactory;
        factory = new ADGLIB_QueryFactory(parentObjectType);
        factory.selectFields(parentObjFields);
        if (String.isNotBlank(childObjRelNm)) {
            childQueryFactory = factory.subselectQuery(getObjectType(childObjRelNm));
            childQueryFactory.selectFields(childObjFields);
            if (String.isNotBlank(childObjCond)) childQueryFactory.setCondition(childObjCond);
            if (String.isNotBlank(childObjFieldOrder)) childQueryFactory.setOrdering(childObjFieldOrder, ADGLIB_QueryFactory.SortOrder.DESCENDING, true);
            if (onlyOneChildRec) childQueryFactory.setLimit(1);
        }
        String addnlQueryCondition = parentObjFieldRef + ' IN (' + String.join(addQuotationMark(new List<Id>(parentObjFieldValues)), ',') + ')';
        factory.setCondition(addnlQueryCondition);

        List<sObject> records = Database.query(factory.toSOQL());
        return records;
    }

    /**
     * Method to get object type
     */
    private static Schema.SObjectType getObjectType(String objNm) {
        return ((SObject)Type.forName(objNm).newInstance()).getSObjectType();
    }

    /**
     * Method to get all fields of an object
     */
    private static Set<String> getAllFieldsObject(String objNm) {
        Map<String, Schema.SObjectField> sObjectFieldsMap = getObjectType(objNm).getDescribe().fields.getMap();

        Set<String> sObjectFieldsAPINm = new Set<String>();
        for (String fieldNm : sObjectFieldsMap.keySet()) {
            sObjectFieldsAPINm.add(sObjectFieldsMap.get(fieldNm).getDescribe().getName());
        }

        return sObjectFieldsAPINm;
    }
}
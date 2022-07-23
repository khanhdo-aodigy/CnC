public with sharing class FormsPanelController {
    @AuraEnabled(cacheable=true)
    public static FormsDefinitionDetails getActiveForms(Id recordId) {
        system.debug('record id:: ' + recordId);
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        system.debug('obj API Name ' + objApiName);
        FormsDefinitionDetails formDetails = new FormsDefinitionDetails(objApiName);
        formDetails.objInfo = getRecords(objApiName, 'Id', recordId, null)[0];
        for (Forms_Controller__c fc : [SELECT Start_Date__c, End_Date__c, Object_API_Name__c, Form_Title__c, Form_Body__c, Form_Name__c, Active__c,
                                              File_Naming_Convention__c, Button_Condition_Field_API_Name__c, Associated_Checkbox_Field_API_Name__c, Display_Order__c
                                       FROM Forms_Controller__c
                                       WHERE Object_API_Name__c = :objApiName
                                       ORDER BY Display_Order__c ASC]) {
            formDetails.forms.add(fc);
        }

        return formDetails;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecordInfo(Id recordId) {
        String objApiName = recordId.getSObjectType().getDescribe().getName();
        List<sObject> records = getRecords(objApiName, 'Id', recordId, null);

        return records;
    }

    @AuraEnabled
    public static List<sObject> getRecords(String objNm, String fieldReference, String fieldValue, String additionalConditions) {
        String mainQueryCondition = fieldReference + ' = ' + '\'' + fieldValue + '\'';
        
        if (additionalConditions != null && String.isNotBlank(additionalConditions)) {
            mainQueryCondition = mainQueryCondition + ' ' + additionalConditions;
        }

        List<sObject> records = ADGLIB_UtilityHelper.getSObjectRecords(objNm, mainQueryCondition, false); 
        return records;
    }

    /**
     * This method to save Form as Attachment to the record
     * And delete signature image file after finishing
     */
    @AuraEnabled
    public static Id saveAttachment(String recordId, String formId, String fileName, String associatedFieldAPINm) {
        system.debug('*** START createAttachment ***');
        Id cdID;
        try {
            // Save form pdf as Attachment to the record
            Blob formContent;
            if (!Test.isRunningTest()) {
               formContent = new PageReference('/apex/SDP_FormControllerPDF?id=' + recordId + '&formId=' + formId).getContentAsPDF();
            } else {
                formContent = Blob.valueOf('Test');
            }
            ContentVersion formCV = new ContentVersion();
            // Create content version
            formCV.ContentLocation = 'S';
            formCV.PathOnClient = '/' + fileName + '.pdf';
            formCV.Origin = 'C';
            formCV.OwnerId = UserInfo.getUserId();
            formCV.Title = fileName + '.pdf';
            formCV.VersionData = formContent;
            insert formCV;

            // After saving the Content Verison, get the ContentDocumentId
            cdID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :formCV.Id].ContentDocumentId;

            // Do this for file to appear on File tab
            ContentDocument cd = [SELECT Description FROM ContentDocument WHERE ID = :cdID];
            cd.Description = fileName;
            update cd;

            // Insert ContentDocumentLink for the file to appear on record's related list
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = cdID;
            cDocLink.LinkedEntityId = recordId;
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'AllUsers';
            insert cDocLink;

            // Update associated checkbox for the record to be checked
            if (String.isNotEmpty(associatedFieldAPINm)) {
                saveRecord(recordId, associatedFieldAPINm, 'true');
            }
        } catch (Exception e) {
            throw new AuraException('Error happen when saving Attachment. Please contact your Administrator for more details!' + e.getMessage());
        }

        system.debug('*** END createAttachment ***');
        return cdID;
    }

    @AuraEnabled
    public static void saveRecord(string recordId, String fieldAPINm, String fieldValue){
        system.debug('*** START saveRecord() ***');

        id objectId = (id)recordId;
        SObject record = objectId.getSobjectType().newSObject(objectId);                                         // re-build record
        Map<String, Schema.SObjectField> objectFields = objectId.getSobjectType().getDescribe().fields.getMap(); // get fields map
        Schema.DescribeFieldResult fieldDescribe = objectFields.get(fieldAPINm).getDescribe();
        String fieldtype = fieldDescribe.getType().name();
        system.debug('Updating for field: ' + fieldAPINm);
        system.debug('Field type: ' + fieldtype);
        switch on fieldtype {
            when 'BOOLEAN' {record.put(fieldAPINm, boolean.valueOf(fieldValue));}
            when 'CURRENCY' {record.put(fieldAPINm, decimal.valueOf(fieldValue));}
            when 'ID' {record.put(fieldAPINm, id.valueOf(fieldValue));}
            when 'INTEGER' {record.put(fieldAPINm, integer.valueOf(fieldValue));}
            when 'LONG' {record.put(fieldAPINm, long.valueOf(fieldValue));}
            when 'PERCENT' {record.put(fieldAPINm, decimal.valueOf(fieldValue));}
            when else {record.put(fieldAPINm, fieldValue);}
        }

        Database.SaveResult sr = Database.update(record, true);
        if (!sr.isSuccess()) throw new AuraException('Error happen when updating record: ' + sr.getErrors()[0].getMessage());
        system.debug('*** END saveRecord() ***');
    }

    public class FormsDefinitionDetails {
        @AuraEnabled public List<Forms_Controller__c> forms {get;set;}
        @AuraEnabled public sObject objInfo {get;set;}

        public FormsDefinitionDetails(String objApiName) {
            this.forms = new List<Forms_Controller__c>();
            this.objInfo = Schema.getGlobalDescribe().get(objApiName).newSObject();
        }
    }
}
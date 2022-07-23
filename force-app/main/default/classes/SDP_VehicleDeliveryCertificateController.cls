public with sharing class SDP_VehicleDeliveryCertificateController {

    @AuraEnabled(cacheable=true)
    public static list<sObject> getRecords(string objectName, string filter, string value, string moreConditions) {
        list<sObject> records = new list<sObject>();
        string mainQueryCondition = ' ' + filter + '=\'' + value + '\' ' + moreConditions;
        system.debug('Query condition from getRecords(): ' + mainQueryCondition);
        records = ADGLIB_UtilityHelper.getSObjectRecords(objectName, mainQueryCondition, false);
        system.debug('Query results from getRecords(): ');
        system.debug(records);
        return records;
    }

    @AuraEnabled
    public static void saveRecord(string recordId, map<string, string> changes){
        system.debug('*** START saveRecord() ***');

        id objectId = (id)recordId;
        SObject record = objectId.getSobjectType().newSObject(objectId); // re-build record
        map<string, Schema.SObjectField> objectFields = objectId.getSobjectType().getDescribe().fields.getMap(); // get fields map

        // get fields description and put to a map
        map<string, Schema.DescribeFieldResult> fieldDescribes = new map<string, Schema.DescribeFieldResult>{};
        for (string fieldName : objectFields.keySet()) {
            fieldDescribes.put(objectFields.get(fieldName).getDescribe().getName(), objectFields.get(fieldName).getDescribe());
        }

        system.debug('Field Describe object:');
        system.debug(fieldDescribes);

        // loop changes list and update record
        for (string changedFieldName : changes.keySet()) {

            // handle special for Car_Collection_Date__c
            if (changedFieldName == 'Car_Collection_Date__c') {
                record.put(changedFieldName, Date.today());
                record.put('Car_Collection_Date_Time__c', DateTime.now());
                system.debug(JSON.serialize(record));
                system.debug('Updating Car_Collection_Date__c with value: ' + string.valueOf(Date.today()));
                continue;
            }

            if (fieldDescribes.get(changedFieldName).isUpdateable()) {
                Schema.DisplayType type = fieldDescribes.get(changedFieldName).getType();
                system.debug('Updating for field: ' + changedFieldName + ' with value: ' + changes.get(changedFieldName));
                system.debug('Field type: ');
                system.debug(type);
                
                // handle for some basic types, excl: date, time, datetime, address, multipicklist
                switch on type {
                    when BOOLEAN {record.put(changedFieldName, boolean.valueOf(changes.get(changedFieldName)));}
                    when CURRENCY {record.put(changedFieldName, decimal.valueOf(changes.get(changedFieldName)));}
                    when ID {record.put(changedFieldName, id.valueOf(changes.get(changedFieldName)));}
                    when INTEGER {record.put(changedFieldName, integer.valueOf(changes.get(changedFieldName)));}
                    when LONG {record.put(changedFieldName, long.valueOf(changes.get(changedFieldName)));}
                    when PERCENT {record.put(changedFieldName, decimal.valueOf(changes.get(changedFieldName)));}
                    when else {record.put(changedFieldName, changes.get(changedFieldName));}
                }
                
            }
        }
        Database.SaveResult sr = Database.update(record, true);
        if (!sr.isSuccess()) throw new AuraException('Error happen when updating SA record: ' + sr.getErrors()[0].getMessage());
        system.debug('*** END saveRecord() ***');
    }

    /**
     -- Handle when user click on Save Certificate button
     */
    @AuraEnabled
    public static void saveCertificate(string recordId, map<string, string> changes){
        system.debug('*** START saveCertificate() ***');
        system.debug('Changes list: ');
        system.debug(changes);
        saveRecord(recordId, changes);
        createOutstandingAccessoriesRecords(recordId, changes.get('VDC_Main_Accessories_Cart__c'), changes.get('VDC_Additional_Accessories_Cart__c'));
        system.debug('*** END saveCertificate() ***');
    }

    /**
     -- Create outstanding accessories record for unselected SA accessories & accessories that is already outstanding
     */
    private static void createOutstandingAccessoriesRecords(string recordId, string mainCart, string additionalCart) {
        system.debug('*** START createOutstandingAccessoriesRecords() ***');
        system.debug('Main cart string: ' + mainCart);
        system.debug('Additional cart string: ' + additionalCart);
        // reduce carts string into list of ID
        list<string> selectedAccessoriesId = new List<String>();
        selectedAccessoriesId.addAll(mainCart.split(','));
        selectedAccessoriesId.addAll(additionalCart.split(','));
        system.debug('Ids of selected accessories: ' + selectedAccessoriesId);

        // query related outstanding accessories record and reduce to list of ID
        list<Outstanding_Accessory__c> outstandingAccs = getRecords('Outstanding_Accessory__c', 'Sales_Agreement__c', recordId, '');
        list<string> outstandingAccessoriesId = new list<string>();
        for (Outstanding_Accessory__c o : outstandingAccs) outstandingAccessoriesId.add(o.SAAccessory__c);
        system.debug('Ids of outstanding accessories: ' + outstandingAccessoriesId);
        
        // query SA Accessories that is main || addional
        list<SA_Accessory__c> accessories = getRecords('SA_Accessory__c', 'Sales_Agreement__c', recordId, 'AND (Accessories_Master__r.AccessoriesGroup__c = \'MAIN ACCESSORIES\' OR Accessories_Master__r.AccessoriesGroup__c = \'ADDITIONAL ACCESSORIES\')');

        // create oustanding accessories record
        list<Outstanding_Accessory__c> newOstAccs = new list<Outstanding_Accessory__c>();
        for (SA_Accessory__c a : accessories) {
            if (!selectedAccessoriesId.contains(a.Id) && !outstandingAccessoriesId.contains(a.Id)) {
                newOstAccs.add(new Outstanding_Accessory__c(SAAccessory__c = a.Id, Sales_Agreement__c = recordId));
            }
        }
        insert newOstAccs;
        system.debug('*** END createOutstandingAccessoriesRecords() ***');
    }

    /**
     -- Render certificate VF page and save as attachment
     */
    @AuraEnabled
    public static Id createAttachment(string recordId) {
        system.debug('*** START createAttachment() ***');

        list<Sales_Agreement__c> sa = getRecords('Sales_Agreement__c', 'Id', recordId, '');
        if (sa.size() < 1) throw new AuraException('Error happen when create attachment: found no SA record with provided ID');
		
        Blob certificateContent = Blob.valueOf('TEST');
        try {
        	certificateContent = new PageReference('/apex/VehicleDeliveryCertificate_pdf?id=' + recordId).getContentAsPDF();    
        } catch (Exception e) {} // do nothing, wrap in try catch block for testing
        
        ContentVersion cv = new ContentVersion();
        ID cdID;
        try {
            // create content version
            cv.ContentLocation = 'S';
            cv.PathOnClient = '/' + sa[0].SOH_SONO__c + '_Vehicle Delivery Certificate.pdf';
            cv.Origin = 'C';
            cv.OwnerId = UserInfo.getUserId();
            cv.Title = sa[0].SOH_SONO__c + '_Vehicle Delivery Certificate.pdf';
            cv.VersionData = certificateContent;
            insert cv;

            //After saved the Content Verison, get the ContentDocumentId
            cdID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

            // do this for file to appear on File tab
            ContentDocument cd = [SELECT Description FROM ContentDocument WHERE ID = :cdID];
            cd.Description = 'Vehicle Delivery Certificate';
            update cd;
            
            // insert ContentDocumentLink for the file to appear on SA's related list
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = cdID;
            cDocLink.LinkedEntityId = sa[0].Id;
            cDocLink.ShareType = 'I';
            cDocLink.Visibility = 'AllUsers';
            insert cDocLink;
        } catch (Exception e) {
            throw new AuraException('Error happen when create attachment: ' + e.getMessage());
        }

        try {
            if(sa[0].DocStatusVehicleDeliveryCertificate__c == null  || !sa[0].DocStatusVehicleDeliveryCertificate__c) {    
                sa[0].DocStatusVehicleDeliveryCertificate__c = true;
                update(sa);
            }
        } catch (Exception e) {
            throw new AuraException('Error happen when ticking VDC checkbox: ' + e.getMessage());
        }

        system.debug('*** END createAttachment() ***');
        return cdID; 
    }

    @AuraEnabled
    public static void sendEmail(String recordId) {
		List<Sales_Agreement__c> sas = getRecords('Sales_Agreement__c', 'Id', recordId, '');

        // Get vehicle delivery certification pdf attachment
        List<ContentDocumentLink> cdlinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Visibility, 
                                                        IsDeleted, ShareType, ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =: recordId AND ContentDocument.Title LIKE '%__Vehicle Delivery Certificate%'
                                             ORDER BY ContentDocument.createdDate DESC NULLS LAST];
        system.debug('------ Content Document Link -----');
        system.debug(cdlinks);
        List<ContentVersion> cvs = getRecords('ContentVersion', 'ContentDocumentId', cdlinks[0].ContentDocumentId, 'ORDER BY ContentModifiedDate');
        // Send email
        Messaging.SingleEmailMessage mail = EmailNotificationsService.renderToEmail(recordId, 'Car_Collection_Email');
        if (cdlinks.size() > 0) {
            List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(cdlinks[0].ContentDocument.Title);
            efa.setBody(cvs[0].VersionData);
            efa.setContentType('application/' + cdlinks[0].ContentDocument.FileType);
            efaList.add(efa);
        	if (!efaList.isEmpty()){
          		mail.setFileAttachments(efaList);
        	}
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>{mail};
        if (mails.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
            if (results[0].success) {
                system.debug('Email sent successfully');
            } else {
                system.debug('Failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}
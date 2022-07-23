/**
 -- Create Date: 27 March 2020
 -- Create By: Mai Phap
 -- Changelog v1.0: prevent __History__.txt & __Changelog__.txt of Sales Agreement record from deleting unless by Admin user
 -- Changelog v1.0: prevent __History__.txt & __Changelog__.txt of Sales Agreement record from changing parentId or Name unless by Admin user
 -- Changelog v1.0: ensure the uniqueness of above files, only 1 attachment of each type per SA record
 */
trigger AttachmentTrigger on Attachment (before delete, before insert, before update) {

    // if (Trigger.isBefore && Trigger.isInsert) {
        
    // }

    // if (Trigger.isBefore && Trigger.isUpdate) {

    // }

    // if (Trigger.isBefore && Trigger.isDelete) {
    //     // boolean isAdmin = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name == 'System Administrator';
    //     // if (isAdmin) return;

    //     list<Attachment> validTriggeredRec = new list<Attachment>();

    //     for (Attachment rec : Trigger.new) {
    //         system.debug('***');
    //         boolean isAttachToSA = rec.parentId.getSobjectType().getDescribe().getName() == 'Sales_Agreement__c';
    //         if (rec.Name != '__History__.txt' || rec.Name != '__Changelog__.txt' || !isAttachToSA) continue;
    //         validTriggeredRec.add(rec);
    //     }
        
    //     if (validTriggeredRec.size() < 1) return;

    //     for (Attachment rec: validTriggeredRec) rec.addError('Unable to delete History or Changelog attachment');
    // }
}
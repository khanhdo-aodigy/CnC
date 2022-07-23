public with sharing class DocuSignRecipients {
    /**
    * Domain layer for DocuSign Recipient object 
    **/
    
    Map<ID, Signing_Group__c> relatedSigningGroups;

    public DocuSignRecipients(List<DocuSign_Recipient__c> newRecords, List<DocuSign_Recipient__c> oldRecords) {
        if (trigger.isDelete) {
            this.relatedSigningGroups = getRelatedSigningGroups(oldRecords);
        } else {
            this.relatedSigningGroups = getRelatedSigningGroups(newRecords);
        }
    }
    
    public DocuSignRecipients(List<DocuSign_Recipient__c> records) {
        this.relatedSigningGroups = getRelatedSigningGroups(records);
    }

    public void handleAfterInsert(List<DocuSign_Recipient__c> newRecords) {
        for (DocuSign_Recipient__c newRecord : newRecords) {
            onAfterInsert(newRecord);
        }
    }

    public void handleAfterDelete(List<DocuSign_Recipient__c> oldRecords) {
        for (DocuSign_Recipient__c oldRecord : oldRecords) {
            onAfterDelete(oldRecord);
        }
    }

    public void handleAfterUpdate(List<DocuSign_Recipient__c> newRecords, Map<Id, DocuSign_Recipient__c> oldRecordsMap) {
        for (DocuSign_Recipient__c newRecord : newRecords) {
            DocuSign_Recipient__c oldRecord = oldRecordsMap.get(newRecord.ID);
            onAfterUpdate(newRecord, oldRecord);
        }
    }

    /**
    * Get the related signing group of triggered recipients
    **/
    private Map<ID, Signing_Group__c> getRelatedSigningGroups(List<DocuSign_Recipient__c> recipientRecords) {
        List<ID> signingGroupIDs = new List<ID>{};
        for (DocuSign_Recipient__c recipientRecord : recipientRecords) {
            signingGroupIDs.add(recipientRecord.Signing_Group__c);
        }
        Map<ID, Signing_Group__c> relatedSigningGroups = new Map<ID, Signing_Group__c> ([SELECT ID, Endorse_Group_ID__c, Approve_Group_ID__c FROM Signing_Group__c WHERE ID IN :signingGroupIDs]);
        return relatedSigningGroups;
    }

    /**
    * if new recipient addedd, make API call to add this new recipient to relevant signing group 
    **/
    private void onAfterInsert(DocuSign_Recipient__c recipientRecord) {
        if (this.relatedSigningGroups.keySet().size() > 0) {
            Signing_Group__c signingGroup = this.relatedSigningGroups.get(recipientRecord.Signing_Group__c);
            string endorseGroupID = signingGroup.Endorse_Group_ID__c;
            string approveGroupID = signingGroup.Approve_Group_ID__c;
            Map<string, string> groupIDByTypes = new Map<string, string> {'Endorser' => endorseGroupID, 'Approver' => approveGroupID};
            Map<string, ID[]> recipientsToUpdate = new Map<string, ID[]> {endorseGroupID => new List<ID>(), approveGroupID => new List<ID>()};

            string newSigningRole = recipientRecord.Signing_Role__c;
            ID newUserID = recipientRecord.User__c;

            if (string.isEmpty(newSigningRole) == false) {
                recipientsToUpdate.get(groupIDByTypes.get(newSigningRole)).add(newUserID);
            }
            recipientsInsert(recipientsToUpdate);
        }
    }

    /**
    * if new recipient deleted, make API call to delete this new recipient to relevant signing group 
    **/
    private void onAfterDelete(DocuSign_Recipient__c recipientRecord) {
        if (this.relatedSigningGroups.keySet().size() > 0) {
            Signing_Group__c signingGroup = this.relatedSigningGroups.get(recipientRecord.Signing_Group__c);
            string endorseGroupID = signingGroup.Endorse_Group_ID__c;
            string approveGroupID = signingGroup.Approve_Group_ID__c;
            Map<string, string> groupIDByTypes = new Map<string, string> {'Endorser' => endorseGroupID, 'Approver' => approveGroupID};
            Map<string, ID[]> recipientsToDelete = new Map<string, ID[]> {endorseGroupID => new List<ID>(), approveGroupID => new List<ID>()};

            string oldSigningRole = recipientRecord.Signing_Role__c;
            string oldUserName = recipientRecord.Recipient_Name__c;
            string oldEmail = recipientRecord.Recipient_Email__c;

            if (string.isEmpty(oldSigningRole) == false) {
                system.debug('[INFO] Delete user : ' + recipientRecord.Recipient_Name__c);
                recipientDelete(groupIDByTypes.get(oldSigningRole), oldUserName, oldEmail);
            }
        }
    }

    /**
    * if new recipient updated, make API call to update this new recipient to relevant signing group 
    **/
    private void onAfterUpdate(DocuSign_Recipient__c newRecord, DocuSign_Recipient__c oldRecord) {
        if (this.relatedSigningGroups.keySet().size() > 0) {
            Signing_Group__c signingGroup = this.relatedSigningGroups.get(newRecord.Signing_Group__c);
            string endorseGroupID = signingGroup.Endorse_Group_ID__c;
            string approveGroupID = signingGroup.Approve_Group_ID__c;
            Map<string, string> groupIDByTypes = new Map<string, string> {'Endorser' => endorseGroupID, 'Approver' => approveGroupID};
            Map<string, ID[]> recipientsToUpdate = new Map<string, ID[]> {endorseGroupID => new List<ID>(), approveGroupID => new List<ID>()};

            string newSigningRole = newRecord.Signing_Role__c;
            string oldSigningRole = oldRecord.Signing_Role__c;

            ID newUserID = newRecord.User__c;
            ID oldUserID = oldRecord.User__c;
            
            string oldUserName = oldRecord.Recipient_Name__c;
            string oldEmail = oldRecord.Recipient_Email__c;
            
            // remove recipient from current signing group when:
            // role changed to --None-- 
            // OR signing role changed
            // OR user changed
            if (string.isEmpty(newSigningRole) == true || newSigningRole != oldSigningRole || oldUserID != newUserID) {
                if (string.isEmpty(newSigningRole) == true)  // role changed to --None--
                    system.debug('[INFO] Remove user : ' + newRecord.Recipient_Name__c + ' because signing role change to --None--');
                else if (newSigningRole != oldSigningRole) // role changed
                    system.debug('[INFO] Remove user : ' + newRecord.Recipient_Name__c + ' because this user has new role');
                else if (oldUserID != newUserID) // user changed
                    system.debug('[INFO] Remove user : ' + newRecord.Recipient_Name__c + ' because the user has changed');
                try {
                    recipientDelete(groupIDByTypes.get(oldSigningRole), oldUserName, oldEmail);
                } catch (Exception e) {
                    system.debug('[INFO] Remove operation fail with error: ' + e.getMessage());
                }
            }

            // add recipient to new signing group when: role changed & new role is not --None--
            if (newSigningRole != oldSigningRole && string.isEmpty(newSigningRole) == false) {
                system.debug('[INFO] Add user : ' + newRecord.Recipient_Name__c + ' to new signing group because signing role changed');
                recipientsToUpdate.get(groupIDByTypes.get(newSigningRole)).add(newUserID);
            }

            // add new recipient when: user changed & new role is not --None--
            if (oldUserID != newUserID && string.isEmpty(newSigningRole) == false && newSigningRole == oldSigningRole) {
                system.debug('[INFO] Add new user : ' + newRecord.Recipient_Name__c + ' to signing group');
                recipientsToUpdate.get(groupIDByTypes.get(newSigningRole)).add(newUserID);
            }

            // perform the API call to update new recipient information
            recipientsInsert(recipientsToUpdate);
        }
    }

    /**
    *  perform the DocuSign API call to insert recipients
    **/ 
    private void recipientsInsert(Map<string, ID[]> recipientsToUpdate) {
        if (recipientsToUpdate.keySet().size() > 0) {
            for (string groupID : recipientsToUpdate.keySet()) {
                EnvelopeSendController.updateSigningGroupsUsers(groupID, recipientsToUpdate.get(groupID), false);
            }
        }
    }

    /**
    * Delete one specific recipient from signing group
    **/
    private void recipientDelete(string groupID, string username, string email) {
        EnvelopeSendController.updateSigningGroupsUser(groupID, username, email , true);
    }
}
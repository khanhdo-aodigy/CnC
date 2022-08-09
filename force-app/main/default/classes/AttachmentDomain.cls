/*==========================================================================================================================================================================
 * Domain class for Attachment Entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          08 Aug 2022                         dangphap.mai@aodigy.com             US-VPO-000024                                       init
 * ========================================================================================================================================================================== 
 */
public with sharing class AttachmentDomain extends ADGLIB_SObjectDomain
{
    public AttachmentDomain(List<Attachment> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new AttachmentDomain(sObjectList);
		}
	}

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
    {
        Map<Id, Attachment> existingAttachments = (Map<Id, Attachment>) existingRecords;
        List<Attachment> updatingAttachments = Records;

        this.checkSnapshotUpdating(existingAttachments, updatingAttachments);
    }

    public override void onBeforeDelete()
    {
        Map<Id, Attachment> existingAttachments = (Map<Id, Attachment>) Trigger.oldMap;

        this.checkSnapshotDeleting(existingAttachments);
    }

    /**
     * ===================================================================================================
     * Only System Admin is allowed to edit attachment with #snapshot description
     * Created By: dangphap.mai@aodigy.com
     * Created Date: 09 Aug 2022
     * ===================================================================================================
     */
    private void checkSnapshotUpdating(Map<Id, Attachment> existingAttachments, List<Attachment> updatingAttachments)
    {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        for (Attachment updatingAttachment : updatingAttachments)
        {
            Attachment existingAttachment = existingAttachments.get(updatingAttachment.Id);

            if (existingAttachment.Description.contains('#snapshot') && UserInfo.getProfileId() != systemAdminProfile.Id)
            {
                updatingAttachment.addError('Only System Admin is allowed to edit snapshot attachment');
            }
        }
    }

    /**
     * ===================================================================================================
     * Only System Admin is allowed to delete attachment with #snapshot description
     * Created By: dangphap.mai@aodigy.com
     * Created Date: 09 Aug 2022
     * ===================================================================================================
     */
    private void checkSnapshotDeleting(Map<Id, Attachment> deletingAttachments)
    {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        for (Attachment deletingAttachment : deletingAttachments.values())
        {
            if (deletingAttachment.Description.contains('#snapshot') && UserInfo.getProfileId() != systemAdminProfile.Id)
            {
                deletingAttachment.addError('Only System Admin is allowed to delete snapshot attachment');
            }
        }
    }
}

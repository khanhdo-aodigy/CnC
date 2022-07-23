/** ******
 * Description : Service Class for Master Approval object
 * 
 * Change History:
 * Date(YYYYMMDD)       Name            Description
 * 20200729            TP@aodigy       Created Initial Version. 
 * 
** ******/

public with sharing  class MasterApprovalService {
    
    private static MasterApprovalSelector masterApprovalSel = new MasterApprovalSelector();
    
    public static Master_Approval__c getMasterApprovalByUniqueKey (String uniqueKey)
    {
        return masterApprovalSel.selectMasterApprovalByUniqueKey(uniqueKey);
    }
}
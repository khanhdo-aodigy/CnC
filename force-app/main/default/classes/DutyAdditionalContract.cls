public inherited sharing class DutyAdditionalContract extends ADGLIB_SObjectDomain {
    public DutyAdditionalContract(List<Duty_Additional_Contract__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new DutyAdditionalContract(sObjectList);
		}
    }

    public override void onAfterUpdate(Map<Id, sObject> previousRecords) {
        processContract(previousRecords, Records);
    }

    /**
     * ==============================================================================================================================================
     * Process for Completed and Sold Contract
     * @param previousRecords: value of records before update
     * @param records: value of records after update
     * Created By: thieudang.vu@aodigy.com
     * Created Date: Sept 2022
     * ===============================================================================================================================================
     */
    private static void processContract(Map<Id, SObject> previousRecords, List<Duty_Additional_Contract__c> records)
    {
        List<String> addnlDutyContractIds = new List<String>();
        Set<String> buyDutyContractIds    = new Set<String>();

        for (Duty_Additional_Contract__c contract : records)
        {
            Duty_Additional_Contract__c oldRecord = (Duty_Additional_Contract__c)previousRecords.get(contract.Id);

            if (contract.Status__c != oldRecord.Status__c&&
                (contract.Status__c == 'Completed' || contract.Status__c == 'Completed (PO Cancel)'))
            {
                addnlDutyContractIds.add(contract.Id);

                buyDutyContractIds.add(contract.Forward_Duty_Contract__c);
            }
        }

        if (addnlDutyContractIds.size() > 0)
        {
            List<sObject> lineItems = TreasuryManagementService.getRecordsByIds('Forward_Duty_Contract_Line_Item__c',
                                                                                TreasuryManagementController.SELECT_FIELDS_BY_OBJECT.get('Forward_Duty_Contract_Line_Item__c'),
                                                                                'Duty_Additional_Contract__c', addnlDutyContractIds);

            TreasuryManagementService.processCompletedContract(lineItems, false);
        }

        if (buyDutyContractIds.size() > 0)
        {
            TreasuryManagementService.processSoldContract('Forward_Duty_Contract_Line_Item__c', 'Forward_Duty_Contract__c', buyDutyContractIds);
        }
    }
}
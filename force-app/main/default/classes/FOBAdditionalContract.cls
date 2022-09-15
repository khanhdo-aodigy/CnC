public inherited sharing class FOBAdditionalContract extends ADGLIB_SObjectDomain {
    public FOBAdditionalContract(List<FOB_Additional_Contract__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
        public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
            return new FOBAdditionalContract(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id, sObject> previousRecords) 
    {
        updateAverageExRateOnSVM(previousRecords, Records);  //Nhung Cao

        processContract(previousRecords, Records);
    }
    /**
     * [29082022] Added by Nhung Cao - US-TMS-0018
     */
    private static void updateAverageExRateOnSVM(Map<Id, SObject> previousRecords, List<FOB_Additional_Contract__c> records)
    {
        
        try
        {   
            List<Id> fobAddIds = new List<Id>();

            for (FOB_Additional_Contract__c contract : records)
            {        
                if (previousRecords.get(contract.Id).get('Status__c') != contract.Status__c && contract.Status__c == 'Completed')
                {
                    fobAddIds.add(contract.Id);
                }
            }
            
            List<Forward_FOB_Contract_Line_Item__c> fobCtrLineItems = new FOBContractLineItemsSelector().getRecordsByFOBAdditionalContractIds(fobAddIds);
            System.debug('fobCtrLineItems' + fobCtrLineItems);
            List<Id> stockVMIds = new List<Id>(); 

            for(Forward_FOB_Contract_Line_Item__c fobLI: fobCtrLineItems)
            {
                stockVMIds.add(fobLI.Stock_Vehicle_Master__c);          
            }
            System.debug('stockVMIds' + stockVMIds);
            Map<Id, Vehicle_Master2__c> relatedSVM = new Map<Id, Vehicle_Master2__c>(
                new StockVehicleMasterSelector().selectRecordsByForUpdateER(stockVMIds)
                );
            System.debug('relatedSVM SVM' + new StockVehicleMasterSelector().selectRecordsByForUpdateER(stockVMIds));
            Map<Id, List<Forward_FOB_Contract_Line_Item__c>> contractLineItemsByStock = new Map<Id, List<Forward_FOB_Contract_Line_Item__c>>();

            List<Vehicle_Master2__c> listToUpdate = new List<Vehicle_Master2__c>();

            for(Vehicle_Master2__c svm: relatedSVM.values())
            {
                System.debug('LOOP 1');
                for (Forward_FOB_Contract_Line_Item__c lineItem : fobCtrLineItems)
                {
                    System.debug('LOOP 2');
                    if(contractLineItemsByStock.keySet().contains(svm.Id))
                    {
                        contractLineItemsByStock.get(svm.Id).add(lineItem);
                        System.debug('contractLineItemsByStock.get(svm.Id)' + contractLineItemsByStock.get(svm.Id));
                    }
                    else
                    {
                        contractLineItemsByStock.put(svm.Id, new List<Forward_FOB_Contract_Line_Item__c> { lineItem });
                        System.debug('lineItem' + lineItem);
                    }
                }
                Forward_FOB_Contract_Line_Item__c updatingContract = contractLineItemsByStock.get(svm.Id)[0];
                System.debug('updatingContract ' + updatingContract);
                svm.Average_Exchange_Rate__c = updatingContract.Average_Exchange_Rate__c;
                System.debug('svm.Average_Exchange_Rate__c ' + svm.Average_Exchange_Rate__c);
                listToUpdate.add(svm);

                system.debug('contractLineItemsByStock.get(svm.Id) === '+ contractLineItemsByStock.get(svm.Id));
            }
            System.debug('successful ');
            
            update listToUpdate;

        }
        catch(Exception e)
        {
            System.debug('Error on Vehicle Master: ' + e.getMessage() + e.getLineNumber());
            System.debug('Error Stack Trace on Vehicle Master: ' + e.getStackTraceString());
        }
    }

    /**
     * ==============================================================================================================================================
     * Group @stocks by a @groupingField
     * @param previousRecords: value of records before update
     * @param records: value of records after update
     * Created By: thieudang.vu@aodigy.com
     * Created Date: Sept 2022
     * ===============================================================================================================================================
     */
    private static void processContract(Map<Id, SObject> previousRecords, List<FOB_Additional_Contract__c> records)
    {
        List<String> addnlFOBContractIds = new List<String>();
        Set<String> buyFOBContractIds    = new Set<String>();
        
        for (FOB_Additional_Contract__c contract : records)
        {
            FOB_Additional_Contract__c oldRecord = (FOB_Additional_Contract__c)previousRecords.get(contract.Id);

            if (contract.Status__c != oldRecord.Status__c &&
                (contract.Status__c == 'Completed' || contract.Status__c == 'Completed (PO Cancel)'))
            {
                addnlFOBContractIds.add(contract.Id);

                buyFOBContractIds.add(contract.Forward_FOB_Contract__c);
            }            
        }
        

        if (addnlFOBContractIds.size() > 0)
        { 
            List<sObject> lineItems = TreasuryManagementService.getRecordsByIds('Forward_FOB_Contract_Line_Item__c',
                                                                                TreasuryManagementController.SELECT_FIELDS_BY_OBJECT.get('Forward_FOB_Contract_Line_Item__c'),
                                                                                'FOB_Additional_Contract__c', addnlFOBContractIds);

            TreasuryManagementService.processCompletedContract(lineItems, true);
        }

        if (buyFOBContractIds.size() > 0)
        {
            TreasuryManagementService.processSoldContract('Forward_FOB_Contract_Line_Item__c', 'Forward_FOB_Contract__c', buyFOBContractIds);
        }
    }
}
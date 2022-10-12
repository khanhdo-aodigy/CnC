public inherited sharing class ForwardFOBContract extends ADGLIB_SObjectDomain {
    public ForwardFOBContract (List<Forward_FOB_Contract__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
        public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
            return new ForwardFOBContract(sObjectList);
        }
    }

    public override void onAfterUpdate(Map<Id, sObject> previousRecords) {
        processAdvancePayment(previousRecords);
    }

    private void processAdvancePayment(Map<Id, sObject> previousRecords)
    {
        String transactionDateStr;
        Date transactionDate;
        Date dToday     = Date.today();
        String todayStr = dToday.year() + '-' + dToday.month() + '-' + dToday.day();

        FOB_Additional_Contract__c newAddnlContract;
        Map<Id, FOB_Additional_Contract__c> addnlContractByFOBIds = new Map<Id, FOB_Additional_Contract__c>();
        List<String> buyContractIds = new List<String>();

        for (Forward_FOB_Contract__c record : (List<Forward_FOB_Contract__c>)Records)
        {
            Forward_FOB_Contract__c oldContract = (Forward_FOB_Contract__c)previousRecords.get(record.Id);
            
            if (record.Forward_Contract_Buy_Approved__c != oldContract.Forward_Contract_Buy_Approved__c &&
                record.Forward_Contract_Buy_Approved__c == true && record.Cover_Percentage__c == 100)
            {
                buyContractIds.add(record.Id);

                transactionDate   = record.Transaction_Date__c;
                transactionDateStr = transactionDate.year() + '-' + transactionDate.month() + '-' + transactionDate.day();

                newAddnlContract = new FOB_Additional_Contract__c();

                newAddnlContract.Forward_FOB_Contract__c          = record.Id;
                newAddnlContract.Status__c                        = 'Completed';
                newAddnlContract.Bank_Contract_No_Sell_Execute__c = record.Bank_Contract_No__c;
                newAddnlContract.Effective_Date_Sell_Execute__c   = TreasuryManagementService.getDate(todayStr);
                newAddnlContract.Transaction_Date_Sell_Execute__c = TreasuryManagementService.getDate(transactionDateStr);
                newAddnlContract.Spot_Rate_Sell_Execute__c        = record.Spot_Rate__c;

                addnlContractByFOBIds.put(record.Id, newAddnlContract);
            }
        }

        Database.insert(addnlContractByFOBIds.values(), false);

        if (buyContractIds.size() > 0)
        {
            Map<Id, FOB_Additional_Contract__c> addnlContractByIds = new Map<Id, FOB_Additional_Contract__c>();

            for (FOB_Additional_Contract__c addnlContract : addnlContractByFOBIds.values())
            {
                addnlContractByIds.put(addnlContract.Id, addnlContract);
            }
    
            Map<Id, List<Forward_FOB_Contract_Line_Item__c>> lineItemsByAddnlContractIds = new Map<Id, List<Forward_FOB_Contract_Line_Item__c>>();
            
            List<sObject> lineItems = TreasuryManagementService.getRecordsByIds('Forward_FOB_Contract_Line_Item__c', TreasuryManagementController.SELECT_FIELDS_BY_OBJECT.get('Forward_FOB_Contract_Line_Item__c'),
                                                                                'Forward_FOB_Contract__c', buyContractIds);
    
            for (Forward_FOB_Contract_Line_Item__c item : (List<Forward_FOB_Contract_Line_Item__c>)lineItems)
            {
                item.FOB_Additional_Contract__c = addnlContractByFOBIds.get(item.Forward_FOB_Contract__c).Id;

                if (lineItemsByAddnlContractIds.containsKey(item.FOB_Additional_Contract__c))
                {
                    lineItemsByAddnlContractIds.get(item.FOB_Additional_Contract__c).add(item);
                }
                else
                {
                    lineItemsByAddnlContractIds.put(item.FOB_Additional_Contract__c, new List<Forward_FOB_Contract_Line_Item__c>{item});
                }
            }

            Database.update(lineItems, false);
    
            List<FOB_Additional_Contract__c> updatedFOBAddnlContracts = new List<FOB_Additional_Contract__c>();
    
            for (Id addnlContractId : lineItemsByAddnlContractIds.keySet())
            {
                List<Forward_FOB_Contract_Line_Item__c> contractLineItems = lineItemsByAddnlContractIds.get(addnlContractId);
 
                sObject addnlContract = TreasuryManagementService.calculateContractAmounts(contractLineItems, 'FOB_Additional_Contract__c', addnlContractByIds.get(addnlContractId));
    
                updatedFOBAddnlContracts.add((FOB_Additional_Contract__c)addnlContract);
            }
    
            Database.update(updatedFOBAddnlContracts, false);
        }
    }
}
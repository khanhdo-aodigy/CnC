/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: 
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      
 *      
 * ========================================================================================================================================================================== 
 */
public inherited sharing class TreasuryManagementService {
    public static List<sObject> getRecordsByIds(String objNm, List<String> selectFields, String fieldRef, List<String> recIds)
    {
        ADGLIB_QueryFactory factory;

        factory = new ADGLIB_QueryFactory(getObjectToken(objNm));
        factory.selectFields(selectFields);

        if (String.isNotBlank(fieldRef))
        {
            String addnlQueryCondition = fieldRef + ' IN (' + String.join(addQuotationMark(recIds), ',') + ')';
 
            factory.setCondition(addnlQueryCondition);
        }

        return Database.query(factory.toSOQL());
    }

    public static sObject calculateContractAmounts(List<sObject> lineItems, String contractObjAPI, sObject contractRec)
    {
        Boolean isBuyContract      = (contractObjAPI == 'Forward_FOB_Contract__c' || contractObjAPI == 'Forward_Duty_Contract__c');
        Boolean isFOBAddnlContract = contractObjAPI == 'FOB_Additional_Contract__c';

        Decimal totalContractAmt, totalExecAmt, totalCoverAmtUSD, totalCoverAmtSpotRate, totalCoverAmtContractRate, totalSpotContractAmt;

        if (isBuyContract)
        {
            totalContractAmt = 0;
        }
        else
        {
            totalCoverAmtUSD          = 0;
            totalExecAmt              = 0;
            totalCoverAmtSpotRate     = 0;
            totalCoverAmtContractRate = 0;

            if (isFOBAddnlContract)
            {
                totalSpotContractAmt = 0;
            }
        }

        for (sObject item : lineItems)
        {
            if (isBuyContract)
            {
                Decimal itemCoverAmt = (Decimal)item.get('Cover_Amount_Foreign__c') == null ? 0 : (Decimal)item.get('Cover_Amount_Foreign__c');
                totalContractAmt += itemCoverAmt;
            }
            else
            {
                Decimal itemExecAmt = (Decimal)item.get('Execution_Amount__c') == null ? 0 : (Decimal)item.get('Execution_Amount__c');
                totalExecAmt += itemExecAmt;
    
                Decimal itemCoverAmtUSD = (Decimal)item.get('Cover_Amount_Foreign__c') == null ? 0 : (Decimal)item.get('Execution_Amount__c');
                totalCoverAmtUSD += itemCoverAmtUSD;
    
                Decimal itemCoverAmtSpotRate = (Decimal)item.get('Cover_Amount_Spot_Rate__c');
                totalCoverAmtSpotRate += itemCoverAmtSpotRate;
    
                Decimal itemCoverAmtContractRate = (Decimal)item.get('Cover_Amount_Contract_Rate__c');
                totalCoverAmtContractRate += itemCoverAmtContractRate;

                if (isFOBAddnlContract)
                {
                    Decimal itemSpotContractAmt = (Decimal)item.get('Spot_Contract_Amount__c');
                    totalSpotContractAmt += itemSpotContractAmt;
                }
            }
        }

        if (isBuyContract)
        {
            contractRec.put('Total_Contract_Amount__c', totalContractAmt);
        }
        else
        {
            contractRec.put('Total_Execution_Amount__c', totalExecAmt);
            contractRec.put('Total_Cover_Amount_In_Currency__c', totalCoverAmtUSD);
            contractRec.put('Total_Cover_Amount_Spot_Rate__c', totalCoverAmtSpotRate);
            contractRec.put('Total_Cover_Amount_Contract_Rate__c', totalCoverAmtContractRate);

            if (isFOBAddnlContract)
            {
                contractRec.put('Total_Spot_Contract_Amount__c', totalSpotContractAmt);
            }
        }

        contractRec.put('Quantity__c', lineItems.size());

        return contractRec;
    }

    public static void processSoldContract(String lineItemObjAPI, String contractObjAPI, Set<String> contractIds)
    {
        Map<Id, List<sObject>> cliByContractIds = new Map<Id, List<sObject>>();
 
        for (sObject cli : getRecordsByIds(lineItemObjAPI, new List<String>{contractObjAPI, 'Status__c'}, contractObjAPI, new List<String>(contractIds)))
        {
            Id contractId = (Id)cli.get(contractObjAPI);

            if (cliByContractIds.containsKey(contractId))
            {
                cliByContractIds.get(contractId).add(cli);
            }
            else
            {
                cliByContractIds.put(contractId, new List<sObject>{cli});
            }
        }

        List<sObject> contracts = getRecordsByIds(contractObjAPI, new List<String>{'Status__c'}, 'Id', new List<String>(contractIds));

        for (sObject contract : contracts)
        {
            Id contractId           = (Id)contract.get('Id');
            List<sObject> lineItems = cliByContractIds.get(contractId);
            Boolean validStatus     = checkAllLineItemsStatus(lineItems);
            if (validStatus)
            {
                contract.put('Status__c', 'Sold');
            }
        }

        Database.update(contracts, false);
    }

    public static void processCompletedContract(List<sObject> lineItems, Boolean isFOBContract)
    {
        String status;
        Set<Id> stockIds = new Set<Id>();
        String fieldAPI  = isFOBContract ? 'FOB_Done__c' : 'Duty_Done__c';
 
        for (sObject item : lineItems)
        {
            stockIds.add((Id)item.get('Stock_Vehicle_Master__c'));
        }

        if (stockIds.size() > 0)
        {
            List<Vehicle_Master2__c> stocks = new StockVehicleMasterSelector().getRecordsByIds(new List<Id>(stockIds));

            for (Vehicle_Master2__c stock : stocks)
            {
                stock.put(fieldAPI, true);
            }

            Database.update(stocks, false);
        }
    }

    public static Map<String, Schema.DescribeFieldResult> getFieldDescription(String objNm)
    {
        Map<String, Schema.SObjectField> fieldTokens = getFieldTokens(getObjectToken(objNm));
 
        Map<String, Schema.DescribeFieldResult> fieldDescription = new map<String, Schema.DescribeFieldResult>();

        for (String fieldName : fieldTokens.keySet())
        {
            fieldDescription.put(fieldTokens.get(fieldName).getDescribe().getName(), fieldTokens.get(fieldName).getDescribe());
        }

        return fieldDescription;
    }

    public static Date getDate(String dateLiteral)
    {
        if (dateLiteral == null) return null;

        List<String> dateComponents = dateLiteral.split('-');
        Integer yyyy = Integer.valueOf(dateComponents[0]);
        Integer mm   = Integer.valueOf(dateComponents[1]);
        Integer dd   = Integer.valueOf(dateComponents[2]);

        return Date.newInstance(yyyy, mm, dd);
    }

    private static Boolean checkAllLineItemsStatus(List<sObject> lineItems)
    {
        String status;
 
        for (sObject item : lineItems)
        {
            status = (String)item.get('Status__c');

            if (status != 'Completed' && status != 'Forward Contract Sell' && 
                status != 'Forward Contract Duty Sale' && status != 'Completed (PO Cancel)') {

                    return false;
            }
        }
        
        return true;
    }

    private static List<String> addQuotationMark(List<String> lstr)
    {
        List<String> results = new List<String>();

        for (String str : lstr)
        {
            results.add('\'' + str + '\'');
        }

        return results;
    }

    private static Schema.SObjectType getObjectToken(String objNm)
    {
        return Schema.getGlobalDescribe().get(objNm);
    }

    private static Map<String, Schema.SObjectField> getFieldTokens(Schema.SObjectType token)
    {
        return token.getDescribe().fields.getMap();
    }
}
/*==========================================================================================================================================================================
 * Selector class for Vehicle Purchase Order Entity
 * Created By: Aodigy Team
 * Create Date: 
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      
 *      23 August 2022                      nhung.cao@aodigy.com                    US-TMS-0001/003/004/005
 * ========================================================================================================================================================================== 
 */

public without sharing class TreasuryManagementController {
    public static final Map<String, List<String>> SELECT_FIELDS_BY_OBJECT = new Map<String, List<String>>{
                                                                                                            'Forward_FOB_Contract__c'    => new List<String>{'Total_Contract_Amount__c','Cover_Percentage__c','Spot_Rate__c','Bank_Contract_No__c','Transaction_Date__c', 'Quantity__c'},
                                                                                                            'Forward_Duty_Contract__c'   => new List<String>{'Total_Contract_Amount__c','Cover_Percentage__c', 'Quantity__c'},
                                                                                                            'FOB_Additional_Contract__c' => new List<String>{'Total_Execution_Amount__c','Total_Cover_Amount_In_Currency__c','Total_Cover_Amount_Contract_Rate__c',
                                                                                                                                                             'Total_Cover_Amount_Contract_Rate__c','Total_Spot_Contract_Amount__c','Status__c'},
                                                                                                            'Duty_Additional_Contract__c'=> new List<String>{'Total_Execution_Amount__c','Total_Cover_Amount_In_Currency__c','Total_Cover_Amount_Contract_Rate__c',
                                                                                                                                                             'Total_Cover_Amount_Contract_Rate__c','Status__c'},
                                                                                                            'Vehicle_Master2__c'         => new List<String>{'FOB_Amount__c','Estimated_FOB__c','Duty_Amount__c','Estimated_Duty__c'},
                                                                                                            'Forward_FOB_Contract_Line_Item__c' => new List<String>{'Execution_Amount__c','Cover_Amount_Foreign__c','Hedging_Gain_Loss__c','Stock_Vehicle_Master__c','Cover_Amount_Spot_Rate__c',
                                                                                                                                                                    'Cover_Amount_Contract_Rate__c','Gain_Loss__c','Status__c','Spot_Contract_Amount__c','Forward_FOB_Contract__c','Spot_Contract_Amount__c'},
                                                                                                            'Forward_Duty_Contract_Line_Item__c' => new List<String>{'Execution_Amount__c','Cover_Amount_Foreign__c','Hedging_Gain_Loss__c','Stock_Vehicle_Master__c','Forward_Duty_Contract__c',
                                                                                                                                                                    'Cover_Amount_Spot_Rate__c','Cover_Amount_Contract_Rate__c','Gain_Loss__c','Status__c'}
                                                                                                        };
    public static final Map<String, Set<String>> LIGHTNING_DATA_TYPE_MAP  = new Map<String, Set<String>>{
                                                                                                            'text'     => new Set<String>{'address', 'id', 'phone', 'email', 'string', 'textarea'},
                                                                                                            'date'     => new Set<String>{'date', 'datetime'},
                                                                                                            'number'   => new Set<String>{'double', 'integer', 'percent'},
                                                                                                            'currency' => new Set<String>{'currency'},
                                                                                                            'url'      => new Set<String>{'url'},
                                                                                                            'boolean'  => new Set<String>{'boolean'}
                                                                                                        };

    @AuraEnabled(cacheable=true)
    public static DataTableWrapper construcDataTable(Id parentRecId, String targetObjNm, String selectFieldsNm, Integer limitSize, Id currentRecId, String addnlCondition)
    {
        String parentObjNm        = parentRecId.getSObjectType().getDescribe().getName();
        String mainQueryCondition = 'SELECT ' + selectFieldsNm + ' FROM ' + targetObjNm + ' WHERE ' + parentObjNm + ' = ' + '\'' + parentRecId + '\'';

        if (String.isNotBlank(currentRecId))
        {
            mainQueryCondition += ' AND Id > ' + '\'' + currentRecId + '\'';
        }

        if (String.isNotBlank(addnlCondition))
        {
            mainQueryCondition += addnlCondition;
        }

        mainQueryCondition += ' ORDER BY Id ASC NULLS LAST';

        if (limitSize != null && limitSize > 0)
        {
            mainQueryCondition += ' LIMIT '+ limitSize;
        }

        List<sObject> records;
        try
        {
            records = Database.query(mainQueryCondition);
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }

        Map<String, Schema.DescribeFieldResult> descriptions = TreasuryManagementService.getFieldDescription(targetObjNm);

        DataTableWrapper dtw                    = new DataTableWrapper();
        List<FieldDescriptionWrapper> fieldList = new List<FieldDescriptionWrapper>();
        Map<String, String> fieldRelNmByObj     = new Map<String, String>();
        Set<String> fieldNmSet                  = new Set<String>(selectFieldsNm.split(','));
        Set<String> objNms                      = new Set<String>();

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(targetObjNm).getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet())
        {
            if (fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE)
            {
                for (Schema.SObjectType reference : fieldMap.get(fieldName).getDescribe().getReferenceTo())
                {
                    String rFieldNm = fieldMap.get(fieldName).getDescribe().getName().replace('__c', '__r').removeEnd('Id');
                    fieldRelNmByObj.put(rFieldNm, reference.getDescribe().getName());
                }
            }
        }

        for (String fieldNm : fieldNmSet)
        {
            if (!fieldNm.contains('.')) continue;

            List<String> fieldRelNms = fieldNm.split('\\.');

            if (fieldRelNms.size() > 2) throw new AuraHandledException('Merged fields from 2 levels and above are not supported!');

            objNms.add(fieldRelNmByObj.get(fieldRelNms[0]));
        }

        Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescriptionByObjNm = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        Map<String, Schema.DescribeFieldResult> fieldsDesc;

        for (Schema.DescribeSObjectResult objectDesc : Schema.describeSObjects(new List<String>(objNms)))
        {
            fieldsDesc = new Map<String, Schema.DescribeFieldResult>();
 
            Map<String, Schema.SObjectField> fieldTokens = objectDesc.fields.getMap();

            for (String fieldName : fieldTokens.keySet())
            {
                fieldsDesc.put(fieldTokens.get(fieldName).getDescribe().getName(), fieldTokens.get(fieldName).getDescribe());
            }

            fieldDescriptionByObjNm.put(objectDesc.getName(), fieldsDesc);
        }

        for (String fieldNm : fieldNmSet)
        {
            if (descriptions.containsKey(fieldNm))
            {
                String fieldType = descriptions.get(fieldNm).getType().name();

                fieldList.add(new FieldDescriptionWrapper(descriptions.get(fieldNm).getLabel(), fieldNm, convertToLightningDataType(fieldType), false, false, false, false));
            }
            else
            {
                String objRelNm         = fieldNm.split('\\.')[0];
                String lookupFieldAPINm = fieldNm.split('\\.')[1];
                String objNm            = fieldRelNmByObj.get(objRelNm);
 
                Map<String, Schema.DescribeFieldResult> descByObjNm = fieldDescriptionByObjNm.get(objNm);
                if (descByObjNm.containsKey(lookupFieldAPINm))
                {
                    String labelField;
                    String fieldType;
                    if (lookupFieldAPINm == 'Name')
                    {
                        labelField = objRelNm.removeEnd('__r').replace('_',' ');
                        fieldType  = 'url';
                    }
                    else
                    {
                        labelField = objRelNm.removeEnd('__r').replace('_',' ') + '.' + descByObjNm.get(lookupFieldAPINm).getLabel();
                        fieldType  = descByObjNm.get(lookupFieldAPINm).getType().name();
                    }

                    fieldList.add(new FieldDescriptionWrapper(labelField, fieldNm.deleteWhitespace(), convertToLightningDataType(fieldType),
                                                              false, false, false, true));
                }
            }
        }

        dtw.fdwList    = fieldList;
        dtw.sobList    = records;
        dtw.totalCount = Database.countQuery('SELECT count() FROM ' + targetObjNm + ' WHERE ' + parentObjNm + ' = ' + '\'' + parentRecId + '\'' + addnlCondition);

        return dtw;
    }

    @AuraEnabled
    public static List<sObject> getRecordsByIds(String objNm, List<String> selectFields, String fieldRef, List<String> recIds)
    {
        return TreasuryManagementService.getRecordsByIds(objNm, selectFields, fieldRef, recIds);
    }

    @AuraEnabled
    public static void processBuyContract(Map<String, String> buyContractInfo, List<String> stockIds, String buyContractObjAPI, String lineItemObjAPI)
    {
        Savepoint sp = Database.setSavepoint();

        sObject buyContract = constructNewSObject(buyContractObjAPI, buyContractInfo);

        try
        {
            insert buyContract;

            Id buyContractId        = (Id)buyContract.get('Id');
            Decimal coverPercentage = (Decimal)buyContract.get('Cover_Percentage__c') / 100;
            system.debug('11111111111: ' + buyContractId);
            system.debug('aaaaaaaaaaaaaaaa: ' + coverPercentage);
            List<sObject> lineItems = newLineItems(stockIds, coverPercentage, lineItemObjAPI, buyContractObjAPI, buyContractId);

            insert lineItems;

            buyContract = buyContractCalculation(lineItems, buyContract);

            update buyContract;
        }
        catch (Exception e)
        {
            Database.rollback(sp);
 
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static sObject processAddnlContract(Map<String, String> addnlContractInfo, List<String> lineItemIds, String lineItemObjAPI, Id contractId)
    {
        Savepoint sp = Database.setSavepoint();

        String contractObjAPI, addnlContractObjAPI;
        if (lineItemObjAPI == 'Forward_FOB_Contract_Line_Item__c')
        {
            contractObjAPI      = 'Forward_FOB_Contract__c';
            addnlContractObjAPI = 'FOB_Additional_Contract__c';
        }
        else
        {
            contractObjAPI      = 'Forward_Duty_Contract__c';
            addnlContractObjAPI = 'Duty_Additional_Contract__c';            
        }

        sObject addnlContract = constructNewSObject(addnlContractObjAPI, addnlContractInfo);
        addnlContract.put(contractObjAPI, contractId);

        try
        {
            insert addnlContract;

            Set<String> svmIds                 = new Set<String>();
            Set<String> buyContractIds         = new Set<String>();
            Map<Id, List<sObject>> cliBySVMIds = new Map<Id, List<sObject>>();

            List<sObject> lineItems = getRecordsByIds(lineItemObjAPI, SELECT_FIELDS_BY_OBJECT.get(lineItemObjAPI), 'Id', lineItemIds);

            for (sObject cli : lineItems)
            { 
                svmIds.add((Id)cli.get('Stock_Vehicle_Master__c'));
    
                buyContractIds.add((Id)cli.get(contractObjAPI));
    
                cli.put(addnlContractObjAPI, (Id)addnlContract.get('Id'));
            }

            update lineItems;

            lineItems = getRecordsByIds(lineItemObjAPI, SELECT_FIELDS_BY_OBJECT.get(lineItemObjAPI), 'Id', lineItemIds);

            addnlContract = TreasuryManagementService.calculateContractAmounts(lineItems, addnlContractObjAPI, addnlContract);

            String contractStatus = (String)addnlContract.get('Status__c');

            if (contractStatus == 'Forward Contract Sell' || contractStatus == 'Forward Contract Duty Sale' || contractStatus == 'PO Cancellation')
            {
    
                TreasuryManagementService.processSoldContract(lineItemObjAPI, contractObjAPI, buyContractIds);

                List<sObject> svms = calculateGainLoss(svmIds, lineItemObjAPI, addnlContractObjAPI);
 
                update svms;
            }

            update addnlContract;

            return addnlContract;
        }
        catch (Exception e)
        {
            Database.rollback(sp);

            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void reCalculateAmounts(Id contractId)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Forward_FOB_Contract__c.SObjectType, Forward_Duty_Contract__c.SObjectType,
                                                                                              FOB_Additional_Contract__c.SObjectType, Duty_Additional_Contract__c.SObjectType });

        String contractObjAPI = contractId.getSObjectType().getDescribe().getName();
        String lineItemObjNm  = contractObjAPI == 'FOB_Additional_Contract__c' || contractObjAPI == 'Forward_FOB_Contract__c' ? 'Forward_FOB_Contract_Line_Item__c' : 'Forward_Duty_Contract_Line_Item__c';

        List<sObject> lineItems = getRecordsByIds(lineItemObjNm, SELECT_FIELDS_BY_OBJECT.get(lineItemObjNm), contractObjAPI, new List<String>{contractId});

        sObject contract = getRecordsByIds(contractObjAPI, SELECT_FIELDS_BY_OBJECT.get(contractObjAPI), 'Id', new List<String>{contractId})[0];

        sObject addnlContract = TreasuryManagementService.calculateContractAmounts(lineItems, contractObjAPI, contract);

        try
        {
            uow.registerDirty(addnlContract);
            uow.commitWork();
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean validateBuyContract(String poId, String buyContractObjAPI)
    {
        List<sObject> records = getRecordsByIds(buyContractObjAPI, new List<String>{'Status__c'}, 'Purchase_Order__c', new List<String>{poId});

        for (sObject rec : records)
        {
            if (rec.get('Status__c') == 'Active')

            return false;
        }

        return true;
    }

    /*
    * [23082022] Added by Nhung Cao - US-TMS-0001
    * Search VPO by Franchise and Production Month
    */
    @AuraEnabled
    public static List<Vehicle_Purchase_Order__c> searchVehiclePurchaseOrder(String franchise, Date productionMonth)
    {
        List<Vehicle_Purchase_Order__c> result = new List<Vehicle_Purchase_Order__c>();

        try{
            List<Vehicle_Purchase_Order__c> searchRs = new VehiclePurchaseOrderSelector().selectVPObyFranchiseAndProductionMonth(franchise,productionMonth);

            for(Vehicle_Purchase_Order__c vpo: searchRs)
            {
                List<Vehicle_Master2__c> svmOnVPO = vpo.Stock_Vehicle_Masters__r;

                if(vpo.TMS_Purchase_Order__c == null && (vpo.Stage__c == 'Closed' || vpo.Stage__c == 'Manufacturer_Confirmed') && svmOnVPO != null)
                {    
                    result.add(vpo);                   
                }                
            }
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }

        return result;        
    }

    /**
     * [23082022] Added by Nhung Cao - US-TMS-0003/0004/005
     * Create TMS PO record from VPO Selection UI during TMS PO creation
     */
    @AuraEnabled
    public static Id createTMSPurchaseOrder(List<Id> vpoIds)
    {
        Purchase_Order__c newPO = new Purchase_Order__c();        

        List<Vehicle_Purchase_Order__c> vpoListForLookup = new VehiclePurchaseOrderSelector().selectVPO_WithRelatedSVM(vpoIds);

        newPO.Franchise__c = vpoListForLookup[0].Franchise_Code__c;

        newPO.Production_Month__c = vpoListForLookup[0].Production_Month__c;

        insert newPO;  
        
        Integer counter = 0;

        List<Vehicle_Master2__c> svmListForLookup = new List<Vehicle_Master2__c>();

        for(Vehicle_Purchase_Order__c vpo: vpoListForLookup)
        {   
            vpo.put('TMS_Purchase_Order__c', newPo.Id);           

            for(Vehicle_Master2__c svm: vpo.Stock_Vehicle_Masters__r)
            {
                if(svm.Vehicle_Purchase_Status__c != 'SCL_Cancel')
                {                    
                    // svm.put('Purchase_Order__c', newPo.Id);
                    svm.Purchase_Order__c = newPo.Id;

                    svmListForLookup.add(svm);

                    counter += 1;
                }
            }
        }

        newPO.Total_Quantity__c = counter;

        update newPO;

        try
        {            
            if(vpoListForLookup.size()>0)
            {
                update vpoListForLookup;
            }

            if(svmListForLookup.size()>0)
            {
                update svmListForLookup;
            }
        } 
        catch (AuraHandledException e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());            
        }
        return newPo.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<TMSPOWrapper> searchTMSPOGroup(String franchise, Date productionMonth)
    {
        system.debug('franchise :: ' + franchise);
        system.debug('productionMonth :: ' + productionMonth);        
        List<TMSPOWrapper> tmsPOWrappers = new List<TMSPOWrapper>();
        
        try
        {
            List<Purchase_Order__c> tmsPOs = new TMSPurchaseOrderSelector().selectTMSPObyFranchiseAndProductionMonth(franchise,productionMonth);  
            System.debug('tmsPOs = ' + tmsPOs);

            List<Id> poIdList = new List<Id>(); 
            System.debug('poIdList = ' + poIdList); 
            for(Purchase_Order__c po:tmsPOs)    
            {
                poIdList.add(po.Id);
            }
            System.debug('poIdList = ' + poIdList);

            List<Forward_FOB_Contract__c> newListFOB = new ForwardFOBContractSelector().selectFOBAddContract(poIdList);
           
            System.debug('poIdList = ' + poIdList.size());
            System.debug('newListFOB = ' + newListFOB);
            
            Map<Id, List<FOB_Additional_Contract__c>> faMap = new Map<Id, List<FOB_Additional_Contract__c>>();

            for(Forward_FOB_Contract__c fContract:newListFOB)
            {
                List<FOB_Additional_Contract__c> newfAList = fContract.FOB_Additional_Contracts__r;
                faMap.put(fContract.Id, newfAList);
                System.debug('newfAList = ' + newfAList);
            } 
            System.debug('faMap = ' + faMap);
            for(Purchase_Order__c po: tmsPOs)
            {
                TMSPOWrapper tmsPOWrapper = new TMSPOWrapper();
                List<FOBContractWrapper> fWrappers = new List<FOBContractWrapper>();
                List<DutyContractWrapper> dWrappers = new List<DutyContractWrapper>();

                tmsPOWrapper.tmsRecord = po;
                System.debug('tmsPOWrapper.tmsPOs = ' + tmsPOWrapper.tmsRecord);

                for(Vehicle_Purchase_Order__c vpo: po.Vehicle_Purchase_Orders__r)
                {
                    tmsPOWrapper.vpoList.add(vpo);        
                }
                System.debug('tmsPOWrapper.vpoList = ' + tmsPOWrapper.vpoList);
                
                for(Forward_FOB_Contract__c fob: po.Forward_Contracts_FOB__r)
                {                    
                    FOBContractWrapper fWrapper = new FOBContractWrapper();
                    fWrapper.fobContract = fob;
                    fWrapper.fobAddContracts = faMap.get(fob.Id);
                    System.debug('faMapget(fob.Id) ====' + faMap.get(fob.Id) );
                    System.debug('fWrapper.fobAddContracts = ' + fWrapper.fobAddContracts);
                    fWrappers.add(fWrapper);
                    System.debug('fWrapper = ' + fWrapper);                     
                }
                System.debug('fWrappers = ' + fWrappers);
                for(Forward_Duty_Contract__c duty: po.Forward_Duty_Contracts__r )
                {                    
                    DutyContractWrapper dWrapper = new DutyContractWrapper();
                    dWrapper.dutyContract = duty;
                    dWrapper.dutyAddContracts = duty.Duty_Additional_Contracts__r;
                    dWrappers.add(dWrapper);
                    System.debug('dWrapper = ' + dWrapper);                                
                }
                System.debug('dWrappers = ' + dWrappers);

                tmsPOWrapper.fobWrappers = fWrappers;
                tmsPOWrapper.dutyWrappers = dWrappers;
                tmsPOWrappers.add(tmsPOWrapper);

                System.debug('tmsPOWrapper.fobWrappers = ' + tmsPOWrapper.fobWrappers);
                System.debug('tmsPOWrapper.dutyWrappers = ' + tmsPOWrapper.dutyWrappers);
                System.debug('tmsPOWrapper = ' + tmsPOWrapper);
            }
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());            
        }
        System.debug('TMS Wrapper = ' + tmsPOWrappers);   
        System.debug('JSON TMS Wrapper = ' + JSON.serialize(tmsPOWrappers));       
          
        
        return tmsPOWrappers;     
    }

    private static sObject buyContractCalculation(List<sObject> lineItems, sObject buyContract)
    {
        Decimal totalContractAmt = 0;

        for (sObject cli : lineItems)
        {
            totalContractAmt += (Decimal)cli.get('Cover_Amount_Foreign__c');
        }

        buyContract.put('Total_Contract_Amount__c', totalContractAmt);
        buyContract.put('Quantity__c', lineItems.size());

        return buyContract;
    }

    private static List<sObject> newLineItems(List<String> stockIds, Decimal coverPercentage, String lineItemObjAPI, String buyContractObjAPI, String buyContractId)
    {
        Map<Id, Vehicle_Master2__c> svmByIds = new Map<Id, Vehicle_Master2__c>();

        for (Vehicle_Master2__c svm : (List<Vehicle_Master2__c>)getRecordsByIds('Vehicle_Master2__c', SELECT_FIELDS_BY_OBJECT.get('Vehicle_Master2__c'), 'Id', stockIds))
        {
            svmByIds.put(svm.Id, svm);
        }

        Decimal actualAmt, estimatedAmt, coverAmtForeign;
        String actualAmtFieldAPI, estimateAmtFieldAPI;

        if (buyContractObjAPI == 'Forward_FOB_Contract__c')
        {
            actualAmtFieldAPI   = 'FOB_Amount__c';
            estimateAmtFieldAPI = 'Estimated_FOB__c';
        }
        else
        {
            actualAmtFieldAPI   = 'Duty_Amount__c';
            estimateAmtFieldAPI = 'Estimated_Duty__c';
        }

        sObject cli;
        Type t = Type.forName(lineItemObjAPI);
        List<sObject> lineItems = new List<sObject>();

        for (String svmId : stockIds)
        {
            cli = (sObject)t.newInstance();

            cli.put(buyContractObjAPI, buyContractId);
            cli.put('Stock_Vehicle_Master__c', svmId);

            Vehicle_Master2__c svm = svmByIds.get(svmId);

            actualAmt       = (Decimal)svm?.get(actualAmtFieldAPI);
            estimatedAmt    = (Decimal)svm?.get(estimateAmtFieldAPI);
            coverAmtForeign = actualAmt == null && estimatedAmt == null ? 0 : (actualAmt == 0 ||
                                                                               actualAmt == null ||
                                                                               buyContractObjAPI == 'Forward_Duty_Contract__c' ? estimatedAmt * coverPercentage : actualAmt * coverPercentage);

            cli.put('Cover_Amount_Foreign__c', coverAmtForeign);
            cli.put('Execution_Amount__c', coverAmtForeign);

            lineItems.add(cli);
        }

        return lineItems;
    }

    private static List<sObject> calculateGainLoss(Set<String> svmIds, String lineItemObjAPI, String addnlContractObjAPI)
    {
        Map<Id, List<sObject>> cliBySVMIds = new Map<Id, List<sObject>>();

        for (sObject cli : getRecordsByIds(lineItemObjAPI, SELECT_FIELDS_BY_OBJECT.get(lineItemObjAPI), 'Stock_Vehicle_Master__c', new List<String>(svmIds)))
        {
            Id svmId = (Id)cli.get('Stock_Vehicle_Master__c');

            if (cliBySVMIds.containsKey(svmId))
            {
                cliBySVMIds.get(svmId).add(cli);
            }
            else
            {
                cliBySVMIds.put(svmId, new List<sObject>{cli});
            }
        }

        List<sObject> svms = getRecordsByIds('Vehicle_Master2__c', new List<String>{'FOB_Gain_Loss__c', 'Duty_Gain_Loss__c'}, 'Id', new List<String>(svmIds));

        String gainLossFieldAPI = addnlContractObjAPI == 'FOB_Additional_Contract__c' ? 'FOB_Gain_Loss__c' : 'Duty_Gain_Loss__c';

        for (sObject svm : svms)
        {
            Decimal totalGainLoss   = 0;
            Id svmId                = (Id)svm.get('Id');
            List<sObject> lineItems = cliBySVMIds.get(svmId);

            for (sObject cli : lineItems)
            {
                if (cli.get('Status__c') != 'Forward Contract Sell' ||
                    cli.get('Status__c') != 'Forward Contract Duty Sale' ||
                    cli.get('Status__c') != 'PO Cancellation')
                {
                    continue;
                }

                totalGainLoss += (Decimal)cli.get('Gain_Loss__c');
            }

            if ((Double)svm.get(gainLossFieldAPI) != null )
            {
                Double curGainLoss = (Double)svm.get(gainLossFieldAPI);

                totalGainLoss += curGainLoss;
            }

            svm.put(gainLossFieldAPI, totalGainLoss);
        }

        return svms;
    }

    private static sObject constructNewSObject(String objAPI, Map<String, String> info)
    {
        Map<String, Schema.DescribeFieldResult> descriptions = TreasuryManagementService.getFieldDescription(objAPI);

        Type t      = Type.forName(objAPI);
        sObject rec = (sObject)t.newInstance();
 
        for (String apiFieldNm : info.keySet())
        {
            if (!descriptions.keySet().contains(apiFieldNm)) continue;
 
            if (!descriptions.get(apiFieldNm).isUpdateable()) continue;

            String fieldVal = info.get(apiFieldNm);

            Schema.DisplayType type = descriptions.get(apiFieldNm).getType();
            switch on type
            {
                when BOOLEAN
                {
                    rec.put(apiFieldNm, Boolean.valueOf(fieldVal));
                }
                when CURRENCY
                {
                    rec.put(apiFieldNm, Decimal.valueOf(fieldVal));
                }
                when INTEGER
                {
                    rec.put(apiFieldNm, Integer.valueOf(fieldVal));
                }
                when LONG
                {
                    rec.put(apiFieldNm, Long.valueOf(fieldVal));
                }
                when PERCENT
                {
                    rec.put(apiFieldNm, Decimal.valueOf(fieldVal));
                }
                when DATE
                {
                    rec.put(apiFieldNm, TreasuryManagementService.getDate(fieldVal));
                }
                when DOUBLE
                {
                    rec.put(apiFieldNm, Double.valueOf(fieldVal));
                }
                when else
                {
                    rec.put(apiFieldNm, (String)fieldVal);
                }
            }
        }

        return rec;
    }

    private static String convertToLightningDataType(String apexFieldDataType)
    {
        String lightningDataType = 'text';
        apexFieldDataType        = apexFieldDataType.toLowerCase();

        for (String type : LIGHTNING_DATA_TYPE_MAP.keySet())
        {
            if (LIGHTNING_DATA_TYPE_MAP.get(type).contains(apexFieldDataType))
            {
                lightningDataType = type;

                break;
            }
        }

        return lightningDataType;
    }

    public class DataTableWrapper
    {
        @AuraEnabled
        public List<FieldDescriptionWrapper> fdwList;
        @AuraEnabled
        public List<sObject> sobList;
        @AuraEnabled
        public Integer totalCount;
    }

    public class FieldDescriptionWrapper
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean sortable;
        @AuraEnabled
        public Boolean editable;
        @AuraEnabled
        public Boolean updateable;
        @AuraEnabled
        public Boolean isReferencedField;

        public FieldDescriptionWrapper(String label, String fieldName, String type, Boolean sortable, Boolean editable,
                                       Boolean updateable, Boolean isReferencedField)
        {
            this.label 	    = label;
            this.fieldName  = fieldName;
            this.type 	    = type;
            this.sortable   = false;
            this.editable   = false;
            this.updateable = updateable;
            this.isReferencedField = isReferencedField;
        }        
    }

    /**
     * [24082022] Added by Nhung Cao - US-TMS-0019
     * Create 'Search TMS PO Group' tab
     */  
    public class TMSPOWrapper {
        @AuraEnabled public Purchase_Order__c tmsRecord;
        @AuraEnabled public List<FOBContractWrapper> fobWrappers = new List<FOBContractWrapper>();
        @AuraEnabled public List<DutyContractWrapper> dutyWrappers = new List<DutyContractWrapper>();
        @AuraEnabled public List<Vehicle_Purchase_Order__c> vpoList = new List<Vehicle_Purchase_Order__c>();
    }

    public class FOBContractWrapper {
        @AuraEnabled public Forward_FOB_Contract__c fobContract;
        @AuraEnabled public List<FOB_Additional_Contract__c> fobAddContracts = new List<FOB_Additional_Contract__c>();
    }

    public class DutyContractWrapper {
        @AuraEnabled public Forward_Duty_Contract__c dutyContract;
        @AuraEnabled public List<Duty_Additional_Contract__c> dutyAddContracts = new List<Duty_Additional_Contract__c>();
    }
}
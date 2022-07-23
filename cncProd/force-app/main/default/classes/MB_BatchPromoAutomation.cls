global class MB_BatchPromoAutomation implements Database.Batchable<sObject> {
    global static Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, Active__c, MB_Stock_Vehicle_Master__c, MB_Promotion__r.Active__c, MB_Promotion__r.End_Date__c, MB_Promotion__r.Start_Date__c, MB_Promotion__r.Flag__c,
                                                MB_Stock_Vehicle_Master__r.Status__c, MB_Stock_Vehicle_Master__r.Name
                                        FROM MB_Promotion_Stock__c
                                        WHERE MB_Stock_Vehicle_Master__r.Status__c != 'Reserved' AND MB_Stock_Vehicle_Master__r.Status__c != 'Blocked'
                                        ORDER BY MB_Promotion__r.CreatedDate DESC]);
    }

    global void execute(Database.BatchableContext bc, List<MB_Promotion_Stock__c> records) {
        Map<Id, List<MB_Promotion_Stock__c>> promoByStockIds = new Map<Id, List<MB_Promotion_Stock__c>>();
        Set<String> pStockPromoIds = new Set<String>();
        for (MB_Promotion_Stock__c pStock : records) {
            pStockPromoIds.add(pStock.MB_Stock_Vehicle_Master__c);
            if (promoByStockIds.containsKey(pStock.MB_Stock_Vehicle_Master__c)) {
                promoByStockIds.get(pStock.MB_Stock_Vehicle_Master__c).add(pStock);
            } else {
                promoByStockIds.put(pStock.MB_Stock_Vehicle_Master__c, new List<MB_Promotion_Stock__c>{pStock});
            }
        }
        system.debug('ID SIZE:: ' + promoByStockIds.size());

        List<MB_Promotion_Stock__c> promos;
        MB_Promotion_Stock__c latestPromo;
        MB_Stock_Vehicle_Master__c stockVehicleMaster;
        List<MB_Stock_Vehicle_Master__c> stocksToBeUpdated = new List<MB_Stock_Vehicle_Master__c>();
        Map<Id, MB_Stock_Vehicle_Master__c> vStocks = new Map<Id, MB_Stock_Vehicle_Master__c>([SELECT Id, Status__c
                                                                                               FROM MB_Stock_Vehicle_Master__c
                                                                                               WHERE Id in :pStockPromoIds]);
        for (Id key : promoByStockIds.keySet()) {
            promos = promoByStockIds.get(key);
            if (hasValidPromo(promos)) {
                stockVehicleMaster = vStocks.get(key);
                stockVehicleMaster.Status__c = 'Open';
                stocksToBeUpdated.add(stockVehicleMaster);
            }
            else {
                latestPromo = getPromoToBeApplied(promos)[0];
                if (latestPromo.MB_Promotion__r.Flag__c == 'Blocked') {
                    stockVehicleMaster = vStocks.get(key);
                    stockVehicleMaster.Status__c = 'Available';
                    stocksToBeUpdated.add(stockVehicleMaster);
                } else if (latestPromo.MB_Promotion__r.Flag__c == 'Return to Pool') {
                    stockVehicleMaster = vStocks.get(key);
                    stockVehicleMaster.Status__c = 'Open';
                    stocksToBeUpdated.add(stockVehicleMaster);
                }
            }
        }
        system.debug('Stock to update:: ' + stocksToBeUpdated);
        system.debug('AAAAAAAAAAA:: ' + latestPromo);

        try {
            Database.update(stocksToBeUpdated, false);
        } catch(Exception e) {
            loggerDataPool.buildLogDataPool('MBBatchPromoAutomation', e);
		}
    }

    global void finish(Database.BatchableContext bc) {
        batchDataPool.buildBatchDataPool('MBBatchPromoAutomation', bc.getJobId());
    }

    private static Boolean hasValidPromo(List<MB_Promotion_Stock__c> promos) {
        //system.debug('VALID PROMOS:: ' + promos);
        for (MB_Promotion_Stock__c pStock : promos) {
            if (pStock.MB_Promotion__r.Active__c) {
                return true;
            }
        }
        return false;
    }

    public static List<MB_Promotion_Stock__c> getPromoToBeApplied(List<MB_Promotion_Stock__c> promos) {
        // If promos has same end date then return promo by latest CreatedDate
        // If promos has different end date then return promo by latest EndDate
        //system.debug('PROMOS APPLIED:: ' + promos);
        Date tmpLatestEndDate = Date.newInstance(1990, 1, 1);
        List<MB_Promotion_Stock__c> tmpLatestPromoStocks = new List<MB_Promotion_Stock__c>();
        for (MB_Promotion_Stock__c pStock : promos) {
            if (pStock.MB_Promotion__r.End_Date__c >= tmpLatestEndDate) {
                tmpLatestEndDate = pStock.MB_Promotion__r.End_Date__c;
                tmpLatestPromoStocks.add(pStock);
            }
        }
        return tmpLatestPromoStocks;
    }
}
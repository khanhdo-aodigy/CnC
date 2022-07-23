/** *****
* Description : Daily Batch for RA Used Car Price Alert
*
* Change History
* Date(YYYYMMDD)        Name       		             Description
* 20210312              khanh.do@aodigy.com          Created Initial Version.
*
** *****/
global with sharing class RA_UpdatePriceAlertBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    private List<String> errMsgs = new List<String>();
    Set<Id> priceAlertIdSet = new Set<Id>();
    private String strRelativeDate = 'YESTERDAY';

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new RA_UpdatePriceAlertBatch(), 200);
    }

    public RA_UpdatePriceAlertBatch() {}

    public RA_UpdatePriceAlertBatch(Set<Id> priceAlertIdSet, String strRelativeDate) {
        this.priceAlertIdSet = priceAlertIdSet;
        this.strRelativeDate = String.isNotBlank(strRelativeDate) ? strRelativeDate : this.strRelativeDate;
    }

    global Iterable<sObject> start(Database.Batchablecontext BC){
        String queryString =  ' SELECT Id, Used_Car_Vehicle_Stock__c, Previous_Price__c, Latest_Price__c, Latest_Price_Updated_Date__c, Vehicle_Stock_Status__c'
                                + ' FROM Price_Alert_for_Non_MF__c'
                                + ' WHERE Subscription_Status__c = \'Open\''
                                ;
        if(priceAlertIdSet != null && priceAlertIdSet.size() > 0) {
            queryString += ' AND Id IN :priceAlertIdSet';
        }

        System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.start() queryString = ' + queryString);
        return Database.getQueryLocator( queryString );
    }

    global void execute(Database.BatchableContext BC, List<Price_Alert_for_Non_MF__c> scope){
        try {
            System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() scope = ' + scope.size());
            System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() scope = ' + scope);

            if(scope.size() > 0) {

                
                Map<String, List<Price_Alert_for_Non_MF__c>> mapStockIdToPriceAlert = new Map<String, List<Price_Alert_for_Non_MF__c>>();
                for(Price_Alert_for_Non_MF__c priceAlert: scope) {
                    
                    String key = priceAlert.Used_Car_Vehicle_Stock__c;
                    if(mapStockIdToPriceAlert.containsKey(key)) {
                        mapStockIdToPriceAlert.get(key).add(priceAlert);
                    } else {
                        List<Price_Alert_for_Non_MF__c> values = new List<Price_Alert_for_Non_MF__c>();
                        values.add(priceAlert);
                        mapStockIdToPriceAlert.put(key, values);
                    }
                }

                Set<String> usedCarStockIds = mapStockIdToPriceAlert.keySet();
                System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() usedCarStockIds = ' + usedCarStockIds.size());

                String strUCVS_SOQL = ' SELECT Id, ParentId, Field, OldValue, NewValue, CreatedDate '+
                                      ' FROM Used_Car_Vehicle_Stock__History '+
                                      ' WHERE ParentId IN :usedCarStockIds ' +
                                      ' AND ( Field = \'Listing_Price__c\'  OR Field = \'Vehicle_Status__c\' ) '+
                                      ' AND CreatedDate = ' + strRelativeDate + 
                                      ' ORDER BY ParentId, CreatedDate DESC ';
                
                List<Used_Car_Vehicle_Stock__History> vehStockHistories = Database.query( strUCVS_SOQL );

                System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() vehStockHistories = ' + vehStockHistories.size());
                
                if(vehStockHistories.size() > 0) {
                    Map<Id, Used_Car_Vehicle_Stock__History> mapVehIdToLatestStatusHistory = new Map<Id, Used_Car_Vehicle_Stock__History>();
                    Map<Id, Used_Car_Vehicle_Stock__History> mapVehIdToPriceHistory  = new Map<Id, Used_Car_Vehicle_Stock__History>();
                    
                    for(Used_Car_Vehicle_Stock__History history : vehStockHistories) {                    
                        if( history.Field == 'Vehicle_Status__c' && !mapVehIdToLatestStatusHistory.containsKey(history.ParentId)) {
                            mapVehIdToLatestStatusHistory.put(history.ParentId, history); //get Latest Status
                        } else if( history.Field == 'Listing_Price__c' && !mapVehIdToPriceHistory.containsKey(history.ParentId)) {
                            if( mapVehIdToLatestStatusHistory.containsKey(history.ParentId) ) {
                                String vehicleStatus = (String)mapVehIdToLatestStatusHistory.get(history.ParentId).get('NewValue');
                                if (vehicleStatus != 'Sold') {
                                    mapVehIdToPriceHistory.put(history.ParentId, history);
                                }
                            } else {
                                mapVehIdToPriceHistory.put(history.ParentId, history);
                            } 
                        }
                    }

                    System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() mapVehIdToPriceHistory = ' + mapVehIdToPriceHistory.size());
                    System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() mapVehIdToLatestStatusHistory = ' + mapVehIdToLatestStatusHistory.size());



                    List<Price_Alert_for_Non_MF__c> priceAlertsToUpdate = new List<Price_Alert_for_Non_MF__c>();

                    for(Id stockId: usedCarStockIds) {
                        List<Price_Alert_for_Non_MF__c> priceAlerts = mapStockIdToPriceAlert.containsKey(stockId) ? mapStockIdToPriceAlert.get(stockId) : null;
                        if( !priceAlerts.isEmpty()){

                            if(!mapVehIdToLatestStatusHistory.isEmpty()) {
                                if(mapVehIdToLatestStatusHistory.containsKey(stockId) && (String)mapVehIdToLatestStatusHistory.get(stockId).get('NewValue') == 'Sold' ) {
                                    for(Price_Alert_for_Non_MF__c priceAlert: priceAlerts) {
                                        priceAlert.Vehicle_Stock_Status__c = 'Sold';
                                        priceAlert.Subscription_Status__c  = 'Completed';
                                        priceAlertsToUpdate.add(priceAlert);
                                    }
                                }
                            }                        

                            if(!mapVehIdToPriceHistory.isEmpty()) {
                                Used_Car_Vehicle_Stock__History priceHistory  = mapVehIdToPriceHistory.containsKey(stockId) ? mapVehIdToPriceHistory.get(stockId) : null;
                                if(priceHistory != null) {
                                    for(Price_Alert_for_Non_MF__c priceAlert: priceAlerts) {
                                        priceAlert.Previous_Price__c            = (Decimal)priceHistory.OldValue;
                                        priceAlert.Latest_Price__c              = (Decimal)priceHistory.NewValue;
                                        priceAlert.Latest_Price_Updated_Date__c = Date.newInstance(priceHistory.CreatedDate.year(), priceHistory.CreatedDate.month(), priceHistory.CreatedDate.day());
                                        priceAlertsToUpdate.add(priceAlert);
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                    System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() priceAlertsToUpdate = ' + priceAlertsToUpdate.size());
                    System.debug('@@@ DEBUG ==== RA_UpdatePriceAlertBatch.execute() priceAlertsToUpdate = ' + priceAlertsToUpdate);
                    
                    update priceAlertsToUpdate;
                } else {
                    System.debug('No Changes has made to alert');
                }
                
            } else {
                System.debug('No Open Price alert found');
            }   

        } catch (Exception ex) {
            System.debug('@@@ ex: ' + ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
            errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('RA_UpdatePriceAlertBatch', ex);
        }
    }

    global void finish(Database.BatchableContext bc)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[] {'khanh.do@aodigy.com'};
        //mail.setToAddresses( toAddresses );
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.saveAsActivity = false;
        String body;
        if(!errMsgs.isEmpty()){
            for(Integer i = 0; i < errMsgs.size(); i++){
                body += (String.valueof(i+1)+' '+errMsgs[i]+ '\r\n');
            }
        }
        else{
            body = 'RA_UpdatePriceAlertBatch Processed Successfully !!!';
        }
        mail.setPlainTextBody(body);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
/** *****
* Description : Daily Batch for Updating RA Used Car Model Alert and Insert Model modelSubscr Staging
*
* Change History
* Date(YYYYMMDD)        Name                         Description
* 20210316              khanh.do@aodigy.com          Created Initial Version.
*
** *****/
global with sharing class RA_UpdateModelAlertBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private List<String> errMsgs = new List<String>();
    private Set<Id> setModelAlertSubIds = new Set<Id>();
    private Set<Id> setModelSubcribedIds = new Set<Id>();
    private String strRelativeDate = 'YESTERDAY';

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new RA_UpdateModelAlertBatch(), 200);
    }

    public RA_UpdateModelAlertBatch() { }

    public RA_UpdateModelAlertBatch( Set<Id> setModelAlertSubIds, Set<Id> setModelSubcribedIds, String strRelativeDate )
    {
        this.setModelAlertSubIds = setModelAlertSubIds;
        this.setModelSubcribedIds = setModelSubcribedIds;
        this.strRelativeDate = String.isNotBlank(strRelativeDate) ? strRelativeDate : this.strRelativeDate;
    }

    global Iterable<sObject> start(Database.Batchablecontext BC)
    {
        String queryString =  ' SELECT Id, Make__c, Model_Name__c, Model_Alert_Subscription__c, Model_Alert_Subscription__r.Subscription_Expiry_Date__c '
                              + ' FROM Model_Subscribed__c'
                              + ' WHERE Model_Alert_Subscription__r.Subscription_Status__c = \'Open\'' ;


        if( setModelSubcribedIds <> null && !setModelSubcribedIds.isEmpty() ) {
            queryString += ' AND ID IN :setModelSubcribedIds ';
        }
        else if( setModelAlertSubIds <> null && !setModelAlertSubIds.isEmpty() ) {
            queryString += ' AND Model_Alert_Subscription__c IN : setModelAlertSubIds ';
        }
        queryString += ' ORDER BY Model_Alert_Subscription__c ';

        System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.start() queryString = ' + queryString);
        return Database.getQueryLocator( queryString );
    }

    global void execute(Database.BatchableContext BC, List<Model_Subscribed__c> scope)
    {
        try 
        {
            System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() scope = ' + scope.size() + ' --- ' + scope );
            if(scope.size() > 0) 
            {
                ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Model_Alert_Subscription__c.SObjectType, Model_Subscribed_Staging__c.SObjectType } );
                List<Model_Alert_Subscription__c> lstExpiredModelAlertSubs = new List<Model_Alert_Subscription__c>();
                List<Model_Subscribed_Staging__c> lstStagingsToInsert = new List<Model_Subscribed_Staging__c>();
                Set<String> makes = new Set<String>();
                Set<String> models = new Set<String>();
                Set<String> makeAndModelKeys = new Set<String>();

                Map<String, List<Model_Subscribed__c>> mapModelSubscribed = new Map<String, List<Model_Subscribed__c>>();

                for(Model_Subscribed__c modelSubscr: scope) 
                {
                    if( modelSubscr.Model_Alert_Subscription__r.Subscription_Expiry_Date__c <= Date.today() ) {
                        lstExpiredModelAlertSubs.add( 
                            new Model_Alert_Subscription__c( Id = modelSubscr.Model_Alert_Subscription__c , Subscription_Status__c = 'Completed' ) 
                        );
                    }
                    else {
                        makes.add(modelSubscr.Make__c);           //Used for Query VehicleStock
                        models.add(modelSubscr.Model_Name__c);    //Used for Query VehicleStock

                        String key = modelSubscr.Make__c + '||' + modelSubscr.Model_Name__c;
                        makeAndModelKeys.add(key);
                        if( !mapModelSubscribed.containsKey(key) ) {
                            mapModelSubscribed.put( key, new List<Model_Subscribed__c>{modelSubscr} );
                        } 
                        else {
                            mapModelSubscribed.get(key).add( modelSubscr );
                        }
                    }
                }
                System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() makeAndModelKeys : ' + makeAndModelKeys.size() + ' === ' + makeAndModelKeys);
                System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() mapModelSubscribed : ' + mapModelSubscribed.size() + ' === ' + mapModelSubscribed);

                if( mapModelSubscribed.size() > 0) 
                {

                    Map<String, List<Used_Car_Vehicle_Stock__c>> mapVehicleStock = new Map<String, List<Used_Car_Vehicle_Stock__c>>();

                    String strUCVS_SOQL = ' SELECT Id, Make__c, Model__c '+
                                          ' FROM Used_Car_Vehicle_Stock__c '+
                                          ' WHERE CreatedDate = ' + strRelativeDate +
                                          ' AND Vehicle_Status__c = \'Open\' '+
                                          ' AND Make__c IN :makes '+
                                          ' AND Model__c IN :models ';
                    for(Used_Car_Vehicle_Stock__c vehicle: Database.query( strUCVS_SOQL ) ) 
                    {
                        String key = vehicle.Make__c + '||' + vehicle.Model__c;
                        if( makeAndModelKeys.contains(key) ) {
                            if( !mapVehicleStock.containsKey(key) ) {
                                mapVehicleStock.put(key, new List<Used_Car_Vehicle_Stock__c>{vehicle});
                            } 
                            else {
                                mapVehicleStock.get( key ).add( vehicle );
                            }
                        }                
                    }
                    System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() mapVehicleStock = ' + mapVehicleStock.size() + ' === ' + mapVehicleStock);


                    if( mapVehicleStock.size() > 0 ) {
                        Id raStagingTypeId = Schema.SObjectType.Model_Subscribed_Staging__c.getRecordTypeInfosByDeveloperName().get('RA_Model_Subscribed_Staging_RT').getRecordTypeId();
                        
                        for(String key: makeAndModelKeys) {
                            if( mapModelSubscribed.containsKey(key) && mapVehicleStock.containsKey(key) ) {

                                for(Used_Car_Vehicle_Stock__c vehicleStock: mapVehicleStock.get(key) ) {
                                    for(Model_Subscribed__c modelSubscribed: mapModelSubscribed.get(key) ) {
                                        Model_Subscribed_Staging__c newStaging = new Model_Subscribed_Staging__c();
                                        newStaging.RecordTypeId                = raStagingTypeId;
                                        newStaging.Used_Car_Vehicle_Stock__c   = vehicleStock.Id;
                                        newStaging.Model_Subscribed__c         = modelSubscribed.Id;
                                        lstStagingsToInsert.add(newStaging);
                                    }                                
                                }
                            }                            
                        }

                    }
                } 
                else {
                    System.debug('@@@ No Vehicle Stock found');
                }
                

                System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() lstExpiredModelAlertSubs = ' + lstExpiredModelAlertSubs.size() + ' === ' + lstExpiredModelAlertSubs);
                System.debug('@@@ DEBUG ==== RA_UpdateModelAlertBatch.execute() stagingsToInsert = ' + lstStagingsToInsert.size() + ' === ' + lstStagingsToInsert);

                if( !lstExpiredModelAlertSubs.isEmpty() ) {
                    uow.registerDirty( lstExpiredModelAlertSubs );    
                }
                
                if( !lstStagingsToInsert.isEmpty() ){
                    uow.registerNew( lstStagingsToInsert );
                }
                uow.commitWork();
                
            } 
            else {
                System.debug('@@@ No Model_Subscribed__c found');
            }
            

        }  
        catch (Exception ex) {
            System.debug('@@@ Exception ex: ' + ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
            errMsgs.add( ex.getCause() + ' -- ' + ex.getMessage() + ' -- At line: #' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('RA_UpdateModelAlertBatch', ex);
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
            body = 'RA_UpdateModelAlertBatch Processed Successfully !!!';
        }
        mail.setPlainTextBody(body);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}
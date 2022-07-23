/** ******
 * Description : Trigger Handler for of CustomerAlertsTrigger.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200319            HS         Created Initial Version
 * 20210709            TPhan      Made changes to cater for RA and NonC&C Cars - IDP Revamp Phase 2
** ******/
public with sharing class CustomerAlertsTriggerHandler 
{   
    public static void handler()
    {   
        System.debug('CustomerAlertsTriggerHandler----> handler');
        if( System.Trigger.isBefore ) 
        {
            if( System.Trigger.isInsert ) 
            {
                populateBroadcastAlert( Trigger.new );
            }
        }
        else if( System.Trigger.isAfter ) 
        {
            if( System.Trigger.isInsert ) 
            {
                pushCustomerBroadcast( Trigger.new );
            }
        }
    }

    public static void populateBroadcastAlert( List<CustomerAlerts__c> lstNewCustAlert )
    {
        Set<Id> setRegisteredVehIds = new Set<Id>();
        Set<Id> setUsedCarIds       = new Set<Id>();
        Set<Id> setNonCCCarIds      = new Set<Id>();
        
        for( CustomerAlerts__c cAlert : lstNewCustAlert )
        {
            if( cAlert.is_Upload__c )
            {
                if (String.isNotBlank(cAlert.Registered_Vehicle__c))
                {
                    setRegisteredVehIds.add( cAlert.Registered_Vehicle__c );
                }
                
                if (String.isNotBlank(cAlert.Used_Car_Vehicle_Stock__c))
                {
                    setUsedCarIds.add(cAlert.Used_Car_Vehicle_Stock__c);
                }

                if (String.isNotBlank(cAlert.Non_C_C_Vehicle__c))
                {
                    setNonCCCarIds.add(cAlert.Non_C_C_Vehicle__c);
                }
            }
        }

        if (setRegisteredVehIds.size() > 0)
        {
            initBroadcastRecord(lstNewCustAlert, setRegisteredVehIds, 'Registered_Vehicle__c');
        }

        if (setUsedCarIds.size() > 0)
        {
            initBroadcastRecord(lstNewCustAlert, setUsedCarIds, 'Used_Car_Vehicle_Stock__c');
        }

        if (setNonCCCarIds.size() > 0)
        {
            initBroadcastRecord(lstNewCustAlert, setNonCCCarIds, 'Non_C_C_Vehicle__c');
        }
    }

    private static void initBroadcastRecord(List<CustomerAlerts__c> newCAlert, Set<Id> vehicleIds, String vehicleType)
    {
        String queryStr = 'SELECT Id, Account__c, Contact__c FROM ' +  vehicleType + ' WHERE Id IN : vehicleIds';
        Map<Id,SObject> mapVehicles = new Map<Id, SObject>((List<SObject>)Database.query(queryStr));
       
        for( CustomerAlerts__c cAlert : newCAlert )
        {
            if( cAlert.is_Upload__c )
            {
                SObject record = mapVehicles.containsKey((String)cAlert.get(vehicleType)) ? mapVehicles.get((String)cAlert.get(vehicleType)) : null;
                CustomerAlerts__c newCustomerAlert = BroadcastController.initBroadcastRecord( cAlert, record );
            }
        }
    }


    public static void pushCustomerBroadcast( List<CustomerAlerts__c> lstNewCustAlert ) 
    {   
        Set<Id> setCustAlertIds = new Set<Id>();
        for( CustomerAlerts__c cAlert : lstNewCustAlert ){
            System.debug('@@@@DEBUG pushCustomerBroadcast :: cAlert = ' + cAlert.RecordTypeId );

            if( String.isNotBlank( cAlert.RecordTypeId ) && 
                Schema.SObjectType.CustomerAlerts__c.getRecordTypeInfosById().get( cAlert.RecordTypeId ).getDeveloperName() == 'Broadcast' )
            {
                setCustAlertIds.add( cAlert.Id );
            }
        }

        if( !setCustAlertIds.isEmpty() ) 
        {
            //Bulk Insert via Batch context
            if( ( System.IsBatch() == true && System.isFuture() == false ) || System.Test.isRunningTest() ) { 
                System.enqueueJob( new BroadcastPushAlertQueueable( setCustAlertIds ) );
            }

            //Bulk Insert via File Import
            if( ( System.IsBatch() == false  && System.isFuture() == false ) || System.Test.isRunningTest() ){
                BroadcastController.pushCustomerBroadcast( setCustAlertIds );
            }
        }
    }
}
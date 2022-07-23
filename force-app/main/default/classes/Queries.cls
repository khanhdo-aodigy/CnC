/*
    Author: Hari Panneerselvam
*/
public class Queries {

    public static String reReserveStockReservation = 'SELECT Id, Reservation_Status__c, Cancellation_Reason__c, Stock_Source__c, Opportunity__r.Owner.Username2__c FROM Stock_Reservation__c '
                                                        + 'where Cancellation_Reason__c = \'SYSTEM CANCEL DUE TO NO AGREEMENT\' AND Stock_Source__c IN (\'KIA Warehouse\',\'MIT Warehouse\',\'CIT Warehouse\') '
                                                        + ' AND Reservation_Status__c = \'Cancel\' AND CreatedDate = Today';

    public static String updateSRToVSMS = 'SELECT Id, Opportunity__r.Owner.Username2__c FROM Stock_Reservation__c WHERE Re_Reserve_To_VSMS__c = true';

    //Commented out 21-May-2019 since these queries are new, will need another deployment to bring these back.

    public static String DataPurge_ServiceDataPool = 'SELECT Id FROM Service_Data_Pool__c WHERE Response_Status_Code__c = \'200\'';

    public static String DataPurge_BatchDataPool = 'SELECT Id FROM BatchDataPool__c WHERE Failures__c = 0';

    public static String DataPurge_LoggerDataPool = 'SELECT Id FROM Logger_Data_Pool__c WHERE Createddate < Last_N_days : 29 order by Createddate desc';

    public static String registerVehicle = 'SELECT ' +Utility.getFields('Registered_Vehicle__c') +' FROM Registered_Vehicle__c WHERE Branch__c in (CCK, CCA, CCF) createddate : LAST_N_DAYS:10';

    public static String contactHistoryQuery = 'SELECT Id,Field,ContactId,NewValue,OldValue,createdDate FROM ContactHistory WHERE CreatedDate = YESTERDAY AND Field = \'Owner\'';

    public static String LeadHistoryQuery = 'SELECT Id,Field,LeadId,NewValue,OldValue,createdDate FROM LeadHistory WHERE CreatedDate = YESTERDAY AND Field = \'Owner\'';

    public static String RegisteredVehicleQuery = 'SELECT Id, Chasis_Number__c, Variant__c, Variant__r.Model_ID__c, Contact__c, Account__c, Account__r.RecordTypeId FROM Registered_Vehicle__c WHERE LeadBatchProcessed__c = false AND Chasis_Number__c != null AND Variant__c != null AND Variant__r.Model_ID__c != null AND CreatedDate = LAST_N_DAYS:'+System.Label.LastStockReservedDay+' ';

    public static List<Stock_Reservation__c > getSR(Set<String> chassisNumRVmap)
    {
        return [SELECT Id, Opportunity__c, Registered_Vehicle__c, Opportunity__r.Contact_Person__c, Vehicle_Chassis_Number__c, 
                    Opportunity__r.Account__c, Opportunity__r.Account__r.PersonContactId, Opportunity__r.Account__r.RecordTypeId, Opportunity__r.Account__r.DWH_Contact_ID__pc,
                    Registered_Vehicle__r.Contact__c, Registered_Vehicle__r.Account__c, Registered_Vehicle__r.Account__r.RecordTypeId
                FROM Stock_Reservation__c 
                WHERE Opportunity__c != null 
                AND Reservation_Status__c = 'Print' 
                AND Vehicle_Chassis_Number__c != null 
                AND Agreement_No__c != null 
                AND Vehicle_Chassis_Number__c IN :chassisNumRVmap];
    }

    public static List<Opportunity> getOpps( Set<Id> oppIdStockmap ) 
    {
        // return [SELECT Id, StageName, Model_c__c, Lead__c, Lead__r.Account__c, Contact_Person__c, Account__c, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName
        //         FROM Opportunity 
        //         WHERE Id IN : oppIdStockmap]; 
        return [SELECT Id, StageName, Model_c__c, Contact_Person__c, Account__c, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName,
                    (SELECT Id, Status__c, Model__c FROM Models_Interested__r )
                FROM Opportunity 
                WHERE Id IN : oppIdStockmap]; 
    }


    public static List<Lead> getLeads( Set<Id> LeadIdSet ){
        return [SELECT Id, Name, Account__c, Account__r.IsPersonAccount, Account__r.PersonContactId, Account__r.RecordTypeId FROM Lead WHERE Id IN : LeadIdSet];
    }

    
    public static List<Models_Interested__c> getModelsInterested( Set<Id> ModelIdSet ) {
        return [SELECT Id, Status__c, Model__c, Opportunity__c 
                FROM Models_Interested__c 
                WHERE Opportunity__c IN : ModelIdSet];
    }


    public static List<Event_Registration__c> getEventRegistrations( Map<Id,Id> LeadIdToConIdMap )
    {
        return [SELECT Id, LeadId__c, LeadId__r.Account__c, ContactId__c, Account__c, Account__r.RecordTypeId
                FROM Event_Registration__c 
                WHERE LeadId__c IN : LeadIdToConIdMap.keySet()];
    }
    

    public static List<Test_Drive__c> getTestDrives( Map<Id,Id> oppIdToContactId )
    {
        return [SELECT Id, Account__c, Account__r.RecordTypeId, Lead__c, Lead__r.Account__c, Prospect__c, Opportunity__c 
                FROM Test_Drive__c 
                WHERE Opportunity__c IN : oppIdToContactId.keySet()];
    }


    public static List<Test_Drive__c> getTestDrives( Set<Id> setOppoIds ){
        return [SELECT Id, Account__c, Account__r.RecordTypeId, Lead__c, Lead__r.Account__c, Prospect__c, Opportunity__c
                FROM Test_Drive__c 
                WHERE Opportunity__c IN : setOppoIds ];
    }

     
    public static List<Custom_Quote__c> getCustomQuotes(Map<Id,Id> LeadIdToConIdMap){
        return [SELECT Id, Lead__c, Lead__r.Account__c, Contact__c, Account__c, Account__r.RecordTypeId 
                FROM Custom_Quote__c 
                WHERE Lead__c IN : LeadIdToConIdMap.keySet()];
    }

    public static String delShareRecQuery = 'SELECT Id FROM Share__c WHERE lead__c !=null AND Lead__r.isconverted=true AND Createddate >= Last_N_months : 6';

    public static String OppforConQuery = 'SELECT Id, Account__c, Contact_Person__c, Lead__r.IsConverted, Lead__c, Lead__r.convertedContactId FROM Opportunity WHERE lead__c!=null AND Lead__r.convertedContactId!=null and lead__r.isconverted=true';


}
/*******************************************
 * Class Name: TriggerHandlerRegisteredVehicle
 * Description: TriggerHandler class for Registered Vehicles
 *******************************************/ 
public without sharing class TriggerHandlerRegisteredVehicle {

    //Recursive Trigger flags.
    public static Boolean isRunBeforeUpdate = false;
    
    /******************************************************
     * Method Name: isRunBeforeUpdate
     * Description: Method to consolidate all before update logic.
     * Parameters:  List<Registered_Vehicle__c> regVehicleList - Trigger.new
     * 				Map<Id, Registered_Vehicle__c> oldMap - Trigger.oldMap
     * Return: N/A
     ******************************************************/ 
    public static void isRunBeforeUpdate(List<Registered_Vehicle__c> regVehicleList, Map<Id, Registered_Vehicle__c> oldMap){
        if(!isRunBeforeUpdate){
            RegisteredVehicleBL.ownerShipChange(regVehicleList, oldMap);
            //isRunBeforeUpdate = true;
        }        
    }
    
    //Thang added 23-July-2021
    /*public static void isRunAfterUpdate(List<Registered_Vehicle__c> regVehicleList, Map<Id, Registered_Vehicle__c> oldMap){     
            RegisteredVehicleBL.updateServicePackages(regVehicleList, oldMap);               
    }*/

    //Thanh added 10-May-2022
    public static void isRunAfterInsert(List<Registered_Vehicle__c> regVehicleList){
        RegisteredVehicleBL.getKCLRecords(regVehicleList);
    }
}
/** *****
* Class Name: RegisteredVehicleBL
* Description : Business Logic class for Registered Vehicle object
* 
* Change History
* Date(YYYYMMDD)       Name                            Description
* 20190429             Christian Gaylan                Created Initial Version.
* 20200901             khanh.do@aodigy                 Added Changes for PA Migration - Phase 2
* 20210316             HS@aodigy                       Added extra checking for owner change
* 
** *****/
public class RegisteredVehicleBL {
    
    /** 
* Method Name: ownerShipChange
* Description: Make status of Service Package and Line Items
* 				inactive by setting flag in the Registered Vehicle object.
* 				A batch will fetch all Registered Vehicles with owner change.
* 
* @param regVehicleList : Trigger.new (List<Registered_Vehicle__c>)
* @param oldMap : Trigger.oldMap (Map<Id, Registered_Vehicle__c>)
**/
    public static void ownerShipChange( List<Registered_Vehicle__c> regVehicleList, Map<Id, Registered_Vehicle__c> oldMap)
    {
        try
        {
            if(regVehicleList != null && !regVehicleList.isEmpty())
            {
                Set<String> setDWHContactIds = new Set<String>();
                Map<Id,String> mapContactDWHIds = new Map<Id,String>();
                for(Registered_Vehicle__c rv : regVehicleList){
                    setDWHContactIds.add(rv.Contact__c);
                }
                setDWHContactIds.remove(null);
                
                for(Contact cnt : [SELECT ID, DWH_Contact_ID__c FROM Contact WHERE ID IN:setDWHContactIds ]){
                    mapContactDWHIds.put( cnt.Id , cnt.DWH_Contact_ID__c );
                }
                
                for(Registered_Vehicle__c rv : regVehicleList)
                {
                    if( oldMap.get(rv.Id).Contact__c <> null && 
                       rv.Contact__c != oldMap.get(rv.Id).Contact__c &&
                       (
                           (mapContactDWHIds.containsKey( rv.Contact__c ) && rv.MagicCustomer__c != mapContactDWHIds.get( rv.Contact__c ) )) || 
                       (rv.MagicCustomer__c != oldMap.get(rv.Id).MagicCustomer__c )
                      )
                    {
                        rv.IsOwnerChanged__c = true;
                        rv.OwnerChangeTimeStamp__c = DateTime.now();
                    }
                }
            }
        }
        catch(Exception e)
        {
            loggerDataPool.buildLogDataPool('RegisteredVehicleBL', e);
        }
    }
    
    //Thang added 23-July-2021
    // public static void updateServicePackages( List<Registered_Vehicle__c> regVehicleList, Map<Id, Registered_Vehicle__c> oldMap)
    // {
    //     try
    //     {
    //         if(regVehicleList != null && !regVehicleList.isEmpty())
    //         {
    //             Map<Id,Registered_Vehicle__c> registeredVehicleMap = new Map<Id, Registered_Vehicle__c>();
    //             for(Registered_Vehicle__c rv : regVehicleList){
    //                 if(rv.Variant__c  != oldMap.get(rv.Id).Variant__c){  
    //                     registeredVehicleMap.put(rv.Id, rv);
    //                 }
    //             }
    //             List<Service_Packages__c> servicePackages = [Select Id, Variant__c, Registered_Vehicle__c FROM Service_Packages__c WHERE Registered_Vehicle__c IN :registeredVehicleMap.keySet()];
    //             if(!servicePackages.isEmpty()){
    //                 for(Service_Packages__c sp : servicePackages){
    //                     sp.Variant__c = registeredVehicleMap.get(sp.Registered_Vehicle__c).Variant__c;
    //                 }
    //                 update servicePackages;
    //             }
                
    //         }
    //     }
    //     catch(Exception e)
    //     {
    //         loggerDataPool.buildLogDataPool('RegisteredVehicleBL.updateServicePackages', e);
    //     }
    // }

    //Thanh added 10-May-2022
    public static void getKCLRecords(List<Registered_Vehicle__c> regVehicleList){
        Map<String, Registered_Vehicle__c> mapChasis = new Map<String, Registered_Vehicle__c>();
        List<Registered_Vehicle__c> temRegVehicleList = new List<Registered_Vehicle__c>();
        
        for(Registered_Vehicle__c regVehicle : regVehicleList){
            if(regVehicle.Branch__c == 'CCK' && regVehicle.Chasis_Number__c != null){
                mapChasis.put(regVehicle.Chasis_Number__c, regVehicle);
            }
        }
        List<Vehicle_Master2__c> vehicleMasterList = [SELECT Id, Chassis__c, KCL_Module_ID__c, KCL_Module_Installation_Date_Time__c, Subscription_Start_Date__c, Subscription_End_Date__c
                                                      FROM Vehicle_Master2__c
                                                      WHERE Chassis__c IN: mapChasis.keySet()];
        
        if(vehicleMasterList.size() > 0){
            for(Vehicle_Master2__c vehicleMaster : vehicleMasterList){
                Registered_Vehicle__c temRegVehicle                 = new Registered_Vehicle__c();
                temRegVehicle.Id                                    = mapChasis.get(vehicleMaster.Chassis__c).Id;
                temRegVehicle.KCL_Module_ID__c                      = vehicleMaster.KCL_Module_ID__c;
                temRegVehicle.KCL_Module_Installation_Date_Time__c  = vehicleMaster.KCL_Module_Installation_Date_Time__c;
                temRegVehicle.Subscription_Start_Date__c            = vehicleMaster.Subscription_Start_Date__c;
                temRegVehicle.Subscription_End_Date__c              = vehicleMaster.Subscription_End_Date__c;
                temRegVehicleList.add(temRegVehicle);
            }
            try{
                update temRegVehicleList;
            }
            catch(Exception e){
                loggerDataPool.buildLogDataPool('RegisteredVehicleBL.getKCLRecords', e);
            }
        }
    }  
}
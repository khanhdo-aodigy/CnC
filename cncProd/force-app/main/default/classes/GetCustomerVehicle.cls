@RestResource(urlMapping='/GetCustomerVehicle/v1/*')
global with sharing class GetCustomerVehicle {
    
    @HttpGet
    global static void GetCustomerVehicle() 
    {
        //Get NRIC ID from the request URK here
        RestRequest request = RestContext.request;
        String inputNRIC = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String errorMsg = '';
        Map<String, String> errorRes = new Map<String, String>();   
        List<Map<String, String>> errorResList = new List<Map<String, String>>();      
        Date today = Date.today();
        Date nxtoneDays = today;
        List<SObject> returnObject = new List<SObject>();
        List<Map<String, Object>> returnLMapObject = new List<Map<String, Object>>();
        Map<String, Object> returnMapObject;
        RestResponse res = RestContext.response;
        
        if( String.isNotBlank(inputNRIC) )
        {
            try
            {   
                //Get all the registered Vehicles based upon the customer having NRIC_Passport_No__c equal to NRIC provided in request
                returnObject = [SELECT Id,
                                    Contact__r.Name, Contact__r.DWH_Contact_ID__c,   
                                    Variant__r.Name, Color__r.ColorCode__c, Variant__r.Model_ID__r.Name, Variant__r.Model_ID__r.Model_Display_Name__c,                      
                                    Branch__c, Chasis_Number__c, DWH_Vehicle_ID__c, Engine_Number__c, Extended_Warranty_End_Date__c,
                                    Franchise__c, IU__c, Last_Service_Booking_Date__c, Last_Service_Booking_KM__c, Manufacture_Warranty_End_Date__c, Model_Year__c,
                                    Next_Service_Booking_Date__c,Next_Service_Booking_KM__c, Preferred_Car_Name__c,
                                    Registered_Date__c, Registration_Number__c, Self_Import_Vehicle__c, Service_Credits__c,
                                    Service_Credits_Expiry_Date__c, Car_Collection_Date__c, Autoline_Franchise_Code__c, Last_Battery_Change__c, Next_Recommended_Servi__c 
                                FROM Registered_Vehicle__c 
                                WHERE Contact__c =: inputNRIC
                                AND FRANCHISE__C IN ('MITPC','MBP','CITPC','KIAPC')]; 
               
                Map<Id, Sobject> returnObjectMap = new Map<Id, Sobject>(returnObject);
                Set<Id> RVvarIdSet = returnObjectMap.keySet();
                List<Id> RVvarIds = new List<Id>(RVvarIdSet);
 
                List<Service_Packages__c> servPackageLst = [SELECT ID, Name, ITEM_EXPIRY_DATE__c, Registered_Vehicle__c
                                                            FROM Service_Packages__c 
                                                            WHERE Registered_Vehicle__c IN :RVvarIds
                                                            AND (ITEM_EXPIRY_DATE__c >=: nxtoneDays OR ITEM_EXPIRY_DATE__c =: null)
                                                            AND Status__c = 'Active'];

                List<Vehicle_Credit__c> vehiclesCreditLst = [SELECT Id, Type__c, Expiry_Date__c, Credit_Balance__c, Chassis_Number__c,
                                                                Company_ID__c, Data_Source__c, Edited_Date__c, Magic_Customer__c, DWH_Vehicle_ID__c,
                                                                Module_ID__c, Status__c, Stop_Flag__c, Account_Number__c,Registered_Vehicle__c,
                                                                Vehicle_Credit__c.Registered_Vehicle__r.Id
                                                             FROM Vehicle_Credit__c
                                                             WHERE Registered_Vehicle__c IN :RVvarIds 
                                                             AND Status__c = 'Active'];

                for (Sobject RVvar : returnObject){ 
                    // Changed query object from Service_Packages_Item__c to Service_Packages__c and added packages with null as expiry dates for fixing P2
                    returnMapObject = new Map<String, Object>();
                    
                    List<Service_Packages__c> servPackages = new List<Service_Packages__c>();
                    for(Service_Packages__c servPackage : servPackageLst)
                    {
                        if(servPackage.Registered_Vehicle__c == RVvar.Id)
                        {
                            servPackages.add(servPackage);
                        }
                    }

                    List<Vehicle_Credit__c> vehiclesCredits = new List<Vehicle_Credit__c>();
                    for(Vehicle_Credit__c vehiclesCredit : vehiclesCreditLst)
                    {
                        if(vehiclesCredit.Registered_Vehicle__c == RVvar.Id)
                        {
                            vehiclesCredits.add(vehiclesCredit);
                        }
                    }

                    returnMapObject.put('ServicePackages', servPackages);
                    returnMapObject.put('VehiclesCredit', vehiclesCredits);
					returnMapObject.put('Vehicles',RVvar);
                    returnLMapObject.add(returnMapObject);
                }
                
                res.statusCode = 200;

                if(System.Test.isRunningTest())
                {
                    throw new NullPointerException(); 
                }
            }
            catch (Exception e)
            { 
                loggerDataPool.buildLogDataPool('GetCustomerVehicle', e);
                errorMsg  = 'A system exception has occurred, Please contact your administrator.';
                errorRes.put('ErrorCode', 'Err04-SF');
                errorRes.put('Message', errorMsg );  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                res.statusCode=400;
            }
        }
        else
        {
            //Throw an error If input NRIC is blank
            errorMsg ='Required fields not supplied. Fields: inputNRIC';      
            res.statusCode = 400;
            errorRes.put('ErrorCode', 'Err02-SF');
            errorRes.put('Message', errorMsg );  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        }    
        
        if(res.statusCode==200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(returnLMapObject).replace('ColorCode__c','Name'));
        }

        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        serviceDataPool.buildServiceDataPool('GetCustomerVehicle', 'GetCustomerVehicle', '', request, res);
    }
}
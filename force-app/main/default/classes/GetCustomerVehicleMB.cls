@RestResource(urlMapping='/GetCustomerVehicleMB/v1/*')
global with sharing class GetCustomerVehicleMB {
    @HttpGet
    global static void GetCustomerVehicleMB() 
    {   
        //Get NRIC ID from the request URL here
        RestRequest request = RestContext.request;
        String inputNRIC = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String errorMsg = '';
        Map<String, String> errorRes = new Map<String, String>();   
        List<Map<String, String>> errorResList = new List<Map<String, String>>();      
        Date today = Date.today();
        Date nxtoneDays = today;
        List<SObject>  returnObject = new List<SObject>();
        List<Map<String, Object>>  returnLMapObject = new List<Map<String, Object>>();
        Map<String, Object>  returnMapObject;
        RestResponse res = RestContext.response;
        
        //Check if input NRIC is not blank  
        if( String.isNotBlank(inputNRIC) )
        {
            try
            {
                //Get all the registered Vehicles based upon the customer having NRIC_Passport_No__c equal to NRIC provided in request
                returnObject = [SELECT Id, 
                                    Contact__r.Name, Contact__r.DWH_Contact_ID__c, 
                                    Variant__r.Name, Color__r.ColorCode__c, Variant__r.Model_ID__r.Name, Branch__c, Chasis_Number__c, DWH_Vehicle_ID__c, Engine_Number__c, Extended_Warranty_End_Date__c,
                                    Franchise__c, IU__c, Last_Service_Booking_Date__c, Last_Service_Booking_KM__c, Manufacture_Warranty_End_Date__c, Model_Year__c,
                                    Next_Service_Booking_Date__c, Next_Service_Booking_KM__c, Preferred_Car_Name__c,
                                    Registered_Date__c, Registration_Number__c, Self_Import_Vehicle__c, Service_Credits__c,
                                    Service_Credits_Expiry_Date__c, Car_Collection_Date__c, Autoline_Franchise_Code__c, Last_Battery_Change__c, Next_Recommended_Servi__c,  SCR__c
                                FROM Registered_Vehicle__c 
                                WHERE Contact__c =: inputNRIC
                                AND Franchise__c IN ('MBP')];    
                            
                Map<Id, SObject> RVvarIDs = new Map<Id, SObject>();
                
                for (SObject RVvar : returnObject)
                { 
                    Registered_Vehicle__c abc = (Registered_Vehicle__c) RVvar;
                    
                    System.debug(abc.Next_Recommended_Servi__c);
                    if(RVvar.get(Registered_Vehicle__c.Next_Recommended_Servi__c) == null)
                    {
                        RVvar.put(Registered_Vehicle__c.Next_Recommended_Servi__c, '');
                    }
  
                    if(RVvar.get(Registered_Vehicle__c.SCR__c) == null)
                    {
                        RVvar.put(Registered_Vehicle__c.SCR__c, 0);
                    }
  
                    RVvarIDs.put(RVVar.id, RVvar);                    
                }
                
                // Changed query object from Service_Packages_Item__c to Service_Packages__c and added packages with null as expiry dates for fixing P2                    
                List<Service_Packages__c> servPackageLst = [SELECT ID, Name, ITEM_EXPIRY_DATE__c, Registered_Vehicle__c, Registered_Vehicle__r.Next_Recommended_Servi__c
                                                            FROM Service_Packages__c 
                                                            WHERE Registered_Vehicle__c in: RVvarIDs.keyset()
                                                            AND (ITEM_EXPIRY_DATE__c >=: nxtoneDays OR ITEM_EXPIRY_DATE__c=:null)
                                                            AND Status__c = 'Active'];   

                Map<Id, List<Service_Packages__c>> mapRegVehToservPackage = new Map<Id, List<Service_Packages__c>>();
                for(Service_Packages__c servPackage: servPackageLst)
                {
                    if(!mapRegVehToservPackage.containskey(servPackage.Registered_Vehicle__c))
                    {
                        List<Service_Packages__c> listTempservPackage = new List<Service_Packages__c>();
                        listTempservPackage.add(servPackage);
                        mapRegVehToservPackage.put(servPackage.Registered_Vehicle__c, listTempservPackage);                                               
                    }  
                    else
                    {
                        mapRegVehToservPackage.get(servPackage.Registered_Vehicle__c).add(servPackage); 
                    }                    
                }                
                
                for (SObject RVvar : returnObject)
                { 
                    returnMapObject = new Map<String, Object>();
                    returnMapObject.put('ServicePackages',mapRegVehToservPackage.get(RVvar.Id));
                    returnMapObject.put('Vehicles',RVvar);                                        
                    returnLMapObject.add(returnMapObject);                    
                }

                res.statusCode = 200;
            }
            catch (Exception e)
            { 
                loggerDataPool.buildLogDataPool('GetCustomerVehicle', e);
                errorMsg = 'A system exception has occurred, Please contact your administrator.';
                errorRes.put('ErrorCode', 'Err04-SF');
                errorRes.put('Message', errorMsg );  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                res.statusCode = 400;
            }
        }
        else
        {
            //Throw an error If input NRIC is blank
            errorMsg ='Required fields not supplied. Fields: inputNRIC';      
            res.statusCode=400;
            errorRes.put('ErrorCode', 'Err02-SF');
            errorRes.put('Message', errorMsg );  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        }    
        //Return List of registered vehicles   
        
        if(res.statusCode==200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(returnLMapObject).replace('ColorCode__c','Name'));
        }
        
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        serviceDataPool.buildServiceDataPool('GetCustomerVehicleMB', 'GetCustomerVehicleMB', '', request, res);
    }
}
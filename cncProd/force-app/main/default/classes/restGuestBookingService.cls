/** ******
 * Class Name: restGuestBookingService
 * Description : Class to generate Errors messages for Guest Booking
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                            Description
 * 20190711             Savita Shetteppa                Created Initial Version
 * 20200322             SJ                              Added PA Migration Changes
 * 
** ******/ 
@RestResource (urlMapping = '/GuestBookingService/*')
global class restGuestBookingService
{
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Map<String, Object> mapJSONBody = new Map<String, Object>();
    private static Map<String, Object> mapParams = new Map<String, Object>();
    private static Map<String, String> mapGenerateDE = new Map<String, String>();
    private static Map<String, Object> mapGenerateJSON = new Map<String, Object>();

   
    @HttpPost
    global static void validateGuestBooking()
	{  
        res.addHeader('Content-Type', 'application/json');
        String sfdcErrorMsg;
        try
		{
			System.debug('+++ guest logger go in');
            processGuestBooking();
        }
        catch(Exception exce)
		{
            loggerDataPool.buildLogDataPool('restGuestBookingService', exce);
            sfdcErrorMsg = exce.getMessage();
        }

        if(sfdcErrorMsg != null)
		{
            res.statusCode = 400;
            mapGenerateJSON.put('Error', sfdcErrorMsg);
            mapGenerateJSON.put('Status', 'Failed');
            res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON));
        }
        serviceDataPool.buildServiceDataPool('validateGuestBooking', 'restGuestBookingService', '', req, res);
		System.debug('+++ guest logger' + res);
    }
    
    /* Method Name: processGuestBooking
     * Description: Validates Guest Booking input form with SFDC
     * 
    */
    
    public static void processGuestBooking()
	{
        List<Registered_Vehicle__c> regVehList = new List<Registered_Vehicle__c>(); 
        List<Contact> conList = new List<Contact>();
		List<Account> accList = new List<Account>();
        List<User> usrList = new List<User>();
        mapParams   = req.params; 
        mapJSONBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        
		System.debug('+++ guest logger go in 1');

        if( mapJSONBody.ContainsKey('VehicleNumber') &&
                mapJSONBody.ContainsKey('MobileNumber') &&            
                    String.IsNotBlank((String)mapJSONBody.get('VehicleNumber')) && 
                        String.IsNotBlank((String)mapJSONBody.get('MobileNumber')) )
		{
            String inputVehNum = (String)mapJSONBody.get('VehicleNumber');
            String inputMobNum = '65'+(String)mapJSONBody.get('MobileNumber');   
			System.debug('+++ guest logger go in 2');

                
            regVehList = [SELECT Id, Contact__c, Contact__r.MobilePhone,
                            Account__c, Account__r.PersonMobilePhone
                          FROM Registered_Vehicle__c 
                          WHERE Registration_Number__c =: inputVehNum.trim() LIMIT 2];
            System.debug('+++ guest logger go in ' + regVehList[0].Contact__c);    
            if(regVehList.isEmpty())
            {
                //Vehicle Not Found Error         
                mapGenerateJSON.put('Message', Label.ErrorVehicleNumNotFoundHeader+'.' +' '+Label.ErrorVehiclenotFoundBody+' '+Label.C_CHelpNumber);
                mapGenerateJSON.put('Status', 'Failed');
                mapGenerateJSON.put('ErrorCode', APICodes.ERR_100);
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON));            
            }
            else if(!regVehList.isEmpty())
            {
                //Vehicle is Found 
                integer vehCount = regVehList.Size();
                if(vehCount > 1)
                {
                    //Duplicate Vehicle Found Eror
                    mapGenerateJSON.put('Message', Label.ErrorDupeVehicles+' '+Label.C_CHelpNumber);
                    mapGenerateJSON.put('Status', 'Failed');
                    mapGenerateJSON.put('ErrorCode', APICodes.ERR_103);
                    res.statusCode   = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON));  
                }
                else if(vehCount == 1 && regVehList[0].Contact__c!=null)
                {
                    conList = [SELECT Id, Name, Email, NRIC_Passport_No__c, MobilePhone               
                                FROM Contact 
                                WHERE Id =: regVehList[0].Contact__c 
                                AND Source__c != null 
                                AND Source__c = 'DWH' LIMIT 2]; 
                    System.debug('+++ guest logger go in ' + conList.size());                            
                    if(conList!=null && !conList.IsEmpty() )
                    { 
                        String CusMobNum;
                        if(conList[0].MobilePhone!=null)
                        {
                            CusMobNum = String.ValueOf(conList[0].MobilePhone); 
                        } 
                                        
                        if(String.IsNotBlank(CusMobNum) && CusMobNum.equalsIgnoreCase(inputMobNum))
                        {
                            // Success : When Vehicle and Contact details are found in SF                                                                                             
                            mapGenerateJSON.put('Email',conList[0].Email);
                            //mapGenerateJSON.put('NRIC',conList[0].NRIC_Passport_No__c);
							mapGenerateJSON.put('NRIC',conList[0].Id);
                            mapGenerateJSON.put('MobilePhone',conList[0].MobilePhone);
                            mapGenerateJSON.put('Name',conList[0].Name);
                            mapGenerateJSON.put('Status', 'Success');
                            res.statusCode = 200;
                            res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON));   
                        }
                        else if(String.IsNotBlank(CusMobNum) && CusMobNum != inputMobNum)
                        {
                            //Vehicle and Contact is found but Mobile Num is not matching with input mobile
                            mapGenerateJSON.put('Message', Label.ErrorWrongMobileHeader+' '+Label.ErrorWrongMobileBody+' '+Label.C_CHelpNumber);
                            mapGenerateJSON.put('Status', 'Failed');
                            mapGenerateJSON.put('ErrorCode', APICodes.ERR_102);
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON)); 
                        }
                        else if(String.IsBlank(CusMobNum)) 
                        {
                            //Vehicle and Contact is found but Mobile Number is missing IN SF
                            mapGenerateJSON.put('Message', Label.ErrorMobileNotFoundHeader+'.'+' '+Label.ErrorMobileNumberBlank+' '+Label.C_CHelpNumber);                            
                            mapGenerateJSON.put('Status', 'Failed');
                            mapGenerateJSON.put('ErrorCode', APICodes.ERR_101 );
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON)); 
                        } 
                    }                  
                } 
            }                     
        }       
        else
		{
            mapGenerateJSON.put('Error Message','Missing required fields: Vehicle Number and/or Mobile Number.');
            mapGenerateJSON.put('Status', 'Failed');  
            mapGenerateJSON.put('ErrorCode', APICodes.ERR_104 );  
            res.statusCode = 400;        
            res.responseBody = Blob.valueOf(JSON.Serialize(mapGenerateJSON)); 
        }
    }   
}
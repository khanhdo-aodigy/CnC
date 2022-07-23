/**************************************************************
 * Class Name: restGetCustomerMagic
 * Description: (GET) RestAPI for DWH Customer Magic from via the
 * 					Registered Vehicle registration number
 * 
 * Revision History
 * Developer Name			Date			Description
 * CGaylan					15-08-2019		Created.
 * 											with sharing not implemented due to
 * 											foreseen change in security model (JWT)
 * 											
 * 											*Please note Exception Messages
 * 											should be placed in a Label 
 * 											or Constants class
 **************************************************************/ 
@RestResource(urlMapping='/GetCustomerMagic/v1/*')
global class restGetCustomerMagic {
    public class SearchException extends Exception{}
    
    private static RestRequest request = RestContext.request;
    private static RestResponse res = RestContext.response;
    private static Map<String, Object>  returnMapObject = new Map<String, Object>();
    private static Map<String, String> errorResponseMap =   new Map<String, String>();
    
    /***************************************
     * Method Name: getCustomerMagic
     * Description: Fetch CustomerMagic (DWH) via
     * 				Vehicle Registration Number
     ***************************************/
    @HttpGet
    global static void getCustomerMagic(){
        try{
            String vehicleRegNum = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            Registered_Vehicle__c rv = new Registered_Vehicle__c();
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            
            if( String.isNotBlank(vehicleRegNum) ){
                //fetch the Customer Magic Number
                rv = [SELECT Id, MagicCustomer__c 
                      FROM Registered_Vehicle__c 
                      WHERE Registration_Number__c=:vehicleRegNum 
                      ORDER BY CreatedDate DESC 
                      LIMIT 1];
            }else{
                throw new SearchException('Vehicle Number not provided.');
            }
            
            if(rv!=null ){
                returnMapObject.put('CustomerMagic', rv.MagicCustomer__c);
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(returnMapObject));
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('GetCustomerMagic', e);
            
            res.statusCode = 400;            
            errorResponseMap.put('ErrorCode', 'Err04-SF');
            String errMsg = e.getMessage();
            if( String.isNotBlank(errMsg) && errMsg.contains('no rows for assignment') ){
                errorResponseMap.put('Message', 'Vehicle Number not found.');
            }else{
                errorResponseMap.put('Message', errMsg);
            }
            
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
        }
        
        serviceDataPool.buildServiceDataPool('restGetCustomerMagic', 'restGetCustomerMagic', '', request, res);
    }
}
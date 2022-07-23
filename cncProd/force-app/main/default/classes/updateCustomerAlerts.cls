//Apex class to Update Alerts Status 
    @RestResource(urlMapping='/UpdateCustomerAlerts/v1/*')
global with sharing class updateCustomerAlerts {
    @HttpPost
    //CallOut method for Expose API
    global static Map<String, String> updateAlerts(String alertID, String status) 
    {   
        String errorMsg='';
        List<SObject>  returnObject = new List<SObject>();
        RestResponse res = RestContext.response;
        CustomerAlerts__c customerAlertsObj; 
        CustomerAlerts__c [] customerAlertsObjList ; 
        Map<String, String> responseMap = new Map<String, String>();
        RestContext.response = res;
        If(alertID!= null && alertID.trim() !='' && status != null && status.trim() != '')
        {
            
            try
            {
                //select alert record based on alert id.
                system.debug(LoggingLevel.INFO,'Start of Select/Update Satement: '+system.currentTimeMillis());
                
                customerAlertsObjList = [SELECT Id FROM CustomerAlerts__c WHERE ID = :alertID];               
                if (customerAlertsObjList != null  && customerAlertsObjList.size()>0)
                {
                    
                        customerAlertsObj =  customerAlertsObjList[0] ;
                        customerAlertsObj.Status__c = status;
                        // update alert record status 
                        update customerAlertsObj;
                        res.statusCode = 200;
                        responseMap.put('Status', 'Success');
                    
                }
                else
                {
                    responseMap.put('ErrorCode', 'Err03-SF');
                    responseMap.put('Message', 'No record found against provided alert id or alert id is invalid');
                    res.statusCode = 400;
                }
                system.debug(LoggingLevel.INFO,'End of Select/Update Satement: '+system.currentTimeMillis());
                
            }
            //Catch the error If any
            catch (DmlException e)
            {     
                errorMsg = 'A system exception has occurred, Please contact your administrator.';
                responseMap.put('ErrorCode', 'Err04-SF');
                responseMap.put('Message', errorMsg);
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                res.statusCode=400;
            }    
        }
        
        else
        {
            responseMap.put('Message', 'Mandatory fields are missing. Please refer API doc');
            responseMap.put('ErrorCode', 'Err02-SF');
            res.statusCode = 400 ;    
            
        }
     
        //Return updated result
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        return responseMap;
    }
}
@RestResource(urlMapping='/ValidateOTP/v1/*')
global with sharing class ValidateOTP {

    @HttpPost
    global static void ValidateOTP( String otp, String nric, String updatedMobileNumber )
    {
        Long elapsedMinute;
        Long currentTime;
        Long otpTimestampMinute;
        String ErrorCode;
        String Errormsg;
        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> ErrorResponseMap = new Map<String, String>();
        RestResponse res = RestContext.response;
            
        if( String.isNotBlank( nric ) && String.isNotBlank( updatedMobileNumber ) && String.isNotBlank( otp )  )
        {
            Long TimeStartObj = System.currentTimeMillis();
            
            // Contact[] con = [SELECT Id, OTP_Timestamp__c, OTP__c, MobilePhone 
            //                  FROM Contact 
            //                  WHERE NRIC_Passport_No__c =: nric 
            //                  AND IsPersonAccount = true                                                      
            //                  AND Source__c = 'DWH'];

            /* Modified on 11/08/2021 by TPhan - MyC&C Login Revamp */
            Contact[] con = [SELECT Id, OTP_Timestamp__c, OTP__c, MobilePhone 
                             FROM Contact 
                             WHERE Id =: nric 
                             AND IsPersonAccount = true];
            /** END */
                              
            System.debug(LoggingLevel.INFO,'Time in MS for Select contact statement: '+String.ValueOf(System.currentTimeMillis()-TimeStartObj));
            
            if(con != null && con.size()>0)
            {
                currentTime        = ((DateTime.now().getTime())/1000/60);
                otpTimestampMinute = ((con[0].OTP_Timestamp__c).getTime()/1000/60);
                elapsedMinute      = currentTime - otpTimestampMinute;
                
                if(elapsedMinute >30)
                {
                    Errormsg = 'OTP Expired'; 
                    res.statusCode = 400;
                    ErrorResponseMap.put('ErrorCode', 'Err03-SF');
                    ErrorResponseMap.put('Message', Errormsg);  
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(ErrorResponseMap));
                }
                else if(con[0].OTP__c == otp)
                {
                    TimeStartObj = System.currentTimeMillis();
                    if(updatedMobileNumber.length() == 8)
                    {
                        updatedMobileNumber = '65'+updatedMobileNumber;
                    }
                    con[0].MobilePhone = updatedMobileNumber;
                    update con[0];
                    responseMap.put('Status', 'Success');
                    res.statusCode = 200; 
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                    System.debug(LoggingLevel.INFO,'Time in MS for Update contact statement: '+String.ValueOf(System.currentTimeMillis()-TimeStartObj));
                }
                else 
                {
                    Errormsg = 'Invalid OTP'; 
                    res.statusCode = 400;
                    ErrorResponseMap.put('ErrorCode', 'Err03-SF');
                    ErrorResponseMap.put('Message', Errormsg);  
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(ErrorResponseMap));
                }
            }
            else
            {
                Errormsg = 'There is no contact for this NRIC Number: '+nric; 
                res.statusCode = 400;
                ErrorResponseMap.put('ErrorCode', 'Err03-SF');
                ErrorResponseMap.put('Message', Errormsg);  
                RestContext.response = res;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(ErrorResponseMap));
            }
            
            System.debug(LoggingLevel.INFO,'End of Select contact Object: '+System.currentTimeMillis());
        }
        else
        {
            Errormsg = 'Required fields not supplied. Fields:NRIC,OTP,updatedMobileNumber';      
            res.statusCode = 400;
            ErrorResponseMap.put('ErrorCode', 'Err02-SF');
            ErrorResponseMap.put('Message', Errormsg);
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(ErrorResponseMap));
        }
    }
}
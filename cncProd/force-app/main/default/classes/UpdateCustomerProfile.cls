@RestResource(urlMapping='/UpdateCustomerProfile/v1/*')
global with sharing class UpdateCustomerProfile {
    
    @HttpPost
    global static void UpdateCustomerProfile(String nric, String email, String addressLine1, String addressLine2, String addressLine3, 
                                                String addressLine4, String addressLine5, String phone, String deviceId, String CommunityNickname ) 
    {

		System.debug('++ ' + nric + '++ ' + email + '++ ' + addressLine1 + '++ ' + addressLine2 + '++ ' + 
					addressLine3 + '++ ' + addressLine4 + '++ ' + addressLine5 + '++ ' + phone + '++ ' + deviceId 
					+ '++ ' + communityNickname);


        RestRequest req = RestContext.request; 
        RestResponse res = RestContext.response;
        Contact[] contactList;
		Account[] accountList;
        User[] userList;
        Contact contact = new Contact();
		Account objAccount;
        User user;
        Boolean isSuccess = false;
        Boolean isSuccessForContact = false;
        Boolean isSuccessForUser = false;
        String ErrorCode;
        String errorMsg;
        String jsonS;
        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> errorResponseMap = new Map<String, String>();
        		
        //JSONGenerator gen = JSON.createGenerator(true);
        if( String.isNotBlank(nric) )
        {
            try
            { 
                Long timeStartObj = system.currentTimeMillis();
                
                // contactList = [SELECT Id FROM Contact WHERE NRIC_Passport_No__c = :nric AND Source__c = 'DWH' AND IsPersonAccount = true];
				
                /* Modified on 11/08/2021 by TPhan - MyC&C Login Revamp */
                contactList = [SELECT Id FROM Contact WHERE Id = :nric /*AND Source__c = 'DWH'*/ AND IsPersonAccount = true];  
                /** END */
                
                // userList = [SELECT Id FROM User WHERE NRIC__c = :nric];  
                if( contactList <> null && !contactList.isEmpty() ){
                    userList = [SELECT Id FROM User WHERE ContactId = :contactList[0].Id ];
                }
                System.debug( LoggingLevel.INFO, 'Time in MS Select contactList/userList: '+ String.ValueOf(System.currentTimeMillis() - timeStartObj) );
                
                if( contactList != null && contactList.size() > 0 ) 
				{
                    contact = contactList[0];
                    if( String.isNotBlank( email ) ) 
					{
                        contact.Email       = email;
                        isSuccessForContact = true;
                        isSuccess           = true;
                    } 

                    if( String.isNotBlank( addressLine1 ) ) 
					{
                        contact.address_Line_1__c = addressLine1;
                        contact.address_Line_2__c = addressLine2;
                        contact.address_Line_3__c = addressLine3;
                        contact.address_Line_4__c = addressLine4;
                        contact.address_Line_5__c = addressLine5;
                        isSuccessForContact       = true;
                        isSuccess                 = true;
                    }  

                    if( String.isNotBlank( phone )) 
					{
                        timeStartObj = System.currentTimeMillis();
                        /* Modified on 13/09/2021 by TPhan - MyC&C Login Revamp */
                        if(phone.length() == 8 && phone.isNumeric())
                        {
                           phone = '65'+phone;
                           generateOTP( phone, nric );
                           System.debug(LoggingLevel.INFO,'Time in MS for generateOTP: '+String.ValueOf(System.currentTimeMillis()-timeStartObj));
                           isSuccessForContact = true;
                           isSuccess           = true;
                        }
                        else 
                        {
                            errorMsg = 'Invalid Phone Number.';
                            res.statusCode = 400;
                            errorResponseMap.put('ErrorCode', 'Err02-SF');
                            errorResponseMap.put('Message', errorMsg);
                            RestContext.response = res;
                            res.addHeader('Content-Type', 'application/json');
                            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
                        }
                        /** END */
                    }

                    if( String.isNotBlank( deviceId ) ) 
                    {
                        contact.Device__c   = deviceId;
                        isSuccessForContact = true;
                        isSuccess           = true;
                    }

                    if( userList != null && userList.size() > 0 )
					{
                        user = userList[0];
                        if(communityNickname.trim() != '')
						{
                            user.Display_Name__c = communityNickname;
                            isSuccessForUser     = true;
                            isSuccess            = true;
                        }   
                    }

                    if(isSuccess)
                    {
                        timeStartObj = System.currentTimeMillis();
                        if(isSuccessForContact) 
						{
                            contact.Contact_Update_Source__c = 'API';
                            update contact;
                        }
                        if(isSuccessForUser) 
						{
                            update user;     
                        } 
                        System.debug(LoggingLevel.INFO,'Time in MS for update Contact & User: '+String.ValueOf(System.currentTimeMillis()-timeStartObj));
                        
                        responseMap.put('Status', 'Success');
                        res.statusCode = 200;      
                        RestContext.response = res;
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                    } 
                    else
                    {
                        errorMsg = 'Required fields not supplied.';
                        res.statusCode = 400;
                        errorResponseMap.put('ErrorCode', 'Err02-SF');
                        errorResponseMap.put('Message', errorMsg);
                        RestContext.response = res;
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
                    }
                    
                }                
                else
                {
                    errorMsg = 'There is no contact for this NRIC Number: '+nric; 
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err03-SF');
                    errorResponseMap.put('Message', errorMsg);  
                    RestContext.response = res;
                    res.addHeader('Content-Type', 'application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap)); 
                }
            }
            catch (DmlException e)
            { 
                String errorMessage= e.getMessage();
                if(errorMessage.contains('Duplicate Nickname'))
                {
                    errorMsg = 'Duplicate Display Name.Another user has already selected this Display Name';
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err04-SF');
                    errorResponseMap.put('Message', errorMsg);  
                    
                }
                else if(errorMessage.contains('Invalid NRIC'))
                {
                    errorMsg = 'Invalid NRIC';
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err04-SF');
                    errorResponseMap.put('Message', errorMsg);
                }
                else
                {
                    errorMsg = 'Something went wrong. One of the required fields not supplied.Please try again'; 
                    res.statusCode = 400;
                    errorResponseMap.put('ErrorCode', 'Err04-SF');
                    errorResponseMap.put('Message', errorMsg);
                }
                
                RestContext.response = res;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
            }  
        }
        else
        {
            errorMsg = 'Required fields not supplied. Fields:NRIC';      
            res.statusCode = 400;
            errorResponseMap.put('ErrorCode', 'Err02-SF');
            errorResponseMap.put('Message', errorMsg);
            RestContext.response = res;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponseMap));
        }  
    }
    

    public static void generateOTP( String phone, String nric )
    {       
        System.debug('generateOTP - ' + phone);
        // List<Contact> lstContact = [SELECT Id FROM Contact WHERE NRIC_Passport_No__c =: nric AND Source__c = 'DWH' AND IsPersonAccount = true];
        
        /* Modified on 11/08/2021 by TPhan - MyC&C Login Revamp */
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE Id =: nric AND IsPersonAccount = true];
        /** END */
        
        final String chars = '0123456789';
        String randStr = '';
        while (randStr.length() < 6) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()*999999), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        
        String msg = 'Your verification code for updating mobile number is '+randStr;
        System.debug('generateOTP >> OTP ======= '+randStr);
        System.debug('generateOTP >> Sending SMS to ' + phone);

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
        String strMobileConnectAPIkeyword = JCC_GlobalVar.MobileConnect_API_Keyword__c;
        Send_OTP_SMS.SENDSMS( msg, phone, phone, strMobileConnectAPIkeyword );

		if( lstContact<>null && lstContact.size() > 0 )
		{
			lstContact[0].OTP__c = randStr;
			lstContact[0].OTP_Timestamp__c = System.now();
			update lstContact[0];
		}
    }
}
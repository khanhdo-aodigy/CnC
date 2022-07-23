/** *****
 * Description : Apex callout to Maybank to check Maybank Loan Application Status
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201214            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class Maybank_CheckApplicationStatus {
    
    @TestVisible 
    static HttpResponse res;

    @TestVisible 
    static FlowOutputs fOutput = new FlowOutputs();  

    @InvocableMethod(label='Check Maybank Loan Application Status')
    public static List<FlowOutputs> checkApplicationStatus( List<FlowInputs> inputs ) 
    {   
        try 
        {     
            if( inputs <> null && !inputs.isEmpty() )
            {   
                global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
                String api_gateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
                String api_gateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

                JSONGenerator jsonGen = JSON.createGenerator(true);
                jsonGen.writeStartObject();
                jsonGen.writeStringField('salesAgreementNo', inputs.get(0).salesAgreementNo );
                jsonGen.writeStringField('dealerID', inputs.get(0).dealerID );
                jsonGen.writeStringField('losWaaNumber', inputs.get(0).losWaaNumber );
                jsonGen.writeStringField('amendmentInd', inputs.get(0).amendmentInd );
                jsonGen.writeEndObject();
                String jsonPayload = jsonGen.getAsString();
                System.debug('@@@@DEBUG checkApplicationStatus :: jsonPayload = ' + jsonPayload );


                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setEndpoint(api_gateway_url+'/maybank/sf/CheckApplicationStatus');
                req.setMethod('POST');
                req.setHeader('Authorization', api_gateway_key);
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(120000);  
                req.setBody( jsonPayload );       
                res = http.send(req);    
                System.debug('@@@@DEBUG checkApplicationStatus :: res = ' + res + ' --- res.getBody() = ' + res.getBody() );

                // exeTestRun( null );
                
                if( res.getStatusCode() == 200 && res.getBody() <> null )
                {
                    Map<String,Object> responseBodyMap   = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String,Object> responseData      = responseBodyMap.get('Data') <> null ? (Map<String,Object>) responseBodyMap.get('Data') : new Map<String,Object>();
                    Map<String,Object> responseMapStatus = responseBodyMap.get('Status') <> null ? (Map<String,Object>) responseBodyMap.get('Status') : new Map<String,Object>();

                    fOutput.api_returned_code = (String)responseMapStatus.get('Code');
                    if( responseMapStatus.get('Code') == 'F' ){
                        fOutput.error_message = responseMapStatus.get('ErrorCode') + ' - ' + responseMapStatus.get('ErrorDescription');
                    }
                    else{
                        //Update Loan Application Status
                        List<Loan_Application__c> lstLoanApplication = [SELECT Id, LOS_WAA_reference_number__c, Sales_Agreement_No__c, Status__c
                                                                        FROM Loan_Application__c
                                                                        WHERE Sales_Agreement_No__c = :inputs.get(0).salesAgreementNo];
                        if( !lstLoanApplication.isEmpty() )
                        {
                            lstLoanApplication.get(0).Status__c = (String)responseData.get('Status');
                            update lstLoanApplication;
                        }
                    }
                }
                // serviceDataPool.buildServiceDataPoolHttp('checkApplicationStatus', 'Maybank_CheckApplicationStatus', '', req, res);
            }
        } 
        catch(System.CalloutException e) {
            System.debug('@@@@DEBUG checkApplicationStatus ::  Callout error: '+ e);
            // loggerDataPool.buildLogDataPool('checkApplicationStatus', e)
        }

        System.debug('@@@@DEBUG checkApplicationStatus :: fOutput = ' + fOutput);
        return new List<FlowOutputs>{ fOutput };
    }
    

    public class FlowInputs 
    {
        @InvocableVariable(required=true)
        public String salesAgreementNo;
    
        @InvocableVariable(required=true)
        public String dealerID;

        @InvocableVariable(required=true)
        public String losWaaNumber;
        
        @InvocableVariable(required=true)
        public String amendmentInd;
    }
    

    public class FlowOutputs
    {    
        @InvocableVariable
        public String error_message;   

        @InvocableVariable
        public String api_returned_code;   
    }

    //For Testing
    // public static void exeTestRun( String strMockResponseResult )
    // {
    //     String result = (String.isNotBlank( strMockResponseResult ) ) ? strMockResponseResult.replaceAll( '\\s+', '') : getMockResult();
    //     HttpResponse mockResponse = new HttpResponse();
    //     mockResponse.setStatus('200');
    //     mockResponse.setBody( result );
    //     res = mockResponse;
    // }


    // public static String getMockResult()
    // { 
    //     return '{"Status":{"Code":"S","ErrorCode":"","ErrorDescription":""},"Data":{"Status":"Approved","SalesAgreementNumber":"SA0001","DealerID":"CA5656","LOSWaaNumber":"LWAA0000002"}}';
    // }
}
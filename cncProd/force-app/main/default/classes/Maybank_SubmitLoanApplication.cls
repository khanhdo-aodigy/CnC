/** *****
 * Description : Apex callout to Maybank to submit Loan Application
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201201            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class Maybank_SubmitLoanApplication {

    @TestVisible 
    static HttpResponse res;

    @TestVisible 
    static FlowOutputs fOutput = new FlowOutputs(); 
    

    @InvocableMethod(label='Submit Maybank Loan Application' description='send submit loan payload to API Gateway' callout=true)
    public static List<FlowOutputs> submitLoanApplication( List<FlowInputs> inputs ) 
    {   
        try 
        {   
            String SAnumber       = inputs.get(0).salesAgreementNo;
            String SAid           = inputs.get(0).salesAgrementId;
            String amdIndicator   = inputs.get(0).amendmentIndicator;
            String SAdocId        = '';
            String SAcontentVerId = '';

            String str_salesAgreement_prefix = SAnumber+'_Sales Agreement'+'%';
            
            //Get Sales Agreement Attachment
            // List<Attachment> lstAtch = new List<Attachment>();
            // lstAtch = [SELECT Id, Name FROM Attachment WHERE ParentId = :SAid AND Name LIKE :str_salesAgreement_prefix];
            // SAdocId = !lstAtch.isEmpty() ? lstAtch.get(0).Id : SAdocId;

            global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
            String api_gateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
            String api_gateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
            
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('salesAgreementNo', SAnumber );
            jsonGen.writeStringField('amendmentIndicator', amdIndicator );
            jsonGen.writeEndObject();
            String jsonPayload = jsonGen.getAsString();
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setEndpoint(api_gateway_url+'/maybank/sf/SubmitApplication');
            req.setMethod('POST');
            req.setHeader('Authorization', api_gateway_key);
            req.setHeader('Content-Type', 'application/json');
            req.setBody( jsonPayload );       
            req.setTimeout(120000);  
            res = http.send(req);    
            System.debug('@@@@DEBUG submitLoanApplication :: res = ' + res + ' --- res.getBody() = ' + res.getBody() );

            if( res.getStatusCode() == 200 && res.getBody() <> null )
            {
                Map<String,Object> responseBodyMap    = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                Map<String,Object> responseDataMap    = (Map<String,Object>) responseBodyMap.get('Data');
                Map<String,Object> responseStatusMap  = (Map<String,Object>) responseBodyMap.get('Status');

                fOutput.api_returned_code = (String)responseStatusMap.get('Code');
                if( responseStatusMap.get('Code') == 'F' ){
                    fOutput.error_message = responseStatusMap.get('ErrorCode') + ' - ' + responseStatusMap.get('ErrorDescription');
                }
                /* Handled by API Gateway
                else{
                    List<Loan_Application__c> lstLoanApplication = [SELECT Id, LOS_WAA_reference_number__c, Sales_Agreement__r.SOH_SONO__c, Sales_Agreement_No__c
                                                                    FROM Loan_Application__c
                                                                    WHERE Sales_Agreement_No__c = :SAnumber];
                    
                    if( !lstLoanApplication.isEmpty() ){
                        lstLoanApplication.get(0).LOS_WAA_reference_number__c = (String)responseDataMap.get('LOSRefNumber');
                        update lstLoanApplication;
                    }
                }
                */
            }
            serviceDataPool.buildServiceDataPoolHttp('submitLoanApplication', 'Maybank_SubmitLoanApplication', SAid, req, res);
        } 
        catch(System.CalloutException e) {
            System.debug('@@@@DEBUG submitLoanApplication ::  Callout error: '+ e);
            loggerDataPool.buildLogDataPool('submitLoanApplication', e);
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG submitLoanApplication :: Error Exception :: err.Msg = '+ ex.getMessage() + ' --- err.Cause = ' +ex.getCause() + ' --- err.Line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('submitLoanApplication', ex);
        }

        System.debug('@@@@DEBUG submitLoanApplication :: fOutput = ' + fOutput);
        return new List<FlowOutputs>{ fOutput };
    }
    

    public class FlowInputs 
    {
        @InvocableVariable(required=true)
        public String salesAgreementNo;
    
        @InvocableVariable(required=true)
        public String salesAgrementId;

        @InvocableVariable(required=false)
        public String amendmentIndicator;
    }


    public class FlowOutputs
    {    
        @InvocableVariable
        public String error_message;   

        @InvocableVariable
        public String api_returned_code;   

        @InvocableVariable
        public Integer fileCount;
    }

}
/** *****
 * Description : Salesforce calls to Machine Learning to update Used Car Quote details
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                             Description
 * 20220504             khanh.do@aodigy.com              Created Initial Version
 * 
** *****/
public with sharing class RAP_SendVehicleDetailsAPI {

    @future(callout=true)
    public static void sendVehicleDetails(String usedCarQuoteId) {
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String apiURL = (String)JCC_GlobalVar.APIGateway_url__c;
        String apiKey = (String)JCC_GlobalVar.SageMakerAPIKey__c;
        
        Used_Car_Quote__c usedCarQuote = UsedCarQuoteService.getUsedCarQuoteById(usedCarQuoteId);                                       
        System.debug('usedCarQuote = ' + usedCarQuote);
        if(usedCarQuote == null){
            return;
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(apiURL +'/rap/sagemaker/test/input');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('apikey', apiKey); //'4950BAF7-8ABC-4A6B-A570-3336951957F3'

        RequestBody reqBodyClass                    = new RequestBody();
        reqBodyClass.QuoteID                        = usedCarQuote.Id;
        reqBodyClass.Owner_ID_Type                  = usedCarQuote.Customer_ID_Type__c;
        reqBodyClass.Owner_ID_Last_4_Digit          = usedCarQuote.Customer_NRIC__c;
        reqBodyClass.Vehicle_No                     = usedCarQuote.Vehicle_No__c;
        reqBodyClass.Vehicle_to_be_Exported         = (usedCarQuote.Vehicle_to_be_Exported__c) ? 'Yes' : 'No';
        reqBodyClass.Intended_Deregistration_Date   = usedCarQuote.Intended_Deregistration_Date__c != null ? getDateFormat(usedCarQuote.Intended_Deregistration_Date__c) : ''; 
        reqBodyClass.Vehicle_Make                   = usedCarQuote.Vehicle_Make__c;
        reqBodyClass.Vehicle_Model                  = usedCarQuote.Vehicle_Model__c;
        reqBodyClass.Primary_Color                  = usedCarQuote.Primary_Color__c;
        reqBodyClass.Manufacturing_Year             = usedCarQuote.Manufacturing_Year__c;
        reqBodyClass.Engine_No                      = usedCarQuote.Engine_No__c;
        reqBodyClass.Chassis_No                     = usedCarQuote.Chassis_No__c;
        reqBodyClass.Maximum_Power_Output           = usedCarQuote.Maximum_Power_Output__c;
        reqBodyClass.Open_Market_Value              = String.valueOf(usedCarQuote.Open_Market_Value__c);
        reqBodyClass.Original_Registration_Date     = usedCarQuote.Original_Registration_Date__c != null ? getDateFormat(usedCarQuote.Original_Registration_Date__c) : '';
        reqBodyClass.First_Registration_Date        = usedCarQuote.First_Registration_Date__c != null ? getDateFormat(usedCarQuote.First_Registration_Date__c) : '';
        reqBodyClass.Transfer_Count                 = String.valueOf(usedCarQuote.Transfer_Count__c);
        reqBodyClass.Actual_ARF_Paid                = String.valueOf(usedCarQuote.Actual_ARF_Paid__c);
        reqBodyClass.PARF_Eligibility               = usedCarQuote.PARF_Eligibility__c;
        reqBodyClass.PARF_Eligibility_Expiry_Date   = usedCarQuote.PARF_Eligibility_Expiry_Date__c != null ? getDateFormat(usedCarQuote.PARF_Eligibility_Expiry_Date__c) : '';
        reqBodyClass.PARF_Rebate_Amount             = String.valueOf(usedCarQuote.PARF_Rebate_Amount__c);
        reqBodyClass.COE_Expiry_Date                = usedCarQuote.COE_Expiry_Date__c != null ? getDateFormat(usedCarQuote.COE_Expiry_Date__c) : '';
        reqBodyClass.COE_Category                   = usedCarQuote.COE_Category__c;
        reqBodyClass.COE_Period_Years               = String.valueOf(usedCarQuote.COE_Period_Years__c);
        reqBodyClass.QP_Paid                        = String.valueOf(usedCarQuote.QP_Paid__c);
        reqBodyClass.COE_Rebate_Amount              = String.valueOf(usedCarQuote.COE_Rebate_Amount__c);
        reqBodyClass.Total_Rebate_Amount            = String.valueOf(usedCarQuote.Total_Rebate_Amount__c);
        reqBodyClass.OPC_Cash_Rebate_Eligibility    = (usedCarQuote.OPC_Cash_Rebate_Eligibility__c) ? 'Yes' : 'No';
        reqBodyClass.OPC_Cash_Rebate_Eligibility_ExpiryDate = usedCarQuote.OPC_Cash_Rebate_Eligibility_Expiry_Date__c != null? getDateFormat(usedCarQuote.OPC_Cash_Rebate_Eligibility_Expiry_Date__c) : '';
        reqBodyClass.OPC_Cash_Rebate_Amount         = String.valueOf(usedCarQuote.OPC_Cash_Rebate_Amount__c);
        reqBodyClass.Mileage                        = String.valueOf(usedCarQuote.Mileage__c);
        reqBodyClass.Sales_Consultant               = usedCarQuote.Sales_Consultant__r.Name;

        String reqBody = JSON.serialize(reqBodyClass);
        System.debug('reqBody = ' + reqBody);
        request.setBody(reqBody);

        HttpResponse response;
        String resBody;
        try {
            response = http.send(request);
            resBody = response.getBody();
            System.debug('response =' + response);
            System.debug('resBody = ' + resBody);
            serviceDataPool.buildServiceDataPoolHttp('RAP_SendVehicleDetailsAPI', 'RAP_SendVehicleDetailsAPI', usedCarQuoteId, request, response);
        } catch(Exception ex) {
            System.debug(ex);
            loggerDataPool.buildLogDataPool('RAP_SendVehicleDetailsAPI', ex);
        }
    }

    private static String getDateFormat(Date d) {
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        String dateFormat;
        dateFormat = String.valueOf(d.day()) + '-' + dt.format('MMM') + '-' + String.valueOf(d.year()).substring(2);
        return dateFormat; 
    }

    public class RequestBody
    {
        public String QuoteID;
        public String Owner_ID_Type;
        public String Owner_ID_Last_4_Digit;
        public String Vehicle_No;
        public String Vehicle_to_be_Exported;
        public String Intended_Deregistration_Date;
        public String Vehicle_Make;
        public String Vehicle_Model;        
        public String Primary_Color;
        public String Manufacturing_Year;
        public String Engine_No;
        public String Chassis_No;
        public String Maximum_Power_Output;
        public String Open_Market_Value;
        public String Original_Registration_Date;
        public String First_Registration_Date;
        public String Transfer_Count;
        public String Actual_ARF_Paid;
        public String PARF_Eligibility;
        public String PARF_Eligibility_Expiry_Date;
        public String PARF_Rebate_Amount;
        public String COE_Expiry_Date;
        public String COE_Category;
        public String COE_Period_Years;
        public String QP_Paid;
        public String COE_Rebate_Amount;
        public String Total_Rebate_Amount;
        public String OPC_Cash_Rebate_Eligibility;
        public String OPC_Cash_Rebate_Eligibility_ExpiryDate;
        public String OPC_Cash_Rebate_Amount;
        public String Mileage;
        public String Sales_Consultant;
    }
}
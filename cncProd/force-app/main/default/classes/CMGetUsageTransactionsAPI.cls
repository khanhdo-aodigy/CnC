/** *****
 * Description : API Class to Get Customer Reward Profile(s) 
 * 
 * Change History
 * Date(YYYYMMDD)       Name                            Description
 * 20200709             khanh.do@aodigy.com             Created Initial Version. 
 * 
** *****/

@RestResource(urlMapping ='/RewardUsage/retrieve/*')
global with sharing class CMGetUsageTransactionsAPI {
    private static RestRequest request = RestContext.request;
    private static RestResponse response = RestContext.response;
    
    private static Utility.httpErrorResponse errorResponse;
    private static RequestBody requestBody = new RequestBody();
    private static ResponseBody responseBody = new ResponseBody();
    private static List<Reward_Usage__c> results = new List<Reward_Usage__c>();
    private static Set<String> brandPicklistValues = RewardService.getPickListValues('Brand__c');

    public class RequestBody {
        public String ProfileType;
        public String UserId;
        public String VehNumber;
        public String Brand;
        public Integer PreviousMonth;
    }   

    public class ResponseBody {
        String message;
        List<RewardUsageWrapper> UsageHistory;        
    }

    @HttpPost
    global static void getRewardUsage() {
        try {
            
            processRequest();
            
        } catch(Exception ex) {
            response.statusCode = 400;
        }

        if(errorResponse != null) 
        {    
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('CMGetUsageTransactionsAPI', 'CMGetUsageTransactionsAPI', '', request, response);
    }

    public static void processRequest() {
        requestBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        String profileType = requestBody.ProfileType;
        String userId = requestBody.UserId;
        String vehNumber = requestBody.VehNumber;
        String brand = requestBody.Brand;
        Integer previousMonth = requestBody.PreviousMonth;
        
        System.debug('profileType = ' + profileType);
        System.debug('userId = ' + userId);
        System.debug('vehNumber = ' + vehNumber);
        System.debug('brand = ' + brand);
        System.debug('previousMonth = ' + previousMonth);

        String profileTypeId;
        String contactId;
        String regVehId;

        if( String.isBlank( profileType )) 
        {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Mandatory field is missing. Please refer API doc');
            return;
        }

        // if(profileType.equalsIgnoreCase('Fleet') && String.isBlank(vehNumber)) {            
        //     errorResponse = new Utility.HttpErrorResponse('Request failed', 'Registered Vehicle Number is required for Fleet Account. Please try again');
        //     return;
        //

        if(profileType.equalsIgnoreCase('Individual') && String.isBlank(userId)) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'UserId is required for Individual Account type. Please try again');
            return;
        }

        if(String.isNotBlank(brand) && !brandPicklistValues.contains(brand)) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Brand. Please try again');
            return;
        }

        if(previousMonth != null && previousMonth < 0) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Number Previous Month. Please try again');
            return;
        }

        profileTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().containsKey( profileType ) ? 
            Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( profileType ).getRecordTypeId() : null;

        if( profileTypeId == null ) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Profile Type. Please check again');
            return;
        }

        if(String.isNotBlank(vehNumber)) {
            regVehId = RewardProfileService.getRegVehId(vehNumber);
            if(String.isBlank(regVehId)) {
                errorResponse = new Utility.HttpErrorResponse('Request failed', 'Cannot find Registered Vehicle with the requested VehNumber. Please check again');
                return;
            }
        }

        if(String.isNotBlank(userId)) {
            if(!userId.startsWith('005')) {
                errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid User Id. Please check again');
                return;
            }
            contactId = RewardProfileService.getPersonContactId(userId);
            if(String.isBlank(contactId)) {
                errorResponse = new Utility.HttpErrorResponse('Request failed', 'Cannot find Contact with requested UserId. Please check again');
                return;
            }  
        }

        results = RewardUsageService.getRewardUsageHistory(profileTypeId, contactId, regVehId, brand, previousMonth);
        
        System.debug('results list size = ' + results.size());
        if(results.size() > 0) {
            generateResponseBody();
        } else {
            responseBody.message = 'No Reward Usage Found';
        }    

        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        
        response.addHeader('Content-Type', 'application/json');    

    }

    public static void generateResponseBody() {
        responseBody.message = 'Retrieve successfully';
        List<RewardUsageWrapper> rewardUsages = new List<RewardUsageWrapper>();

        for(Reward_Usage__c obj: results) {
            RewardUsageWrapper rewardUsage = new RewardUsageWrapper();
            rewardUsage.UsageId = obj.Id;
            rewardUsage.UsageRecordType = RewardUsageService.getRecordTypeNameById(obj.RecordTypeId);
            rewardUsage.Channel = obj.Channel__c;
            rewardUsage.Type = obj.Type__c;
            rewardUsage.CreditAmount = obj.Credit_Amount__c;
            rewardUsage.Status = obj.Status__c;
            rewardUsage.TransactionDate = obj.Transaction_Date__c;
            rewardUsage.eInvoiceNumber = obj.e_Invoice__c;
            rewardUsage.eInvoiceDate = obj.e_Invoice_Date__c;
            rewardUsage.AutolineInvoiceNumber = obj.Autoline_Invoice_Number__c;
            rewardUsage.AutolineInvoiceDate = obj.AutoLine_Invoice_Date__c;
            rewardUsage.RewardType = obj.Reward__r.Type__c;
            rewardUsage.RewardId = obj.Reward__c;
            rewardUsage.Brand = obj.Reward__r.Brand__c;
            
            rewardUsages.add(rewardUsage);
        }

        responseBody.UsageHistory = rewardUsages;
    }

    public class RewardUsageWrapper {
        public String UsageId;
        public String UsageRecordType;
        public String Channel;
        public String Type;        
        public Decimal CreditAmount;
        public String Status;
        public Date TransactionDate;
        public String eInvoiceNumber;
        public Date eInvoiceDate;
        public String AutolineInvoiceNumber;
        public Date AutolineInvoiceDate;
        public String RewardType;
        public String RewardId;
        public String Brand;

    }

}

// List<Reward_Usage__c> rewardUsageToInsert = new List<Reward_Usage__c>();
// for(Integer i=0; i<5; i++) {
//     Reward_Usage__c newRewardUsage = new Reward_Usage__c();
// newRewardUsage.RecordTypeId = RewardUsageService.getRecordTypeId('Debit');
// newRewardUsage.Reward__c = 'a2zO0000001CBSDIA4';
// newRewardUsage.Channel__c = 'Service';
// newRewardUsage.Status__c = 'Utilised';
// newRewardUsage.Transaction_Date__c = Date.today();
// newRewardUsage.Order__c = null;
// newRewardUsage.Order_Number__c = null;
// rewardUsageToInsert.add(newRewardUsage);
    
//     Reward_Usage__c creditUsage = new Reward_Usage__c();
// creditUsage.RecordTypeId = RewardUsageService.getRecordTypeId('Credit');
// creditUsage.Reward__c = 'a2zO0000001CBSDIA4';
// creditUsage.Channel__c = 'Service';
// creditUsage.Status__c = 'Issued';
// creditUsage.Transaction_Date__c = Date.today();
// creditUsage.Order__c = null;
// creditUsage.Order_Number__c = null;
// rewardUsageToInsert.add(creditUsage);
// }

// insert rewardUsageToInsert;
/** *****
 * Description : API Class to Get Customer Reward Profile(s) 
 * 
 * Change History
 * Date(YYYYMMDD)       Name                            Description
 * 20200617             khanh.do@aodigy.com             Created Initial Version. 
 * 
** *****/

@RestResource(urlMapping ='/RewardProfiles/retrieve/*')
global with sharing class CMGetRewardProfileAPI {
    
    private static RestRequest request = RestContext.request;
    private static RestResponse response = RestContext.response;
    
    private static Utility.httpErrorResponse errorResponse;
    private static RequestBody requestBody = new RequestBody();
    private static ResponseBody responseBody = new ResponseBody();
    private static List<Reward_Profile__c> returnObjects = new List<Reward_Profile__c>();
    private static Set<String> brandPicklistValues = RewardService.getPickListValues('Brand__c');

    public class RequestBody {
        public String ProfileType;
        public String UserId;
        public String VehNumber;
        public String Brand;
    }   

    public class ResponseBody {
        String message;
        List<RewardProfile> RewardProfile;

    }

    public class RewardProfile {
        public String RewardProfileId;
        public String Type;
        public Decimal TotalCredit;
        public Decimal TotalCreditedUsage;        
        public Decimal TotalDebitedUsage;
        public Decimal TotalRemainder;
        public List<Reward> Rewards;

        public RewardProfile(String Id, String Type, Decimal TotalCredit, Decimal TotalCreditedUsage, Decimal TotalDebitedUsage, Decimal TotalRemainder, List<Reward> Rewards) {
            this.RewardProfileId = Id;
            this.Type = Type;
            this.TotalCredit = TotalCredit;
            this.TotalCreditedUsage = TotalCreditedUsage;
            this.TotalDebitedUsage = TotalDebitedUsage;
            this.TotalRemainder = TotalRemainder;
            this.Rewards = Rewards;
        }

    }

    public class Reward {
        public String RewardId;
        public String Type;
        public String Status;
        public String RegisterVehicleID;
        public String RegisterVehicleNumber;
        public Decimal Remainder;
        public Date Expiry;

        public Reward(String Id, String Type, String Status, String RegisterVehicleID, String RegisterVehicleNumber, Decimal Remainder, Date Expiry) {
            this.RewardId = Id;
            this.Type = Type;
            this.Status = Status;
            this.RegisterVehicleID = RegisterVehicleID;
            this.RegisterVehicleNumber = RegisterVehicleNumber;
            this.Remainder = Remainder;
            this.Expiry = Expiry;
            
        }
    }

    @HttpPost
    global static void getRewardProfiles() {
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
        
        serviceDataPool.buildServiceDataPool('CMGetRewardProfileAPI', 'CMGetRewardProfileAPI', '', request, response);
    }

    public static void processRequest() {
        requestBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        String profileType = requestBody.ProfileType;
        String userId = requestBody.UserId;
        String vehNumber = requestBody.VehNumber;
        String brand = requestBody.Brand;
        
        String recordTypeId;
        String contactId;
        String regVehId;
        System.debug('profileType = ' + profileType);
        System.debug('userId = ' + userId);
        System.debug('vehNumber = ' + vehNumber);
        System.debug('brand = ' + brand);

        if( String.isBlank( profileType )) 
        {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Mandatory field is missing. Please refer API doc');
            return;
        }

        if(String.isNotBlank(brand) && !brandPicklistValues.contains(brand)) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Brand. Please try again');
            return;
        }

        recordTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().containsKey( profileType ) ? 
            Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( profileType ).getRecordTypeId() : null;

        if( recordTypeId == null ) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Profile Type. Please check again');
            return;
        }

        if(profileType.equalsIgnoreCase('Fleet') && String.isBlank(vehNumber)) {            
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Registered Vehicle Number is required for Fleet Account. Please try again');
            return;
        }

        if(profileType.equalsIgnoreCase('Individual') && String.isBlank(userId)) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'UserId is required for Individual Account type. Please try again');
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


        returnObjects = RewardProfileService.getRewardProfiles(recordTypeId, contactId, regVehId, brand);
        System.debug('list size' + returnObjects.size());
        if(returnObjects.size() > 0) {
            generateResponseBody();
        } else {
            responseBody.message = 'No Reward Profile Found';
        }
    

        response.statusCode = 200;
        if(response.statusCode == 200)
        {
            response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
        }
        
        response.addHeader('Content-Type', 'application/json');
    }

    public static void generateResponseBody() {
        responseBody.message = 'Retrieve successfully';
        List<RewardProfile> rewardProfiles = new List<RewardProfile>();   

        for(Reward_Profile__c returnObj: returnObjects) {
            List<Reward> rewards = new List<Reward>();
            for(Reward__c rewardObj : returnObj.Rewards__r) {
                Reward newReward = new Reward(
                    rewardObj.Id,
                    rewardObj.Type__c,
                    rewardObj.Status__c,
                    rewardObj.Registered_Vehicle__c,
                    rewardObj.Registered_Vehicle__r.Name,
                    rewardObj.Remainder__c,
                    rewardObj.Expiry__c
                );
                rewards.add(newReward);
            }
                
            RewardProfile rewardProfile = new RewardProfile(returnObj.Id,
                                                            returnObj.Type__c,
                                                            returnObj.Total_Credit__c,
                                                            returnObj.Total_Credited_Usage__c,
                                                            returnObj.Total_Debited_Usage__c,
                                                            returnObj.Total_Remainder__c,
                                                            rewards );
            rewardProfiles.add(rewardProfile);
        }

        responseBody.RewardProfile = rewardProfiles;
    }

}
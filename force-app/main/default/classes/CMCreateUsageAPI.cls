/** *****
 * Description : API class for Reward Usage Creation upon Order Submission
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20200617             TP@aodigy.com               Created Initial Version
 * 20200903             KD@aodigy.com               Added calling to CMUsageTransactionService 
 * 
** *****/
@RestResource (urlMapping = '/RewardUsage/insert/*')
global class CMCreateUsageAPI {

    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static RequestBody reqBody = new RequestBody();
    private static ResponseBody resBody = new ResponseBody();
    private static Map<String,List<Reward_Usage__c>> rewardUsageMap = new Map<String,List<Reward_Usage__c>>();
    private static Map<String,List<Reward__c>> rewardMap = new Map<String,List<Reward__c>>();
    private static Map<String, Reward_Profile__c> rewardProfileMap = new Map<String, Reward_Profile__c>();
    private static Map<String, String> creditTypeMap = new Map<String, String>();
    private static Map<String, List<Reward__c>> rewardsToUpdateMap = new Map<String, List<Reward__c>>();
    private static List<Reward_Usage__c> newRewardUsages = new List<Reward_Usage__c>();
    private static List<Reward__c> relatedRewards = new List<Reward__c>();
    private static List<Reward_Profile__c> relatedRewardProfiles = new List<Reward_Profile__c>();
    private static Set<String> rewardProfileIds = new Set<String>();
    private static Order__c relatedOrder = new Order__c(); 

    @HttpPost
    global static void doPost() {
        res.addHeader('Content-Type', 'application/json');
        
        try 
        {  
            processPostRequest();               
        }
        catch(Exception e) 
        {
            loggerDataPool.buildLogDataPool('CMCreateUsageAPI', e);
            System.debug('CMCreateUsageAPI >> ex ' + e.getMessage() + '. Cause: ' + e.getCause() + '. Error at line: ' + e.getLineNumber());
            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());            
        }

        if(errorResponse != null) 
        {    
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('RewardUsageInsert', 'CMCreateUsageAPI', '', req, res);
    }

    public static void processPostRequest() 
    {
        reqBody = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);  
        
        if (reqBody.OrderID == '')
        {
            errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. OrderID Cannot Be Blank.');
        }
        else 
        {
            relatedOrder = OrderService.getOrder(reqBody.OrderID);
            
            if (relatedOrder == null)
            {
                errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Order Is Found With OrderID ' + reqBody.OrderID);
            }
            else 
            {
                if (reqBody.FIFO) 
                {
                    processBasedOnRewardProfile();
                } 
                else
                {
                    processBasedOnVehicleRegNum();
                }       
            }
        }
    }

    public static void processBasedOnRewardProfile () 
    {
        for (Usage usage : reqBody.Usage) 
        {
            rewardProfileIds.add(usage.RewardProfileId);
        }
        
        relatedRewardProfiles = RewardProfileService.getRewardProfilesByIdsWithRewards(rewardProfileIds);

        for (Reward_Profile__c rewardProfile : relatedRewardProfiles)
        {
            if(!rewardProfile.Rewards__r.isEmpty()) 
            {
                rewardMap.put(rewardProfile.Id, rewardProfile.Rewards__r);
                rewardProfileMap.put(rewardProfile.Id, rewardProfile);
            }
            else
            {
                errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Valid Rewards Found For RewardProfileId - ' + rewardProfile.Id);
                break;
            }
           
        }
        
		if (errorResponse == null)
        {    
            for (Usage usage : reqBody.Usage) 
            {
                if (rewardProfileMap.get(usage.RewardProfileId).Total_Remainder__c < usage.CreditAmount) 
                {
                    String errorMessage = 'Sorry. The Total Remainder Of The Corresponding Reward Profile ' + rewardProfileMap.get(usage.RewardProfileId).Name + ' Is Smaller Than The Credit Amount.';
                    errorResponse = new Utility.httpErrorResponse('Failed', errorMessage);
                    break;
                } 
                else
                {
                    relatedRewards  = rewardMap.get(usage.RewardProfileId);
                    newRewardUsages = CMDebitUsageService.rewardCreditDeduction(relatedRewards, usage.CreditAmount, false);
                    if (newRewardUsages <> null || !newRewardUsages.isEmpty())
                    {
                        createNewRewardUsage(newRewardUsages);              
                        rewardUsageMap.put(usage.RewardProfileId, newRewardUsages);
                        rewardsToUpdateMap.put(usage.RewardProfileId, relatedRewards);
                    }
                    else 
                    {
                        errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Reward Usages Created.');
                        break;
                    }
                }       
            }
        }

        if ( errorResponse == null )
        {
            generateReponse(true);    
        }               
    }

    public static void processBasedOnVehicleRegNum() 
    {
  		if (reqBody.VehicleRegNum == '')
        {
            errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. VehicleRegNum Cannot Be Blank.');
        }
        else
        {
            for (Usage usage: reqBody.Usage)
            {
                creditTypeMap.put(usage.RewardProfileId, usage.CreditType);
            }
            
            List<Reward__c> returnedRewards = RewardService.getRewardsByRewardTypes(reqBody.VehicleRegNum, new Set<String>(creditTypeMap.values()));
            
            for (Usage usage: reqBody.Usage)
            {
                List<Reward__c> rewards = new List<Reward__c>();
                for (Reward__c reward : returnedRewards)
                {
                    if (reward.Type__c == usage.CreditType)
                    {
                        rewards.add(reward);
                    }                
                }
                rewardMap.put(usage.CreditType, rewards);
            }
            
            
            for (Usage usage: reqBody.Usage)
            {
                relatedRewards  = rewardMap.get(usage.CreditType);
                
                if (relatedRewards != null && relatedRewards.size() > 0)
                {
                    if (relatedRewards.size() == 1)
                    {
                        if (relatedRewards[0].Remainder__c > 0)
                        {
                            if (relatedRewards[0].Remainder__c < usage.CreditAmount)
                            {
                                errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. The Remainder Of The Related Reward Is Smaller Than The Credit Amount.');
                                break;
                            }
                            else if (relatedRewards[0].Remainder__c == usage.CreditAmount)
                            {
                                Reward_Usage__c newRewardUsage  = new Reward_Usage__c();
                                newRewardUsage.Credit_Amount__c = usage.CreditAmount;
                                newRewardUsage.Reward__c        = relatedRewards[0].Id;
                                createNewRewardUsage(new List<Reward_Usage__c>{newRewardUsage});
                                rewardUsageMap.put(usage.CreditType, new List<Reward_Usage__c>{newRewardUsage});       
                                
                                relatedRewards[0].Status__c     = 'Consumed';
                                rewardsToUpdateMap.put(usage.CreditType, relatedRewards);                        
                            }
                            else if (relatedRewards[0].Remainder__c > usage.CreditAmount)
                            {
                                Reward_Usage__c newRewardUsage  = new Reward_Usage__c();
                                newRewardUsage.Credit_Amount__c = usage.CreditAmount;
                                newRewardUsage.Reward__c        = relatedRewards[0].Id;
                                createNewRewardUsage(new List<Reward_Usage__c>{newRewardUsage});
                                rewardUsageMap.put(usage.CreditType, new List<Reward_Usage__c>{newRewardUsage});  
                            }    
                        }
                        else 
                        {
                            errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Reward Usages Created.');
                        }                      
                    }
                    else
                    {
                        if (!CMDebitUsageService.checkTotalRemainder(relatedRewards, usage.CreditAmount))
                        {
                            errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. The Total Remainder Of The Related Rewards Is Smaller Than The Credit Amount.');
                            break;
                        }
                        else 
                        {
                            newRewardUsages = CMDebitUsageService.rewardCreditDeduction(relatedRewards, usage.CreditAmount, false);             
                            if (newRewardUsages <> null || !newRewardUsages.isEmpty())
                            {
                                createNewRewardUsage(newRewardUsages);    
                                rewardUsageMap.put(usage.CreditType, newRewardUsages);   
                                rewardsToUpdateMap.put(usage.CreditType, relatedRewards);
                            }
                            else 
                            {
                                errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Reward Usages Created.');
                                break; 
                            }
                        }
                    }
                } 
                else
                {
                    errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. No Related Rewards Of Type ' + usage.CreditType + ' Found.');
                    break;
                }
            }
        }
        
        if (errorResponse == null)
        {
            generateReponse(false);
        }
    }

    public static void generateReponse(Boolean isRewardProfile)
    {
        List<Reward_Usage__c> rewardUsagesToCreate = new List<Reward_Usage__c>();
        List<Remainder> remainders = new List<Remainder>();
        
        for (List<Reward_Usage__c> rewardUsages : rewardUsageMap.values())
        {
            rewardUsagesToCreate.addAll(rewardUsages);        
        }

        insert rewardUsagesToCreate;
        
        rewardUsagesToCreate = EShopOrderCheckoutService.updateRelatedRewardUsages(relatedOrder, '');
        update rewardUsagesToCreate;
        CMUsageTransactionService.processUsageTransaction(rewardUsagesToCreate);

        List<Reward__c> rewardsToUpdate = new List<Reward__c>();
        for (List<Reward__c> rewards : rewardsToUpdateMap.values())
        {
            rewardsToUpdate.addAll(rewards);
        }

        update rewardsToUpdate;
        
        Set<Id> newUsageIds = new Set<Id>();
        for (Reward_Usage__c rewardUsage : rewardUsagesToCreate)
        {
            newUsageIds.add(rewardUsage.Id);
        }

        List<Reward_Usage__c> createdUsages = RewardUsageService.getRewardUsagesByIds(newUsageIds);

        if (isRewardProfile)
        {                      
            for (Reward_Usage__c createdUsage : createdUsages)
            {
                Remainder newRemainder = new Remainder();
                newRemainder.RewardProfileId = createdUsage.Reward__r.Reward_Profile__c;
                newRemainder.Type            = createdUsage.Reward__r.Type__c;
                newRemainder.TotalRemainder  = createdUsage.Reward__r.Reward_Profile__r.Total_Remainder__c;
                newRemainder.PaymentId       = createdUsage.Payment__c;
                
                remainders.add(newRemainder);
            }
            
            resBody.Remainder = remainders;
        }
        else 
        {
            Map<String, Decimal> remainderMap = new Map<String, Decimal>();
            List<Reward__c> returnedRewards = RewardService.getRewardsByRewardTypes(reqBody.VehicleRegNum,  new Set<String>(creditTypeMap.values()));

            for (Usage usage: reqBody.Usage)
            {
                Decimal totalRemainder = 0;
                for (Reward__c reward : returnedRewards)
                {
                    if (reward.Type__c == usage.CreditType)
                    {
                        totalRemainder += reward.Remainder__c;
                    }                
                }
                remainderMap.put(usage.CreditType, totalRemainder);
            }
            
            for (Reward_Usage__c createdUsage : createdUsages)
            {
                Remainder newRemainder = new Remainder();
                newRemainder.RewardProfileId = createdUsage.Reward__r.Reward_Profile__c;
                newRemainder.Type            = createdUsage.Reward__r.Type__c;
                newRemainder.TotalRemainder  = remainderMap.get(createdUsage.Reward__r.Type__c);
                newRemainder.PaymentId       = createdUsage.Payment__c;
                
                remainders.add(newRemainder);
            }

            resBody.Remainder     = remainders;
        }

        resBody.status        = 'Success';
        resBody.VehicleRegNum = reqBody.VehicleRegNum;

        res.statusCode   = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(resBody));            
    }

    public static void createNewRewardUsage (List<Reward_Usage__c> newRewardUsages) 
    {
        Id recordTypeId = RewardUsageService.getRecordTypeId('Debit');

        for (Reward_Usage__c newRewardUsage  : newRewardUsages) 
        {
            newRewardUsage.RecordTypeId      = recordTypeId;
            newRewardUsage.Channel__c        = reqBody.Channel;
            newRewardUsage.Invoice_Amount__c = reqBody.TotalAmount;
            newRewardUsage.Order__c          = relatedOrder != null ? relatedOrder.Id : null;
            newRewardUsage.Order_Number__c   = relatedOrder != null ? relatedOrder.Name : '';
            newRewardUsage.Status__c         = 'Utilised';
            newRewardUsage.Type__c           = 'Purchase';
            newRewardUsage.Transaction_Date__c= reqBody.transactionDate == null ? Date.today() : Date.parse(reqBody.transactionDate);
        }    
    }

    public class RequestBody {
        public String UserId; 
        public String Branch;
        public String Brand;
        public String OrderID;
        public String OrderNumber;
        public String transactionDate;
        public Decimal TotalAmount;
        public String Channel;
        public String VehicleRegNum;
        public Boolean FIFO;
        public List<Usage> Usage;
    }
    
    public class Usage {
        public String RewardProfileId;
        public String CreditType;
        public String TransactionType;
        public Decimal CreditAmount;
    }

    public class ResponseBody {
        public String status;
        public String VehicleRegNum;
        public List<Remainder> Remainder;
    }

    public class Remainder {
        public String RewardProfileId;
        public String Type;
        public Decimal TotalRemainder;
        public String PaymentId;
    }
}
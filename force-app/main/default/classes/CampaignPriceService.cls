public inherited sharing class CampaignPriceService {
    
    public static Boolean verifyCampaignPrices(List<CampaignPaymentDetails> campaignPaymentDetails) {
        List<CampaignInvoiceDetails> campaignInvoiceDetails = new List<CampaignInvoiceDetails>();
        for(CampaignPaymentDetails campPayDet : campaignPaymentDetails) {
            campaignInvoiceDetails.add(campPayDet.campInvDet);
		}        
        
        Map<Id, Campaign> campaignById = getCampaignById(campaignInvoiceDetails);
        for(CampaignPaymentDetails campPayDet : campaignPaymentDetails) {
            Campaign camp = campaignById.get(campPayDet.campInvDet.campaignId);
            if(getMultipliedLongValue(campPayDet.actualCost) != getMultipliedLongValue(camp.Actual_Cost_in_Campaign__c)) {
                logVerificationFailure(campPayDet, 'ActualCost (API) not equal to Campaign Actual Cost');
                return false;
            }
        }
        
        return verifyCampaignPrices(campaignInvoiceDetails);
	}    
    
    public static Boolean verifyCampaignPrices(List<CampaignInvoiceDetails> campaignInvoiceDetails) {
        Map<Id, Campaign> campaignById = getCampaignById(campaignInvoiceDetails);
        
        for(CampaignInvoiceDetails campInvDet : campaignInvoiceDetails) {
            Campaign camp = campaignById.get(campInvDet.campaignId);
            Long multipliedPrice = getMultipliedLongValue(campInvDet.totalPrice);
			Long multipliedDiscount = getMultipliedLongValue(campInvDet.discountedPrice);
            
            if( (camp.Budgeted_Cost_in_Campaign__c != null && multipliedPrice != getMultipliedLongValue(camp.Budgeted_Cost_in_Campaign__c)) ||
                (camp.Budgeted_Cost_in_Campaign__c == null && multipliedPrice != getMultipliedLongValue(camp.Actual_Cost_in_Campaign__c)) || 
                (camp.Type == 'Events' && multipliedDiscount != 0) )
            {
                logVerificationFailure(campInvDet, 'TotalPrice (API) calculation error, or Campaign Type is Events but DiscountedPrice (API) is not 0');
                return false;
            }
            
            if(camp.Actual_Cost_in_Campaign__c == null || camp.Budgeted_Cost_in_Campaign__c == null) {
                if(multipliedDiscount != 0) {
                    logVerificationFailure(campInvDet, 'Campaign Actual Cost or Budgeted Cost is null, but DiscountedPrice (API) is not 0');
                    return false;
                }
            } else if(multipliedDiscount != getMultipliedLongValue(camp.Actual_Cost_in_Campaign__c - camp.Budgeted_Cost_in_Campaign__c)) {
				logVerificationFailure(campInvDet, 'DiscountedPrice (API) not equal to difference between Campaign Actual Cost and Campaign Budgeted Cost');
                return false;
            }
        }
        
        return true;
    }

    private static Map<Id, Campaign> getCampaignById(List<CampaignInvoiceDetails> campaignInvoiceDetails) {
        Set<Id> campaignIds = new Set<Id>();
        
        for(CampaignInvoiceDetails campInvDet : campaignInvoiceDetails) {
            campaignIds.add(campInvDet.campaignId);
		}
        
        List<Campaign> campaigns = new CampaignSelector().selectSObjectsById(campaignIds);
        return new Map<Id, Campaign>(campaigns);        
    } 
    
    private static Long getMultipliedLongValue(Decimal val) {
        if(val == null) {
            return 0;
        }
        return (Long)(val * 1000);
    }
    
    private static void logVerificationFailure(CampaignPaymentDetails campaignPaymentDetails, String message) {
    	Logger_Data_Pool__c newLogDataPool = buildLog(campaignPaymentDetails.campInvDet);
        newLogDataPool.Message__c += ', ActualCost: ' + campaignPaymentDetails.actualCost;
        newLogDataPool.Message__c += ', ' + message;
        
		insert newLogDataPool;
    }     
    
    private static void logVerificationFailure(CampaignInvoiceDetails campaignInvoiceDetails, String message) {
    	Logger_Data_Pool__c newLogDataPool = buildLog(campaignInvoiceDetails);
        newLogDataPool.Message__c += ', ' + message;
        
		insert newLogDataPool;
    }   
    
    private static Logger_Data_Pool__c buildLog(CampaignInvoiceDetails campaignInvoiceDetails) {
		Logger_Data_Pool__c newLogDataPool = new Logger_Data_Pool__c(
        	Instance__c = 'CampaignPriceService',
            Type__c = 'Verification Failure'
        );
		newLogDataPool.Message__c = 'CampaignId: ' + campaignInvoiceDetails.campaignId + ', TotalPrice: ' + campaignInvoiceDetails.totalPrice;
        newLogDataPool.Message__c += ', DiscountedPrice: ' + campaignInvoiceDetails.discountedPrice;

		return newLogDataPool;
    }
    
    public class CampaignPaymentDetails {
        CampaignInvoiceDetails campInvDet;
        Decimal actualCost;
        
        public CampaignPaymentDetails(CampaignInvoiceDetails campInvDet, Decimal actualCost) {
            this.campInvDet = campInvDet;
            this.actualCost = actualCost;
		}          
    }    
    
    public class CampaignInvoiceDetails {
        Id campaignId;
        Decimal totalPrice;
        Decimal discountedPrice;
        
        public CampaignInvoiceDetails(Id campaignId, Decimal totalPrice, Decimal discountedPrice) {
            this.campaignId = campaignId;
            this.totalPrice = totalPrice;
            this.discountedPrice = discountedPrice;
		}    
    }
}
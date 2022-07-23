/*****************************************
 * Class Name: restCampaignInfo
 * Description: REST API to provide Campaign Details.
 *              Initial build for Paid Events. 
 * 
 *****************************************/ 
@RestResource (urlMapping = '/CampaignInfo/*')
global class restCampaignInfo {

    //Restful params
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static CampaignWrapper errorResp;
    
    @HttpGet
    global static void getCampaignDetails(){
        String cmpId = req.params.get('Id'); //Id from the header
        CampaignWrapper wrp = new CampaignWrapper();
        
        res.addHeader('Content-Type', 'application/json');
        

        wrp = getDetails( cmpId );

        if(errorResp != null){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResp));
        }else{
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(wrp));
        }
        
        serviceDataPool.buildServiceDataPool('restCampaignInfo', 'CampaignInfo', '', req, res);
    }
    
    global static CampaignWrapper getDetails(String cmpgnId){
        CampaignWrapper cmpProcessed = new CampaignWrapper();
        try{
            //Campaign Details
            Campaign cmp = [SELECT Id, 
                                    Name, 
                                    Number_of_Guests__c, 
                                    UnitPrice__c 
                            FROM Campaign
                            WHERE Id=:cmpgnId 
                            LIMIT 1];
                            
            if(cmp!=null){
                //Campaign Exists, get the Number of registrations
                Integer registered = 0;
                for(Event_Registration__c reg : [SELECT NumberOfGuests__c 
                                                 FROM Event_Registration__c  
                                                 WHERE PromoID__c=: cmp.Id
                                                 AND Waitlist__c=false
                                                 AND NumberOfGuests__c!=NULL ]
                   )
                {
                    registered = registered + Integer.valueOf(reg.NumberOfGuests__c);
                    
                    
                }
              
                Integer numGuest = Integer.valueOf(cmp.Number_of_Guests__c) - registered;
                
                cmpProcessed.status = 'Success';
                cmpProcessed.campaignName = cmp.Name;
                cmpProcessed.campaignId = cmp.Id;
                cmpProcessed.availableSlots = numGuest;
                cmpProcessed.maxGuest = Integer.valueOf(cmp.Number_of_Guests__c);
                cmpProcessed.unitPrice = cmp.UnitPrice__c;
                
                //Initial Paid Events build: Unit Price = Additional Price
                cmpProcessed.additionalPrice = cmp.UnitPrice__c;
            }
        }catch(Exception e){
            cmpProcessed = null;
            loggerDataPool.buildLogDataPool('restCampaignInfo', e);
            
            //Create Error Response
            CampaignWrapper wrp = new CampaignWrapper();
            wrp.status='Error';
            wrp.campaignName='';
            wrp.maxGuest = 0;
            wrp.availableSlots = 0;
            wrp.campaignId = '';
            wrp.unitPrice = 0;
            wrp.additionalPrice = 0;
            errorResp = wrp;
        }
        
        return cmpProcessed;
    }
    
    
    global class CampaignWrapper{
        global String status {get; set;} //Status: Success or Error
        global String campaignName {get; set;} 
        global String campaignId {get; set;}
        global Integer availableSlots {get; set;}
        global Integer maxGuest {get; set;} //Maximum Number of Guest
        global Double unitPrice {get; set;} //Price per guest
        global Double additionalPrice {get; set;} //Additional Price per guest
    }
}
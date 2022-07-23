/** *****
 * Description : GetCampaign_RegisteredVehicle_fromNRIC API
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * 20180630            Jacob Khouli                  Created Initial Version. 
 * 20200921            khanh.do@aodigy               Added PA - Phase 2 Changes
 * 20210412            phan.thu@aodigy               Added logic on line 66 - Generic AfterSales Promotions
** *****/
@RestResource(urlMapping='/GetCampaign_RegisteredVehicle_fromNRIC/v1/*')
global with sharing class GetCampaign_RegisteredVehicle_fromNRIC {

    @HttpGet
    global static void GetCampaign_RegisteredVehicle_fromNRIC() 
    {
        //Get NRIC ID from the request URL here
        RestRequest request = RestContext.request;
        String InputNRIC = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String Errormsg='';
        
        List<Campaign> records = new List<Campaign>();    
        RestResponse res = RestContext.response;
        Map<String, String> errorRes = new Map<String, String>();
        List<Map<String, String>> errorResList = new List<Map<String, String>>();

		System.debug('InputNRIC ++ ' + InputNRIC);
        
        //Check if input NRIC is not blank  
        if( String.isNotBlank(InputNRIC) )
        {
            try
            {	
                //Get all the CampaignId based upon the CampaignMemebers having NRIC_Passport_No__c equal to NRIC provided in request.                    
                //Put all of the CampaignId's into List of type string
                List<String> CampaignMemList = new List<String>();
                
				//for(CampaignMember cm: [SELECT CampaignId FROM CampaignMember WHERE /*Contact.NRIC_Passport_No__c =:c.NRIC_Passport_No__c*/ ContactId =: InputNRIC]) 
                //{
                //    if(cm.CampaignId != null)
                //    {
                //        CampaignMemList.add(cm.CampaignId);  
                //    } 
                //}       

				for(Campaign_Member_Vehicle__c cmv : [select Campaign__r.id, Campaign__r.RecordType.DeveloperName, Offboarded__c from Campaign_Member_Vehicle__c where Contact__c=: InputNRIC])
				{
					if(cmv.Campaign__r.id != null)
					{
                        if ((cmv.Campaign__r.RecordType.DeveloperName == 'C_C_Campaign_RT_Sales_Targeted_Promo' && cmv.Offboarded__c == false)
                            || (cmv.Campaign__r.RecordType.DeveloperName <> 'C_C_Campaign_RT_Sales_Targeted_Promo'))
                        {
                            CampaignMemList.add(cmv.Campaign__r.id);
                        }
					}
				}
                
                //Get all the Campaign and Registered Vehicles related to that Campaign based upon the list of the Campaigns returned above. 
                records = [SELECT Name, Description, Type, Status, StartDate, EndDate, Parent.Id, Owner.Id, 
                                  Actual_Cost_in_Campaign__c, Budgeted_Cost_in_Campaign__c,
                                  IsExclusive__c, CTA__c, CampaignID__c, Branch_Code__c,
                                  ( SELECT Registered_Vehicle__c, Account__c, Sales_Agreement__c
                                    FROM Campaign_Member_and_Vehicles__r 
                                    WHERE Contact__c =: InputNRIC
                                    //Contact__r.NRIC_Passport_No__c = :c.NRIC_Passport_No__c
                                    AND Offboarded__c = false)
                           FROM Campaign 
                           WHERE Id IN : CampaignMemList 
                           AND IsActive = true 
                           AND EndDate >= Today 
                           AND Target_Audience__c != 'Public And Targeted'
                           ORDER BY StartDate DESC, CreatedDate DESC];
                
                res.statusCode = 200;            
            }
            //Catch the error If any
            catch (DmlException e)
            {   
                errorMsg = 'A system exception has occurred, Please contact your administrator.';
                errorRes.put('ErrorCode', 'Err04-SF');
                errorRes.put('Message', errorMsg);  
                errorResList.add(errorRes);
                res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
                res.statusCode=400;
            }
        }
        else
        {
            //Throw an error If input NRIC is blank
            Errormsg='Required fields not supplied. Fields: InputNRIC';      
            res.statusCode=400;
            errorRes.put('ErrorCode', 'Err02-SF');
            errorRes.put('Message', errorMsg);  
            errorResList.add(errorRes);
            res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        }    
        //Return List of registered vehicles      
        if(res.statusCode == 200)
        {
            res.responseBody = Blob.valueOf(JSON.serialize(records).replace('Budgeted_Cost_in_Campaign__c','BudgetedCost').replace('Actual_Cost_in_Campaign__c','ActualCost'));
        }
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
    }
}
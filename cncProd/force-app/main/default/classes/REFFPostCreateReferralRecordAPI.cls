/** ******
 * Description : Service Class for Referral object
 * 
 * Change History :
 * Date(YYYYMMDD)       Name                Description
 * 20200211             HS@aodigy           Created Initial Version. 
 * 20200325				SJ@aodigy			Improve version round two. Added Referral Code
 * 20200908             Thu@aodigy          PA Phase-2 : Removed Lead Reference 
 * 20211213             Thu@aodigy          Added check to reffWrap.ProspectObj
** ******/
@RestResource(urlMapping='/PostCreateReferralRecord/v1/*')
global with sharing class REFFPostCreateReferralRecordAPI 
{
    public class CustomException extends Exception {}    

    @HttpPost
    global static void createReferral() 
	{
        
        Map<String, String> responseMap = new Map<String, String>();
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response = res;

        Savepoint sp = Database.setSavepoint();       
        try 
		{
            
            System.debug('@@@@DEBUG createReferral :: req.requestBody.toString() = ' + req.requestBody.toString() );

            ReferralWrapper referralWrap = (ReferralWrapper)JSON.deserialize( req.requestBody.toString(), ReferralWrapper.class );
            
            System.debug('@@@@DEBUG createReferral :: referralWrap = ' + referralWrap );

            String contactId;
            String personContactId;
            String appuserId = referralWrap.UserId;    
            Set<String> setUserRecIds = new Set<String>();
			Set<String> setStrBrands = new Set<String>();
            Map<Id,User> mapUser = new Map<Id,User>();
            Map<String,RecordType> mapOppoRecordType = new Map<String,RecordType>();
            List<ReferralWrapper> lstReferralWrap = new List<ReferralWrapper>{ referralWrap };

            Map<String,ReferralWrapper> mapReferralToProcess = new Map<String,ReferralWrapper>();

            setUserRecIds.add( appuserId );
            for( ReferralWrapper reffWrap : lstReferralWrap )
			{
                setUserRecIds.add( reffWrap.PreferredSC );
				setStrBrands.add( reffWrap.Brand);
            }
            setUserRecIds.remove( null );
        
            if( String.isNotBlank( appuserId ) )
			{
                mapUser   = ReferralService.getUserRecordMap( setUserRecIds );
            }


            for( ReferralWrapper reffWrap : lstReferralWrap ) 
            {
                String theKey = reffWrap.Email.toLowerCase();    
                
                if( !mapReferralToProcess.containsKey( theKey ) )
                {
                    if( !mapUser.isEmpty() && mapUser.containsKey( appuserId ) ) 
                    {
                        reffWrap.referrerContactId = mapUser.get( appuserId ).ContactId__c; 
                        reffWrap.referrerPAId = mapUser.get( appuserId ).Contact.AccountId; 
                    }
                    
                    //reffWrap.leadObj = ReferralWrapper.populateLeadRecord( reffWrap, mapUser );

                    reffWrap.ProspectObj = ReferralWrapper.populateProspectRecord( reffWrap, mapUser );

                    if (reffWrap.ProspectObj == null) 
                    {
                        throw new CustomException('Sorry! It seems like your friend is already in our records.');
                    }

                    reffWrap.OpportunityObj = ReferralWrapper.populateOpportunityRecord( reffWrap, mapUser );

                    reffWrap.ReferralObj = ReferralWrapper.populateReferralRecord( reffWrap );

                    mapReferralToProcess.put( theKey, reffWrap );
                }
            }
            
            //CHECK DUPLICATE Referral
            Map<String, ReferralWrapper> mapDupicateReferral = new Map<String, ReferralWrapper>();
            mapDupicateReferral = ReferralService.filterDuplicateReferral( mapReferralToProcess , setStrBrands);

            //GENERATE DUPLICATE MESSAGE
            String strDupMsg = '';			
			strDupMsg = compileDuplicateMsg( mapDupicateReferral);

			//Second round of checks --> NSJ
			if(strDupMsg == '')
			{
				List<contact> cc = new list<contact>();
				cc = [select email , id from contact where email in: mapReferralToProcess.keySet() and ispersonaccount = false ];

				for(contact c : cc)
				{
					System.debug('c details ++ ' + c);
					strDupMsg += 'Invalid : ' + c.Email + ' has been referred. \n';
				}				
			}
            
            //PROCESS DATA INSERTION 
            if( mapReferralToProcess <> null && !mapReferralToProcess.isEmpty() && strDupMsg == '') 
            {
                ReferralService.processReferralRequest( mapReferralToProcess );
            }

            System.debug('@@@@DEBUG createReferral :: mapReferralToProcess = ' + mapReferralToProcess );
            System.debug('@@@@DEBUG createReferral :: mapDupicateReferral = ' + mapDupicateReferral );
            
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
            responseMap.put('Status', 'Success');
            responseMap.put('Message', strDupMsg );
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
        }
        catch(Exception ex) {

            System.debug('@@@@DEBUG createReferral :: ERR CAUSE = ' + ex.getCause() + ' --- ERR MSG = ' + ex.getMessage() + ' --- ERR LINE NUMER = ' + ex.getLineNumber());
            Database.rollback(sp);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode   = 400;
            responseMap.put('Status', 'Failed');
            responseMap.put('Message', ex.getMessage());
            res.responseBody = Blob.valueOf (JSON.serialize(responseMap) ); 
        }

        serviceDataPool.buildServiceDataPool('createReferral', 'REFFPostCreateReferralRecordAPI', '', req, res);
    }


    public static String compileDuplicateMsg( Map<String,ReferralWrapper> mapDupicateReferral)
	{
        String msg = '';
        for( String key : mapDupicateReferral.keySet() )
		{
				System.debug('mapDupicateReferral details ++ ' + mapDupicateReferral.get(key));
				msg += 'Invalid : ' + mapDupicateReferral.get( key ).prospectObj.PersonEmail + ' has been referred. \n';
        }
        return msg;
    } 

	public static string genRefCode(string brand)
	{
		String header = brand + '-Ref-';

		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String Code = '';
		while (Code.length() < 5) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			Code += chars.substring(idx, idx+1);
		}

		System.debug('Code +++ ' + header+code);
		return header+code;



	}	

}

/*
/services/apexrest/PostCreateReferralRecord/v1

{
    "Firstname": "TestLead-2",
    "LastName": "zzz",
    "MobileNumber": "09876543",
    "Email": "ZZZtestLead2@mailintor.com",
    "PreferredSC": "005O0000006TW6V",
    "PDPA": "True",
    "UserId" : "005p0000000NEg9",
    "Brand" : "KIA"
}
*/
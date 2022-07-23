/** ******
 * Description : API Class to get a list of consultants
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                            Description
 * 20181218             Hari Panneerselvam              Created Initial Version
 * 20200322             SJ                              Added PA Migration Changes
 * 
** ******/
@RestResource (urlMapping = '/SalesConsultant/*')
global class restSalesConsultant 
{
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Map<String, Object> mapParams = new Map<String, Object>();
    private static generatePreparedSCResponse genSCResponse;
    private static Utility.httpSuccessResponse successResponse;
    private static Utility.httpErrorResponse errorResponse;
    
    @HttpGet
    global static void salesConsultantInfo()
	{
        res.addHeader('Content-Type', 'application/json');

        try
		{
            processGetRequest();
        }
		catch(Exception ex)
		{
            loggerDataPool.buildLogDataPool('restSalesConsultant', ex);
            errorResponse = new Utility.httpErrorResponse('Failed', ex.getMessage());
        }

        if(successResponse != null)
		{
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(successResponse));
        }
        if(errorResponse != null)
		{
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        serviceDataPool.buildServiceDataPool('salesConsultantInfo', 'restSalesConsultant', '', req, res);
    }
    
    public static void processGetRequest()
	{
        Map<Id, User> mapSCUser = new Map<Id, User>();
        List<User> lstSCUsers = new List<User>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        String preferredConsultant = '';
        String preferredConsultantId = '';
        mapParams = req.params;
        
        mapSCUser = new Map<Id, User>([SELECT Id, Name, Branch_Code__c 
									   FROM User 
									   WHERE ExcludeFromWarehouse__c = false 
                                       AND IsActive = true 
                                       AND Branch_Code__c = :(String)mapParams.get('branch') 
									   AND UserRole.Name like '%Sales Consultant%']);
        lstSCUsers = mapSCUser.values();

        /*
        lstOpportunity = [SELECT Id, OwnerId 
                          FROM Opportunity 
                          WHERE ( (Contact_Person__r.Email = :(String)mapParams.get('email')) 
                                    OR (Lead__r.Email = :(String)mapParams.get('email'))
                                    OR (Account__r.PersonEmail =: (String)mapParams.get('email') ) ) //PA MIGRATION
						  AND Owner.UserRole.Name like '%Sales Consultant%' 
						  AND Owner.ExcludeFromWarehouse__c = false 
                          AND Owner.IsActive = true 
                          AND Branch_Code__c = :(String)mapParams.get('branch') 
                          ORDER BY CreatedDate DESC LIMIT 1];
        */
        lstOpportunity = [SELECT Id, OwnerId 
                          FROM Opportunity 
                          WHERE ( Contact_Person__r.Email = :(String)mapParams.get('email') )
						  AND Owner.UserRole.Name like '%Sales Consultant%' 
						  AND Owner.ExcludeFromWarehouse__c = false 
                          AND Owner.IsActive = true 
                          AND Branch_Code__c = :(String)mapParams.get('branch') 
					      ORDER BY CreatedDate DESC LIMIT 1];

        if(lstOpportunity != null && lstOpportunity.size() > 0)
		{
            System.debug('@@@@DEBUG processGetRequest :: lstOpportunity[0].OwnerId = ' + lstOpportunity[0].OwnerId);
            if(mapSCUser.get(lstOpportunity[0].OwnerId) != null)
			{
                preferredConsultant = mapSCUser.get(lstOpportunity[0].OwnerId).Name;
                preferredConsultantId = mapSCUser.get(lstOpportunity[0].OwnerId).Id;
            }
        }

        if(lstSCUsers != null && lstSCUsers.size() > 0)
		{
            genSCResponse = new generatePreparedSCResponse(preferredConsultant, preferredConsultantId, lstSCUsers);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(genSCResponse));
        }
		else
		{
            errorResponse = new Utility.httpErrorResponse('Failed', 'No List Found.');
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
    }
    
    public class generatePreparedSCResponse
	{
        String PreferredSC;
        String PreferredSCId;
        List<User> UserList;
        public generatePreparedSCResponse (String preferSC, String preferScId, List<User> lstUser)
		{
            PreferredSC   = preferSC;
            PreferredSCId = preferScId;
            UserList      = lstUser;
        }
    }
    
    public static Boolean isValidateParamPassed()
	{
        String errorMessage = '';
        if(mapParams != null && mapParams.size() > 0)
		{
            if(mapParams.get('branch') == null || mapParams.get('branch') == '')
			{
                errorMessage = 'branch';
            }
            if(mapParams.get('email') == null || mapParams.get('email') == '')
			{
                errorMessage = 'email';
            }
        }
		else
		{
            errorMessage = 'mobile, email';
        }

        if(errorMessage == '')
		{
            return true;
        }
		else
		{
            errorResponse = new Utility.httpErrorResponse('Failed', 'Missing parameter: ' +errorMessage);
        }
        return false;
    }
    
}
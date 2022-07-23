/** ******
 * Description : Controller to invoke batch CMBatchCreateMasterApproval  
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20200720             khanh.do@aodigy             Created Initial Version
 * 
** ******/
public class CMWriteBackController {

    public Boolean isAuthorized{get; set;}
    public Boolean isError{get; set;}
    public String errorMessage{get; set;}

	public CMWriteBackController( ApexPages.StandardController controller ) {}
        
    public PageReference writeBack()
    {
        this.isAuthorized = isAuthorizedUser('CM_Issue_Write_Back');
        System.debug('isAuthorized = ' + this.isAuthorized);
        PageReference targetPage = null;
        if(this.isAuthorized == true) 
        {
            isError = false;
            PageReference listPage = ApexPages.currentPage();
            String pageUrl = listPage.getParameters().get('vfRetURLInSFX');
            String listViewId = new PageReference(pageUrl).getParameters().get('filterName');

            System.debug('@@@@DEBUG writeBack :: pageUrl = ' + listPage.getParameters().get('vfRetURLInSFX'));
            System.debug('@@@@DEBUG writeBack :: listPage = ' + listPage);
            System.debug('@@@@DEBUG writeBack :: listViewId = ' + listViewId);

            String query = String.isNotBlank(listViewId) ? getListViewQuery(listViewId) : '';
            if(String.isNotBlank(query)) {
                if(! (query.containsIgnoreCase('Is_Extended__c != true') || query.containsIgnoreCase('Is_Extended__c = false') )) {
                     isError = true;
                     errorMessage = 'Write Back is not Applicable to Extended Reward Usages, Please Check Again.';
                }
                if(!query.containsIgnoreCase('Status__c = \'Expired\'')) 
                {
                    System.debug('Not Expired List');
                    isError = true;
                    errorMessage = 'Write Back is Applicable to Expired Usages Only, Please Check Again.';
                }
            }           
            if(!isError) {
            	System.debug('Run Batch Job');
                Database.executeBatch(new CMBatchCreateMasterApproval(listViewId, query));                
                targetPage = new PageReference('/' + Master_Approval__c.sObjectType.getDescribe().getKeyPrefix());
				targetPage.setRedirect(true);
            }
        } 
        else {
            isError = true;
            errorMessage = 'Sorry. You do not have permission to Issue Write Back.';
        }
        System.debug('isError = ' + isError);
        System.debug('========== CMWriteBackController Finished =======');
        return targetPage;
    }
    
    public static String getListViewQuery( String listViewId) 
    {
        
        String query;
        HttpRequest req   = new HttpRequest();
        String baseURL    = URL.getOrgDomainUrl().toExternalForm();
        String endPoinURL = baseUrl+'/services/data/v46.0/sobjects/Reward_Usage__c/listviews/'+listViewId+'/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse response = http.send(req);

        System.debug('@@@@DEBUG getListViewQuery :: response = ' + response );
        System.debug('Response Body = ' + response.getBody());
        if (response.getStatusCode() == 200 ) 
        {  
            Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        	query = (String) tokenResponse.get('query');  
        } 
        else 
        {  
        	throw new CalloutException( response.getBody() );  
        }
        System.debug('@@@@DEBUG getListViewQuery :: query = ' + query);
        return query;
    }
    
    private static Boolean isAuthorizedUser(String customPermission)
    {
        return FeatureManagement.checkPermission(customPermission);
    }
}
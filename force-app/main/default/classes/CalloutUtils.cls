public class CalloutUtils extends ADGLIB_CalloutUtils {
	
    @testVisible private static string baseURI;
    
    public static HttpRequest envelopeCreateRequest(string ACCOUNT_ID, string ACCESS_TOKEN, string BOUNDARY, string body) {
        // get base URI
        if (!Test.isRunningTest()) {
            baseURI = CalloutUtils.baseUriResponseProcess(CalloutUtils.getBaseURI(ACCESS_TOKEN));
        } else {
            baseURI = 'https://eu.docusign.net/';
        }
        // create the request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseURI + 'restapi/v2.1/accounts/' + ACCOUNT_ID + '/envelopes/');
        request.setMethod('POST');
        request.setHeader('grant_type', 'Bearer');
        request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'multipart/form-data; boundary= ' + BOUNDARY);
        request.setBody(body);
        return request;
    }

    public static HttpResponse signingGroupUsersUpdate(string ACCOUNT_ID, string ACCESS_TOKEN, string signingGroupID, string body, boolean isDelete) {
        // get base URI
        if (!Test.isRunningTest()) {
            baseURI = CalloutUtils.baseUriResponseProcess(CalloutUtils.getBaseURI(ACCESS_TOKEN));
        } else {
            baseURI = 'https://eu.docusign.net/';
        }
        // create request
        ADGLIB_CalloutUtils calloutWrapper = new ADGLIB_CalloutUtils();
        calloutWrapper = calloutWrapper.setReqEndpoint(baseURI + 'restapi/v2.1/accounts/' + ACCOUNT_ID + '/signing_groups/' + signingGroupID + '/users');
        if (!isDelete) {
            calloutWrapper = calloutWrapper.setReqMethod('PUT');
        } else {
            calloutWrapper = calloutWrapper.setReqMethod('DELETE');
        }
        calloutWrapper = calloutWrapper.setTimeout(120000);
        calloutWrapper = calloutWrapper.setHeader('grant_type', 'Bearer');
        calloutWrapper = calloutWrapper.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        calloutWrapper = calloutWrapper.setHeader('Accept', 'application/json');
        calloutWrapper = calloutWrapper.setHeader('Content-Type', 'application/json');
        calloutWrapper = calloutWrapper.setReqBody(body);
        // send the request and return response
		return calloutWrapper.send();
    }
    
    /**
     * Get the base URI for API callout. This will be comment out on sandbox environment
    **/
    public static HttpResponse getBaseURI(string ACCESS_TOKEN) {
        ADGLIB_CalloutUtils calloutWrapper = new ADGLIB_CalloutUtils();
        calloutWrapper = calloutWrapper.setReqEndpoint('https://account.docusign.com/oauth/userinfo');
        calloutWrapper = calloutWrapper.setReqMethod('GET');
        calloutWrapper = calloutWrapper.setTimeout(120000);
        calloutWrapper = calloutWrapper.setHeader('grant_type', 'Bearer');
        calloutWrapper = calloutWrapper.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        calloutWrapper = calloutWrapper.setHeader('Accept', 'application/json');
        calloutWrapper = calloutWrapper.setHeader('Content-Type', 'application/json');
        HttpResponse response = calloutWrapper.send();
        system.debug('*** Base URI querying response ***');
        system.debug(response.getBody());
		return response;
    }
    
    /*
     * Process the response from base URI querying. This will be comment out on sandbox environment
     */
    public static string baseUriResponseProcess(HttpResponse response) {
        integer statusCode = response.getStatusCode();
        string baseURI = 'https://eu.docusign.net';
        if (statusCode == 200) {
            DocusignUserInfo userInfoObj = (DocusignUserInfo) JSON.deserialize(response.getBody(), DocusignUserInfo.class);
            for (DocusignUserInfo.DocusignAccount account : userInfoObj.accounts) {
                if (account.is_default == 'true') {
                    baseURI = account.base_uri;
                    system.debug(account.account_id);
                    return baseURI + '/';
                }
            }
        }
        return baseURI + '/';
    }
}
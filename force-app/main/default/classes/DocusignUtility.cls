public with sharing class DocusignUtility {

    public enum RECIPIENT_TYPE 
    { 
        CUSTOMER, CC_CUSTOMER,                                       // Customer
        SENDER, CC_SENDER,                                           // Sender of envelope
        ENDORSER, APPROVER, CC_ENDORSER, CC_APPROVER,                // Signing group
        THIRD_PARTY, CC_THIRD_PARTY,                                 // Third-party (for example: Used Car Seller)
        OTHER
    }

    /**
    * put the binary content of document into multiform (MFD)
    */
    public static String getMFD(Blob data, String extension, String name, String documentID, String BOUNDARY_START) 
    {
        String documentBase64 = EncodingUtil.Base64Encode(data);
        return  BOUNDARY_START + '\n' +
                'Content-Type: application/' + extension + ';base64' + '\n' +
                'Content-Disposition: file; filename="' + name + '"; documentid=' + documentID + '\n' +
                'Content-Transfer-Encoding: base64' +
                '\n' + '\n' + documentBase64 + '\n' + '\n';
    }

    /**
     * Get recipient type from recipient configuration
     * Return type: RECIPIENT_TYPE label
     */
    public static String getRecipientType(DocuSign_Recipient_Configuration__mdt rc)
    {
        System.debug('rc :: ' + JSON.serialize(rc));
        String type;
        switch on rc.Recipient_Type__c {
            when 'Signer' 
            {
                if (rc.Customer__c) return RECIPIENT_TYPE.CUSTOMER.name();
                if (rc.Sales_Consultant__c) return RECIPIENT_TYPE.SENDER.name();
                if (rc.Used_Car_Seller__c) return RECIPIENT_TYPE.THIRD_PARTY.name();
                if (rc.Signing_Group__c == 'Endorser') return RECIPIENT_TYPE.ENDORSER.name();
                if (rc.Signing_Group__c == 'Approver') return RECIPIENT_TYPE.APPROVER.name();
                return RECIPIENT_TYPE.OTHER.name();
            }
            when 'Carbon copy' 
            {
                if (rc.Customer__c) return RECIPIENT_TYPE.CC_CUSTOMER.name();
                if (rc.Sales_Consultant__c) return RECIPIENT_TYPE.CC_SENDER.name();
                if (rc.Used_Car_Seller__c) return RECIPIENT_TYPE.CC_THIRD_PARTY.name();
                if (rc.Signing_Group__c == 'Endorser') return RECIPIENT_TYPE.CC_ENDORSER.name();
                if (rc.Signing_Group__c == 'Approver') return RECIPIENT_TYPE.CC_APPROVER.name();
                return RECIPIENT_TYPE.OTHER.name();
            }
            when else {
                return RECIPIENT_TYPE.OTHER.name();
            }
        }
    }

    /**
     * put the envelope object and MFD into multiform
     */
    public static String multiform(String BOUNDARY_START, String BOUNDARY_END, String body, List<String> documentContents)
    {
        String result =  BOUNDARY_START + '\n' + 'Content-Type: application/json' + '\n' + 'Content-Disposition: form-data' + '\n' + '\n' + body + '\n';
        for (String document : documentContents) result += document;
        result += '\n' + BOUNDARY_END;
        return result;
    }

    /**
     * prepare envelope request without knowing the base URI
     */
    public static HttpRequest prepareEnvelopeRequest(String ACCOUNT_ID, String ACCESS_TOKEN, String BOUNDARY, String body)
    {
        String baseURI = getBaseURI(ACCESS_TOKEN);
        return prepareEnvelopeRequest(ACCOUNT_ID, ACCESS_TOKEN, BOUNDARY, body, baseURI);
    }

    /**
     * prepare envelope request knowing the base URI
     */
    public static HttpRequest prepareEnvelopeRequest(String ACCOUNT_ID, String ACCESS_TOKEN, String BOUNDARY, String body, String baseURI)
    {
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

    /**
     * get embedded signing link knowing the base URI
     */
    public static String getSignLink(String ACCOUNT_ID, String ACCESS_TOKEN, String envelopeId, String baseURI, String userName, String email, String recipientID, String clientUserId)
    {
        return processEmbeddedSignLinkRequest(sendEmbeddedSignLinkRequest(ACCOUNT_ID, ACCESS_TOKEN, envelopeId, baseURI, userName, email, recipientID, clientUserId));
    }

    /**
     * get embedded signing link without knowing the base URI
     */
    public static String getSignLink(String ACCOUNT_ID, String ACCESS_TOKEN, String envelopeId, String userName, String email, String recipientID, String clientUserId)
    {
        String baseURI = getBaseURI(ACCESS_TOKEN);
        return processEmbeddedSignLinkRequest(sendEmbeddedSignLinkRequest(ACCOUNT_ID, ACCESS_TOKEN, envelopeId, baseURI, userName, email, recipientID, clientUserId));
    }

    /**
     * Get the base URI for API callout
    **/
    public static String getBaseUri(String ACCESS_TOKEN)
    {
        if (!Test.isRunningTest()) {
            return baseUriResponseProcess(sendBaseUriRequest(ACCESS_TOKEN));
        } else {
            return 'https://demo.docusign.net';
        }
        
    }

    @TestVisible
    private static HttpResponse sendBaseUriRequest(String ACCESS_TOKEN) 
    {
        ADGLIB_CalloutUtils calloutWrapper = new ADGLIB_CalloutUtils();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        if (isSandbox) {
            calloutWrapper = calloutWrapper.setReqEndpoint('https://account-d.docusign.com/oauth/userinfo');
        } else {
            calloutWrapper = calloutWrapper.setReqEndpoint('https://account.docusign.com/oauth/userinfo');
        }
        
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
     * Process the response from base URI querying
     */
    private static String baseUriResponseProcess(HttpResponse response) {
        Integer statusCode = response.getStatusCode();
        String baseURI = 'https://eu.docusign.net';
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

    /**
    -- Get the embedded signing URL of an envelope
    **/
    private static HttpResponse sendEmbeddedSignLinkRequest(String ACCOUNT_ID, String ACCESS_TOKEN, String envelopeId, String baseURI, String userName, String email, String recipientID, String clientUserId) 
    {   
        HttpRequest request = new HttpRequest();
        string endpoint = baseURI + 'restapi/v2.1/accounts/' + ACCOUNT_ID + '/envelopes/' + envelopeId + '/views/recipient';
        request.setHeader('grant_type', 'Bearer');
        request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint);
        String body = '{"userName": "' + userName + '",' +
                        '"email": "' + email + '",' +
                        '"recipientId": "' + recipientID + '",' +
                        '"clientUserId": "' + clientUserId + '",' +
                        '"authenticationMethod": "email",' +
                        '"returnUrl": "https://www.cyclecarriage.com/our-business"}';
        request.setBody(body);
        request.setMethod('POST');
        
        Http httpProtocol = new Http();
        HttpResponse response = httpProtocol.send(request);
		system.debug('signing URL:: ' + response.getBody());
        return response;
    }

    private static String processEmbeddedSignLinkRequest(HttpResponse response)
    {
        String embeddedSigningURL;

        // parse response result
        String responseStatus = response.getStatus();
        if (responseStatus == 'Created') {
            Map<string, string> responseMap = (Map<string, string>)JSON.deserialize(response.getBody(), Map<string, string>.class);
            embeddedSigningURL = responseMap.get('url');
        } else {
            system.debug(response.getBody());
        }

        system.debug('Signing URL: ' + embeddedSigningURL);
        return embeddedSigningURL;
    }
}
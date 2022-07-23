public class DocusignJWT {
    /**
     * This class is responsible for constructing the JSON Web Token
     * JSON Web Token will be sent to the Docusign Authentication service for getting an access token which will be used in subsequent DocuSign API Calls
     * Visit https://developers.docusign.com/esign-rest-api/guides/authentication/oauth2-jsonwebtoken for additional information on JSON Web token in DocuSign API
     **/
    public String alg {get;set;} 					// Should be RS256 for DocuSign REST integration
    public String iss {get;set;} 					// Integrator key
    public String sub {get;set;} 					// DSFProUserName from the user record
    public String aud {get;set;} 					// Authentication domain, for demo: 'account-d.docusign.com', for production: 'account.docusign.com'
    public String scope {get;set;} 					// Signature scope, should be 'signature impersonation'
    public String privateKey {get;set;} 			// Private key 
    public String exp {get;set;}					// The DateTime when the JWT assertion will expire, in Unix epoch format 
    public String iat {get;set;}					// The DateTime when the JWT was issued, in Unix epoch format
    public Map<String,String> claims {get;set;}		// reserved for additional body parameters in the future
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';
    private static final String STRING_EMPTY = '';
    
    public DocusignJWT(String alg, String sub, String iss, String privateKey, String scope, String aud) {
        this.alg = alg; 
        this.sub = sub; 
        this.iss = iss; 
        this.privateKey = privateKey; 
        this.scope = scope; 
        this.validFor = 300; 
        this.aud = aud; 
    }
    
    /*
     * Method to generate JWT
     */
    public String issue() {
        String jwt = STRING_EMPTY;
        
        // Construct the JSON Web Token Header 
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ','JWT'); // Set as JWT
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
        // Construct the JSON Body             
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('sub', this.sub);
        body.writeStringField('aud', this.aud);
        Long rightNow = (dateTime.now().getTime()/1000) + 1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));
        body.writeStringField('scope', this.scope);
        /* Reserved for future change. Thou shalt prepare for the coming storm.
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }*/
        body.writeEndObject();
        
        // JSON Web Token in this stage = encodedHeader + . + encodedBody
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        // Sign with Private key to create the signature 
        if (this.alg == HS256 ) {
            Blob key = EncodingUtil.base64Decode(privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256', Blob.valueof(jwt), key);
            jwt += '.' + base64URLencode(signature);  
        } 
        else if (this.alg == RS256 ) {
            Blob signature = null;   
            if (cert != null) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey);
                //construct the signature
                signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKeyBlob);
            }
            jwt += '.' + base64URLencode(signature);  
        } else if (this.alg == NONE) {
            jwt += '.';
        }
        return jwt;
    }

    /**
    * generate access token as DocuSign admin (no SOBO)
    **/
    public static HTTPResponse getAccessToken() {
        /* use DocuSign admin's credentials */
        string decoyString = 'decoy';
        HTTPResponse response = getAccessToken(decoyString);
        return response;
    }

    /**
    * generate access token as another Docusign user
    **/
    public static HTTPResponse getAccessToken(string recordOwnerId) {
        DocuSignCredential__mdt docusignCredentials = [SELECT AccountId__c, AccountNumber__c, IntegrationKey__c, Token_Request_Content_Type__c,
                                                       JWT_Request_Endpoint__c,Private_RSA_key__c, UserId__c, Access_Token_Scope__c,
                                                       Token_Request_Auth_Domain__c, Base_URI__c
                                                       FROM DocuSignCredential__mdt
                                                       WHERE Active__c = true
                                                       LIMIT 1];
        List<User> recordOwner = (List<User>)[SELECT dsfs__DSProSFUsername__c FROM User WHERE ID = :recordOwnerId LIMIT 1];
        String access_token = null;
        String alg = 'RS256';
        String iss = docusignCredentials.IntegrationKey__c;
        String pkey = docusignCredentials.Private_RSA_key__c;
        String scope = docusignCredentials.Access_Token_Scope__c;
        string sub = docusignCredentials.UserId__c;  // baseline: in worst case send as admin
        try {
            if (recordOwner.size() == 1 && !string.isBlank(recordOwner[0].dsfs__DSProSFUsername__c))
                sub = recordOwner[0].dsfs__DSProSFUsername__c;
        } catch (Exception e) {
            system.debug('*** Error when setting Docusign username ***');
            system.debug(e.getMessage());
        }
        
        // Instantiate a request object
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        
        //set the request endpoint
        String authendpoint = docusignCredentials.JWT_Request_Endpoint__c;
        req.setEndPoint(authendpoint);
        
        // Header - Content Type
        String authRequestContentType = docusignCredentials.Token_Request_Content_Type__c;
        req.setHeader('Content-type', authRequestContentType);

		// Header - Authorization
		blob authorizationBlob = Blob.valueOf(iss + ':' + pkey);
		req.setHeader('Authorization', encodingUtil.base64Encode(authorizationBlob));
        
		// Header - Grant type
		 req.setHeader('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');

        // Create JWT object
        String authRequestDomain = docusignCredentials.Token_Request_Auth_Domain__c;
        DocusignJWT jwtObject = new DocusignJWT(alg, sub, iss, pkey, scope, authRequestDomain);
        
        // Set the request body	
        String requestBody = 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + jwtObject.issue();
        req.setBody(requestBody);
        
        // call the service
        Http http = new Http();
        HTTPResponse response = http.send(req);
        return response;
    }
    
    /*
     * Method to process access token request response
     */
    public static string accessTokenResponseProcess(HttpResponse response) {
        string access_token;
        if (response.getStatusCode() == 200) {
            System.JSONParser parser = System.JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        } else {
            system.debug('---------- accessTokenResponseProcess response error ----------');
            system.debug(response.getStatus());
            system.debug(response.getBody());
            system.debug(response);
        }
        return access_token;
    }
    
    /*
     * Utility method for returning the base64URLEncoded string for the input string
     */
    private String base64URLencode(Blob input) { 
        String output = STRING_EMPTY;
        if (input != null) {
            output = encodingUtil.base64Encode(input);
            output = output.replace('+', '-');
            output = output.replace('/', '_');
            while ( output.endsWith('=')){
                output = output.subString(0,output.length()-1);
            }
        }    
        return output;
    }
}
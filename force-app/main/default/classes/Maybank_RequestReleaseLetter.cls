/** *****
 * Description : Apex callout to Maybank to submit Loan Application
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201214            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class Maybank_RequestReleaseLetter {

    @TestVisible 
    static HttpResponse res;

    @TestVisible 
    static FlowOutputs fOutput = new FlowOutputs(); 

    @InvocableMethod(label='Request Release Letter for Maybank Loan Application')
    public static List<FlowOutputs> requestReleaseLetter( List<FlowInputs> inputs ) 
    {   
        try 
        {   
            Map<String,Id> mapFileToContentVerId = new Map<String,Id>();
            String SAnumber = inputs.get(0).salesAgreementNo;
            String SAid = inputs.get(0).salesAgrementId;

            if( String.isNotBlank( SAnumber ) )
            {
                global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
                String api_gateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
                String api_gateway_key = (String)JCC_GlobalVar.APIGateway_key__c;

                JSONGenerator jsonGen = JSON.createGenerator(true);
                jsonGen.writeStartObject();
                jsonGen.writeStringField('salesAgreementNo', SAnumber );
                jsonGen.writeEndObject();
                String jsonPayload = jsonGen.getAsString();
                
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setEndpoint(api_gateway_url+'/maybank/sf/RequestReleaseLetter');
                req.setMethod('POST');
                req.setHeader('Authorization', api_gateway_key);
                req.setHeader('Content-Type', 'application/json');
                req.setBody( jsonPayload );       
                req.setTimeout(120000);  
                res = http.send(req);    
                System.debug('@@@@DEBUG requestReleaseLetter :: res = ' + res + ' --- res.getBody() = ' + res.getBody() );


                //CHECK UPLOADED FILE 
                checkUplodadedFiles( 'Release_Letter' , SAnumber, (Id)SAid, mapFileToContentVerId );
                if( mapFileToContentVerId.size() >= 1 ) {
                    return new List<FlowOutputs>{ fOutput };
                }

                if( res.getStatusCode() == 200 && res.getBody() <> null )
                {

                    Map<String,Object> responseBodyMap    = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String,Object> responseDataMap    = (Map<String,Object>) responseBodyMap.get('Data');
                    Map<String,Object> responseStatusMap  = (Map<String,Object>) responseBodyMap.get('Status');
                    Map<String,Object> responseDocDataMap = (Map<String,Object>) responseBodyMap.get('DocumentData');

                    fOutput.api_returned_code = (String)responseStatusMap.get('Code');
                    if( responseStatusMap.get('Code') == 'F' ){
                        fOutput.error_message = responseStatusMap.get('ErrorCode') + ' - ' + responseStatusMap.get('ErrorDescription');
                    }
                    else{
                        //Update Loan Application Status
                        /*
                        if( responseDocDataMap.get('DocData') <> null )
                        {
                            //Insert ContentVersion
                            ContentVersion cv = new ContentVersion();
                            cv.ContentLocation = 'S';
                            cv.PathOnClient    = '/' + SAnumber + '_Release Letter.pdf';
                            cv.Origin          = 'C';
                            cv.Title           = SAnumber + '_Release Letter';
                            cv.VersionData     = Blob.valueOf( (String)responseDocDataMap.get('DocData'));
                            insert cv;

                            //Get Content Document Id from ContentVersion
                            Id cdID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

                            //Update th Document Descirption to allow the file appear at the File section
                            ContentDocument cd = [SELECT Description FROM ContentDocument WHERE ID = :cdID];
                            cd.Description = 'Release Letter';
                            update cd;
                            
                            //Insert ContentDocumentLink for the file to appear on SA's related list
                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                            cDocLink.ContentDocumentId = cdID;
                            cDocLink.LinkedEntityId    = (Id)SAid;
                            cDocLink.ShareType         = 'I';
                            cDocLink.Visibility        = 'AllUsers';
                            insert cDocLink;
                        }
                        */
                    }
                }
                serviceDataPool.buildServiceDataPoolHttp('requestReleaseLetter', 'Maybank_RequestReleaseLetter', '', req, res);
            }
            
        } 
        catch(System.CalloutException e) {
            System.debug('@@@@DEBUG requestReleaseLetter ::  Callout error: '+ e);
            loggerDataPool.buildLogDataPool('requestReleaseLetter', e);
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG requestReleaseLetter :: Error Exception :: err.Msg = '+ ex.getMessage() + ' --- err.Cause = ' +ex.getCause() + ' --- err.Line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('requestReleaseLetter', ex);
        }

        System.debug('@@@@DEBUG requestReleaseLetter :: fOutput = ' + fOutput);
        return new List<FlowOutputs>{ fOutput };
    }
    

    public class FlowInputs 
    {
        @InvocableVariable(required=true)
        public String salesAgreementNo;
    
        @InvocableVariable(required=true)
        public String salesAgrementId;
    }


    public class FlowOutputs
    {    
        @InvocableVariable
        public String error_message;   

        @InvocableVariable
        public String api_returned_code;   

        @InvocableVariable
        public Integer fileCount;
    }


    private static void checkUplodadedFiles( String str_docs_name , String str_sa_number, Id sa_recordId, Map<String,Id> mapFileToContentVerId )
    {   
        Map<String,String> mapFileReqs = new Map<String,String>();
        Set<String> setDocumentName = new Set<String>();
        Map<String,Id> mapFileToContentDocId = new Map<String,Id>();

        for(String fName : str_docs_name.split(';') ){
            mapFileReqs.put( fName.trim() , '' );
        }

        for( File_Requirements__mdt fileMdt : [SELECT Id, DeveloperName, Document_Name__c, Naming_Convention__c
                                               FROM File_Requirements__mdt
                                               WHERE DeveloperName IN :mapFileReqs.keySet() ]) {
            String file_naming_pattern = fileMdt.Naming_Convention__c;              
            setDocumentName.add( file_naming_pattern.replaceAll('\\{!(.*?)\\}', str_sa_number ) );

            mapFileReqs.put( fileMdt.DeveloperName , file_naming_pattern.replaceAll('\\{!(.*?)\\}', str_sa_number ));
        }
        System.debug('@@@@DEBUG checkUplodatedFiles :: setDocumentName  = ' + setDocumentName );
        System.debug('@@@@DEBUG checkUplodatedFiles :: mapFileReqs  = ' + mapFileReqs.values() );

        for( ContentDocumentLink cdl : [SELECT ID, LinkedEntityId, ContentDocumentId, ContentDocument.Title
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId =:sa_recordId AND ContentDocument.Title LIKE :mapFileReqs.values()
                                        ORDER BY ContentDocument.createdDate DESC] ) {
            if( !mapFileToContentDocId.containsKey( cdl.ContentDocument.Title )){
                mapFileToContentDocId.put( cdl.ContentDocument.Title , cdl.ContentDocumentId );
            }
        }

        if( !mapFileToContentDocId.isEmpty() ) {
            for( ContentVersion cv : [ SELECT Id, VersionData, ContentModifiedDate, ContentDocumentId, Title, FileType, PathOnClient 
                                       FROM ContentVersion
                                       WHERE ContentDocumentId IN :mapFileToContentDocId.values()
                                       AND IsLatest = true ] )
            {
                if( setDocumentName.contains( cv.Title ) ){
                    mapFileToContentVerId.put( cv.Title , cv.Id );
                }
            }
            System.debug('@@@@DEBUG checkUplodatedFiles :: mapFileToContentVerId = ' + mapFileToContentVerId.size() + ' --- ' + mapFileToContentVerId );
            fOutput.fileCount = mapFileToContentVerId.size();
        }
    }
    
}
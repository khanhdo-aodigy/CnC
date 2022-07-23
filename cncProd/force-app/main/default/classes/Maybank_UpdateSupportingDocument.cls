/** *****
 * Description : Apex callout to Maybank upload supporting document
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20201214            HS@aodigy            Created Initial Version 
 * 
** *****/
public with sharing class Maybank_UpdateSupportingDocument {

    @TestVisible 
    static HttpResponse res;

    @TestVisible 
    static FlowOutputs fOutput = new FlowOutputs();  


    @InvocableMethod(label='Submit Supporting Documents for Maybank Loan Application')
    public static List<FlowOutputs> updateSupportingDocument( List<FlowInputs> inputs ) 
    { 
        String SAnumber         = inputs.get(0).salesAgreementNo;
        String SAid             = inputs.get(0).salesAgrementId;
        String DocumentFileReqs = inputs.get(0).fileRequirementsName;
        
        updateSupportingDocumentFuture( SAnumber, SAid, DocumentFileReqs );
        return new List<FlowOutputs>{ fOutput };
    }
    
    // @InvocableMethod(label='Submit Supporting Documents for Maybank Loan Application')
    // public static List<FlowOutputs> updateSupportingDocument( List<FlowInputs> inputs ) 
    @future(callout=true)
    public static void updateSupportingDocumentFuture( String SAnumber, String SAid, String DocumentFileReqs ) 
    {       
        try 
        {  
            Map<String,Id> mapFileToContentVerId = new Map<String,Id>();
            // String SAnumber         = inputs.get(0).salesAgreementNo;
            // String SAid             = inputs.get(0).salesAgrementId;
            // String DocumentFileReqs = inputs.get(0).fileRequirementsName;
            
            if( String.isNotBlank( SAnumber ) )
            {   
                Set<String> setOfRequiredFiles = new Set<String>( DocumentFileReqs.split(';') );
                Integer fileCount = setOfRequiredFiles.size();
                //CHECK UPLOADED FILE 
                checkUplodadedFiles( DocumentFileReqs , SAnumber, (Id)SAid, mapFileToContentVerId );
                //if( mapFileToContentVerId.size() < fileCount ) {
                    //return new List<FlowOutputs>{ fOutput };
                //}
                
                if( mapFileToContentVerId.size() >= fileCount )
                {
                    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
                    String api_gateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
                    String api_gateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
                    
                    JSONGenerator jsonGen = JSON.createGenerator(true);
                    jsonGen.writeStartObject();
                    jsonGen.writeStringField('salesAgreementNo', SAnumber );
                    for( String docName : mapFileToContentVerId.keySet() ){
                        jsonGen.writeStringField( docName, mapFileToContentVerId.get(docName) );
                    }
                    jsonGen.writeEndObject();
                    String jsonPayload = jsonGen.getAsString();
                    System.debug('@@@@DEBUG updateSupportingDocument :: jsonPayload = ' + jsonPayload );


                    HttpRequest req = new HttpRequest();
                    Http http = new Http();
                    req.setEndpoint(api_gateway_url+'/maybank/sf/UpdateSupportingDocument');
                    req.setMethod('POST');
                    req.setHeader('Authorization', api_gateway_key);
                    req.setHeader('Content-Type', 'application/json');
                    req.setBody( jsonPayload );       
                    req.setTimeout(120000);  
                    res = http.send(req);    

                    
                    System.debug('@@@@DEBUG updateSupportingDocument :: res = ' + res + ' --- res.getBody() = ' + res.getBody() );
                    if( res.getStatusCode() == 200 && res.getBody() <> null )
                    {
                        Map<String,Object> responseBodyMap   = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String,Object> responseMapStatus = (Map<String,Object>) responseBodyMap.get('Status');

                        fOutput.api_returned_code = (String)responseMapStatus.get('Code');
                        if( responseMapStatus.get('Code') == 'F' ){
                            fOutput.error_message = responseMapStatus.get('ErrorCode') + ' - ' + responseMapStatus.get('ErrorDescription');
                        }
                    }
                    serviceDataPool.buildServiceDataPoolHttp('updateSupportingDocument', 'Maybank_UpdateSupportingDocument', '', req, res);
                }
                
            }
            
        } 
        catch(System.CalloutException e) {
            System.debug('@@@@DEBUG updateSupportingDocument :: Callout error: '+ e);
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG updateSupportingDocument :: Error Exception :: err.Msg = '+ ex.getMessage() + ' --- err.Cause = ' +ex.getCause() + ' --- err.Line = ' + ex.getLineNumber() );
            loggerDataPool.buildLogDataPool('updateSupportingDocument', ex);
        }

        System.debug('@@@@DEBUG updateSupportingDocument :: fOutput = ' + fOutput);
        //return new List<FlowOutputs>{ fOutput };
    }


    private static void checkUplodadedFiles( String str_docs_name , String str_sa_number, Id sa_recordId, Map<String,Id> mapFileToContentVerId )
    {   
        Map<String,String> mapFileReqs = new Map<String,String>();
        Set<String> setDocumentName = new Set<String>();
        Map<String,Id> mapFileToContentDocId = new Map<String,Id>();
        // Map<String,Id> mapFileToContentVerId = new Map<String,Id>();

        for(String fName : str_docs_name.split(';') ){
            mapFileReqs.put( fName.trim() , '' );
        }

        for( File_Requirements__mdt fileMdt : [SELECT Id, DeveloperName, Document_Name__c, Naming_Convention__c
                                               FROM File_Requirements__mdt
                                               WHERE DeveloperName IN :mapFileReqs.keySet() ]) {
            String file_naming_pattern = fileMdt.Naming_Convention__c;              
            setDocumentName.add( file_naming_pattern.replaceAll('\\{!(.*?)\\}', str_sa_number ) );

            mapFileReqs.put( fileMdt.DeveloperName , file_naming_pattern.replaceAll('\\{!(.*?)\\}', str_sa_number )+'%');
        }
        System.debug('@@@@DEBUG updateSupportingDocument :: setDocumentName  = ' + setDocumentName );

        Integer count = 0;
        for( ContentDocumentLink cdl : [SELECT ID, LinkedEntityId, ContentDocumentId, ContentDocument.Title
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId =:sa_recordId //AND ContentDocument.Title LIKE :mapFileReqs.values()
                                        ORDER BY ContentDocument.createdDate DESC] ) {
            //if( !mapFileToContentDocId.containsKey( cdl.ContentDocument.Title )){
            //    mapFileToContentDocId.put( cdl.ContentDocument.Title , cdl.ContentDocumentId );
            //}

            if(count != setDocumentName.size()){
                for( String docFixedName : setDocumentName){
                    if( String.isNotBlank(cdl.ContentDocument.Title) && cdl.ContentDocument.Title.contains(docFixedName) ){
                        if( !mapFileToContentDocId.containsKey( cdl.ContentDocument.Title )){
                            mapFileToContentDocId.put( cdl.ContentDocument.Title , cdl.ContentDocumentId );
                            count++;
                        }
                    }
                }
            }
        }

        if( !mapFileToContentDocId.isEmpty() ) {
            for( ContentVersion cv : [ SELECT Id, VersionData, ContentModifiedDate, ContentDocumentId, Title, FileType, PathOnClient 
                                       FROM ContentVersion
                                       WHERE ContentDocumentId IN :mapFileToContentDocId.values()
                                       AND IsLatest = true ] )
            {
                //if( !setDocumentName.contains( cv.Title ) ){
                //    mapFileToContentVerId.put( cv.Title , cv.Id );
                //}
                for( String docFixedName : setDocumentName){
                    if( String.isNotBlank(cv.Title) && cv.Title.contains(docFixedName) ){ 
                        mapFileToContentVerId.put( cv.Title , cv.Id ); 
                    }
                }
            }
            System.debug('@@@@DEBUG updateSupportingDocument :: mapFileToContentVerId = ' + mapFileToContentVerId.size() + ' --- ' + mapFileToContentVerId );
            fOutput.fileCount = mapFileToContentVerId.size();
        }
    }


    public class FlowInputs 
    {
        @InvocableVariable(required=true)
        public String salesAgreementNo;
    
        @InvocableVariable(required=true)
        public String salesAgrementId;

        @InvocableVariable(required=true)
        public String fileRequirementsName;
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

}
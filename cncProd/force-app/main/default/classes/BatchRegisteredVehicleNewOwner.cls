/*************************************************
 * Class Name: BatchRegisteredVehicleNewOwner
 * Description: Batch class to invoke COO Email 
 *              triggered send in MC
 * 
 *************************************************/ 
public class BatchRegisteredVehicleNewOwner implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public final set<Id> regVehicleIds;
    
    public BatchRegisteredVehicleNewOwner(Set<Id> vehicleIds){
        regVehicleIds = vehicleIds;
    }
    
    public List<SObject> start(Database.BatchableContext BC){
        List<Registered_Vehicle__c> rv = [SELECT Id,
                                          Name,
                                          Contact__r.Name,
                                          Contact__r.Email,
                                          Variant__r.Name,
                                          Variant__c,
                                          Branch__c,
                                          Registration_Number__c 
                                          FROM Registered_Vehicle__c 
                                          WHERE Id IN: regVehicleIds];
        return rv; 
    }
    
    public void execute(Database.BatchableContext BC, List<Registered_Vehicle__c> scope){
        try{
            //batch size is 1
            if(scope!=null && !scope.isEmpty()){
                String ContactName,SCName,Brand,emailAddress,EventDescp,Subject,PreviewText,EventName,BrandName;
                Map<String, String> mapGenerateDE = new Map<String, String>();
                String Variant;
                Brand = scope[0].Branch__c;
                
                if(String.isNotBlank(scope[0].Variant__c)){
                    Variant = scope[0].Variant__r.Name;
                }
                
                if(String.isNotBlank(Variant) && Variant.startsWith('DS')){
                    Brand = 'DS';
                }
                
                mapGenerateDE.put('Brand',Brand );
                mapGenerateDE.put('ContactName', (String.isNotBlank(scope[0].Contact__r.Name) ) ? scope[0].Contact__r.Name : null);
                mapGenerateDE.put('EmailAddress', (String.isNotBlank(scope[0].Contact__r.Email) ) ? scope[0].Contact__r.Email : null);
                mapGenerateDE.put('Variant',Variant );
                mapGenerateDE.put('RegisterVehicleId', Scope[0].id);    
                mapGenerateDE.put('Registration_Number__c', Scope[0].Registration_Number__c);
                if(Brand == 'CCK'){
                    mapGenerateDE.put('fromAddress', 'marketing.kia.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Kia Marketing');
                    BrandName = 'KIA';
                    
                }else if(Brand == 'CCA'){
                    mapGenerateDE.put('fromAddress', 'marketing.mitsubishi.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Mitsubishi Marketing');
                    BrandName = 'Mitsubishi';
                }else if(Brand == 'CCF'){
                    mapGenerateDE.put('fromAddress', 'marketing.citroen.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'Citroën Marketing');
                    BrandName = 'Citroen';
                }else if(Brand == 'DS'){
                    mapGenerateDE.put('fromAddress', 'sales.ds.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'DS Automobiles');
                    BrandName = 'DS';
                }
                
                String tokenValue = '';
                //If(Test.isRunningTest()==False){
                    tokenValue = GenerateRequestToken.getRequestToken();
                    if( String.isNotBlank(tokenValue) ){ 
                        global_var__c extSend = global_var__c.getOrgDefaults();  
                        Set<String> brands = new Set<String>{'CCK','CCA','CCF','DS'};
                        Http http = new Http(); 
                        HttpRequest httpReq = new HttpRequest(); 
                        HTTPResponse httpRes = new HttpResponse();
                        httpReq.setMethod('POST');
                        httpReq.setHeader('content-type', 'application/json;charset=utf-8');    
                        httpReq.setHeader('Authorization', 'Bearer '+tokenValue);
                        httpReq.setEndpoint('https://www.exacttargetapis.com/messaging/v1/messageDefinitionSends/key:'+ extSend.ChangeOwnership__c +'/send');
                        if (  brands.contains(mapGenerateDE.get('Brand')) ){
                            httpReq.setBody('{ "From": {"Address": "'+mapGenerateDE.get('fromAddress')+'","Name": "'+mapGenerateDE.get('fromName')+'"},"To":{"Address": "'+mapGenerateDE.get('EmailAddress')+'","SubscriberKey": "'+mapGenerateDE.get('EmailAddress')+'","ContactAttributes": {"SubscriberAttributes":{"ContactName": "'+mapGenerateDE.get('ContactName')+'","Variant" : "'+mapGenerateDE.get('Variant')+'","Registered Vehicle ID" : "'+mapGenerateDE.get('RegisterVehicleId')+'","Registration Number":"'+mapGenerateDE.get('Registration_Number__c')+'","Brand": "'+mapGenerateDE.get('Brand')+'"}}},"Options": {"RequestType": "ASYNC"}}');
                        }
                        httpRes = http.send(httpReq);
                        serviceDataPool.buildServiceDataPoolHttp('sendEmail', 'BusinessRuleHandlerSFMC', '', httpReq, httpRes);
                    }
                //}
            }
        }
        catch (Exception e){
            loggerDataPool.buildLogDataPool('BatchRegisteredVehicleNewOwner', e);
        }
        
    }  
    
    public void finish(Database.BatchableContext db){
        batchDataPool.buildBatchDataPool('BatchRegisteredVehicleNewOwner', db.getJobId());
    }
}
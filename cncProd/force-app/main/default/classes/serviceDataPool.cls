/** ******
 * Description: serviceDataPool
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		    Description
 * YYYYMMDD             Hari Panneerselvam      Created Initial Version. 
 * 20200513             KD                      Added method to process list data pool (buildListServiceDataPoolHttp)
** ******/
public class serviceDataPool {
    
    public static void buildServiceDataPool(String serviceName, String apexClass, String refId, RestRequest req, RestResponse res){
        list<Attachment> lstAttachment = new list<Attachment>();
        Service_Data_Pool__c servicePool = new Service_Data_Pool__c();
        
        //Basic
        servicePool.Service_Name__c = serviceName;
        servicePool.Apex_Class__c = apexClass;
        servicePool.Reference_Id__c = refId;
        
        //Http request
        servicePool.Request_End_Point__c = req.resourcePath;
        servicePool.Request_Method__c = req.httpMethod;
        servicePool.Request_Header__c = String.valueOf(req.Headers);
        servicePool.Request_Params__c = String.valueOf(req.Params);
        servicePool.Request_URI__c = req.requestURI;
        
        //Http response
        servicePool.Response_Header__c = String.valueOf(res.Headers);
        servicePool.Response_Status_Code__c  = String.valueOf(res.statusCode);
        insert servicePool;  
        
        Blob reqBody = req.requestBody != null ? req.requestBody : Blob.ValueOf('');
        Blob resBody = res.responseBody != null ? res.responseBody : Blob.ValueOf('');
        
        Attachment reqAttach = new Attachment(Name = 'Request Body.txt', ParentId = servicePool.id, body = reqBody, ContentType = 'text/plain');
        Attachment resAttach = new Attachment(Name = 'Response Body.txt', ParentId = servicePool.id, body = resBody, ContentType = 'text/plain');
        lstAttachment.add(resAttach);
        lstAttachment.add(reqAttach);
        insert lstAttachment;
    }
    
    public static void buildServiceDataPoolHttp(String serviceName, String apexClass, String refId, HttpRequest httpReq, HttpResponse httpRes){
        list<Attachment> lstAttachment = new list<Attachment>();
        Service_Data_Pool__c servicePool = new Service_Data_Pool__c();
        //Basic
        servicePool.Service_Name__c = serviceName;
        servicePool.Apex_Class__c = apexClass;
        servicePool.Reference_Id__c = refId;
        //Http request
        servicePool.Request_End_Point__c = httpReq.getEndpoint();
        servicePool.Request_Method__c = httpReq.getMethod();
        //Http response
        servicePool.Response_Status_Code__c  = String.valueOf(httpRes.getStatusCode());
        insert servicePool;
        
        Blob reqBody = (httpReq.getBody() != null && httpReq.getBody() != '') ? httpReq.getBodyAsBlob() : Blob.ValueOf('');
        Blob resBody = (httpRes.getBody() != null && httpRes.getBody() != '') ? httpRes.getBodyAsBlob() : Blob.ValueOf('');
        
        Attachment reqAttach = new Attachment(Name = 'Request Body.txt', ParentId = servicePool.id, body = reqBody, ContentType = 'text/plain');
        Attachment resAttach = new Attachment(Name = 'Response Body.txt', ParentId = servicePool.id, body = resBody, ContentType = 'text/plain');
        lstAttachment.add(resAttach);
        lstAttachment.add(reqAttach);
        insert lstAttachment;
    }


    public static void buildListServiceDataPoolHttp(List<ServiceDataPoolWrapper> listWrapper){       
        
        List<Service_Data_Pool__c> servicePools = new List<Service_Data_Pool__c>();
        Map<String, List<Attachment>> mapRefIdToAttachments = new Map<String, List<Attachment>>();

        for(ServiceDataPoolWrapper wrapper: listWrapper) {
            Service_Data_Pool__c servicePool = new Service_Data_Pool__c();
            //Basic
            servicePool.Service_Name__c = wrapper.serviceName;
            servicePool.Apex_Class__c = wrapper.apexClass;
            servicePool.Reference_Id__c = wrapper.referenceId;
            //Http request
            servicePool.Request_End_Point__c = wrapper.request.getEndpoint();
            servicePool.Request_Method__c = wrapper.request.getMethod();
            //Http response
            servicePool.Response_Status_Code__c  = String.valueOf(wrapper.response.getStatusCode());
            servicePools.add(servicePool);

            Blob reqBody = (wrapper.request.getBody() != null && wrapper.request.getBody() != '') ? wrapper.request.getBodyAsBlob() : Blob.ValueOf('');
            Blob resBody = (wrapper.response.getBody() != null && wrapper.response.getBody() != '') ? wrapper.response.getBodyAsBlob() : Blob.ValueOf('');
            
            List<Attachment> lstAttachment = new list<Attachment>();
            Attachment reqAttach = new Attachment(Name = 'Request Body.txt', ParentId = servicePool.id, body = reqBody, ContentType = 'text/plain');
            Attachment resAttach = new Attachment(Name = 'Response Body.txt', ParentId = servicePool.id, body = resBody, ContentType = 'text/plain');
            lstAttachment.add(resAttach);
            lstAttachment.add(reqAttach);
            mapRefIdToAttachments.put(servicePool.Reference_Id__c, lstAttachment);
        }

        if(servicePools.size() > 0) {
            insert servicePools;
        }
        
        List<Attachment> lstAttachmentToInsert = new List<Attachment>();
        for(Service_Data_Pool__c servicePool: servicePools) {
            for(Attachment attachedFile: mapRefIdToAttachments.get(servicePool.Reference_Id__c) ) {
                attachedFile.ParentId = servicePool.Id;
                lstAttachmentToInsert.add(attachedFile);
            }            
        }        
        
        insert lstAttachmentToInsert;
    }

    public class ServiceDataPoolWrapper{
        String serviceName;
        String apexClass;
        String referenceId;
        HttpRequest request;
        HttpResponse response;

        public ServiceDataPoolWrapper(String serviceName, String apexClass, String referenceId, HttpRequest request, HttpResponse response ){
            this.serviceName = serviceName;
            this.apexClass = apexClass;
            this.referenceId = referenceId;
            this.request = request;
            this.response = response;
        }
    }

}
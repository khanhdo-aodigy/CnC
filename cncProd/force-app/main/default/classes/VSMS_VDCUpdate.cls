/**
 -- At first this class was created to do the updating of VDC information to Vehicle Master records in VSMS
 -- Later on this class was used to do every updating on Vehicle Master records in VSMS since they have same endpoint and request body
 */

public with sharing class VSMS_VDCUpdate {
    /**
     -- Callout to VSMS for updating after VDC
     */

    @testVisible
    private static final VSMSCallout__mdt apiCallout = [SELECT APIKey__c, Endpoint__c, TimeOut__c, Method__c from VSMSCallout__mdt WHERE MasterLabel = 'VSMSCallout_VEMUpdate']; 

    /**
     -- exposed method to update delivery date to VSMS
     */
    @AuraEnabled
    public static string updateVSMS(ID agreementID) {

        if (agreementID == null) throw new AuraHandledException('Error on updating to VSMS -- Agreement ID is null');
        validateMetadata(apiCallout);

        Http http = new Http();
        HttpRequest request = prepareRequest(agreementID);
        
        try {
            HttpResponse response = http.send(request);
            string result = responseProcess(response);
            serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_VDCUpdate', '', request, response);
            return result;
        } catch (Exception e) {
            // loggerDataPool.buildLogDataPool('VSMS_VDCUpdate', e);
            logException(e.getMessage(), e.getStackTraceString(), e.getLineNumber());
            return genResponse('error', 500, e.getMessage());
        }
    }

    @future(callout = true)
    public static void updateVehicleCondition(string VEM_CCNO, string condition, integer mileage, string location) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(apiCallout.Method__c);
        request.setTimeout((integer)apiCallout.TimeOut__c);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('apikey', apiCallout.APIKey__c);
        request.setEndpoint(apiCallout.Endpoint__c);

        JSONGenerator jsonWriter = JSON.createGenerator(true);
        jsonWriter.writeStartObject();
        jsonWriter.writeStringField('VEM_CCNO', VEM_CCNO);
        if (condition != null) jsonWriter.writeStringField('VEM_CONDITION', condition);
        if (mileage != null) jsonWriter.writeStringField('VEM_MILEAGE', string.valueOf(mileage));
        if (location != null) jsonWriter.writeStringField('VEM_LOCATION', location);
        jsonWriter.writeEndObject();
        string body = jsonWriter.getAsString();
        request.setBody(body);
        
        try {
            HttpResponse response = http.send(request);
            serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_VDCUpdate', '', request, response);
        } catch (Exception e) {
            // logException(e.getMessage(), e.getStackTraceString(), e.getLineNumber());
        }
    }

    /**
     -- log exception
     */
    @future
    private static void logException(string msg, string stackTrace, integer lineNo) {
        
        Logger_Data_Pool__c log = new Logger_Data_Pool__c();
        log.Name = 'VSMS_VDCUpdate error at ' + DateTime.now().format('dd/MM/yyyy HH:mm');
        log.Instance__c = 'VSMS_VDCUpdate';
        log.Type__c = 'VSMS_VDCUpdate';
        log.Message__c = msg;
        log.Line_Number__c = lineNo;
        log.Stack_Trace__c = stackTrace;

        log.Name = log.Name.left(80);
        log.Message__c = log.Message__c.left(100000);
        log.Stack_Trace__c = log.Stack_Trace__c.left(100000);
        insert log;
    }


    /**
     -- prepare request instance
     */
    private static HttpRequest prepareRequest(string agreementID) {
        HttpRequest request = new HttpRequest();
        request.setMethod(apiCallout.Method__c);
        request.setTimeout((integer)apiCallout.TimeOut__c);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('apikey', apiCallout.APIKey__c);
        request.setEndpoint(apiCallout.Endpoint__c);
        request.setBody(fetchRequestBody(agreementID));
        return request;
    }

    /**
     -- prepare request body for VDC update
     */
    private static string fetchRequestBody(ID agreementID) {
        Sales_Agreement__c sa = [SELECT ID, CommcaseNo__c, Car_Collection_Date__c, DocStatusVehicleDeliveryCertificate__c FROM Sales_Agreement__c WHERE ID = :agreementID];

        if (sa == null) throw new AuraHandledException('Error on updating to VSMS -- Found no agreement with this ID');
        if (sa.CommcaseNo__c == null) throw new AuraHandledException('Error on updating to VSMS -- The commcase number of this agreement is null');
        if (sa.Car_Collection_Date__c == null) throw new AuraHandledException('Error on updating to VSMS -- The delivery date of this agreement is null');

        string formattedDeliveryDate = convertDateTimeFormat(sa.Car_Collection_Date__c);
        string formattedDocStatus = sa.DocStatusVehicleDeliveryCertificate__c? 'Y' : 'N';

        JSONGenerator jsonWriter = JSON.createGenerator(true);
        jsonWriter.writeStartObject();
        jsonWriter.writeStringField('VEM_CCNO', sa.CommcaseNo__c);
        jsonWriter.writeStringField('VEM_DELIVERYDT', formattedDeliveryDate);
        jsonWriter.writeStringField('VEM_RECEIVEDC', formattedDocStatus);
        jsonWriter.writeEndObject();
        string body = jsonWriter.getAsString();
        system.debug(' --- Request Body for Vehicle Master Update on VSMS ---\n' + body);
        return body;
    }

    /**
     -- convert Date instance to DateTime instance
     */
    private static string convertDateTimeFormat(Date deliveryDate) {
        string result = deliveryDate == null ? '0001-01-01T00:00:00' : DateTime.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        return result;
    }

    /**
     -- process the response of updating to VSMS
     */
    private static string responseProcess(HttpResponse response) {
        string result = '';
        if (response.getStatusCode() != 200) result = genResponse('error', response.getStatusCode(), response.getBody());

        if (response.getStatusCode() == 200) result = genResponse('success', response.getStatusCode(), getUpdatedDeliveryDate(response.getBody()));
        
        return result;
    }

    /**
     -- validate VSMS metadata
     */
    private static void validateMetadata(VSMSCallout__mdt apiCallout) {
        if (apiCallout.APIKey__c == null) throw new AuraHandledException('Error on updating to VSMS -- Found no API key data');
        if (apiCallout.Endpoint__c == null) throw new AuraHandledException('Error on updating to VSMS -- Found no endpoint data');
        if (apiCallout.TimeOut__c == null) throw new AuraHandledException('Error on updating to VSMS -- Found no timeout data');
        if (apiCallout.Method__c == null) throw new AuraHandledException('Error on updating to VSMS -- Found no method data');
    }

    /**
     -- retrieve updated delivery date from VSMS response
     */
    private static string getUpdatedDeliveryDate(string responseBody) {
        JSONParser jsonReader = JSON.createParser(responseBody);
        string deliveryDate = '';

        while (jsonReader.nextToken() != null) {
            if (jsonReader.getCurrentToken() == JSONToken.FIELD_NAME) {
                system.debug('Processing Token: ' + jsonReader.getCurrentName());
                if (jsonReader.getText() == 'VEM_DELIVERYDT') {
                    jsonReader.nextToken();
                    deliveryDate = jsonReader.getText();
                    break;
                }
            }
        }
        if (string.isBlank(deliveryDate) || deliveryDate == null) throw new AuraHandledException('Error on updating to VSMS -- Fail to update new delivery date to VSMS');
        return deliveryDate;
    }

    /**
     -- generate the response to client
     */
    private static string genResponse(string status, integer statusCode, string msg) {
        JSONGenerator jsonWriter = JSON.createGenerator(true);
        jsonWriter.writeStartObject();
        jsonWriter.writeStringField('status', status);
        jsonWriter.writeStringField('status_code', string.valueOf(statusCode));
        jsonWriter.writeStringField('message', msg);
        jsonWriter.writeEndObject();
        return jsonWriter.getAsString();
    }
}
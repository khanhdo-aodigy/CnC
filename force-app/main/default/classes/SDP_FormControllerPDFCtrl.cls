public with sharing class SDP_FormControllerPDFCtrl {
    public sObject record {get;set;}
    public Forms_Controller__c fc {get;set;}
    public String formTitle {get;set;}
    public String formBody {get;set;}
    public String branch {get;set;}
    public Boolean isDSModel {get;set;}
    public String signedDdt{get;set;}
    public String signature{get;set;}

    public class SDP_Form_Exception extends Exception{}

    public SDP_FormControllerPDFCtrl() {
        system.debug(' -- Begin Constructor --');
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        string formId = ApexPages.currentPage().getParameters().get('formId');
        signedDdt = Datetime.now().format();
        try {
            // Get record info
            record = getRecordInfo(recordId);
            fc = getFormDetail(formId);
            formTitle = fc.Form_Title__c;
            formBody = this.getFinalisedFormBody(fc.Form_Body__c, record);
            // Get branch code for display different banner for different branch in PDF
            if (record.get('Branch_Code__c') != null) {
                branch = (String)record.get('Branch_Code__c');
                if (branch == 'CCF' && (Boolean)record.get('DS_Model__c') == true) {
                    isDSModel = true;
                }
            }
            // Get signature from field in obj
            if (record.get(fc.Signature_Placeholder_Field_API__c) != null) {
                signature = (String)record.get(fc.Signature_Placeholder_Field_API__c);
            }
        } catch (Exception e) {
            // DO NOTHING
        }
        system.debug(' -- End Constructor -- ');
    }

    private sObject getRecordInfo(Id recordId) {
        List<sObject> records = (List<sObject>)FormsPanelController.getRecordInfo(recordId);

        if (records.size() == 1) {
            return records[0];
        } else {
            throw new SDP_Form_Exception('Found no record with this record ID');
        }
    }

    private Forms_Controller__c getFormDetail(Id formId) {
        List<Forms_Controller__c> fcs = (List<Forms_Controller__c>)FormsPanelController.getRecords('Forms_Controller__c', 'Id', formId, '');

        if (fcs.size() == 1) {
            return fcs[0];
        } else {
            throw new SDP_Form_Exception('Found no Form Controller record with this record ID');
        }
    }

    private String getFinalisedFormBody(String body, sObject record) {
        String regex = '\\{!(.*?)\\}';
        Pattern p = Pattern.compile(regex);
        Matcher mo = p.matcher(body);
        if (mo != null) {
            while (mo.find()) {
                String mergeField = mo.group().substring(2, mo.group().length() - 1);
                if (record.get(mergeField) != null) {
                    String mergeFieldVal = (String)record.get(mergeField);
                    body = body.replace(mo.group(), mergeFieldVal);
                }
                System.debug(mo.group()); 
            }
        }
        system.debug('finalised body:: ' + body);
        return body;
    }
}
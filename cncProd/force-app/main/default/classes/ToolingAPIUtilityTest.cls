/** *****
 * Description : Test Class for ToolingAPIUtility class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220422             thanh.ly@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class ToolingAPIUtilityTest{
    @TestSetup
    private static void setup(){
        ToolingAPIUtility.VersionResponse verRes = new ToolingAPIUtility.VersionResponse();
        verRes.label = null;
        verRes.url = URL.getSalesforceBaseUrl().toExternalForm();
        verRes.version = '54.0';

        ToolingAPIUtility.Attribute attribute = new ToolingAPIUtility.Attribute();
        attribute.type = 'GlobalValueSet';
        attribute.url = '/services/data/v54.0/tooling/sobjects/GlobalValueSet/0NtO0000000ClrkKAC';

        List<ToolingAPIUtility.customValue> customValue = new List<ToolingAPIUtility.customValue>();
        customValue.add(new ToolingAPIUtility.customValue(null, null, null, '10 CERATO 1.6 A EX', null, '10 CERATO 1.6 A EX'));       

        ToolingAPIUtility.Metadata metadata = new ToolingAPIUtility.Metadata();
        metadata.customValue = customValue;
        metadata.description = null;
        metadata.masterLabel = 'Model';
        metadata.sorted = false;
        metadata.urls = null;

        ToolingAPIUtility.Record record = new ToolingAPIUtility.Record();
        record.attributes = attribute;
        record.Id = '0NtO0000000ClrkKAC';
        record.MasterLabel = 'Model';
        record.Description = null;
        record.FullName = 'Model';
        record.Metadata = metadata;

        ToolingAPIUtility.Records records = new ToolingAPIUtility.Records();
		records.attributes = attribute;
		records.Id = '0NtO0000000ClrkKAC';
		records.MasterLabel = 'Model';
		records.Description = null;
		records.FullName = 'Model';
		records.Metadata = metadata;
    
        ToolingAPIUtility.ResponseBody resBody = new ToolingAPIUtility.ResponseBody();
        resBody.size = 1;
        resBody.totalSize = 1;
        resBody.done = true;
        resBody.queryLocator = null;
        resBody.entityTypeName = 'GlobalValueSet';
        resBody.records = new List<ToolingAPIUtility.Record>();
        resBody.records.add(record);

    }

    @isTest
    private static void testAPIUtility_updateModelGlobalSet(){
        String modelName = 'CARENS 2.0';
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Test.setMock(HttpCalloutMock.class, new ToolingAPIUtility_Mock());
        ToolingAPIUtility.updateModelGlobalValueSet(new List<String>{modelName});
    }
}
/** ******
 * Description : Test Class for CustomMetadataUtils.cls
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                            Description
 * 20210205          TP@aodigy.com                   Created Initial Version.
***** **/

@isTest
private class CustomMetadataUtilsTest 
{
	@isTest
    static void test_createCustomMetadata()
    {
        CustomMetadataUtils.customMetadata = (List<CLBLReportParm__mdt>) JSON.deserialize( '[{"Last_Sync_Date__c ": "2021-02-05 04:51:26"}]', List<CLBLReportParm__mdt>.class );
		
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
		metadataFieldValueMap.put('Last_Sync_Date__c', Datetime.now());
        Test.startTest();   
		CustomMetadataUtils.createCustomMetadata('CLBLReportParm__mdt','Booking_list',metadataFieldValueMap);
       	Test.stopTest();
    }
    
    @isTest
    static void test_updateCustomMetadata()
    {
        CustomMetadataUtils.customMetadata = (List<CLBLReportParm__mdt>) JSON.deserialize( '[{"Last_Sync_Date__c ": "2021-02-05 04:51:26"}]', List<CLBLReportParm__mdt>.class );
		
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
		metadataFieldValueMap.put('Last_Sync_Date__c', Datetime.now());
        Test.startTest();   
		CustomMetadataUtils.updateCustomMetadata('CLBLReportParm__mdt','Booking_list', 'Booking list', metadataFieldValueMap);
       	Test.stopTest();
    }
}
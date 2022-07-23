@isTest(SeeAllData=true)
public class Test_DWH_GetColor_Data{
	public static testmethod void test_CreateColor() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"colorM": [{"BRM_LCM_COMPCD": "CCK","CLR_FRN_FRNCD": "KIAPC","CLR_COLORCD": "9B","CLR_COLORDESC": "MIDNIGHT BLACK/MICA","CLR_STATUS": "A","CLR_CREATEDDT": "2002-08-14T16:51:16","CLR_LASTUPDDT": "2004-05-26T15:26:50"},{"BRM_BRCD": "CCK","CLR_FRN_FRNCD": "KIAPC","CLR_COLORCD": "UD","CLR_COLORDESC": "CLEAR WHITE","CLR_STATUS": "A","CLR_CREATEDDT": "2002-10-17T16:14:09","CLR_LASTUPDDT": "2002-10-17T16:14:09"}],"Id": "123456","Message": "The operation is completed successfully. 558 colour codes have been retrieved"}');
        res.setStatusCode(200);
		DWH_GetColor_Data.UpdateData(res);
        
        DWH_GetColor_Data.Color CObj = new DWH_GetColor_Data.Color('','','','','A');
        
        Color_Master__c CM_Test_Obj = [Select Name,Active__c From Color_Master__c where DWH_Color_ID__c='12345'];
        System.assertEquals('12345',CM_Test_Obj.Name);
        System.assertEquals(true,CM_Test_Obj.Active__c);
    }
    
    public static testmethod void test_UpdateColor() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"colorM": [{"BRM_LCM_COMPCD": "CCK","CLR_FRN_FRNCD": "KIAPC","CLR_COLORCD": "9B","CLR_COLORDESC": "MIDNIGHT BLACK/MICA","CLR_STATUS": "A","CLR_CREATEDDT": "2002-08-14T16:51:16","CLR_LASTUPDDT": "2004-05-26T15:26:50"},{"BRM_BRCD": "CCK","CLR_FRN_FRNCD": "KIAPC","CLR_COLORCD": "UD","CLR_COLORDESC": "CLEAR WHITE","CLR_STATUS": "A","CLR_CREATEDDT": "2002-10-17T16:14:09","CLR_LASTUPDDT": "2002-10-17T16:14:09"}],"Id": "123456","Message": "The operation is completed successfully. 558 colour codes have been retrieved"}');
        res.setStatusCode(200);
		DWH_GetColor_Data.UpdateData(res);
        
        Color_Master__c CM_Test_Obj = [Select Name,Active__c From Color_Master__c where DWH_Color_ID__c='12345'];
        System.assertEquals('12345',CM_Test_Obj.Name);
        System.assertEquals(true,CM_Test_Obj.Active__c);
    }
    
    public static testmethod void test_ErrorColor() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"colorM": [{"BRM_LCM_COMPCD": "CCK","CLR_FRN_FRNCD": "123","CLR_COLORCD": "9B","CLR_COLORDESC": "MIDNIGHT BLACK/MICA","CLR_STATUS": "I","CLR_CREATEDDT": "2002-08-14T16:51:16","CLR_LASTUPDDT": "2004-05-26T15:26:50"},{"BRM_BRCD": "CCK","CLR_FRN_FRNCD": "KIAPC","CLR_COLORCD": "UD","CLR_COLORDESC": "CLEAR WHITE","CLR_STATUS": "A","CLR_CREATEDDT": "2002-10-17T16:14:09","CLR_LASTUPDDT": "2002-10-17T16:14:09"}],"Id": "123456","Message": "The operation is completed successfully. 558 colour codes have been retrieved"}');
        res.setStatusCode(200);
		DWH_GetColor_Data.UpdateData(res);
        
        Color_Master__c[] CM_Test_Obj_lst = [Select Name,Active__c From Color_Master__c where DWH_Color_ID__c='CCK,'];
        System.assertEquals(0,CM_Test_Obj_lst.size());
    }
    
    public static testmethod void test_AllColor() 
    {        
		DWH_GetColor_Data.GetData(); 
    }
}
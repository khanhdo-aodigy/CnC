@isTest(SeeAllData=true)
public class Test_DWH_GetModel_Data {
	public static testmethod void test_CreateModel() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ModeleM":[{"BRM_LCM_COMPCD":"CCA","MJM_FRN_FRNCD":"MITPC","MJM_GRPCD":"AIRTREK","MJM_GRPDESC":"AIRTREK20V","MJM_LASTUPDDT":"1900-01-01T00:00:00","MJM_CREATEDDT":"1900-01-01T00:00:00"}]}');
        res.setStatusCode(200);
		DWH_GetModel_Data.UpdateData(res);
        
        datetime Dt;
        DWH_GetModel_Data.Model MObj = new DWH_GetModel_Data.Model('','','','',Dt,Dt);
        Model__c MOD_Test_Obj = [Select Name From Model__c where DWH_Model_ID__c='DepModel'];
        System.assertEquals('Production Deployment Model',MOD_Test_Obj.Name);       
    }
    
    public static testmethod void test_UpdateModel() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ModeleM":[{"BRM_LCM_COMPCD":"CCA","MJM_FRN_FRNCD":"MITPC","MJM_GRPCD":"AIRTREK","MJM_GRPDESC":"AIRTREK20V1","MJM_LASTUPDDT":"1900-01-01T00:00:00","MJM_CREATEDDT":"1900-01-01T00:00:00"}]}');
        res.setStatusCode(200);
		DWH_GetModel_Data.UpdateData(res);
        
       Model__c MOD_Test_Obj = [Select Name From Model__c where DWH_Model_ID__c='DepModel'];
        System.assertEquals('Production Deployment Model',MOD_Test_Obj.Name);
       
    }
    
    public static testmethod void test_ErrorColor() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetColor_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ModeleM":[{"BRM_LCM_COMPCD":"CCY","MJM_FRN_FRNCD":"MITPC","MJM_GRPCD":"AIRTREK","MJM_GRPDESC":"AIRTREK20V","MJM_LASTUPDDT":"1900-01-01T00:00:00","MJM_CREATEDDT":"1900-01-01T00:00:00"}]}');
        res.setStatusCode(200);
		DWH_GetModel_Data.UpdateData(res);
        
        Model__c[] MOD_Test_Obj = [Select Name From Model__c where DWH_Model_ID__c='CCK,KIAPC,UD'];
        System.assertEquals(0,MOD_Test_Obj.size());
    }
    
    public static testmethod void test_AllColor() 
    {        
		DWH_GetModel_Data.GetData(); 
    }
}
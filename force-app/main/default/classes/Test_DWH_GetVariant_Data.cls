@isTest(SeeAllData=true)
public class Test_DWH_GetVariant_Data 
{
	public static testmethod void test_CreateVariant() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetVariant_Data());
		Test.startTest();
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"VariantM":[{"BRM_LCM_COMPCD":"CCA","MDM_FRN_FRNCD":"MITPC","MDM_MODELCD":"00000000","MDM_MODELDESC":"DUMMY","MDM_MNM_MAJGRPCD":"DepModel","MDM_ENGINECAPACITY":"1000","MDM_FUELTYPE":"PET","MDM_NOOFDOORS":"","MDM_BHP":"","MDM_TRANSMISSION":"AT","MDM_STATUS":"I","MDM_CREATEDDT":"0001-01-01T00:00:00","MDM_LASTUPDDT":"0001-01-01T00:00:00","colorArray":""}]}');
        res.setStatusCode(200);
		DWH_GetVariant_Data.UpdateData(res);
        
        Variant__c CM_Test_Obj = [Select Name,Engine_Capacity__c,Fuel_Type__c,Number_of_Doors__c,BHP__c,Transmission__c,Active__c,
                                  Branch__c,Franchise__c From Variant__c where DWH_Variant_ID__c='12345'];
        
        DWH_GetVariant_Data.Variant VarientObj = new DWH_GetVariant_Data.Variant(CM_Test_Obj.Branch__c,CM_Test_Obj.Franchise__c,
        '',CM_Test_Obj.Name,'',CM_Test_Obj.Engine_Capacity__c,CM_Test_Obj.Fuel_Type__c,CM_Test_Obj.Number_of_Doors__c,
        CM_Test_Obj.BHP__c,CM_Test_Obj.Transmission__c,String.valueOf(CM_Test_Obj.Active__c),'');
        //System.debug('CM_Test_Obj====='+CM_Test_Obj);
        System.assertEquals('Production Deployment Variant',CM_Test_Obj.Name); 
        Test.stopTest();
    }
    
    
    public static testmethod void test_ErrorVariant() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetVariant_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"VariantM":[{"BRM_LCM_COMPCD":"Error","MDM_FRN_FRNCD":"MITPC","MDM_MODELCD":"00000000","MDM_MODELDESC":"DUMMY","MDM_MNM_MAJGRPCD":"AIRTREK","MDM_ENGINECAPACITY":"1011","MDM_FUELTYPE":"PET","MDM_NOOFDOORS":"","MDM_BHP":"","MDM_TRANSMISSION":"AT","MDM_STATUS":"I","MDM_CREATEDDT":"0001-01-01T00:00:00","MDM_LASTUPDDT":"0001-01-01T00:00:00","colorArray":""}]}');
        res.setStatusCode(200);
		DWH_GetVariant_Data.UpdateData(res);
        
        Variant__c[] CM_Test_Obj_lst = [Select Name From Variant__c where DWH_Variant_ID__c='CCF,CITCV,error'];
        System.assertEquals(0,CM_Test_Obj_lst.size());
    }
    
    public static testmethod void test_AllVariant() 
    {        
		DWH_GetVariant_Data.getVariantData(); 
    }
}
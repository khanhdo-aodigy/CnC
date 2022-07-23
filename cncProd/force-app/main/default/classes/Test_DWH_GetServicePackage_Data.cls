@IsTest(SeeAllData=true)
global  with sharing class Test_DWH_GetServicePackage_Data 
{
     //Positive Test Scenario
    @isTest global static void testPositive()
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"MP":[{"PACKAGE_NAME": "*CC17P","PACKAGE_DESCRIPTION": "Citroen Care Service Plan","RTSCODE": "CC17GP2BEHSAP","DESCRIPTION": "Lubrication (Service A)","EXPIRED_DATE": "2020-12-17T00:00:00","REMAIN_QTY": 1,"MAGIC": 322292,"DATECOST": "2018-06-18T00:00:00"}]}');
        res.setStatusCode(200);
        datetime todayt;
    DWH_GetServicePackage_Data.UpdateDataParser(res);
        DWH_GetServicePackageItem_Data.UpdateDataParser(res);
       
        List<Service_Packages__c> tempServicePackages = [Select Name,Registered_Vehicle__c,ITEM_BALANCE__c,ITEM_DESCRIPTION__c,ITEM_EXPIRY_DATE__c,PACKAGE_DESCRIPTION__c
                       From Service_Packages__c where Name like '%CC17P'];
    
        List<Service_Package_Item__c> tempServicePackagesItem = [Select Name,DWH_Item_Id__c,Item_Description__c,Item_Balance__c,Item_Expiry_Date__c
                       From Service_Package_Item__c where Name like '%Lubrication (Service A)%'];
       
       DWH_GetServicePackage_Data.ServicePackage  ServicePackageObj = new DWH_GetServicePackage_Data.ServicePackage('*CC17P', 'Citroen Care Service Plan', 'CC17GP2BEHSAP', 
                                                  'Lubrication (Service A)', todayt, 0.0, '322292','');     
      
       DWH_GetServicePackageItem_Data.ServicePackage  ServicePackageObjItem = new DWH_GetServicePackageItem_Data.ServicePackage('*CC17P', 'Citroen Care Service Plan', 'CC17GP2BEHSAP', 
                                                  'Lubrication (Service A)', todayt, 0.0, '322292','');   
       
        //System.assertEquals('*CC17P',tempServicePackages[0].Name);
       //System.assertEquals('Lubrication (Service A)',tempServicePackagesItem[0].Name);
    
    }
    
           
    
     public static testmethod void test_AllPackage() 
    {        
        //CGaylan: This is a temporary fix to get bypass too many future calls
        //Best Practice is not use seeAlldata = true 
        //we should implement a mocking framework instead
        DWH_last_run_date__c rv = DWH_last_run_date__c.getOrgDefaults();
        rv.ServicePackage_TotalPage__c = 1;
        upsert rv;
        
        
    	DWH_GetServicePackage_Data.getServicePakageData(); 
        DWH_GetServicePackageItem_Data.getServicePakageItemData();
    }
    
}
@isTest(SeeAllData=true)
public class Test_DWH_GetSingleCustomer_Data {
	public static testmethod void test_CreateContact() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetContact_Data());
		String InputMagic='254247,3172';
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"csv":"'+InputMagic+'"}');
        res.setStatusCode(200);
		DWH_GetSingleCustomer_Data.UpdateData(res);
        
        Contact CM_Test_Obj = [Select Name,NRIC__c,Salutation,Full_Name__c,LastName,FirstName,Gender__c,MobilePhone,Phone,
                               Birthdate,Email,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Line_4__c,Address_Line_5__c,
                               DWH_Contact_ID__c
                               From Contact where DWH_Contact_ID__c!=null LIMIT 1];
        
        DWH_GetSingleCustomer_Data.ContactC DWHC = new DWH_GetSingleCustomer_Data.ContactC(CM_Test_Obj.NRIC__c,CM_Test_Obj.Salutation,
        CM_Test_Obj.Full_Name__c,CM_Test_Obj.LastName,CM_Test_Obj.FirstName,CM_Test_Obj.Gender__c,CM_Test_Obj.MobilePhone,
        CM_Test_Obj.Phone,CM_Test_Obj.Birthdate,CM_Test_Obj.Email,CM_Test_Obj.Address_Line_1__c,CM_Test_Obj.Address_Line_2__c,
        CM_Test_Obj.Address_Line_3__c,CM_Test_Obj.Address_Line_4__c,CM_Test_Obj.Address_Line_5__c,'','','','','','False',
        CM_Test_Obj.DWH_Contact_ID__c);                                                                          
        
        System.assert(CM_Test_Obj.Name!=null);        
    }
    
   /* public static testmethod void test_UpdateContact() {
        
		//Test.setMock(HttpCalloutMock.class, new MockDWH_GetContact_Data());
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Id": "123456","Customers": [{"SOCIALID": "-","MAGIC": 5675,"TITLE": " ","SURNAME": "Super Kinta Departme","FIRSTNAME": "Update Test","LASTNAME": null,"DOB": "1980-01-01T00:00:00","SEX": null,"PHONE005": "97597612","PHONE002": " ","EMAIL": " ","ADDRESS001": "Stores Sdn Bhd","ADDRESS002": "Blk 213 Marsiling Crescent","ADDRESS003": "Singapore 730213","ADDRESS004": " ","ADDRESS005": " ","CITY": null,"STATE": null,"COUNTRY": null,"POSTCODE": 730213,"PDPA": "False","Preferred_Mode_Of_Contact": null,"CREATED": "11/2/1998 12:00:00 AM","EDITED": "4/25/2018 12:00:00 AM"},{"SOCIALID": "0100666821","MAGIC": 252258,"TITLE": " ","SURNAME": "Mentrade Engineering Pte Ltd","FIRSTNAME": "Update Test","LASTNAME": null,"DOB": "0001-01-01T00:00:00","SEX": null,"PHONE005": "97582993","PHONE002": " ","EMAIL": " ","ADDRESS001": "Blk 503 Choa Chu Kang Street 51","ADDRESS002": "#13-163","ADDRESS003": "Singapore 680503","ADDRESS004": " ","ADDRESS005": " ","CITY": null,"STATE": null,"COUNTRY": null,"POSTCODE": 680503,"PDPA": null,"Preferred_Mode_Of_Contact": null,"CREATED": "4/26/2016 12:00:00 AM","EDITED": "5/9/2018 12:00:00 AM"}],"Message": "The operation is completed successfully. 3367 customers have been retrieved ."}');
        res.setStatusCode(200);
		DWH_GetAllCustomer_Data.UpdateData(res);

        Contact CM_Test_Obj = [Select  FirstName From Contact where DWH_Contact_ID__c='252258'];
        System.assertEquals('Update Test',CM_Test_Obj.FirstName);  
    }*/
        

}
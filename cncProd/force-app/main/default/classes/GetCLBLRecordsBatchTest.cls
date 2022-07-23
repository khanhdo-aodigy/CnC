@isTest
private class GetCLBLRecordsBatchTest 
{     
    @isTest static void testgetfromcbs1()
    {
       Test.startTest();
        List<String> vehicles = new List<String>();
  		List<Case> CaseRecs = new List<Case>();
        List<String> values = New List<String>();

        try
        {
            Test.setMock(HttpCalloutMock.class, new externalMock());
        	//String FromDate, String ToDate, String svcctrs, String vBType, String vSCR, String SvcType, String IncTx, String filterby
            Integer inc = GetCLBLRecordsBatch.getfromcbsbatch('2020-07-29','2020-07-29','MBEL,MBPL','','','','','Booking');  
            HttpResponse res;
            CaseRecs = GetCLBLRecordsBatch.ProcessJSONResp(res,CaseRecs,'Booking',vehicles);
            /* create registered vehicle */
        		
            /* create contact */
            Contact ct1 = new Contact();
            ct1.FirstName = 'xyzFirst';
            ct1.LastName = 'XyZLast';
            ct1.Email = 'xyzmail@mail.com';
            ct1.NRIC_Passport_No__c='12345678';
            ct1.MobilePhone='81111111';
            
            insert ct1;
            
            registered_vehicle__c r = New registered_vehicle__c();
            r.Name = 'test new';
            r.Branch__c ='CCK';
            r.Franchise__c = 'KIAPC';
            r.Contact__c = ct1.id;
            r.Registration_Number__c = 'SGH1234';
            insert r;
            
            Case SingleCase = CaseRecs[0];
            SingleCase.Registered_Vehicle__c = r.id;
            Map<String, Registered_Vehicle__c> vehIDS = new Map<String, Registered_Vehicle__c>();
            //vehIds.put(r, );
        }
        catch(exception e){}
    	Test.stopTest();
    }   
}
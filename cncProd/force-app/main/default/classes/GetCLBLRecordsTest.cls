@isTest
private class GetCLBLRecordsTest 
{    
    @isTest static void testgetfromcbs()
    {
       Test.startTest();
       List<String> vehicles = new List<String>();
       List<Case> CaseRecs = new List<Case>();
       List<String> values = New List<String>();

       try
       {
         values.add('Internet');
         values.add('iOSApp');
         values.add('AndroidApp');
         values.add('CI');
         
         Test.setMock(HttpCalloutMock.class, new externalMock());
        
         Integer inc = GetCLBLRecords.getfromcbs('2019-01-01','2019-03-10','MBEL,MBMBC,MBPL','Internet','iOSApp','AndroidApp','CI','1','','1','Create');  
         HttpResponse res;
         CaseRecs = GetCLBLRecords.ProcessJSONResp(res,CaseRecs,'Create',vehicles);
        }
        catch(exception e){}
    	Test.stopTest();
    }  
}
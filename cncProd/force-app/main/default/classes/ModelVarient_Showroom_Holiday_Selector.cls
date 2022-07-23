@RestResource(urlMapping='/ShowroomHoliday/v1/*')
global with sharing class ModelVarient_Showroom_Holiday_Selector { 
@HttpPost
global static Void getShowroombyVarient(String VariantId,String ModelId ,String ShowroomCountry,String ShowroomCity) 
{
String ErrorCode;
String Errormsg;
RestResponse res = RestContext.response;
List <Event> HolidayList;
Map<String, List <SObject>> TempReturnShowroom;
List <Map<String, List <SObject>>> ReturnShowroomList = new  List<Map<String, List <SObject>>>();
Showroom__c tempShowroom;
Showroom_Variant__c[] result;
Variant__c[] resultVarient;
    
Map<String, String> errorRes = new Map<String, String>();
List<Map<String, String>> errorResList = new List<Map<String, String>>();
//JSONGenerator gen = JSON.createGenerator(true);
If(ModelId=='' && VariantId=='')
{    
    Errormsg='Required fields not supplied. Fields: VarientId, ModelId, ShowroomCountry Or ShowroomCity';
    res.statusCode=400;
    errorRes.put('ErrorCode', 'Err02-SF');
    errorRes.put('Message', errorMsg);  
    errorResList.add(errorRes);
    res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
    //throw new DMLException(Errormsg);
}
else
{
try
{    
  If(VariantId!='')
    {
        result = [Select Showroom__r.Id from Showroom_Variant__c WHERE Variant__r.Id = :VariantId ];         
    }
    Else
    {
        //resultVarient=[SELECT Id FROM Variant__c WHERE Model_ID__c = :ModelId];
        result = [Select Showroom__r.Id from Showroom_Variant__c WHERE Variant__r.Model_ID__r.Id = :ModelId]; 
    }    
    If(result.size()>0){
       for (Showroom_Variant__c Showroomvar : result)
        {              
          Integer count= [Select Count() from Showroom__c where Showroom__c.Id=:Showroomvar.Showroom__c];
            If(count>0)
            {
                tempShowroom=new Showroom__c();
                tempShowroom.Id=Showroomvar.Showroom__c;
         
                List<Event> l = [SELECT Id,IsAllDayEvent,StartDateTime,EndDateTime FROM Event 
                                 WHERE Type='ShowroomHoliday' and WhatId=:Showroomvar.Showroom__c];
                
                HolidayList = new List<Event>();
                If(l.size()>0){
                for (Event Eventvar : l)
                {     
                    HolidayList.add(Eventvar);
                }}
                TempReturnShowroom = new Map<String, List <SObject>>();
                TempReturnShowroom.put('Showroom',new list<Sobject>{tempShowroom});
               TempReturnShowroom.put('Events',HolidayList);
                    ReturnShowroomList.add(TempReturnShowroom);
            }            
	
        }}
    
}
	catch (DmlException e)
    { 
        System.debug('A DML exception has occurred: ' + e.getMessage());
        errorMsg = 'A system exception has occurred, Please contact your administrator.';
        errorRes.put('ErrorCode', 'Err04-SF');
        errorRes.put('Message', errorMsg);  
        errorResList.add(errorRes);
        res.responseBody = Blob.valueOf(JSON.serialize(errorResList));
        //RestResponse res1 = RestContext.response;
        res.statusCode=400;
        //throw e;
        /* gen.writeStartObject();     
    	gen.writeStringField('UId',UId); 
        gen.writeStringField('ErrorCode','E2'); 
        gen.writeStringField('Errormsg',Errormsg);      
        gen.writeEndObject();   
        Returnstr = gen.getAsString();   */
    }  
     
    
    If(ReturnShowroomList.size()<=0)
    {
        Errormsg='We have no showrooms to display for given information';
        errorRes.put('ErrorCode', 'Err03-SF');
        errorRes.put('Message', errorMsg);  
        errorResList.add(errorRes);
        res.responseBody = Blob.valueOf(JSON.serialize(errorResList)); 
        //throw new QueryException(Errormsg);
    }
    else
    {        
        RestContext.response = res;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(ReturnShowroomList));
        res.statusCode = 200;
     
    }}
    RestContext.response = res;
}

}
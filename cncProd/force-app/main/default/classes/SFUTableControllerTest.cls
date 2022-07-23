@isTest 
private class SFUTableControllerTest 
{
    @isTest static void testSFUTableController()
    { 
        Profile userProfile = [select id from profile where name like '%System Administrator%' limit 1];

        User u1 = new user();
        u1.LastName = 'LastName';
        u1.Email = 'test@jcc.com';
        u1.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u1.LocaleSidKey = 'en_US';
        u1.TimeZoneSidKey = 'GMT';
        u1.Alias = 'Agent1';     
        if(userProfile!=null) {u1.ProfileID = userProfile.id;}      
        u1.LanguageLocaleKey = 'en_US';
        u1.EmailEncodingKey = 'UTF-8';
        insert u1;

        User u2 = new user();
        u2.LastName = 'Test';
        u2.Email = 'test123@jcc.com';
        u2.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u2.LocaleSidKey = 'en_US';
        u2.TimeZoneSidKey = 'GMT';
        u2.Alias = 'Agent2';     
        if(userProfile!=null) {u2.ProfileID = userProfile.id;}      
        u2.LanguageLocaleKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        insert u2;

        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Surveys').getRecordTypeId();
        date dd = date.today() - 10;
        date dd2 = date.today() + 2;        
    
        Survey_Date_Master__c SFUDates = New Survey_Date_Master__c(Survey_Type__c='SFU', 
                            From_Date__c=dd, //date.newInstance(2019, 11, 15),
                            To_Date__c= dd2);//date.newInstance(2019, 12, 5));
        insert SFUDates;
            
        Survey_Call_Log__c sc1 = New Survey_Call_Log__c();
        insert sc1;
        
        Case c1 = New Case(Survey_Call_Log__c=sc1.id, status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='PLSC', Title__c='Mr', Customer_Name__c='Name 1', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c1;
        
        Survey_Call_Log__c sc11 = New Survey_Call_Log__c();
        insert sc11;
        
        Case c11 = New Case(Survey_Call_Log__c=sc11.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='PLSC', Title__c='Mr', Customer_Name__c='Name 1', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c11;
        
        Survey_Call_Log__c sc12 = New Survey_Call_Log__c();
        insert sc12;
        Case c12 = New Case(Survey_Call_Log__c=sc12.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='PLSC', Title__c='Mr', Customer_Name__c='Name 1', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c12;   
        
        Survey_Call_Log__c sc2 = New Survey_Call_Log__c();
        insert sc2;
        Case c2 = New Case(Survey_Call_Log__c=sc2.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='ELSC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c2;
        
            Survey_Call_Log__c sc21 = New Survey_Call_Log__c();
        insert sc21;
            Case c21 = New Case(Survey_Call_Log__c=sc21.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='ELSC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c21;
        
            Survey_Call_Log__c sc22 = New Survey_Call_Log__c();
        insert sc22;
        Case c22 = New Case(Survey_Call_Log__c=sc22.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='ELSC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c22;
        
            Survey_Call_Log__c sc3 = New Survey_Call_Log__c();
        insert sc3;
            Case c3 = New Case(Survey_Call_Log__c=sc3.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                            Location__c='MBC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                            Phone_1__c='12345678');
        insert c3;

        Survey_Call_Log__c sc31 = New Survey_Call_Log__c();
        insert sc31;
        Case c31 = New Case(Survey_Call_Log__c=sc31.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                        Location__c='MBC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                        Phone_1__c='12345678');
        insert c31;
    
    
        Survey_Call_Log__c sc32 = New Survey_Call_Log__c();
        insert sc32;
        Case c32 = New Case(Survey_Call_Log__c=sc32.id,status='New', survey_status__c='Open', Survey_Type__c='SFU', Priority='P4', Origin='Phone',
                        Location__c='MBC', Title__c='Mr', Customer_Name__c='Name 3', RecordTypeId=RecordTypeIdCase,
                        Phone_1__c='12345678');
        insert c32;
    
        integer initialRows = 30;

        list<case> List_cc = new list<case>();
        List_cc = [SELECT Id, Location__c, CaseNumber,  
                            Survey_Status__c, Additional_Remarks__c, 
                            Survey_Call_Log__r.Call_back_Date__c,
                            Survey_Call_Log__r.Call_back_Time__c,
                            Survey_Call_Log__r.X1st_Call_Date__c,
                            Survey_Call_Log__r.X1st_Call_Status__c, 
                            Survey_Call_Log__r.X1st_Call_Time__c,
                            Survey_Call_Log__r.X2nd_Call_Date__c,
                            Survey_Call_Log__r.X2nd_Call_Status__c,
                            Survey_Call_Log__r.X2nd_Call_Time__c,
                            Owner.alias
                            FROM Case 
                            Where CreatedDate >=: dd and CreatedDate <=: dd2 
                            And Status != 'Closed'
                            AND Survey_Type__c = 'SFU' AND Survey_Status__c NOT IN ('Completed', 'Incomplete')
                            ORDER BY Location__c, CaseNumber
                            Limit :initialRows OFFSET 0];
        system.debug('++ ' + List_cc.size());
    
        SFUTableController.SFUWrapper SFUWrapper= new SFUTableController.SFUWrapper();
    
        SFUTableController.SFUSurvey SFUSingle = New SFUTableController.SFUSurvey();
        SFUSingle.CaseId = c32.Id;
        SFUSingle.CaseNo = c32.CaseNumber;
        SFUSingle.Loca = c32.Location__c;
        SFUSingle.SurveyStatus = c32.Survey_Status__c;
        SFUSingle.AddiRemarks = c32.Additional_Remarks__c;
        SFUSingle.CallbackDate = c32.Survey_Call_Log__r.Call_back_Date__c;
        SFUSingle.CallbackTime = c32.Survey_Call_Log__r.Call_back_Time__c;
        SFUSingle.firstCallDate = c32.Survey_Call_Log__r.X1st_Call_Date__c;
        SFUSingle.firstCallTime = c32.Survey_Call_Log__r.X1st_Call_Time__c;
        SFUSingle.firstCallStatus = c32.Survey_Call_Log__r.X1st_Call_Status__c;
        SFUSingle.secondCallDate = c32.Survey_Call_Log__r.X2nd_Call_Date__c;
        SFUSingle.secondCallTime = c32.Survey_Call_Log__r.X2nd_Call_Time__c;
        SFUSingle.secondCallStatus = c32.Survey_Call_Log__r.X2nd_Call_Status__c;
        SFUSingle.agentno = c32.Owner.Alias;
        SFUSingle.Owner = c32.OwnerId;
        //SFUwrapper.FromDate = date.today();
        //SFUwrapper.ToDate = date.today();
        SFUWrapper.sfusList.add(SFUSingle);
        
        SFUTableController.getSFURecords(1, 'All');
        SFUTableController.loadSFURecords(1, 1,'All');   
        
        SFUTableController.getSFUByLoc(1, 'MBC');
        SFUTableController.loadSFURecords(1, 1,'MBC');   
        
        SFUTableController.getSFUByLoc(1, 'ELSC');
        SFUTableController.loadSFURecords(1, 1,'ELSC');
        
        SFUTableController.getSFUByLoc(1, 'PLSC');
        SFUTableController.loadSFURecords(1, 1,'PLSC');
        
        
        List<SFUTableController.SFUSurvey> vselRecs = New List<SFUTableController.SFUSurvey>();
        vselrecs.add(sfusingle);
        SFUTableController.assignAgent(vselRecs, 'Agent1');
        SFUTableController.assignAgent(vselRecs, 'Agent2');
    }
}
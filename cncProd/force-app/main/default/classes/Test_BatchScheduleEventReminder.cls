@isTest
private class Test_BatchScheduleEventReminder{
    Static Date eventDate  = Date.today().addDays(2);                                    
    Static BatchScheduleEventReminder testInvokeScheduled = new BatchScheduleEventReminder();               
    Static String scheduledTime = '0  00 1 3 * ?';                                                         
    Static Account acct = Test_DataFactory.createAccount(true,'testRun');                 
    Static Contact testCon  = Test_DataFactory.createContact(true,'testRun','testRun',acct.Id);      
    Static Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);       
    Static Model__c testMod = Test_DataFactory.createmodelId(true,'testRun','CCA','MITPC');              
    
    static testmethod void  testschedule(){        
        Campaign testCamp1 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCK');
        testCamp1.Description = 'TestDescp for camp1';
        testCamp1.UnitPrice__c = 10;
        insert testCamp1;
        Test.startTest();
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,testCon.Id,testCamp1.id,null,oppt.id,null,testMod.Id); 
        tempInsertER.Event_Reminder_Status__c = true;
        tempInsertER.Event_Status__c = 'Attended';
        tempInsertER.Event_Date__c = eventDate;
        tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Name = 'Test_Er1';
         insert tempInsertER;
        system.schedule('Test', scheduledTime, testInvokeScheduled);                                                          
        Test.stopTest();
    }
    static testmethod void  testschedule1(){        
        Campaign testCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCA');
        testCamp2.Branch_Code__c = null;
        testCamp2.Description = 'TestDescp for camp2';
        testCamp2.UnitPrice__c = 10;
        insert testCamp2;
        oppt.Opportunity_Score__c = 1232134;
        Insert oppt;
        Test.startTest();
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,testCamp2.id,null,oppt.id,testLead.id,testMod.Id); 
        tempInsertER.Event_Reminder_Status__c = true;
        tempInsertER.Event_Status__c = 'Attended';
        tempInsertER.Event_Date__c = eventDate;
        tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Name = 'Test_Er1';
        insert tempInsertER;
        system.schedule('Test', scheduledTime, testInvokeScheduled);                                                          
        Test.stopTest();
    }
    static testmethod void  testschedule2(){   
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getLastName(), 'Customer');
        Campaign testCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');
        testCamp2.Description = 'TestDescp for camp2';
        testCamp2.UnitPrice__c = 10;
        insert testCamp2;
        oppt.Opportunity_Score__c = 1232134;
        Insert oppt;
        testMod.Name = testMod.Name + 'DS';
        update testMod;
        Test.startTest();
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        //Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,testCamp2.id,null,oppt.id,testLead.id,testMod.Id); 
        Event_Registration__c tempInsertER = Test_DataFactory.createPAEventReg(false, acc.id, testCamp2.id, null, oppt.id, testMod.Id);
        
        tempInsertER.Event_Reminder_Status__c = true;
        tempInsertER.Event_Status__c = 'Attended';
        tempInsertER.Event_Date__c = eventDate;
        tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Name = 'Test_Er1';
        insert tempInsertER;
        system.schedule('Test', scheduledTime, testInvokeScheduled);                                                          
        Test.stopTest();
    }
    static testmethod void  testschedule3(){   
        Account acc = Test_DataFactory.createPerson(true, UserInfo.getLastName(), 'Prospect');
        Campaign testCamp2 = Test_DataFactory.createCamp(false,'testRun','Paid Event','CCF');
        testCamp2.Description = 'TestDescp for camp2';
        testCamp2.UnitPrice__c = 10;
        insert testCamp2;
        oppt.Opportunity_Score__c = 1232134;
        Insert oppt;
        testMod.Name = testMod.Name + 'DS';
        update testMod;
        Test.startTest();
        Lead testLead = Test_DataFactory.createLead(true,'testRun','testRun');
        //Event_Registration__c tempInsertER = Test_DataFactory.createEventReg(false,null,testCamp2.id,null,oppt.id,testLead.id,testMod.Id); 
        Event_Registration__c tempInsertER = Test_DataFactory.createPAEventReg(false, acc.id, testCamp2.id, null, oppt.id, testMod.Id);
        
        tempInsertER.Event_Reminder_Status__c = true;
        tempInsertER.Event_Status__c = 'Attended';
        tempInsertER.Event_Date__c = eventDate;
        tempInsertER.NumberOfGuests__c = 3;
        tempInsertER.Name = 'Test_Er1';
        insert tempInsertER;
        system.schedule('Test', scheduledTime, testInvokeScheduled);                                                          
        Test.stopTest();
    }
}
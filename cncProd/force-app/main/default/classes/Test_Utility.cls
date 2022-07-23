@isTest
public class Test_Utility {
    @TestSetup public static void testSetData(){
        user uc = Test_DataFactory.createUser(true, 'test', 'mykcc1');
        Account acc = Test_DataFactory.createAccount(true, 'test');
        Model_Master__c mc =  Test_DataFactory.createModelCode(true, 'testModel');
        Color_Master__c cm =  Test_DataFactory.createColorCode(true, 'testModelColor','KIAvs','CCF','CITCV'); 
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'testTrim');
        Model_Year_Master__c mdy = Test_DataFactory.createModelYearCode(true,mc.id );
        lead ld1 = Test_DataFactory.createLead(true, 'testJcc', 'MyJcc');
        Opportunity op1 = Test_DataFactory.createOpportunity(false, 'test', acc.id);
        op1.Lead__c = ld1.Id;
        op1.OwnerId = uc.Id;
        insert op1;
        Contact c = Test_DataFactory.createContact(false, 'test', 'test',acc.id);
        c.Email = 'test1@jcc.com';
        insert c;
        Lead ld = Test_DataFactory.createLead(false, 'jcc', 'test');
        ld.Email = 'test1@jcc.com';
        insert ld;
        
        Stock_Reservation__c sr1 = Test_DataFactory.StockReservation(false, mc.id, cm.id, tm.id, null);
        sr1.Reservation_Status__c = 'Cancel';
        sr1.Cancellation_Reason__c = 'SYSTEM CANCEL DUE TO NO AGREEMENT';
        sr1.Stock_Source__c = 'KIA Warehouse';
        sr1.Franchise_Code__c = 'KIACV';
        sr1.Opportunity__c = op1.Id;
        sr1.OwnerId = uc.Id;
        insert sr1;
        Datetime yesterday1 = Datetime.now().addDays(-1);
        Test.setCreatedDate(sr1.Id, yesterday1);
        update sr1;
        
        
        Vehicle_Master2__c vehicleMaster2 = Test_DataFactory.createVehicleMaster2(false, mc.id, cm.id, tm.id, mdy.id,'test','test');
        vehicleMaster2.ProductionMonth__c = Date.today().addMonths(-5);
        insert vehicleMaster2;
        Model__c md1  = Test_DataFactory.createmodelId(true,'test','CCK','KIAPC');
        Variant__c createVariant  = Test_DataFactory.createVariant(false,'test',md1.id, 'CCF');
        createVariant.Branch__c = 'CCK';
        createVariant.Franchise__c = 'KIAPC';
        insert createVariant;
        global_var__c gb = Test_DataFactory.createGlobalOrfDefaults(true); 
        
    }
    
    @istest public static void testbatch(){
        Stock_Reservation__c sr1 =  [Select id,Createddate,Franchise_Code__c, Reservation_Status__c,OwnerId, Cancellation_Reason__c, Stock_Source__c, Opportunity__r.Owner.Username2__c,Opportunity__c from Stock_Reservation__c ];
        Vehicle_Master2__c vehicleMaster2 =  [Select id,Model_Code__c,Model_Year_Code__c, System_Commcase__c,Original_Commcase__c, Trim_Code__c,Model_Code__r.Branch_Code__c,Model_Code__r.Franchise_Code__c,Model_Code__r.Name from Vehicle_Master2__c ];
        Variant__c vc =  [Select id,Model_ID__c,DWH_Variant_ID__c,Branch__c,Franchise__c from Variant__c ];
        
        test.startTest();
        utility.createToDoTask(sr1, 'Confirmation');
        utility.createToDoTask(sr1, 'refund');
        utility.httpSuccessResponse tempSucess =  new utility.httpSuccessResponse('test','testMessage');
        utility.httpErrorResponse tempError =  new utility.httpErrorResponse('test','testMessage');
        utility.checkForOpenInvoice('test@jcc.com');
        utility.getSequenceNo('CCK');
        utility.getSequenceNo('CCA');
        utility.getSequenceNo('CCF');
        utility.getBatchConfiguration();
        utility.getFields('Stock_Reservation__c');
        utility.checkForContact('test@jcc.com');
        utility.checkForLead('test@jcc.com');
        utility.getVariantFromStockVehicleMaster(vehicleMaster2);
        
        Account acct = Test_DataFactory.createAccount(true,'testRun');    
        Contact TestCon =  Test_DataFactory.createContact(true,'testRun','testRun',acct.Id);        
      //  Opportunity opp = Test_DataFactory.createOpportunity(false,'testRun',acct.Id);
       // opp.Contact_Person__c = TestCon.Id;
      //  opp.Branch_Code__c = 'CCK';
      //  insert opp;      
date myDate = date.today();
Date newDate = mydate.addDays(2);

  Opportunity newOpp = new Opportunity();            
           newOpp.RecordTypeId = Utility.getBatchConfiguration().get('CCK').Opp_RT__c;
           newopp = new Opportunity(Contact_Person__c = TestCon.id, Branch_Code__c='CCK',StageName='Open',LeadSource='PriceAlert',CloseDate=newDate);
           newopp.Name = TestCon.Name +' - '+Utility.getBatchConfiguration().get('CCK').Branch_Name__c;
           newOpp.Franchise_Code__c = 'KIAPC';

insert newOpp;
        utility.createTask(newOpp.Id, newOpp.OwnerId, 'System.Label.OppAssignment');        
        utility.webTDManagerAccess('Test');
        
        
        //utility.checkForExistingOpportunity(utility.checkForContact('test1@jcc.com'), utility.checkForLead('test1@jcc.com'), new List<Variant__c>{vc});
        
        utility.checkForExistingOpportunity('test1@jcc.com', new List<Variant__c>{vc});
        utility.checkOppExistsForThisConsultant('testId','check@test.com');
        utility.checkOpenOppExistsForTheContact('CCK','TestId');       
        utility.checkOppExistsForTheContact('CCK','TestId');
        utility.checkBookedOppExistsForTheLead('CCK','TestId');
        utility.checkOppExistsForTheLead('CCK','TestId');
        utility.getModelForTestDrive(vc);
        
         
        test.stopTest();
        
    }
    
}
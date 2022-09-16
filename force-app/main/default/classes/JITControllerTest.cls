@isTest
private class JITControllerTest 
{
    @TestSetup
    static void setUpData()
    {
        Account personAcc = Test_DataFactory.createPerson(false, 'Test', 'Prospect');
        personAcc.PersonEmail = 'patest@mail.com';
        insert personAcc;
        personAcc = [SELECT Id, PersonContactId FROM Account WHERE ID =: personAcc.Id];
        Opportunity oppt = Test_DataFactory.createOpportunity(false,'testRun', personAcc.Id);
        oppt.Branch_Code__c = 'CCA';
        oppt.Opportunity_Score__c = 40;
        oppt.Account__c = personAcc.Id;
        //oppt.Person_Account__c = personAcc.Id;
        oppt.Contact_Person__c = personAcc.PersonContactId;
        insert oppt;

        /** == MASTER TEST DATA - BEGIN == */

        // Model Master
        Model_Master__c modelCode = Test_DataFactory.createModelCode(false, 'Test Model Code');
        modelCode.Engine_Capacity__c = 1600;    // To test COE Category
        modelCode.BHP__c = 130;                 // To test COE Category
        modelCode.Franchise_Code__c = 'KIAPC';
        insert modelCode;
        // Model Year Master
        //Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(true, modelCode.Id);     
        Model_Year_Master__c modelYearCode = new Model_Year_Master__c(ModelYear__c = Date.today().addYears(-1), Model_Master__c = modelCode.Id, VSMS_Compound_Primary_Key__c='1');
        insert modelYearCode;
        // Color Master
        Color_Master__c colorCode = Test_DataFactory.createColorCode(true, 'Test Color Code', 'Test', 'CCK', 'KIAPC');
        // Trim Master
        Trim_Master__c trimCode = Test_DataFactory.createTrimCode(true, 'Test Trim Code');
        Date productionMonth = Date.newInstance(2019, 08, 01);  
        // Stock Vehicle Master
        Vehicle_Master2__c vMaster = new Vehicle_Master2__c(Original_Commcase__c = 'KIAPC0120190086', 
                                                            Model_Year_Code__c = modelYearCode.ID,
                                                            System_Commcase__c = 'KIAPC0120190086', 
                                                            Engine_No__c = 'ENGINE279831',
                                                            Chassis__c = 'CHAS279831', 
                                                            Model_Code__c = modelCode.ID, 
                                                            ProductionMonth__c = productionMonth,
                                                            Color_Code__c = colorCode.ID, 
                                                            Trim_Code__c = trimCode.ID);
        insert vMaster;
        // Package Header
		Package_Header__c pckHeader = new Package_Header__c(PKH_FRN_FRNCD__c = 'KIAPC',
                                                            Model_Master__c = modelCode.Id,
                                                            PKH_STATUS__c = 'A');
        insert pckHeader;
        // Stock Reservation
        Stock_Reservation__c sr = Test_DataFactory.StockReservation(false, modelCode.ID, colorCode.ID, trimCode.ID, modelYearCode.ID);
        sr.Package_Header_From_PickList__c = pckHeader.Id;
        sr.Vehicle_Master__c = vMaster.ID;
        sr.Opportunity__c    = oppt.Id;
        sr.Customer_Mobile_Number__c = '6587546859';
        sr.Vehicle_Master__c = vMaster.Id;
        insert sr;

        /** == MASTER TEST DATA - END ==*/

        // Accessories Master
        List<Accessories_Master__c> accMasters = new List<Accessories_Master__c>();
        Accessories_Master__c accMaster = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                    ACM_ACCSDESC__c = 'ACC',
                                                                    ACM_ACCSCD__c = 'TESTACCMASTER',
                                                                    Rate__c = 5000,
                                                                    ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster);
        
        Accessories_Master__c accMaster2 = new Accessories_Master__c(ACM_FRN_FRNCD__c = 'KIAPC',
                                                                     ACM_ACCSDESC__c = 'Service Credit',
                                                                     ACM_ACCSCD__c = 'SVC1000',
                                                                     Rate__c = 1000,
                                                                     ACM_ACCSTYPE__c = 'C');
        accMasters.add(accMaster2);
 
        insert accMasters;
        
        // Create Accs Rate Master
        Accs_Rate_Master__c accRateMaster = new Accs_Rate_Master__c(Accessories__c = accMasters[0].Id,
                                                                    ARM_ACM_FRNCD__c = 'KIAPC');
        insert accRateMaster;

        // Create Package Accessories
        List<Package_Accs__c> pckAccList = new List<Package_Accs__c>();
        Package_Accs__c pckAcc = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                     Accessories_Master__c = accMasters[0].Id,
                                                     PKA_PKH_FRNCD__c = 'KIAPC',
                                                     PKA_VALUE__c = null);
        pckAccList.add(pckAcc);

        Package_Accs__c pckAcc2 = new Package_Accs__c(Package_Header__c = pckHeader.Id,
                                                      Accessories_Master__c = accMasters[1].Id,
                                                      PKA_PKH_FRNCD__c = 'KIAPC');
        pckAccList.add(pckAcc2);
		insert pckAccList;

		// Additional Charges Master
		Additional_Charges_Master__c addnlChargeMaster = new Additional_Charges_Master__c(ADM_CHRGDESC__c = 'Addnl Charge Test',
                                                                                          ADM_CHRGCD__c = 'R004',
                                                                                          VSMS_Compound_Primary_Key__c = '1');
        insert addnlChargeMaster;

        // Package Addtional Charges
        List<Package_Additional_Charges__c> pckAddnlChargeList = new List<Package_Additional_Charges__c>();
        Package_Additional_Charges__c pckAddnlCharge1 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R004',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge1);
        Package_Additional_Charges__c pckAddnlCharge2 = new Package_Additional_Charges__c(PKC_PKH_FRNCD__c = 'KIAPC',
                                                                                          Additional_Charges_Master__c = addnlChargeMaster.Id,
                                                                                          Package_Header__c = pckHeader.Id,
                                                                                          PKC_ADM_CHRGCD__c ='R002',
                                                                                          PKC_INCPRICE__c = 'INC',
                                                                                          PKC_CHARGES__c = 100);
        pckAddnlChargeList.add(pckAddnlCharge2);
        insert pckAddnlChargeList;

        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        Sales_Agreement__c sAgree = Test_DataFactory.createSalesAgreement(true, 'CCK', 'NO9999', sr.Id, 'Test'); 
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        // sAgree.JIT_Date__c = Date.ValueOf('20-08-2022');
        // update sAgree;
        JIT_Day__c jitDay = Test_DataFactory.createJITDay(true, 'JIT_Test', 'KIAPC');
        JIT_Day__c jitDay2 = Test_DataFactory.createJITDay_NoMoreSlot(true, 'JIT_Test_No_Slot', 'MITPC');
        vMaster.JIT_Day__c = jitDay.Id;
    }

    @isTest
    static void Test_createJITDayWithoutSlot()
    {
        JIT_Day__c sa = [SELECT Id FROM JIT_Day__c WHERE Name =: 'JIT_Test_No_Slot'];
    }

    
    @isTest
    static void Test_getRecords_onDSA()
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        Sales_Agreement__c sa = [SELECT Id FROM Sales_Agreement__c WHERE Stock_Reservation__c =: stockReservation.Id];
        JITController.getRecords('Sales_Agreement__c', 'Id', sa.Id, 'LIMIT 1');       
    }

    @isTest
    static void Test_getRecords_onSVM()
    {
        Stock_Reservation__c stockReservation = [SELECT Id FROM Stock_Reservation__c];
        JITController.getRecords('Stock_Reservation__c', 'Id', stockReservation.Id, 'LIMIT 1');       
    }

    @isTest
    static void Test_sendEmailToNCLUsers()
    {
        Id newCarLogisticsProId = [SELECT Id FROM Profile WHERE Name = 'New Car Logistic'].Id;
        User usersToSendEmail = Test_DataFactory.createUserWithProfileID(true, 'Nhung', 'Cao', 'nhung.cao@aodigy.com', newCarLogisticsProId);
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'New Car Logistic'];
        JITController.sendEmailToNCLUsers(sa.SOH_SONO__c, svm.Agreement_No__c, sa.Sales_Consultant__c, svm.Chassis__c, svm.Name);
    }

    @isTest
    static void Test_lookUpJITDayRecord_onDSA()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];
        JITController.lookUpJITDayRecord('Sales_Agreement__c',sa.Id, jitDay.Id);
    }

    @isTest
    static void Test_lookUpJITDayRecord_onSVM()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];
        JITController.lookUpJITDayRecord('Vehicle_Master2__c',svm.Id, jitDay.Id);
    }

    @isTest
    static void Test_cancelSlot_onDSA_Pending()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c,JIT_Day__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Day__c = jitDay.Id;
        sa.JIT_Status__c =  'Pending';
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        JITController.cancelSlot('Sales_Agreement__c',sa.Id);
        System.debug('sa jit day ='  +  sa.JIT_Day__c);
        System.debug('successfull cancel slot');
    }

    @isTest
    static void Test_cancelSlot_onDSA_NotPending()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c, JIT_Day__c  FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Day__c = jitDay.Id;
        sa.JIT_Status__c = 'Started';
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        try 
        {
            JITController.cancelSlot('Sales_Agreement__c',sa.Id);
        } catch (AuraHandledException e) 
        {
            System.debug('message: ' + e.getMessage());
            System.assert(e.getMessage().contains('JIT SLot can not be cancelled. Please check JIT Status!'));
        }
        
        
    }

    @isTest
    static void Test_cancelSlot_onDSA_Pending_No_Utilised_Slots()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c, JIT_Day__c  FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test_No_Slot'];   
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Day__c = jitDay.Id;
        sa.JIT_Status__c = 'Pending';
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        try 
        {
            JITController.cancelSlot('Sales_Agreement__c',sa.Id);
        } catch (AuraHandledException e) 
        {
            System.debug('message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Oops! Something wrong with Utilised Slot. Please check again!'));
        }
        
    }

    @isTest
    static void Test_cancelSlot_onSVM_Pending()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c,JIT_Day__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c,JIT_Day__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        svm.JIT_Day__c = jitDay.Id;
        update svm;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Status__c = 'Pending';
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
        JITController.cancelSlot('Vehicle_Master2__c',svm.Id);
    }

    @isTest
    static void Test_cancelSlot_onSVM_Not_Pending()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c,JIT_Day__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c, JIT_Day__c  FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        JIT_Day__c jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        svm.JIT_Day__c = jitDay.Id;
        update svm;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Status__c = 'Started';
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);

        JITController.cancelSlot('Vehicle_Master2__c',svm.Id);
    }


    @isTest
    static void Test_constructWrapper_onDSA_withoutJITDate()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        
        try 
        {
            JITController.constructWrapper('Sales_Agreement__c', sa.Id);
        } catch (AuraHandledException e) 
        {
            System.debug('message: ' + e.getMessage());
            System.assert(e.getMessage().contains('JIT Date is currently empty. Please check again!'));
        }
    }

    @isTest
    static void Test_constructWrapper_onDSA_withJITDate()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c, JIT_Date__c,JIT_Day__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        List<JIT_Day__c> jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Day__c = jitDay[0].Id;
        sa.JIT_Date__c = Date.today();
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);

        JITController.constructWrapper('Sales_Agreement__c', sa.Id);   
    }

    @isTest
    static void Test_constructWrapper_onSVM()
    {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c,JIT_Day__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c, JIT_Date__c  FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        List<JIT_Day__c> jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        svm.JIT_Day__c = jitDay[0].Id;
        update svm;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', true);
        sa.JIT_Date__c = Date.today();        
        update sa;
        TriggerExclusion.excludeTrigger('Sales_Agreement__c', false);
       

        try 
        {
            JITController.constructWrapper('Vehicle_Master2__c', svm.Id); 
        } catch (AuraHandledException e) 
        {
            System.debug('message: ' + e.getMessage());
            System.assert(e.getMessage().contains('JIT Date is currently empty. Please check again!'));
        }
    }

    @isTest
    static void test_WrapperClass() {
        Vehicle_Master2__c svm = [SELECT Id, Chassis__c, Name, Agreement_No__c FROM Vehicle_Master2__c];        
        Stock_Reservation__c sr = [SELECT Id, Vehicle_Master__c FROM Stock_Reservation__c WHERE Vehicle_Master__c =: svm.Id];
        Sales_Agreement__c sa = [SELECT Id, SOH_SONO__c, Sales_Consultant__c, Stock_Reservation__c, JIT_Status__c FROM Sales_Agreement__c WHERE Stock_Reservation__c =: sr.Id];
        List<JIT_Day__c> jitDay = [SELECT Id, Utilised_Slots__c FROM JIT_Day__c WHERE Name = 'JIT_Test'];   
        sa.JIT_Day__c = jitDay[0].Id;

        JITController.JITWrapper wrapper = new JITController.JITWrapper();
        wrapper.curRecInfo = sa;
        wrapper.jitDaysList = jitDay;
        wrapper.isSalesAdmin = true;
        wrapper.isSalesConsultant = false;
        // wrapper.bookedJIT = jitDay[0];

    }

}
/** *****
 * Description : Test Class for CreateSalesPromoInvoiceAPI class
 * 
 * Change History
 * Date(YYYYMMDD)       Name                      Description
 * 20220414             thanh.ly@aodigy           Created Initial Version. 
 * 
** *****/
@isTest
private class CreateSalesPromoInvoiceAPITest {
    @TestSetup
    private static void testRecord(){
        EmailTemplate e = [SELECT Id FROM EmailTemplate WHERE Name = 'JCC Account Activation'];
        global_var__c globalVar = new global_var__c();
        globalVar.Account_Activation_EmailId__c = e.Id;
        globalVar.APIGateway_url__c = 'https://api.stg.cyclecarriage.com/CmsAPI/GetPromos';
        globalVar.APIGateway_key__c = '1b58ae26-48d4-4efc-944d-f089258f81sf2';
        insert globalVar;

        Campaign cam = Test_DataFactory.createCamp(false, 'Test', 'Promotions', 'CCK');
        cam.EndDate = Date.today() + 10;
        cam.Brand__c = 'KIAPC';
        insert cam;

        Account acc = Test_DataFactory.createAccount(true, 'Test');
        Contact con = Test_DataFactory.createContact(true, 'Test', '123', acc.Id);

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
        Model_Year_Master__c modelYearCode = Test_DataFactory.createModelYearCode(false, modelCode.Id);
        modelYearCode.VSMS_Compound_Primary_Key__c = '1';
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

        Sales_Agreement__c sAgree1 = Test_DataFactory.createSalesAgreement(false, 'CCK', 'NO9999', sr.Id, 'Test1'); 
        sAgree1.Package_Header__c = pckHeader.Id;
        insert sAgree1;

        // CampaignMember camMem = Test_DataFactory.createCampaignMember(false, cam.Id, con.Id);
        // camMem.Purchase_Date__c = Date.today();
        // camMem.Purchased__c = true;
        // camMem.Sales_Agreement__c = sAgree1.Id;
        // insert camMem;

        Campaign_Member_Vehicle__c camMemVehicle = new Campaign_Member_Vehicle__c();
        camMemVehicle.Name = 'Test';
        camMemVehicle.Campaign__c = cam.Id;
        camMemVehicle.Contact__c = con.Id;
        camMemVehicle.Account__c = acc.Id;
        camMemVehicle.Sales_Agreement__c = sAgree1.Id;
        insert camMemVehicle;

        Promo_Line_Item__c item1 = new Promo_Line_Item__c();
        item1.Item_Display_Name__c = 'USB Device';
        item1.Usual_Price__c = 51.05;
        item1.Promo_Price__c = 45; 
        item1.No_of_Stock__c = 1;
        item1.Cost_Price__c = 20;
        item1.Commission_Value__c = 2;
        insert item1;

        Promo_Line_Item__c item2 = new Promo_Line_Item__c();
        item1.Item_Display_Name__c = 'Firefly Bluetooth Receiver';
        item1.Usual_Price__c = 51.05;
        item1.Promo_Price__c = 45; 
        item1.No_of_Stock__c = 1;
        item2.Cost_Price__c = 21;
        item2.Commission_Value__c = 3;
        insert item2;
    }

    @isTest
    private static void testCreatePromoInvoice_MissingRequired(){
        List<Promo_Line_Item__c> Items = new List<Promo_Line_Item__c>();
        Items = [SELECT Item_Display_Name__c, Usual_Price__c, Promo_Price__c, No_of_Stock__c, Cost_Price__c, Commission_Value__c
                 FROM Promo_Line_Item__c]; 

        CreateSalesPromoInvoiceAPI.Item item = new CreateSalesPromoInvoiceAPI.Item();
        item.ItemID = null;
        item.ActualPrice = Items[0].Usual_Price__c;
        item.DiscountPrice = Items[0].Promo_Price__c;
        item.Quantity = (Integer)Items[0].No_of_Stock__c;            

        CreateSalesPromoInvoiceAPI.RequestBody reqBodyClass = new CreateSalesPromoInvoiceAPI.RequestBody();
        reqBodyClass.NetAmount = 100;
        reqBodyClass.Discount = 10;
        reqBodyClass.Department = null;
        reqBodyClass.CampaignId = null;
        reqBodyClass.ContactId = null;
        reqBodyClass.Items = new List<CreateSalesPromoInvoiceAPI.Item>();
        reqBodyClass.Items.add(item);

        String reqBody = JSON.serialize(reqBodyClass);
        Test.startTest();
        String reqURI = '/upsertSalesPromoInvoice/*';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        CreateSalesPromoInvoiceAPI.doPost();
        Test.stopTest();
    }

    @isTest
    private static void testCreatePromoInvoice(){
        Promo_Line_Item__c Items = new Promo_Line_Item__c();
        Items = [SELECT Id, Item_Display_Name__c, Usual_Price__c, Promo_Price__c, No_of_Stock__c, Cost_Price__c, Commission_Value__c
                 FROM Promo_Line_Item__c
                 LIMIT 1]; 

        Campaign cam = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Sales_Agreement__c sAgree = [SELECT Id From Sales_Agreement__c LIMIT 1];
       
        CreateSalesPromoInvoiceAPI.Item item = new CreateSalesPromoInvoiceAPI.Item();
        item.ItemID = Items.Id;
        item.ActualPrice = Items.Usual_Price__c;
        item.DiscountPrice = Items.Promo_Price__c;
        item.Quantity = (Integer)Items.No_of_Stock__c;     

        CreateSalesPromoInvoiceAPI.RequestBody reqBodyClass = new CreateSalesPromoInvoiceAPI.RequestBody();
        reqBodyClass.NetAmount = 100;
        reqBodyClass.Discount = 10;
        reqBodyClass.Department = 'CCK';
        reqBodyClass.CampaignId = cam.Id;
        reqBodyClass.ContactId = con.Id;
        reqBodyClass.SalesAgreementId = sAgree.Id;
        reqBodyClass.Items = new List<CreateSalesPromoInvoiceAPI.Item>();
        reqBodyClass.Items.add(item);

        String reqBody = JSON.serialize(reqBodyClass);
        String resBody = '{' +
        ' "InvoiceNumber": "123",' +
        ' "CreatedDate": "' + Date.today() + '"' +
        '}';
        
        Test.startTest();
        String reqURI = '/upsertSalesPromoInvoice/*';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, resBody, 200);
        CreateSalesPromoInvoiceAPI.doPost();
        Test.stopTest();
    }
}
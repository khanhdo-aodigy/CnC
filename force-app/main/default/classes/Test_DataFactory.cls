/**
 * @File Name          : Test_DataFactory.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/21/2020, 9:50:27 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/21/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public with sharing class Test_DataFactory {
    
    
    /** This method is test data for create Account **/ 
    
    public static Account createAccount(Boolean doInsert,String accName)
    {
        Account acc = new Account();
        acc.Name = accName+' '+String.valueOf(Math.random()).substring(2, 6) ;
        //acc.Type='Business Account';
        acc.Phone='9988998899';
        if(doInsert){
            insert acc;
        }
        return acc;
    }
    
    /** This method is test data for create Contact **/ 
    public static Contact createContact(Boolean doInsert,String fname,String lname, String accountid)
    {
        Contact con = new Contact();
        con.LastName            = lname;
        con.FirstName           = fname; 
        //con.accountid           = accountid;
        con.NRIC_Passport_No__c = fname;
        con.Gender__c           = 'Female';
        con.MobilePhone         = '65'+Math.round((Math.random() * (90000000) + 10000000));
        con.Email               = (lname+fname+'test@zoho.com').deleteWhitespace().trim();
        con.Birthdate           = Date.today();

        if(doInsert){
            insert con;
        }
        return con;
    }
    
    /** This method is test data for create User with profile **/ 
    public static User createUser(Boolean doInsert,String LastName, String userAlias)
    {
        Profile userProfile = [select id from profile where name like '%System Administrator%' limit 1];
        
        User u = new user();
        u.LastName = LastName;
        u.Email = 'test@jcc.com';
        u.Username = 'test_datafactory' +String.valueOf(Math.random()).substring(2, 6)  + '@jcc.com';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.Alias = userAlias;
        
        if(userProfile!=null) {
            u.ProfileID = userProfile.id; 
        }
        
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        if(doInsert){
            insert u;
        }
        return u;
    }
    
    /** This method is test data for create User with profile **/ 
    public static User createUserWithProfileID(Boolean doInsert,String firstName,String lastName,String email,String profileId){
        User user = new User();
        user.FirstName = firstName;
        user.LastName = lastName;
        user.Email = 'test@jcc.com';
        user.profileId = profileId;
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Los_Angeles';
        String randomString =String.valueOf(Math.random()).substring(2, 6);
        user.UserName = lastName+randomString+'@testorg.com';
        //user.UserName='testuser@testorg.com';
        user.EmailEncodingKey='UTF-8';
        user.phone = '+911234532212';
        user.companyName = 'JCC';
        user.department = 'KIA';
        user.Alias = firstName+'lt';
        user.title = 'Dev';
        user.signature = 'Test';
        
        if(doInsert)
            insert user;
        
        return user;
    }

    /** This method is test data for create postal code **/ 
    public static Postal_Code__c createPostalCode( Boolean doInsert, String postalCode ){
        Postal_Code__c pcode = new Postal_Code__c();
        pcode.Name              = postalCode;
        pcode.Address_Line_1__c = 'Address1';
        pcode.Address_Line_2__c = 'Address2';
        pcode.Address_Line_3__c = 'Address3';
        pcode.Country__c        = 'SG';

        if(doInsert){
            insert pcode;
        }
        return pcode;
    }

    /** This method is test data for create opp **/ 
    public static Opportunity createOpportunity(Boolean doInsert,String oppName, Id accId)
    {
        Opportunity oppt = new Opportunity();
        oppt.Name ='New test Opportunity - '+oppName;
        oppt.AccountId = accId;
        oppt.Account__c = accId;
        oppt.StageName = 'Open';
        oppt.Amount = 3000;
        oppt.CloseDate = Date.today().addDays(5);
        if(doInsert)
        {
            insert oppt;
        }
        return oppt;
    }   
    
    /** This method is test data for create Lead **/ 
    public static Lead createLead(Boolean doInsert,String company,String lName){
        Lead leadObj = new Lead();
        leadObj.Company  = company;
        leadObj.LastName = lName;
        leadObj.Email    = lName+'test@123.com';
        leadObj.NRIC__c  = lName;
        leadObj.Birthdate__c = Date.today();
        
        if(doInsert)
            insert leadObj;
        
        return leadObj;
    }
    
    /** This method is test data for create Campaign **/ 
    public static Campaign createCamp(Boolean doInsert,String name,String type,String branch){
        Campaign CampaignObj = new Campaign();
        CampaignObj.Name           = name;
        CampaignObj.Type           = type;
        CampaignObj.Branch_Code__c = branch;
        
        if(branch == 'CCI' && type == 'Promotions') {
            CampaignObj.Promotion_Type__c = 'One Time Purchase';
        }        
        
        if(doInsert)
            insert CampaignObj;
        
        return CampaignObj;
    }
    
    public static Promo_Code_Master__c createPromoCode(Boolean doInsert, String campId, String name, String type, Double amount, Date expiryDate) {
        Promo_Code_Master__c promoCode = new Promo_Code_Master__c();
        promoCode.Campaign__c = campId;
        promoCode.Promo_Code__c = name;
        promoCode.Promo_Discount_Type__c = type;
        promoCode.Amount__c = amount;
        promoCode.Expiry_Date__c = expiryDate;
        
        if(doInsert) {
            insert promoCode;
        }

        return promoCode;
    }
    /** This method is test data for create Invoice Sequence Number**/ 
    public static InvoiceSeqNum__c createInvoiceSeqNum(Boolean doInsert, Id campaignId) {
        InvoiceSeqNum__c invSeqNum = new InvoiceSeqNum__c(
        	Campaign__c = campaignId
        );
        
        if(doInsert) 
            insert invSeqNum;
        
        return invSeqNum;
	}
    
    /** This method is test data for create Lead History**/ 
    public static LeadHistory createLeadHistory(Boolean doInsert,String fieldenabled,Lead ld){
        LeadHistory leadObj = new LeadHistory();
        leadObj.field = fieldenabled;
        leadObj.leadId = ld.Id;
        
        if(doInsert)
            insert leadObj;
        
        return leadObj;
    }
    
    /** This method is test data for create Model_Master__c **/ 
    public static  Model_Master__c createModelCode (Boolean doInsert,String ModelCodeName){
        Model_Master__c modelCode = new Model_Master__c();
        modelCode.name = ModelCodeName;
        
        if(doInsert)
            insert modelCode;
        
        return modelCode;
    }
    
    private static Integer MODEL_YEAR_COUNTER = -1;
    /** This method is test data for create Model_Year_Master__c **/ 
    public static  Model_Year_Master__c createModelYearCode (Boolean doInsert, String ModelmasteId){
        Model_Year_Master__c modelYearCode = new Model_Year_Master__c();
        modelYearCode.ModelYear__c = Date.today().addYears(MODEL_YEAR_COUNTER--);
        modelYearCode.Model_Master__c = ModelmasteId;
        // modelYearCode.VSMS_Compound_Primary_Key__c = 'VSMS_' + String.valueOf(VSMS_COMPOUND_KEY_COUNTER++);
        modelYearCode.VSMS_Compound_Primary_Key__c = 'VSMS_' + randomString(10);
        
        if(doInsert)
            insert modelYearCode;
        
        return modelYearCode;
    } 

    /** This method is test data for create Vehicle_Purchase_Ordered__c**/
    public static Vehicle_Purchase_Order__c createVehiclePurchaseOrder(Boolean doInSert, String SupplierId ){
        Vehicle_Purchase_Order__c VehiclePurchaseOrder = new Vehicle_Purchase_Order__c();
        VehiclePurchaseOrder.Franchise_Code__c ='KIAPC';
        VehiclePurchaseOrder.Currency_Code__c = 'USD';
        VehiclePurchaseOrder.Production_Month__c = Date.today();
        VehiclePurchaseOrder.Supplier_Account__c = SupplierId;
        if (doInSert) 
            insert VehiclePurchaseOrder;
            return VehiclePurchaseOrder;
    }


    /**Create Method is test data for create Model_Color_Trim_Master__c**/
    public static Model_Color_Trim_Master__c createModelColorTrimMaster(Boolean doInsert, String ColorCodeId, String ModelCodeId, String TrimCodeId){
        Model_Color_Trim_Master__c modelColorTrimMaster = new Model_Color_Trim_Master__c();
        modelColorTrimMaster.Name = 'Model Color Trim Master';
        modelColorTrimMaster.Branch_Code__c= 'KIA';
        modelColorTrimMaster.Franchise_Code__c = 'KIAPC';
        modelColorTrimMaster.Color_Code__c = ColorCodeId;
        modelColorTrimMaster.Model_Code__c = ModelCodeId;
        modelColorTrimMaster.Trim_Code__c = TrimCodeId;
        if (doInsert) 
            insert modelColorTrimMaster;
            return modelColorTrimMaster;
    }

    /**Create Method is test data for create Vehicle_Purchase_Ordered_Line_Items__c **/
    public static Vehicle_Purchase_Order_Line_Items__c createVehiclePurchaseOrderedLineItems(Boolean doInsert, String VehiclePurchaseOrderId, String modelMasterId, String colorMasterId, String trimMasterId, String modelColorTrimMasterId, String ModelYearMasterId){
        Vehicle_Purchase_Order_Line_Items__c VehiclePurchaseOrderedLineItems = new Vehicle_Purchase_Order_Line_Items__c();
        VehiclePurchaseOrderedLineItems.Vehicle_Purchase_Order__c = VehiclePurchaseOrderId;
        VehiclePurchaseOrderedLineItems.Model_Master__c = modelMasterId;
        VehiclePurchaseOrderedLineItems.Color_Master__c = colorMasterId;
        VehiclePurchaseOrderedLineItems.Trim_Master__c = trimMasterId;
        VehiclePurchaseOrderedLineItems.Model_Color_Trim_Master__c = modelColorTrimMasterId;
        VehiclePurchaseOrderedLineItems.Model_Year_Master__c = ModelYearMasterId;
        VehiclePurchaseOrderedLineItems.Units_Ordered__c = 5;

        if (doInsert) 
            insert VehiclePurchaseOrderedLineItems;
            return VehiclePurchaseOrderedLineItems;
    }
    
    /** This method is test data for create Color_Master__c **/ 
    public static Color_Master__c createColorCode (Boolean doInsert,String colorCodeName, String colorCodeValue, String branchCode, String franchiseCode){
        Color_Master__c colorCode = new Color_Master__c();

        colorCode.name = colorCodeName;
        colorCode.ColorCode__c = colorCodeValue;
        colorCode.Branch_Code__c = branchCode;
        colorCode.Franchise_Code__c = franchiseCode;
        
        if(doInsert)
            insert colorCode;
        
        return colorCode;
    }
    
    /** This method is test data for create Trim_Master__c **/ 
    public static Trim_Master__c createTrimCode (Boolean doInsert,String trimCodeName){
        Trim_Master__c trimCode = new Trim_Master__c();
        trimCode.name = trimCodeName;
        
        if(doInsert)
            insert trimCode;
        
        return trimCode;
    }
    
    /** This method is test data for create Stock_Reservation__c **/ 
    public static Stock_Reservation__c StockReservation (Boolean doInsert,String modelCode, String colorCode, String trimCode, String modelYearCode){
        Stock_Reservation__c stockRes = new Stock_Reservation__c();
        stockRes.Model_Code__c = modelCode;
        stockRes.Color_Code__c = colorCode;
        stockRes.Trim_Code__c = trimCode;
        stockRes.Franchise_Code__c = 'KIAPC';
        stockRes.Model_Year_Code__c = modelYearCode;
        stockRes.Customer_Social_ID__c = 'S1234567K';

        if(doInsert)
            upsert stockRes;
        
        return stockRes;
    }
    
    /** This method is test data for create Vehicle_Master2__c **/ 
    public static Vehicle_Master2__c createVehicleMaster2 (Boolean doInsert,String modelCode, String colorCode, String trimCode, String modelYearCode, String originalCommacase, String systemCommcase){
        Vehicle_Master2__c vehiclemaster = new Vehicle_Master2__c();
        vehiclemaster.Original_Commcase__c = originalCommacase;
        vehiclemaster.System_Commcase__c = systemCommcase;
        vehiclemaster.Model_Code__c = modelCode;
        vehiclemaster.Color_Code__c = colorCode;
        vehiclemaster.Trim_Code__c = trimCode;
        vehiclemaster.Model_Year_Code__c = modelYearCode;
        
        if(doInsert)
            insert vehiclemaster;
        
        return vehiclemaster;
    }

    /** This methoc is test data for create TMS_Insurance__c  **/
    public static TMS_Insurance__c createTMSInsurance (Boolean doInsert){
        TMS_Insurance__c tms = new TMS_Insurance__c();
        tms.Franchise_Code__c = 'KIAPC';
        tms.Insurance_Percentage__c = 0;

        if(doInSert)
             upsert tms;

        return tms;     
    }

    /** This method is test data for create Vehicle_Shipment__c */
    public static Vehicle_Shipment__c createVehicleShipment(Boolean doInsert, String Supplier){
        Vehicle_Shipment__c vehicleShipment= new Vehicle_Shipment__c();
        vehicleShipment.Supplier_Account__c = Supplier;
        vehicleShipment.Franchise_Code__c = 'KIAPC';
        vehicleShipment.Currency_Code__c = 'USD';
        vehicleShipment.Brand__c='CIT';

        if (doInsert) {
            upsert vehicleShipment;
        }
        return vehicleShipment;
    }

    /**This method is test data for create Shipment_Line_Item */
    public static Shipment_Line_Item__c createShipmentLineItem(Boolean doInsert, String vehicleShipment, String invoiceId){
        Shipment_Line_Item__c shipmentLineItem = new Shipment_Line_Item__c();
        shipmentLineItem.Vehicle_Shipment__c = vehicleShipment;
        shipmentLineItem.Chassis_No__c  = '3423545647653';
        shipmentLineItem.Engine_No__c = '1232435456546 ';
        shipmentLineItem.Colour_Code__c ='rwerwet';
        shipmentLineItem.Production_Month__c = '08/2022';
        shipmentLineItem.Shipment_Line_Item_Sequence_No__c = '1232';
        shipmentLineItem.Invoice_No__c = invoiceId;
        if (doInsert) {
            upsert shipmentLineItem;
        }
        return shipmentLineItem;
    }

    /** This method is test data for create Manufacturer_Invoice */
    public static Manufacturer_Invoice__c createManufacturerInvoice(Boolean doInsert){
        Manufacturer_Invoice__c  manufacturerInvoice = new Manufacturer_Invoice__c();
        manufacturerInvoice.Name                     = 'INV-082022-000000007';
        manufacturerInvoice.Invoice_Date__c          = Date.today();
        // manufacturerInvoice.Shipment_Line_Items__c   = shipmentLineItem;
        if (doInsert) {
            upsert manufacturerInvoice;
        }
        return manufacturerInvoice;
    }
    /** This method is test data for create Model__c **/     
    public static Model__c createmodelId(Boolean doInsert,String modelName, String branchCode, String franchiseCode ){
        Model__c modelId = new Model__c();
        modelId.Name = modelName;
        modelId.Branch_Code__c = branchCode;
        if(franchiseCode != null){
            modelId.Franchise_Code__c = franchiseCode;
            modelId.DWH_Model_ID__c = branchCode + ',' +franchiseCode +',' +modelName;
        }else{
             modelId.DWH_Model_ID__c = branchCode + ',' +'' +',' +modelName;
        }

        if(doInsert)
            insert modelId;
        
        return modelId;
    }
    
    /** This method is test data for create Variant__c **/ 
    public static Variant__c createVariant (Boolean doInsert,String variantName, Id modelId, String branch){
        Variant__c createVariant = new Variant__c();
        createVariant.Name = variantName;
        createVariant.Model_ID__c = modelId;
        
        if(branch=='CCK'){
            createVariant.Franchise__c ='KIAPC'; 
            createVariant.Branch__c='CCK';
        }
        if(branch=='CCA'){
            createVariant.Franchise__c ='MITPC'; 
            createVariant.Branch__c='CCA';
        }
        if(branch=='CCF'){
            createVariant.Franchise__c ='CITPC'; 
            createVariant.Branch__c='CCF';
        }
        if(branch=='CCI'){
            createVariant.Franchise__c ='MBP'; 
            createVariant.Branch__c='CCI';   
        }
        
        if(doInsert)
            insert createVariant;
        
        return createVariant;
    }
    
    /** This method is test data for create Showroom__c**/ 
    public static Showroom__c createShowroom(Boolean doInsert){
        Showroom__c TestShow =  new Showroom__c(Name='TestShow',Address_Line_1__c='Address',City__c='SG',Country__c='SG');   
        
        if(doInsert)
            insert TestShow;
        
        return TestShow;
    }
    
    /** This method is test data for create Stock_Promotion__c**/ 
    public static Stock_Promotion__c createstockPromotion(Boolean doInsert,String stockPromotionName, String type, Id stockVehicleMaster){
        Stock_Promotion__c createstockProm = new Stock_Promotion__c();
        createstockProm.Name = stockPromotionName;
        createstockProm.Promotion_Type__c = type;
        createstockProm.Stock_Vehicle_Master__c = stockVehicleMaster;
        
        if(doInsert)
            insert createstockProm;
        
        return createstockProm;
    }
    
    /** This method is test data for create Test_Drive__c**/
    public static Test_Drive__c createTestDrive(Boolean doInsert,String OpportunityId){
        Test_Drive__c  td = new Test_Drive__c ();
        td.Opportunity__c = OpportunityId;
        
        if(doInsert)
            insert td;
        
        return td; 
    }
    
    /** This method is test data for create Model Interested**/
    public static Models_Interested__c createmodelsInterested(Boolean doInsert,Id ModelId,Id OpportunityId,String status,String tp){
        Models_Interested__c mi = new Models_Interested__c();
        mi.Model__c = ModelId;
        mi.Opportunity__c = OpportunityId;
        mi.Status__c = status;
        mi.Touch_Points__c = tp;
        
        if(doInsert)
            insert mi;
        
        return mi; 
    }
    
    /** This method is test data for create Stock_Reservation__c**/ 
    public static Stock_Reservation__c createstockReservation(Boolean doInsert,Id modmaster, Id colmaster, Id trmaster, Id modyrmaster){
        Stock_Reservation__c sr=new Stock_Reservation__c();
        sr.Model_Code__c= modmaster;
        sr.Model_Year_Code__c=modyrmaster;
        sr.Franchise_Code__c = 'KIAPC';
        sr.Color_Code__c=colmaster;
        sr.Trim_Code__c=trmaster;
        
        if(doInsert)
            insert sr;
        
        return sr;
    }
    
    /** This method is test data for create Invoice__c**/ 
    public static Invoice__c createInvoice(Boolean doInsert, Contact Con){
        Invoice__c InvoiceObj = new Invoice__c(NRIC__C='198400907Z',Transaction_Status__c='settled',Vehicle_Registration_Number__c='SGU4225Z',
                                               Transaction_ID__c='3ex4b0ym',Campaign_ID__c='CID-13',Contact__r=Con,TC_Val__c = 'TestVal',Department__c = 'CCK',SeqNum__c = 314);
        
        if(doInsert)
            insert InvoiceObj;
        
        return InvoiceObj;
    }
    
   /*
    * Method Name: createReqSF
    * Description: Used for Inbound SF API calls.
    * Parameters:	String url - endpoint uri (services/apexrest/GetCustomerProfileBySFUserID/v1/)
    * 				String method - http method (such as GET, POST, PATCH, etc)
    * 				String reqBody - JSON request body
    * 				String respBody - JSON response body
    * 				Integer statCode - HTTP status code
    * Return: N/A
    */ 
    public static void createReqSF(String url, String method, String reqBody, String respBody, Integer statCode){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = url;
        req.httpMethod = method;
        
        if( String.isNotBlank(reqBody) ){
            req.requestBody = Blob.valueOf(reqBody);  
        }
        
        if( String.isNotBlank(respBody) ){
            res.responseBody = Blob.valueOf(respBody);
        }
        res.statusCode = statCode;
        RestContext.request = req;
        RestContext.response = res;
    }    
    
    /** This method is test data for create global_var__c custom settings **/ 
    public static global_var__c createGlobalOrfDefaults(Boolean doInsert)
    {
        global_var__c gb = new global_var__c();
        gb.Account_Activation_EmailId__c ='00Xp0000000I2bZ';
        gb.APIGateway_key__c ='HwrsOLYCDaIbsPfmRMki-PvITQRPjJ8d0eda5WF3gPUAxa3a-LkfniQaYD2TR2EjBUXLQYAQ9zqhYyiQT5sOV7XaMVyIlKC1T';
        gb.APIGateway_url__c ='https://api.cyclecarriage.com';
        gb.buId__c ='100014836';
        gb.Cancel_Service_MC_TriggerId__c ='4413';
        gb.CITSeqNumGV__c = 11.0;
        gb.cmsHeaderDomain__c ='scsit.cyclecarriage.com';
        gb.Community_URL__c ='https://partcopy-digitalmvp-digmvpuat-devjcc.cs5.force.com';
        //gb.CreatedById ='005p0000000NDNVAA4';
        gb.Create_Service_MC_TriggerId__c ='4401';
        gb.CustomQuoteTriggeredId__c ='10555';
        gb.Edit_Service_MC_TriggerId__c ='4414';
        gb.EventConfirmationTriggeredID__c ='8584';
        gb.Forgot_Password_EmailId__c ='00Xp0000000I2bb';
        //gb.InvoiceEmail__c ='14318';
        gb.KIASeqNumGV__c = 311.0;
        gb.MBSeqNumGV__c = 115.0;
        gb.MC_ClientId__c ='yeyzj9hucm16ee3rp9ezgdxq';
        gb.MC_ClientSecret__c ='B82GKjTzhX7IMSMS6YU3OhAb';
        gb.MITSeqNumGV__c = 2.0;
        gb.MobileRedirect_URI__c ='https://test.salesforce.com/services/oauth2/success&scope=&response_type=token';
        gb.Name ='a14p0000000gFH2';
        gb.No_Show_Email_MC_TriggerId__c ='11174';
        gb.objectId__c ='b399ab8e-476e-4c8e-bac4-b7f8836298ea';
        gb.Opportunity_Seq_CIT__c = 7.0;
        gb.Opportunity_Seq_KIA__c = 218.0;
        gb.Opportunity_Seq_MB__c = 11.0;
        gb.Opportunity_Seq_MIT__c = null;
        gb.Password_Reset_EmailId__c ='00Xp0000000I2bd';
        gb.PriceAlertTriggeredId__c ='11175';
        gb.Profile_Id__c ='00ep0000000QHVf';
        gb.QA_Domain_URL__c ='https://scuat.cyclecarriage.com';
        //gb.SetupOwnerId ='00DO00000055kITMAY';
        gb.SF_Mobile_App_ClientID__c ='3MVG9Nvmjd9lcjRlslF9y0GaJ9fgsMt5I9CJZHJvYgxEfGAwiVy1wRTpUB9xXrGHrLrxpNavdw24k02phKNkx';
        gb.SF_Mobile_App_ClientSecret__c ='1424732183323263988';
        gb.SF_Web_App_ClientID__c ='3MVG9Nvmjd9lcjRlslF9y0GaJ9apgxtZidrbjv3KKX.6Do0VUXimZQCNAk9eOO6JD73jcjUOuD5kHT0QoOZk_';
        gb.TestDrive_Confirm_Email_MC_TriggerId__c ='10213';
        gb.TriggeredPush__c ='MjoxMTQ6MA';
        gb.TriggeredsmsId__c ='Mjo3ODow';
        gb.Update_Mobile_Number__c ='9943';
        gb.WebRedirect_URI__c ='https://scsit.cyclecarriage.com/sg/feature/Login/LoggedIn&response_type=token';
        
        
        if(doInsert){
            insert gb;
        }
        return gb;
    }
    
    public static List<Service_Data_Pool__c> createServiceDataPool(Boolean doInsert, Integer size){
        List<Service_Data_Pool__c> listToInsert = new List<Service_Data_Pool__c>();
        for(integer i=0 ;i<size; i++){
            Service_Data_Pool__c sdp = new Service_Data_Pool__c(Apex_Class__c = 'Test',Reference_Id__c = 'test123',Request_End_Point__c = '/services/apexrest/Warehouse/',Request_Header__c='{SecureSpan-Gateway/v9.3.00-b7814, X-Salesforce-SIP=13.250.195.22, apikey=1b58ae26-48d4-4efc-944d-f089258f81sf2}',Request_Method__c='GET',Request_Params__c='{branch=CCK, source=demoandpromo}',Request_URI__c='/Warehouse',Response_Header__c='{Content-Type=application/json}',Response_Status_Code__c='200',Service_Name__c='wareHouseDetails');
            listToInsert.add(sdp);
        }
        if(doInsert){
            Insert listToInsert;
        }
        return listToInsert;
        
    }

    public static List<BatchDataPool__c> createBatchDataPool(Boolean doInsert, Integer size){
        List<BatchDataPool__c> listToInsert = new List<BatchDataPool__c>();
        for(integer i=0 ;i<size; i++){
            BatchDataPool__c sdp = new BatchDataPool__c(ApexClass__c = 'BatchToUpdateSRToVSMS',Batches_Processed__c=1,Batch_Name__c='BatchToUpdateSRToVSMS',Extended_Status__c='Test',Failures__c=0,Job_Id__c='707O000001btnyz',Job_Status__c= 'Completed',Job_Type__c='BatchApex',Total_Batches__c=1);
            listToInsert.add(sdp);
            
        }
        if(doInsert){
            Insert listToInsert;
        }
        return listToInsert;
    }
    
    public static List<Logger_Data_Pool__c> createLoggerDataPool(Boolean doInsert, Integer size){
        List<Logger_Data_Pool__c> listToInsert = new List<Logger_Data_Pool__c>();
        for(integer i=0 ;i<size; i++){
            Logger_Data_Pool__c sdp = new Logger_Data_Pool__c(Cause__c = 'Test',Instance__c='restWarehouse',Line_Number__c=11,Message__c= 'Test Message',Stack_Trace__c='Test Strack Trace',Type__c = 'Test Type');
            listToInsert.add(sdp);
            
        }
        if(doInsert){
            Insert listToInsert;
        }
        return listToInsert;
    }
    
    public static Registered_Vehicle__c createRegVehicle(Boolean doInsert,String name,String branch,String Franchise,String regId,Id con){
        Registered_Vehicle__c regVehicle = new Registered_Vehicle__c(
            name = name,
            Branch__c = branch,
            Franchise__c = Franchise,
            Registration_Number__c = regId,
            Contact__c = con
        );    
        if(doInsert)
            insert regVehicle;
        
        return regVehicle;                                
    }
    
    public static Vehicle_Master__c createVehicleMaster(Boolean doInsert,String name,String VarinatId,String ModelId){
        Vehicle_Master__c vhMaster = new Vehicle_Master__c();
        vhMaster.Name = 'Test Veh MAster';
        if(VarinatId != null){
            vhMaster.Variant__c = VarinatId;
        }
        if(ModelId != null){
            vhMaster.Model__c = ModelId;
        }
        
        if(doInsert)
            insert vhMaster;
        
        return vhMaster;                                
    }

    
    public static Referral__c createReferral(Boolean doInsert,String referrerId, String refereeId){
        Referral__c ref = new Referral__c();
        ref.Referrer_Account__c = referrerId;
        ref.Referee_Account__c = refereeId;
        ref.Stage__c = 'Opened';
        if(doInsert) {
            insert ref;
        }        
        return ref;                                
    }
    
    

    /*
    * This method is used to create http request using below parameters
    * Required Parameters: services/apexrest/' "Name Of Request "'/v1/ and DataBody: JSON BODY OF Request 
    */           
    public static void createReq(String url,String dataBody){
        
        if(dataBody == null){
            RestRequest request   = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri    = 'services/apexrest/'+url+'/v1/';
            request.httpMethod    = 'POST';
            RestContext.request   = request;
            RestContext.response  = response ;
        }else{
            RestRequest req     = new RestRequest();
            RestResponse res    = new RestResponse();
            req.requestURI      = 'services/apexrest/'+url+'/v1/'; 
            req.httpMethod      = 'POST';
            req.requestBody     = Blob.valueOf(dataBody);   
            res.responseBody    = Blob.valueOf(dataBody);
            res.statusCode      = 200;
            RestContext.request = req;
            RestContext.response= res;
        }
        
    }
    
    /** This method is test data for create Invoice__c**/     
    public static Invoice__c createInvoice(Boolean doInsert, String conId, String leadId){
        Invoice__c InvoiceObj = new Invoice__c();
        if(conId != null){
            InvoiceObj.Contact__c = conId;  
        }else if(leadId != null){
            InvoiceObj.Lead__c = leadId;
        }
        
        if(doInsert)
            insert InvoiceObj;
        
        return InvoiceObj;            
    }

    /** PA MIGRATION: Newly Added **/     
    // public static Invoice__c createInvoice(Boolean doInsert,Id accId, Id conId){
    //     Invoice__c invoice = new Invoice__c();
        
    //     if(accId != null){            
    //         invoice.Account__c = accId;  
    //     }

    //     if(conId != null){            
    //         invoice.Contact__c = conId;  
    //     }
        
    //     if(doInsert){
    //         insert invoice;
    //     }
        
    //     return invoice;            
    // }
    
    /*
    * This method is used to create Event_Registration__c using below Parameters 
    * Required Fields : OpportunityId, LeadId, ModalId, CampaignId 
    * Optional Fields : ContactId, InvoiceId
    */           
    public static Event_Registration__c createEventReg(boolean doInsert,Id contId,Id campaId,Id invoId,Id oppId,Id leadId,Id modelId){     
        Event_Registration__c tempInsertER = new Event_Registration__c();
        tempInsertER.Name           = 'Test_Er';
        if(contId != null){ 
            tempInsertER.ContactId__c   = contId; 
        }else if(leadId != null){
            tempInsertER.LeadId__c      = leadId;
        }
        tempInsertER.PromoID__c     = campaId;
        if(invoId != null){ 
            tempInsertER.payment__c     = invoId; 
        } 
        if(oppId != null){
            tempInsertER.Opportunity__c = oppId;
        }
        tempInsertER.ModelCode__c   = ModelId;           
        if(doInsert)
            insert tempInsertER;        
        
        return tempInsertER;                                    
    }

     /* PA MIGRATION: Newly Added
    * This method is used to create Event_Registration__c link up to Account using below Parameters 
    * Required Fields : AccountId, OpportunityId, ModalId, CampaignId 
    * Optional Fields : InvoiceId
    */           
    public static Event_Registration__c createPAEventReg(boolean doInsert, Id accId, Id campaId, Id invoId, Id oppId, Id modelId){     
        Event_Registration__c tempInsertER = new Event_Registration__c();
        tempInsertER.Name = 'DummyEvtReg';
        if(accId != null){
            tempInsertER.Account__c = accId;
        }
        tempInsertER.PromoID__c = campaId;

        if(invoId != null){ 
            tempInsertER.payment__c = invoId; 
        } 
        if(oppId != null){
            tempInsertER.Opportunity__c = oppId;
        }
        tempInsertER.ModelCode__c= ModelId;           
        if(doInsert)
            insert tempInsertER;        
        
        return tempInsertER;                                    
    }
    
    /*
    * This method is used to create Attachment Type "File" using below Parameters 
    * Required Fields : ParentId of respected object where the attachment has to be added
    */            
    public static void createFileAttachment(Id ParentId){        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.pdf'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        Insert content;    
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId     = ParentId;
        contentlink.contentdocumentid  = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';        
        Insert contentlink;        
    }

    /**
    * create sales agreement
    **/
    public static Sales_Agreement__c createSalesAgreement(Boolean doInsert, string branchCode, string agreementNo, ID stockReservationId, string customerName) {
        
        // create new account, opportunity & lead
        // email of lead is test@123.com
        Account tempAccount = Test_DataFactory.createAccount(true, 'TestAccount');
        Lead tempLead = Test_DataFactory.createLead(true, 'Aodigy', 'TestLead');
        Contact tempCt = Test_DataFactory.createContact(true, 'TestName', 'TestName', tempAccount.Id);
        Opportunity tempOpportunity = Test_DataFactory.createOpportunity(true, 'TestOpportunity', tempAccount.ID);
        tempOpportunity.Lead__c = tempLead.ID;
        tempOpportunity.Contact_Person__c = tempCt.Id;
        update tempOpportunity;
        
        // create sales agreement
        Sales_Agreement__c SA = new Sales_Agreement__c();
        SA.Branch_Code__c = branchCode;
        SA.SOH_SONO__c = agreementNo;
        SA.Stock_Reservation__c = stockReservationId;
        system.debug('JMT ' + stockReservationId);
        //SA.Customer_Full_Name__c = customerName;
        SA.NCD__c = 20;
        SA.Promo_Discount__c = 200;
        SA.Accessories_Discount__c = 500;
        SA.Expected_Delivery_From__c = Date.today();
        SA.Expected_Delivery_To__c = Date.today();
        SA.Payment__c = 'Car Loan';
        SA.ARCA_Number__c = 'UEN123456';
        SA.Company_Name__c = 'ABC TEST';
        if (doInsert) {insert SA;}
        return SA;
    }

    /**
    * Attach a pdf document to sales agreement with tittle contain SA's auto number
    **/
    public static ID attachDSA(ID salesAgreementId) {
        // get the sales agreement's auto number
        Sales_Agreement__c SA = [SELECT Name, SOH_SONO__c FROM Sales_Agreement__c WHERE ID = :salesAgreementId];

        // create content for document
        ContentVersion documentContent = new ContentVersion();
        documentContent.Title = 'TEST_' + SA.Name + '_TEST';
        documentContent.PathOnClient = '/' + documentContent.Title + '.pdf';
        Blob bodyBlob = Blob.valueOf('Digital Sales Agreement Testing'); 
        documentContent.VersionData = bodyBlob;
        insert documentContent;

        // link content to sales agreement
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = salesAgreementId;
        contentLink.ContentDocumentId  = [SELECT ContentDocumentId FROM ContentVersion WHERE ID =: documentContent.id].ContentDocumentId;       
        contentLink.ShareType = 'V';
        insert contentLink; 
        return contentLink.ContentDocumentId;
    }
    
    public static Accessories_Master__c createAccessoriesMaster(Boolean doInsert) {
        Accessories_Master__c accessoriesMaster = new Accessories_Master__c();
        
        if(doInsert) {
            insert accessoriesMaster;
		}
        
        return accessoriesMaster;        
    }
    
    public static Accs_Rate_Master__c createAccsRateMaster(Boolean doInsert, Id accessoriesId, Date effectiveDate, Decimal salePrice) {
        Accs_Rate_Master__c accsRateMaster = new Accs_Rate_Master__c(
        	Accessories__c = accessoriesId,
            ARM_EFFDT__c = effectiveDate,
            ARM_SALEPRICE__c = salePrice
        );
        
        if(doInsert) {
            insert accsRateMaster;
		}
        
        return accsRateMaster;
    }
    
    public static Additional_Charges_Master__c createAdditionalChargesMaster(Boolean doInsert, String chargeCode) {
        Additional_Charges_Master__c additionalChargesMaster = new Additional_Charges_Master__c(
        	ADM_CHRGCD__c = chargeCode
        );
            
        if(doInsert) {
            insert additionalChargesMaster;
		}          
        
        return additionalChargesMaster;
    }
    
    public static SA_Additional_Charge__c createSAAdditionalCharge(Boolean doInsert, Id additionalChargesMasterId, Id salesAgreementId) {
        SA_Additional_Charge__c saAdditionalCharge = new SA_Additional_Charge__c(
            AdditionalChargesMaster__c = additionalChargesMasterId,
        	Sales_Agreement__c = salesAgreementId
        );
        
        if(doInsert) {
            insert saAdditionalCharge;
        }
        
        return saAdditionalCharge;
    }    
    
    // Inserted files will have the same name and type
    public static void attachFilesToRecord(Map<Id, List<Blob>> filesByRecId,
                                           String fileDescription,
                                           String fileType)
    {
        Map<Blob, String> descriptionForFile = new Map<Blob, String>();
        Map<Blob, String> typeForFile = new Map<Blob, String>();
        
        for(List<Blob> files : filesByRecId.values()) {
            for(Blob file : files) {
                descriptionForFile.put(file, fileDescription);
                typeForFile.put(file, fileType);
            }
        }
        
        attachFilesToRecord(filesByRecId, descriptionForFile, typeForFile);
    }
    
    // More complex method signature allows for bulkified insertion of files with different names and/or types 
    public static void attachFilesToRecord(Map<Id, List<Blob>> filesByRecId,
                                           Map<Blob, String> descriptionForFile,
                                           Map<Blob, String> typeForFile)
    {
        List<ContentVersion> attachmentsToCreate = new List<ContentVersion>();
        
        for(Id recId : filesByRecId.keySet()) {
            for(Blob content : filesByRecId.get(recId)) {
                String fileDescription = descriptionForFile.get(content);
                
                ContentVersion cv = new ContentVersion(
                    Description = fileDescription,
                    PathOnClient = fileDescription + '.' + typeForFile.get(content),
                    Title = fileDescription + ' (' + recId + ')',
                    VersionData = content
                );
                
                attachmentsToCreate.add(cv);        
            }
        }
        
        insert attachmentsToCreate;    
        
        Set<Id> attachmentCreatedIds = new Set<Id>();
        for(ContentVersion cv : attachmentsToCreate) {
            attachmentCreatedIds.add(cv.Id);
        }
        
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();        
        for(ContentVersion cv : [Select ContentDocumentId, Title From ContentVersion Where Id In :attachmentCreatedIds]) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = cv.Title.substringBeforeLast(')').right(18);
            cdl.ShareType = 'I';
            docLinks.add(cdl);
        }
        insert docLinks;          
    }

    public static Order__c createOrder(String recordTypeId){
        return new Order__c(Adjustment__c = 500,
                            Created_Date__c = system.today(),
                            Grand_Total__c = 1000,
                            OrderID__c = 'ABCDE',
                            RecordTypeId = recordTypeId,
                            Shop__c = 'MIT e-shop',
                            Status__c = 'Ordered',
                            Subtotal__c = 500,
                            Updated_Date__c = system.today());

   } 

    public static Campaign_Member_Vehicle__c createCampVehicle(Boolean doInsert, String name, String campId, String ContactId, String vhId){
        Campaign_Member_Vehicle__c cmv = new Campaign_Member_Vehicle__c();
        cmv.Campaign__c = campId;
        cmv.Contact__c = ContactId;
        cmv.Registered_Vehicle__c = vhId;
        cmv.Name = name;

        if(doInsert){
            insert cmv;
        }
        return cmv;

    }

    // Hobbies__c, ContactHobby__c is deleted [Thang - 04/08/21]
  	/*  public static Hobbies__c createHobby(Boolean doInsert, String name){
        Hobbies__c hb = new Hobbies__c();
        hb.Name = name;
        if(doInsert){
            insert hb;
        }
        return hb;
    	}
	
    public static ContactHobby__c createConHobby(Boolean doInsert, String contactId){
            Hobbies__c hob =  createHobby(true, 'Test');
            ContactHobby__c conHobby = new ContactHobby__c();
            conHobby.Contact__c = contactId;
            conHobby.Hobby__c = hob.Id;
            if(doInsert){
                insert conHobby;
            }
            return conHobby;
    }
	*/
    public static CustomerAlerts__c createCusAlert(Boolean doInsert, String name, String conId){
        CustomerAlerts__c cAlert = new CustomerAlerts__c();
        cAlert.Name = name;
        cAlert.Contact__c = conId;
        cAlert.Status__c = 'read';
        if(doInsert){
            insert cAlert;
        }
        return cAlert;
    }
    public static Case createCase (Boolean doInsert, String conId){
        Case objCase = new Case();
        objCase.Status ='New';
        objCase.ContactID = conId;
        objCase.Subject = 'CaseSubject_'+conId;
        if(doInsert){
            insert objCase;
        }

        return objCase;

    }
    public static Feedback__c createFeedback (Boolean doInsert, String name){
        Feedback__c fb = new Feedback__c();
        fb.Name = name;
        fb.Category__c = 'Sales';
        fb.Email__c = 'abc@zoho.com';
        fb.Mobile__c = '123444444';
        fb.Name__c = name;
        if(doInsert){
            insert fb;
        }
        return fb;
    }

    public static Account createPerson (Boolean doInsert, String lastName, String recordType){
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( recordType ) ? 
                                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( recordType ).getRecordTypeId() :
                                    acc.recordTypeId;
        acc.LastName = lastName;
        acc.PersonEmail = 'test@mail.com';
        if(doInsert){
            insert acc;
        }
        return acc;

    }
    
    public static Account createPA(Boolean doInsert, String lastName, String email, String recordType){
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey( recordType ) ? 
                                Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( recordType ).getRecordTypeId() :
                                    acc.recordTypeId;
        acc.LastName = lastName;
        acc.PersonEmail = email;
        if(doInsert){
            insert acc;
        }
        return acc;

    }
    
    public static Reward_Profile__c createRewardProfile (Boolean doInsert, String recordType, String branch, String brand, String type) {
        Reward_Profile__c rewardProfile = new Reward_Profile__c();
        rewardProfile.RecordTypeId = Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().containsKey( recordType ) ? 
                                     Schema.SObjectType.Reward_Profile__c.getRecordTypeInfosByDeveloperName().get( recordType ).getRecordTypeId() : rewardProfile.recordTypeId;
        rewardProfile.Branch__c = branch;
        rewardProfile.Brand__c = brand;
        rewardProfile.Type__c = type;
        if (doInsert) {
            insert rewardProfile;
        }
        
        return rewardProfile;
    }
    
    public static Reward__c createReward (Boolean doInsert, String rewardProfileId, String type, String status, Date expiryDate) {
        Reward__c reward = new Reward__c();
        reward.Reward_Profile__c = rewardProfileId;
        reward.Type__c = type;
        reward.Status__c = status;
        reward.Expiry__c = expiryDate;
        if(doInsert) {
            insert reward;
        }
        
        return reward;
    }
    
    public static Reward_Usage__c createRewardUsage (Boolean doInsert, String rewardId, String status, String recordType) {
        Reward_Usage__c rewardUsage = new Reward_Usage__c();
        rewardUsage.RecordTypeId = Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().containsKey( recordType ) ? 
                                     Schema.SObjectType.Reward_Usage__c.getRecordTypeInfosByDeveloperName().get( recordType ).getRecordTypeId() : rewardUsage.recordTypeId;
        rewardUsage.Reward__c = rewardId;
        rewardUsage.Status__c = status;
        rewardUsage.Transaction_Date__c = Date.today();
        if(doInsert) {
            insert rewardUsage;
        }
        
        return rewardUsage;
    }


    public static Account_Mapping__c createAccountMapping(Boolean doInsert, String strRewardType, String strSrcCode, String strVehFran, String strDivision ){
        Account_Mapping__c actMap = new Account_Mapping__c();
        actMap.Reward_Type__c       = strRewardType;
        actMap.Starting_Number__c   = 0;
        actMap.Current_NUmber__c    = 0;
        actMap.Description__c       = 'Testing';
        actMap.Account_Prefix__c    = 'XYZ';
        actMap.Source_Code__c       = strSrcCode;
        actMap.Reward_Type__c       = strRewardType;
        actMap.Vehicle_Franchise__c = strVehFran;
        actMap.Division__c          = strDivision;
        if( actMap.Source_Code__c == 'ACS' ){
            actMap.Source__c = 'Sold Credits';
        }
        else if( actMap.Source_Code__c == 'AGA' ){
            actMap.Source__c = 'Aftersales - Goodwill';
        }
        else if( actMap.Source_Code__c == 'AGS' ){
            actMap.Source__c = 'Sales - Goodwill';
        }
        else if( actMap.Source_Code__c == 'ANC' ){
            actMap.Source__c = 'New Car Purchase';
        }
        actMap.Composite_Key__c = actMap.Source_Code__c + actMap.Vehicle_Franchise__c;

        if(doInsert) {
            insert actMap;
        }
        return actMap;
    }


    public static Transaction__c createTransaction(Boolean doInsert, String strSRC, String strFRAN, String strREGN, String strCHASSIS, String strNRIC ){
        Transaction__c trxn = new Transaction__c();
        trxn.SRC__c     = strSRC;
        trxn.FRAN__c    = strFRAN;
        trxn.REGN__c    = strREGN;
        trxn.CHASSIS__c = strCHASSIS;
        trxn.NRIC__c    =  strNRIC;
        trxn.FLEET__c   = 'N';
        trxn.P__c       = 'M';
        trxn.COST__c    = '1000';
        trxn.SEQ__c     = 1.0;
        trxn.TARMAGIC__c = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
        trxn.NLCODE__c  = 'NL'+Math.round((Math.random() * (90000) + 10000));
        trxn.EXPIRY__c  = Date.today().addYears(1);
        trxn.CR_AMT__c  = 2000;

        if(doInsert) {
            insert trxn;
        }
        return trxn;
    }

    public static Master_Approval__c createMasterApproval(Boolean doInsert, Double totalAmount, String uniqueKey) {
        Master_Approval__c masterApproval = new Master_Approval__c();
        masterApproval.Request_Type__c = 'Writeback';
        masterApproval.Submitted_Date__c  = Date.today();
        masterApproval.Total_Amount__c = totalAmount;
        masterApproval.Unique_Key__c = uniqueKey;
        
        if(doInsert) {            
            insert masterApproval;
        }
        return masterApproval;
    }

    public static Usage_Transaction__c createUsageTransaction(Boolean doInsert, String recordType, String invoiceNo, Double invoiceAmount, Double creditAmount) {
        Usage_Transaction__c usageTransaction = new Usage_Transaction__c();
        usageTransaction.RecordTypeId = Schema.SObjectType.Usage_Transaction__c.getRecordTypeInfosByDeveloperName().containsKey( recordType ) ? 
                                     Schema.SObjectType.Usage_Transaction__c.getRecordTypeInfosByDeveloperName().get( recordType ).getRecordTypeId() : usageTransaction.recordTypeId;
        usageTransaction.Autoline_Invoice_Number__c = invoiceNo;
        usageTransaction.Invoice_Amount__c = invoiceAmount;
        usageTransaction.Autoline_Invoice_Date__c = Date.today() - 3;        
        usageTransaction.Credit_Amount__c = creditAmount;
        if(recordType == 'Debit') {
            usageTransaction.Outstanding_Payment_Amount__c = invoiceAmount - creditAmount;
            usageTransaction.Outstanding_Payment_Type__c = 'Cash';
        }
        if(recordType == 'Credit') {
            usageTransaction.Credit_Note__c = 'CN0001';
        }
        if(doInsert) {
            insert usageTransaction;
        }
        
        return usageTransaction;
    }


    public static Loan_Application__c createLoanApplication(Boolean doInsert, String recordType, Id salesAgreementId ) {
        Loan_Application__c loanAppl = new Loan_Application__c();
        loanAppl.Sales_Agreement__c = salesAgreementId;
        loanAppl.Status__c      = 'Draft';
        loanAppl.VehicleMake__c = 'KIA';
        loanAppl.VehicleType__c = 'N';
        if(doInsert) {
            insert loanAppl;
        }
        return loanAppl;
    }

    
    public static Person_Account_Profiling__c createPAProfiling(Boolean doInsert, String accId, String recordTypeAPINAme){
        Person_Account_Profiling__c profiling = new Person_Account_Profiling__c();
        String recordTypeId  = Schema.SObjectType.Person_Account_Profiling__c.getRecordTypeInfosByDeveloperName().containsKey( recordTypeAPINAme ) 
            					  ? Schema.SObjectType.Person_Account_Profiling__c.getRecordTypeInfosByDeveloperName().get(recordTypeAPINAme).getRecordTypeId()
                                  : null;
        profiling.RecordTypeId = recordTypeId;
        profiling.Account__c    = accId;

        if(doInsert){
            insert profiling;
        }
        return profiling;

    }

    public static Sales_Opportunity__c createSalesOpp(Boolean doInsert, String accId, String status, String scName, String scEmail, String scMobile) {
        Sales_Opportunity__c salesOpp = new Sales_Opportunity__c();
        
        salesOpp.Account__c = accId;
        salesOpp.Status__c  = status;
        salesOpp.Salesman_Name__c   = scName;
        salesOpp.Salesman_Email__c  = scEmail;
        salesOpp.Salesman_Mobile__c = scMobile;
        if(doInsert){
            insert salesOpp;
        }
        return salesOpp;
    }

    public static Used_Car_Vehicle_Stock__c createSoldUsedCar(Boolean doInsert, String accId, String stockNo, String registeredNo, String make, String model){
        Used_Car_Vehicle_Stock__c vehicleStock   = new Used_Car_Vehicle_Stock__c();
        vehicleStock.recordTypeId  = Schema.SObjectType.Used_Car_Vehicle_Stock__c.getRecordTypeInfosByDeveloperName().get('RA_Used_Car_Vehicle_Stock_RT').getRecordTypeId();
        vehicleStock.Account__c                  = accId;
        vehicleStock.Stock_Number__c             = stockNo;
        vehicleStock.Registered_Number__c        = registeredNo;
        vehicleStock.Make__c                     = make;
        vehicleStock.Model__c                    = model;
        vehicleStock.Vehicle_Status__c           = 'Sold';
        if (doInsert){
            insert vehicleStock;
        }
        return vehicleStock;
    }

    public static Used_Car_Vehicle_Stock__c createOpenUsedCar(Boolean doInsert, String stockNo, String registeredNo, String make, String model){
        Used_Car_Vehicle_Stock__c vehicleStock   = new Used_Car_Vehicle_Stock__c();
        vehicleStock.recordTypeId  = Schema.SObjectType.Used_Car_Vehicle_Stock__c.getRecordTypeInfosByDeveloperName().get('RA_Used_Car_Vehicle_Stock_RT').getRecordTypeId();                  
        vehicleStock.Stock_Number__c             = stockNo;
        vehicleStock.Registered_Number__c        = registeredNo;
        vehicleStock.Make__c                     = make;
        vehicleStock.Model__c                    = model;
        vehicleStock.Vehicle_Status__c           = 'Open'; 
        if (doInsert){
            insert vehicleStock;
        }
        return vehicleStock;
    }

    public static Price_Alert_for_Non_MF__c createRAPriceAlert(Boolean doInsert, String accId, String stockId, String status) {
        Price_Alert_for_Non_MF__c priceAlert   = new Price_Alert_for_Non_MF__c();
        priceAlert.RecordTypeId                = Schema.SObjectType.Price_Alert_for_Non_MF__c.getRecordTypeInfosByDeveloperName().get('RA_Price_Alert_RT').getRecordTypeId();
        priceAlert.RecordTypeId                = Schema.SObjectType.Price_Alert_for_Non_MF__c.getRecordTypeInfosByDeveloperName().get('RA_Price_Alert_RT').getRecordTypeId();
        priceAlert.Account__c                  = accId;
        priceAlert.Used_Car_Vehicle_Stock__c   = stockId;
        priceAlert.Subscription_Status__c      = status;
        if(doInsert){
            insert priceAlert;
        }
        return priceAlert;
    }

    public static Model_Alert_Subscription__c createRAModelAlert(Boolean doInsert, String accId, String salesOppId, Date expiryDate, String status) {
        Model_Alert_Subscription__c modelAlert = new Model_Alert_Subscription__c();
        modelAlert.recordTypeId  = Schema.SObjectType.Model_Alert_Subscription__c.getRecordTypeInfosByDeveloperName().get('RA_Model_Alert_Subcription_RT').getRecordTypeId();
        modelAlert.Account__c                  = accId;
        modelAlert.Sales_Opportunity__c        = salesOppId;
        modelAlert.Subscription_Expiry_Date__c = expiryDate;
        modelAlert.Subscription_Status__c      = status;

        if (doInsert){
            insert modelAlert;
        }

        return modelAlert;
    }

    public static Model_Subscribed__c createRAModelSubscribed(Boolean doInsert, String modelAlertId, String make, String model) {
        Model_Subscribed__c subscribed = new Model_Subscribed__c();
        subscribed.RecordTypeId = Schema.SObjectType.Model_Subscribed__c.getRecordTypeInfosByDeveloperName().get('RA_Model_Subscribed_RT').getRecordTypeId();
        subscribed.Model_Alert_Subscription__c = modelAlertId;
        subscribed.Make__c                     = make;
        subscribed.Model_Name__c               = model;
        if (doInsert){
            insert subscribed;
        }

        return subscribed;
    }

    public static Vehicle_Stock_Reservation__c createReservation(Boolean doInsert, String accId, Datetime apptDatetime, String location, Double depositPaid, Id salesOppId,  Id vehicleStockId) {
        Vehicle_Stock_Reservation__c reservation = new Vehicle_Stock_Reservation__c();
        reservation.Account__c                = accId;
        reservation.Appointment_Date_Time__c  = apptDatetime;
        reservation.Location__c               = location;
        reservation.Deposit_Paid__c           = depositPaid;
        reservation.Sales_Opportunity__c      = salesOppId;
        reservation.Used_Car_Vehicle_Stock__c = vehicleStockId;
        if(doInsert){
            insert reservation;
        }
        return reservation;
    }

    public static Vehicle_Pricing_Option__c createPricingOption(Boolean doInsert, String purchaseOptionId) {
        Vehicle_Pricing_Option__c pricingOption = new Vehicle_Pricing_Option__c();
        pricingOption.Purchase_Option__c = purchaseOptionId;
        
        if(doInsert){
            insert pricingOption;
        }
        return pricingOption;
    }

    public static Invoice__c createRAPayment(Boolean doInsert,String regNo, String paymentType, Double netAmount, String transactionId, String cardType, String transactionStatus, String maskedCCNo, String sitename, String branch) {
        Invoice__c payment = new Invoice__c();
        payment.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'RA_Payment_RT' ).getRecordTypeId();
         
        payment.Vehicle_Registration_Number__c = regNo;
        payment.Payment_Type__c                = paymentType;
        payment.Net_Amount__c                  = netAmount;
        payment.Transaction_ID__c              = transactionId;
        payment.CardType__c                    = cardType;
        payment.Transaction_Status__c          = transactionStatus;
        payment.MaskedCCNo__c                  = maskedCCNo;
        payment.Brand__c                       = sitename;
        payment.Department__c                  = branch;

        if(doInsert){
            insert payment;
        }
        return payment;
    }

    public static Used_Car_Vehicle_Sizing__c createUCVehicleSizing (Boolean doInsert, String make, String model, String size)
    {
        Used_Car_Vehicle_Sizing__c vehicleSizing = new Used_Car_Vehicle_Sizing__c();
        vehicleSizing.Make__c  = make;
        vehicleSizing.Model__c = model;
        vehicleSizing.Name     = make + ' ' + model;
        // update by KT to reference Vehicle_Size picklist field 18/10/2021
        vehicleSizing.Vehicle_Size__c  = size;

        if (doInsert)
        {
            insert vehicleSizing;
        }

        return vehicleSizing;
    }

    public static Courtesy_Vehicle__c createCourtesyVehicle (Boolean doInsert, String recordType, String status, String branchCode, String franchiseCode, Id modelId, Id variantId)
    {
        String recordTypeId  = Schema.SObjectType.Courtesy_Vehicle__c.getRecordTypeInfosByDeveloperName().containsKey(recordType) ? Schema.SObjectType.Courtesy_Vehicle__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId() : null;
        Courtesy_Vehicle__c veh = new Courtesy_Vehicle__c();
        veh.RecordTypeId        = recordTypeId;
        veh.Status__c           = status;
        veh.Branch_Code__c      = branchCode;
        veh.Franchise_Code__c   = franchiseCode;
        veh.Model__c            = modelId;
        veh.Variant__c          = variantId;

        if (doInsert)
        {
            insert veh;
        }

        return veh;
    }   

    public static MB_Test_Drive_Daily_Log__c createMBTestDriveDailyLog(Boolean doInsert, Decimal openingMileage, Decimal closingMileage, String status, Id courtersyVehId)
    {
        MB_Test_Drive_Daily_Log__c log = new MB_Test_Drive_Daily_Log__c();
        log.Opening_Mileage__c         = openingMileage;
        log.Closing_Mileage__c         = closingMileage;
        log.Status__c                  = status;
        log.Courtesy_Vehicle__c        = courtersyVehId;

        if (doInsert)
        {
            insert log;
        }

        return log;
    }

    public static Campaign_Promo_Line_Item__c createCampaignPromoLineItem(Boolean doInsert, Id campaignId, Id promoLineItemId){
        Campaign_Promo_Line_Item__c camItem = new Campaign_Promo_Line_Item__c();
        camItem.Campaign__c = campaignId;
        camItem.Promo_Line_Item__c = promoLineItemId;

        if (doInsert) {
            insert camItem;
        }

        return camItem;
    }

    public static Invoice_Promo_Line_Item__c createInvoicePromoLineItem(Boolean doInsert, Id invoiceId, Id promoLineItemId){
        Invoice_Promo_Line_Item__c invItem = new Invoice_Promo_Line_Item__c();
        invItem.Payment__c = invoiceId;
        invItem.Promo_Line_Item__c = promoLineItemId;

        if(doInsert){
            insert invItem;
        }

        return invItem;
    }

    public static Promo_Line_Item__c createPromoLineItem(Boolean doInsert, String itemName, Double usualPrice, Double promoPrice, String variantName, Integer noOfStock){
        Promo_Line_Item__c item = new Promo_Line_Item__c();
        item.Item_Display_Name__c = itemName;
        item.Usual_Price__c = usualPrice;
        item.Promo_Price__c = promoPrice;
        item.Variant_Display_Name__c = variantName;
        item.No_of_Stock__c = noOfStock;

        if (doInsert) {
            insert item;
        }

        return item;
    }

    public static CampaignMember createCampaignMember(Boolean doInsert, Id campaignId, Id contactId){
        CampaignMember camMem = new CampaignMember();
        camMem.CampaignId = campaignId;
        camMem.ContactId = contactId;
        if(doInsert){
            insert camMem;
        }
        
        return camMem;
    }

    @testVisible static List<CLBLReportParm__mdt> customMetadata { 
        get {
            if ( customMetadata == null )
                customMetadata = [ SELECT Last_Sync_Date__c FROM CLBLReportParm__mdt WHERE DeveloperName='Booking_List']; 
            return customMetadata;
        } set; }

    public static Used_Car_Quote__c createUCQ(Boolean doInsert, String chassisNo, String vehicleNo, Date IDD, String NRIC) {
        Used_Car_Quote__c ucq = new Used_Car_Quote__c();
        ucq.Chassis_No__c = chassisNo;
        ucq.Vehicle_No__c = vehicleNo;
        ucq.Intended_Deregistration_Date__c = IDD;
        ucq.Customer_ID_Type__c = Used_Car_Quote__c.Customer_ID_Type__c.getDescribe().getPicklistValues()[1].getValue();
        ucq.Customer_NRIC__c = NRIC;
        ucq.Status__c = 'Open';
        ucq.recordTypeId = UsedCarQuoteService.getMBRecordTypeId();

        if(doInsert){
            insert ucq;
        }

        return ucq;

    }
    
    public static List<Sales_Agreement__c> create_List_Sales_Agreement(Integer listSize){
        List<Sales_Agreement__c> listSA = new List<Sales_Agreement__c>();
        for(Integer i; i < listSize;i++){
            listSA.add(new Sales_Agreement__c(
                 // create sales agreement                
                Branch_Code__c = 'branchCode_' + i,
                SOH_SONO__c = 'agreementNo',
                Stock_Reservation__c = 'stockReservationId'
            ));
        }
        insert listSA;
        return listSA;
    }

    public static COE_Bid_Period__c createCOEPeriod(Boolean doInsert, Date startDate, Date endDate){
        COE_Bid_Period__c coePeriod = new COE_Bid_Period__c();
        coePeriod.From_Date__c = startDate;
        coePeriod.To_Date__c = endDate;

        if(doInsert){
            insert coePeriod;
        }

        return coePeriod;
    }

    public static JIT_Day__c createJITDay(Boolean doInsert, String name, String franchise){
        JIT_Day__c jitDay = new JIT_Day__c();
        jitDay.Name = name;
        jitDay.JIT_Date__c = Date.today();
        jitDay.No_of_Slots__c = 10;
        jitDay.Opened_Slots__c = 6;
        jitDay.Utilised_Slots__c = 2;
        jitDay.Franchise__c = franchise;

        if(doInsert){
            insert jitDay;
        }

        return jitDay;
    }

    public static JIT_Day__c createJITDay_NoMoreSlot(Boolean doInsert, String name, String franchise){
        JIT_Day__c jitDay = new JIT_Day__c();
        jitDay.Name = name;
        jitDay.JIT_Date__c = Date.today();
        jitDay.No_of_Slots__c = 1;
        jitDay.Opened_Slots__c = 6;
        jitDay.Utilised_Slots__c = -1;
        jitDay.Franchise__c = franchise;

        if(doInsert){
            insert jitDay;
        }

        return jitDay;
    }

    /**
     * Generate a string of @length random characters. This method is for testing purpose so no input validate is applied.
     * @param length desired length of string. The method expect @length to be greater than 1.
     */
    private static String randomString(Integer length)
    {
        List<String> ALPHA_NUMERIC_CHARACTERS = new List<String> {
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
        };

        String result = '';

        for (Integer i = 0; i < length; i++)
        {
            Integer randomNumber = (Integer) ( Math.random() * (ALPHA_NUMERIC_CHARACTERS.size() - 1) );

            result += ALPHA_NUMERIC_CHARACTERS[randomNumber];
        }

        return result;
    }
    /** Adding By Nhung Cao [16092022]**/ 
   public static List<Vehicle_Master2__c> createListVehicleMaster2 (Boolean doInsert){
        //full record to send email
        Purchase_Order__c po = new Purchase_Order__c();
        po.Franchise__c = 'KIAPC';
        po.Production_Month__c = Date.valueOf('2022-08-01');
        insert po;        

        Forward_FOB_Contract__c fobCtr = new Forward_FOB_Contract__c();
        fobCtr.Purchase_Order__c = po.Id;
        fobCtr.Status__c = 'Active';
        insert fobCtr;

        Forward_Duty_Contract__c dutyCtr = new Forward_Duty_Contract__c();
        dutyCtr.Purchase_Order__c = po.Id;
        dutyCtr.Status__c = 'Active';
        insert dutyCtr;

        Account supplierAcc = new Account();
        supplierAcc.Name = 'test_Name';
        insert supplierAcc;
        Vehicle_Purchase_Order__c vpo = new Vehicle_Purchase_Order__c();
        vpo.TMS_Purchase_Order__c = po.Id;
        vpo.Franchise_Code__c = 'KIAPC';
        vpo.Supplier_Account__c = supplierAcc.Id;
        vpo.Currency_Code__c = 'USD';
        vpo.Production_Month__c = Date.valueOf('2022-08-01');
        insert vpo;

        // Purchase_Order__c po1 = new Purchase_Order__c();
        // po1.Franchise__c = 'KIAPC';
        // po1.Production_Month__c = Date.valueOf('2022-08-02');
        // insert po1;        

        // Forward_FOB_Contract__c fobCtr1 = new Forward_FOB_Contract__c();
        // fobCtr1.Purchase_Order__c = po1.Id;
        // fobCtr1.Status__c = 'Active';
        // insert fobCtr1;

        // Forward_Duty_Contract__c dutyCtr1 = new Forward_Duty_Contract__c();
        // dutyCtr1.Purchase_Order__c = po1.Id;
        // dutyCtr1.Status__c = 'Sold';
        // insert dutyCtr1;

        // Account supplierAcc1 = new Account();
        // supplierAcc1.Name = 'test_Name';
        // insert supplierAcc1;
        // Vehicle_Purchase_Order__c vpo1 = new Vehicle_Purchase_Order__c();
        // vpo1.TMS_Purchase_Order__c = po1.Id;
        // vpo1.Franchise_Code__c = 'KIAPC';
        // vpo1.Supplier_Account__c = supplierAcc1.Id;
        // vpo1.Currency_Code__c = 'USD';
        // vpo1.Production_Month__c = Date.valueOf('2022-08-02');
        // insert vpo1;

        //FOB and Duty contract with Status != 'Active'
        Purchase_Order__c po2 = new Purchase_Order__c();
        po2.Franchise__c = 'KIAPC';
        po2.Production_Month__c = Date.valueOf('2022-08-03');
        insert po2;        

        Forward_FOB_Contract__c fobCtr2 = new Forward_FOB_Contract__c();
        fobCtr2.Purchase_Order__c = po2.Id;
        fobCtr2.Status__c = 'Sold';
        insert fobCtr2;

        Forward_Duty_Contract__c dutyCtr2 = new Forward_Duty_Contract__c();
        dutyCtr2.Purchase_Order__c = po2.Id;
        dutyCtr2.Status__c = 'Sold';
        insert dutyCtr2;

        Account supplierAcc2 = new Account();
        supplierAcc2.Name = 'test_Name';
        insert supplierAcc2;
        Vehicle_Purchase_Order__c vpo2 = new Vehicle_Purchase_Order__c();
        vpo2.TMS_Purchase_Order__c = po2.Id;
        vpo2.Franchise_Code__c = 'KIAPC';
        vpo2.Supplier_Account__c = supplierAcc2.Id;
        vpo2.Currency_Code__c = 'USD';
        vpo2.Production_Month__c = Date.valueOf('2022-08-03');
        insert vpo2;

        List<Vehicle_Master2__c> listSVM = new List<Vehicle_Master2__c>();
        
        for(Integer i = 0; i < 5; i++)
        {   
            Vehicle_Master2__c vehiclemaster = new Vehicle_Master2__c();
            vehiclemaster.Purchase_Order__c = po.Id;
            vehiclemaster.Vehicle_Purchase_Order__c = vpo.Id;
            vehiclemaster.Vehicle_Purchase_Status__c = 'Confirmed';
            vehiclemaster.ProductionMonth__c = Date.valueOf('2022-08-01');
            listSVM.add(vehiclemaster);
        }   
        // for(Integer i = 0; i < 5; i++)
        // {   
        //     Vehicle_Master2__c vehiclemaster = new Vehicle_Master2__c();
        //     vehiclemaster.Purchase_Order__c = po1.Id;
        //     vehiclemaster.Vehicle_Purchase_Order__c = vpo1.Id;
        //     vehiclemaster.Vehicle_Purchase_Status__c = 'Confirmed';
        //     vehiclemaster.ProductionMonth__c = Date.valueOf('2022-08-02');
        //     listSVM.add(vehiclemaster);
        // } 

        for(Integer i = 0; i < 5; i++)
        {   
            Vehicle_Master2__c vehiclemaster = new Vehicle_Master2__c();
            vehiclemaster.Purchase_Order__c = po2.Id;
            vehiclemaster.Vehicle_Purchase_Order__c = vpo2.Id;
            vehiclemaster.Vehicle_Purchase_Status__c = 'Confirmed';
            vehiclemaster.ProductionMonth__c = Date.valueOf('2022-08-03');
            listSVM.add(vehiclemaster);
        } 
           
        
        if(doInsert) {
            insert listSVM;  
        }
                    
        return listSVM;
    }
}
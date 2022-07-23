/** *****
 * Class name : StockReservationCon
 * Description : Controller for Stock Reservation
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * YYYYMMDD            C&C                           Created Initial Version.
 * 20210621            khanh.do@aodigy.com           Added Person Account Profiling creation
 * 
** *****/
public without sharing class StockReservationCon{
    //Existing Stock, Incoming Stock, Stock To Indent
    public List<wStock> ListwrapperPromotionStock{get;set;}
    public List<wStock> ListwrapperExistingStock{get;set;}
    public List<wStock> ListwrapperIncomingStock{get;set;}
    public List<wStock> ListwrapperStock2Indent{get;set;}
    public Boolean showPopUp{get;set;}
    public String nricfield{get;set;}
    public String NRICErr {get;set;}
    public String NRICSuccess {get;set;}
    public String custFirstName {get;set;}
    public String custLastName {get;set;}
    public Boolean showPromoStock {get;set;}
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    public string callfunc {get;set;}
    public Date custBirthDate {get;set;}                                  // Added by Vu 06/07/2022 - To store value of Date of Birth input

    public class wStock {
        public String wID {get;set;}
        public Integer No {get;set;}
        public String Model {get;set;}
        public String Color {get;set;}
        public String Trim {get;set;}
        public String ModelYear {get;set;}
        public String Quantity {get;set;}
        public String ProductMonth {get;set;}
        public String Remarks {get;set;}
        public ID ModelYearID {get;set;}
        public ID ColorID {get;set;}
        public ID TrimID {get;set;}
        public ID VMID {get;set;}

        public wStock(String iwID, Integer iNo, String iModel, String iColor, String iTrim, String iModelYear, String iQuantity, String iProductMonth, String iRemarks, ID iModelYearID, ID iColorID, ID iTrimID, ID iVMID) {
            this.wID = iwID;
            this.No = iNo;
            this.Model = iModel;
            this.Color = iColor;
            this.Trim = iTrim;
            this.ModelYear = iModelYear;
            this.Quantity = iQuantity;
            this.ProductMonth = iProductMonth;
            this.Remarks = iRemarks;
            this.ModelYearID = iModelYearID;
            this.ColorID = iColorID;
            this.TrimID = iTrimID;
            this.VMID = iVMID;
        }
    }

    public integer showPage {get;set;}
    public List<SelectOption> ListOptions_Model {get;set;}
    public List<SelectOption> ListOptions_Color {get;set;}
    public List<SelectOption> ListOptions_Trim {get;set;}
    public string selectedModel {get;set;}
    public string selectedColor {get;set;}
    public string selectedTrim {get;set;}
    public string ReserveSelectedVehicle {get;set;}
    public id ReservationId {get;set;}

    public List<Stock_Reservation__c> ListReservation {get;set;}
    public User SalesUser {get;set;}
    public Stock_Reservation__c Reservation {get;set;}
    public Vehicle_Master2__c VehicleMaster {get;set;}

    public String logo1{get;set;}
    public String logo2{get;set;}

    public List<Model_Color_Trim_Master__c> ListModelColorTrimMaster {get;set;}

    public Map<String, Vehicle_Master2__c> MapModel_VM_PromotionStock {get;set;}
    public Map<String, Integer> MapModel_Qty_PromotionStock {get;set;}

    public Map<String, Vehicle_Master2__c> MapModel_VM_IncomingStock {get;set;}
    public Map<String, Integer> MapModel_Qty_IncomingStock {get;set;}

    public Map<String, Vehicle_Master2__c> MapModel_VM_ExistingStock {get;set;}
    public Map<String, Integer> MapModel_Qty_ExistingStock {get;set;}

    public Map<String, Vehicle_Master2__c> MapModel_VM_IndentStock {get;set;}
    public Map<String, Integer> MapModel_Qty_IndentStock {get;set;}

    public Boolean promtErrorOnSR {get;set;}
    public String printErrorOnSR {get;set;}
    // public List<Contact> listExistingContact {get;set;}
    public List<Account> listExistingAccount {get;set;}

    public integer Threshold {get;set;}
    public Map<Id,String> MapVehicleMasterId_Comment {get;set;}

    public Boolean showError{get;set;}
    public String modelSelected{get;set;}

    public class wIndent {
        public String IDModel {get;set;}
        public String IDModelYear {get;set;}
        public String IDColor {get;set;}
        public String IDTrim {get;set;}
        public String Model {get;set;}
        public String ModelYear {get;set;}
        public String Color {get;set;}
        public String Trim {get;set;}
        public String VmId {get;set;}

        public wIndent(String iIDModel, String iIDModelYear, String iIDColor, String iIDTrim, String iModel, String iModelYear, String iColor, String iTrim, String VmId) {
            this.IDModel     = iIDModel;
            this.IDModelYear = iIDModelYear;
            this.IDColor     = iIDColor;
            this.IDTrim      = iIDTrim;
            this.Model       = iModel;
            this.ModelYear   = iModelYear;
            this.Color       = iColor;
            this.Trim        = iTrim;
            this.VmId        = VmId;
        }
    } 

    public StockReservationCon() {
        showPopUp = false;
        showPromoStock = false;
        SalesUser = new User();
        SalesUser = [SELECT Id, NRIC__c, Name, Branch_Code__c, Franchise_Code__c, Username2__c
                     FROM User 
                     WHERE Id = :UserInfo.getUserId() 
                     LIMIT 1];
                     
        String branchCode    = SalesUser.Branch_Code__c;
        String franchiseCode = SalesUser.Franchise_Code__c;

        switch on franchiseCode{
            when 'MITPC' {
              showPromoStock = true;
            }
            when else {
              showPromoStock = false;
            }
        }

        logo1 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c = '' AND Franchise_Code__c = '' LIMIT 1].FileName__c;
        logo2 = [SELECT FileName__c FROM Logo__c WHERE Branch_Code__c = :branchCode LIMIT 1].FileName__c;
        showPage = 1;
        showError = FALSE;
        initPage();
    }

    public void initPage() {
        selectedModel = '';
        selectedColor = '';
        selectedTrim  = '';
        ReserveSelectedVehicle = '';
        ReservationId  = null;
        promtErrorOnSR = false;
        printErrorOnSR = '';
        // listExistingContact = new List<Contact>();
        listExistingAccount = new List<Account>();
        Reservation         = new Stock_Reservation__c();
        VehicleMaster       = new Vehicle_Master2__c();

        /*
        *  1. List the Color Trim Master Record then put it under map (for search)
        *  2. query the vehicle2 master then put it under map:
        *  - to store the vehicle2 master based on the model year, color, trim
        *  - to store the quantity of the vehicle2 master
        *  3. show the map under 4 different list (Promotion, Existing, Incoming, Stock to Indent)
        *  4. list out active the reservation for respective sales person.
        */
        ListModelColorTrimMaster = new List<Model_Color_Trim_Master__c>();
        ListModelColorTrimMaster = [SELECT Id, Model_Code__c, Model_Code__r.Model_Description__c, Trim_Code__c, Trim_Code__r.Trim_Description__c, 
                                        Color_Code__c, Color_Code__r.Color_Description__c
                                    FROM Model_Color_Trim_Master__c
                                    WHERE Franchise_Code__c = :SalesUser.Franchise_Code__c
                                    AND Branch_Code__c = :SalesUser.Branch_Code__c
                                    AND Active__c = true
                                    ORDER BY CreatedDate desc, Model_Code__r.Model_Description__c, Color_Code__r.Color_Description__c, Trim_Code__r.Trim_Description__c
                                    LIMIT 5000
                                    ];
        
        //get the value for the option
        Map<Id,String> MapModelId_ModelName = new Map<Id,String>();
        for(Model_Color_Trim_Master__c fVM: ListModelColorTrimMaster) {
            if( String.isNotBlank(fvM.Model_Code__c) ) {
                MapModelId_ModelName.put( fvM.Model_Code__c, fVM.Model_Code__r.Model_Description__c );
            }            
        }

        ListOptions_Model = new List<SelectOption>();
        for(Id fId: MapModelId_ModelName.KeySet()) {
            ListOptions_Model.add(new SelectOption(fId, MapModelId_ModelName.get(fId)));
        }
        if(ListOptions_Model.size()>0){
            selectedModel = ListOptions_Model[0].getValue();
        }
        else{
            showError = true;
        }
        ListOptions_Color = new List<SelectOption>();
        ListOptions_Trim = new List<SelectOption>();
        //end option value

        refresh_VehicleMaster();


        ListReservation = new List<Stock_Reservation__c>();
        ListReservation = [SELECT Id, Name, Stock_Source__c, Agreement_No__c, Cancellation_Reason__c, Customer_Mobile_Number__c, Customer_Name__c, Customer_Social_ID__c, Downpayment_No__c,
                                Employee_Reassign_Code__c, Reservation_Date__c, Comment__c, Reservation_Status__c, Vehicle_Master__c,
                                Color_Code__c, Color_Code__r.Color_Description__c, Model_Code__c, Model_Code__r.Model_Description__c, Model_Year_Code__c, Model_Year_Code__r.Model_Year__c,
                                Trim_Code__c, Trim_Code__r.Trim_Description__c, CreatedDate, Vehicle_Condition__c, Vehicle_Location__c
                           FROM Stock_Reservation__c
                           WHERE OwnerId = :SalesUser.Id
                           AND (Reservation_Status__c = 'Reserve' OR Reservation_Status__c = 'Indent')
                           ORDER BY Reservation_Date__c];

        //show quantity as available or {n}
        //if less than threshold show as {n}
        //if more or equal show as 'Available'
        Threshold = 5;
        List<Custom_Parameter__c> ListCustomParameter = new List<Custom_Parameter__c>();
        ListCustomParameter = [SELECT Id, Value__c
                               FROM Custom_Parameter__c
                               WHERE Branch_Code__c = :SalesUser.Branch_Code__c
                               AND Franchise_Code__c = :SalesUser.Franchise_Code__c
                               AND Type__c = 'SR_MIN_QTY'];
        if( ListCustomParameter.size() > 0 && ListCustomParameter[0].Value__c <> null ) {
            Threshold = Integer.ValueOf(ListCustomParameter[0].Value__c);
        }
        refresh_Color_Trim_Option();
    }

    public void refresh_VehicleMaster() {
        //list vehicle based on each type: Promotion Stock, Existing Stock, Incoming Stock, Stock To Indent
        //and then remove the set indent
        MapModel_VM_PromotionStock = new Map<String, Vehicle_Master2__c>();
        MapModel_VM_IncomingStock  = new Map<String, Vehicle_Master2__c>();
        MapModel_VM_ExistingStock  = new Map<String, Vehicle_Master2__c>();
        MapModel_VM_IndentStock    = new Map<String, Vehicle_Master2__c>();

        MapModel_Qty_PromotionStock = new Map<String, Integer>();
        MapModel_Qty_IncomingStock  = new Map<String, Integer>();
        MapModel_Qty_ExistingStock  = new Map<String, Integer>();
        MapModel_Qty_IndentStock    = new Map<String, Integer>();

        //get comment the promotion stock to put it as remarks
        Set<Id> SetVehicleMasterIds = new Set<Id>();
        MapVehicleMasterId_Comment  = new Map<Id,String>();

        //add by taufik 18 may 2016 to only include 'ADD' promo stock only
        Set<Id> SetPromoIds = new Set<Id>();
        for(Stock_Promotion__c lSP: [SELECT Stock_Vehicle_Master__c
                                     FROM Stock_Promotion__c
                                     WHERE Stock_Promotion_Status__c='ADD'])
        {
            SetPromoIds.Add(lSP.Stock_Vehicle_Master__c);
        }

        for(Vehicle_Master2__c fVM: [SELECT Id, Name, Vehicle_Type_For_Sale__c, Color_Code__c, Color_Code__r.Color_Description__c,
                                        Trim_Code__c, Trim_Code__r.Trim_Description__c, Model_Code__c, Model_Code__r.Model_Description__c,
                                        Model_Year_Code__c, Model_Year_Code__r.Model_Year__c,Dummy_Model__c, Reservation_No__c,
                                        Production_Month__c, Remarks__c, LastModifiedDate, Vehicle_Condition__c, Location__c, Mileage__c
                                     FROM Vehicle_Master2__c
                                     WHERE Exclude_Flag__c = FALSE
                                     AND Reserve_Flag__c = FALSE
                                     AND Franchise_Code__c = :SalesUser.Franchise_Code__c
                                     AND Branch_Code__c = :SalesUser.Branch_Code__c
                                     AND Vehicle_Type_For_Sale__c <> ''
                                     ORDER BY Model_Code__r.Model_Description__c, Color_Code__r.Color_Description__c, Trim_Code__r.Trim_Description__c, ProductionMonth__c, Original_Commcase__c])
        {
            String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);
            if(fVM.Vehicle_Type_For_Sale__c=='Promotional Stock') {
                if (SetPromoIds.contains(fVM.id)==true){
                    tempSS=fVM.Id; //add 1 line code for display promo as 1 record only 1st july 2016 by tvx
                    if(MapModel_VM_PromotionStock.get(tempSS)==NULL) {
                        MapModel_VM_PromotionStock.put(tempSS, fVM);
                        SetVehicleMasterIds.Add(fVM.Id);
                        MapVehicleMasterId_Comment.put(fVM.Id, '');
                    }
                    if(MapModel_Qty_PromotionStock.get(tempSS)<>NULL || MapModel_Qty_PromotionStock.containsKey(tempSS)) {
                        Integer i = MapModel_Qty_PromotionStock.get(tempSS) + 1;
                        MapModel_Qty_PromotionStock.put(tempSS, i);
                    } 
                    else {
                        MapModel_Qty_PromotionStock.put(tempSS, 1);
                    }
                }
            }

            if(fVM.Vehicle_Type_For_Sale__c=='Incoming Stock') {
                if(MapModel_VM_IncomingStock.get(tempSS)==NULL) {
                    MapModel_VM_IncomingStock.put(tempSS, fVM);
                    SetVehicleMasterIds.Add(fVM.Id);
                    MapVehicleMasterId_Comment.put(fVM.Id, '');
                }
                if(MapModel_Qty_IncomingStock.get(tempSS)<>NULL || MapModel_Qty_IncomingStock.containsKey(tempSS)) {
                    Integer i = MapModel_Qty_IncomingStock.get(tempSS) + 1;
                    MapModel_Qty_IncomingStock.put(tempSS, i);
                }
                else {
                    MapModel_Qty_IncomingStock.put(tempSS, 1);
                }
            }

            if(fVM.Vehicle_Type_For_Sale__c=='Existing Stock') {
                if(MapModel_VM_ExistingStock.get(tempSS)==NULL) {
                    MapModel_VM_ExistingStock.put(tempSS, fVM);
                    SetVehicleMasterIds.Add(fVM.Id);
                    MapVehicleMasterId_Comment.put(fVM.Id, '');
                }
                if(MapModel_Qty_ExistingStock.get(tempSS)<>NULL || MapModel_Qty_ExistingStock.containsKey(tempSS)) {
                    Integer i = MapModel_Qty_ExistingStock.get(tempSS) + 1;
                    MapModel_Qty_ExistingStock.put(tempSS, i);
                }
                else {
                    MapModel_Qty_ExistingStock.put(tempSS, 1);
                }
            }
        }

        //get comment the promotion stock to put it as remarks
        for(Stock_Promotion__c fSP: [SELECT Comment__c, Stock_Promotion_Status__c, Stock_Vehicle_Master__c
                                     FROM Stock_Promotion__c
                                     WHERE Stock_Vehicle_Master__c in :SetVehicleMasterIds
                                     AND Stock_Promotion_Status__c='ADD']){
            MapVehicleMasterId_Comment.put(fSP.Stock_Vehicle_Master__c, fSP.Comment__c);
        }

        Map<Id,Model_Year_Master__c> MapModelYearId_ModelYear = new Map<Id,Model_Year_Master__c>();
        List<Model_Year_Master__c> ListModelYear = new List<Model_Year_Master__c>();
        ListModelYear = [SELECT Id, Model_Master__c, Model_Year__c, ModelYear__c
                         FROM Model_Year_Master__c
                         WHERE Franchise_Code__c = :SalesUser.Franchise_Code__c
                         AND Branch_Code__c = :SalesUser.Branch_Code__c
                         AND Active__c = TRUE
                         ORDER BY ModelYear__c];
        for(Model_Year_Master__c fModelYear: ListModelYear) {
            MapModelYearId_ModelYear.put(fModelYear.Model_Master__c, NULL);
        }

        for(Model_Year_Master__c fModelYear: ListModelYear) {
            MapModelYearId_ModelYear.Put(fModelYear.Model_Master__c, fModelYear);
        }

        for(Model_Color_Trim_Master__c fMCT: [SELECT Id, Model_Code__c, Model_Code__r.Model_Description__c, Color_Code__c, Color_Code__r.Color_Description__c, 
                                                    Trim_Code__c, Trim_Code__r.Trim_Description__c
                                              FROM Model_Color_Trim_Master__c
                                              WHERE Active__c = true
                                              AND Franchise_Code__c = :SalesUser.Franchise_Code__c
                                              AND Branch_Code__c = :SalesUser.Branch_Code__c
                                              ORDER BY Model_Code__r.Model_Description__c, Color_Code__r.Color_Description__c, Trim_Code__r.Trim_Description__c])
        {
            Model_Year_Master__c tempModelYear = new Model_Year_Master__c();
            if( MapModelYearId_ModelYear.get(fMCT.Model_Code__c) <> null ) 
            {
                tempModelYear = MapModelYearId_ModelYear.get(fMCT.Model_Code__c);

                Vehicle_Master2__c tempVM = new Vehicle_Master2__c();
                tempVM.Remarks__c         = 'Stock To Indent';
                tempVM.Color_Code__c      = fMCT.Color_Code__c;
                tempVM.Trim_Code__c       = fMCT.Trim_Code__c;
                tempVM.Model_Code__c      = fMCT.Model_Code__c;
                tempVM.Model_Year_Code__c = tempModelYear.Id;
                tempVM.Dummy_Color__c     = fMCT.Color_Code__r.Color_Description__c;
                tempVM.Dummy_Trim__c      = fMCT.Trim_Code__r.Trim_Description__c;
                tempVM.Dummy_Model__c     = fMCT.Model_Code__r.Model_Description__c;
                Date yyyy = tempModelYear.ModelYear__c;
                tempVM.Dummy_Year__c = String.ValueOf(yyyy.Year());

                String tempSS = String.ValueOf(fMCT.Model_Code__c) + String.ValueOf(fMCT.Color_Code__c) + String.ValueOf(fMCT.Trim_Code__c);
                MapModel_VM_IndentStock.put(tempSS, tempVM);
                MapModel_Qty_IndentStock.put(tempSS, 1);
            }
        }
        ListwrapperPromotionStock = new List<wStock>();
        ListwrapperExistingStock = new List<wStock>();
        ListwrapperIncomingStock = new List<wStock>();
        ListwrapperStock2Indent = new List<wStock>();
    }

    public void refresh_Color_Trim_Option() {
        Map<Id,String> MapColorId_ColorName = new Map<Id,String>();
        Map<Id,String> MapTrimId_TrimName = new Map<Id,String>();
        for(Model_Color_Trim_Master__c fVM: ListModelColorTrimMaster) {
            if(fVM.Model_Code__c==selectedModel) {
                MapColorId_ColorName.put(fvM.Color_Code__c, fVM.Color_Code__r.Color_Description__c);
                MapTrimId_TrimName.put(fvM.Trim_Code__c, fVM.Trim_Code__r.Trim_Description__c);
            }
        }
        ListOptions_Color = new List<SelectOption>();
        ListOptions_Color.add(new SelectOption('',''));
        for(Id fId: MapColorId_ColorName.KeySet()) {
            ListOptions_Color.add(new SelectOption(fId, MapColorId_ColorName.get(fId)));
        }
        ListOptions_Trim = new List<SelectOption>();
        ListOptions_Trim.add(new SelectOption('',''));
        for(Id fId: MapTrimId_TrimName.KeySet()) {
            ListOptions_Trim.add(new SelectOption(fId, MapTrimId_TrimName.get(fId)));
        }
    }

    public void refresh_Color_Option() {
        if(selectedTrim<>NULL) {
            Map<Id,String> MapColorId_ColorName = new Map<Id,String>();
            for(Model_Color_Trim_Master__c fVM: ListModelColorTrimMaster) {
                if(fVM.Model_Code__c==selectedModel && fVM.Trim_Code__c==selectedTrim) MapColorId_ColorName.put(fvM.Color_Code__c, fVM.Color_Code__r.Color_Description__c);
            }

            ListOptions_Color = new List<SelectOption>();
            ListOptions_Color.add(new SelectOption('',''));
            for(Id fId: MapColorId_ColorName.KeySet()) {
                ListOptions_Color.add(new SelectOption(fId, MapColorId_ColorName.get(fId)));
            }
        }
    }

    public void refresh_Trim_Option() {
        if(selectedColor<>NULL) {
            Map<Id,String> MapTrimId_TrimName = new Map<Id,String>();
            for(Model_Color_Trim_Master__c fVM: ListModelColorTrimMaster) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor){
                    MapTrimId_TrimName.put(fvM.Trim_Code__c, fVM.Trim_Code__r.Trim_Description__c);
                }
            }

            ListOptions_Trim = new List<SelectOption>();
            ListOptions_Trim.add(new SelectOption('',''));
            for(Id fId: MapTrimId_TrimName.KeySet()) {
                ListOptions_Trim.add(new SelectOption(fId, MapTrimId_TrimName.get(fId)));
            }
        }
    }

    public void SearchVehicle() {
        refresh_VehicleMaster();

        ListwrapperPromotionStock = new List<wStock>();
        ListwrapperExistingStock = new List<wStock>();
        ListwrapperIncomingStock = new List<wStock>();
        ListwrapperStock2Indent = new List<wStock>();
        Integer incID = 0;
        /*
        PS=Promotion
        ES=Existing
        IS=Incoming
        SI=StockIndent
        reason why i not put the wID in the long structure (like: Vehicle_Type_For_Sale__c + tempSS +  incID)
        because, it will be hard to do searching after user select the list (to get the id of vehicle2 master)
        */
        if(selectedModel==NULL && selectedColor==NULL && selectedTrim==NULL) {
            for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                String tempQTY = '';
                if(MapModel_Qty_PromotionStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_PromotionStock.get(tempSS)) + '</font>';

                ListwrapperPromotionStock.Add(new wStock('PS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, MapVehicleMasterId_Comment.get(fVM.Id), fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                incID++;
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                String tempQTY = '';
                if(MapModel_Qty_ExistingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_ExistingStock.get(tempSS)) + '</font>';

                ListwrapperExistingStock.Add(new wStock('ES'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                incID++;
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                String tempQTY = '';
                if(MapModel_Qty_IncomingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IncomingStock.get(tempSS)) + '</font>';

                ListwrapperIncomingStock.Add(new wStock('IS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                incID++;
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                String tempQTY = '';
                if(MapModel_Qty_IndentStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IndentStock.get(tempSS)) + '</font>';

                ListwrapperStock2Indent.Add(new wStock('SI'+String.ValueOf(incID),incID, fVM.Dummy_Model__c, fVM.Dummy_Color__c, fVM.Dummy_Trim__c, fVM.Dummy_Year__c, tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                incID++;
            }
        }
        else if(selectedModel<>NULL && selectedColor==NULL && selectedTrim==NULL) {
            for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                if(fVM.Model_Code__c==selectedModel) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_PromotionStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_PromotionStock.get(tempSS)) + '</font>';

                    ListwrapperPromotionStock.Add(new wStock('PS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, MapVehicleMasterId_Comment.get(fVM.Id), fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_ExistingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_ExistingStock.get(tempSS)) + '</font>';

                    ListwrapperExistingStock.Add(new wStock('ES'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IncomingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IncomingStock.get(tempSS)) + '</font>';

                    ListwrapperIncomingStock.Add(new wStock('IS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                if(fVM.Model_Code__c==selectedModel) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IndentStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IndentStock.get(tempSS)) + '</font>';

                    ListwrapperStock2Indent.Add(new wStock('SI'+String.ValueOf(incID),incID, fVM.Dummy_Model__c, fVM.Dummy_Color__c, fVM.Dummy_Trim__c, fVM.Dummy_Year__c, tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
        }
        else if(selectedModel<>NULL && selectedColor<>NULL && selectedTrim==NULL) {
            for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_PromotionStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_PromotionStock.get(tempSS)) + '</font>';

                    ListwrapperPromotionStock.Add(new wStock('PS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, MapVehicleMasterId_Comment.get(fVM.Id), fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_ExistingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_ExistingStock.get(tempSS)) + '</font>';

                    ListwrapperExistingStock.Add(new wStock('ES'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IncomingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IncomingStock.get(tempSS)) + '</font>';

                    ListwrapperIncomingStock.Add(new wStock('IS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IndentStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IndentStock.get(tempSS)) + '</font>';

                    ListwrapperStock2Indent.Add(new wStock('SI'+String.ValueOf(incID),incID, fVM.Dummy_Model__c, fVM.Dummy_Color__c, fVM.Dummy_Trim__c, fVM.Dummy_Year__c, tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
        }
        else if(selectedModel<>NULL && selectedColor==NULL && selectedTrim<>NULL) {
            for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_PromotionStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_PromotionStock.get(tempSS)) + '</font>';

                    ListwrapperPromotionStock.Add(new wStock('PS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, MapVehicleMasterId_Comment.get(fVM.Id), fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_ExistingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_ExistingStock.get(tempSS)) + '</font>';

                    ListwrapperExistingStock.Add(new wStock('ES'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IncomingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IncomingStock.get(tempSS)) + '</font>';

                    ListwrapperIncomingStock.Add(new wStock('IS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IndentStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IndentStock.get(tempSS)) + '</font>';

                    ListwrapperStock2Indent.Add(new wStock('SI'+String.ValueOf(incID),incID, fVM.Dummy_Model__c, fVM.Dummy_Color__c, fVM.Dummy_Trim__c, fVM.Dummy_Year__c, tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
        }
        else if(selectedModel<>NULL && selectedColor<>NULL && selectedTrim<>NULL) {
            for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_PromotionStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_PromotionStock.get(tempSS)) + '</font>';

                    ListwrapperPromotionStock.Add(new wStock('PS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, MapVehicleMasterId_Comment.get(fVM.Id), fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_ExistingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_ExistingStock.get(tempSS)) + '</font>';

                    ListwrapperExistingStock.Add(new wStock('ES'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IncomingStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IncomingStock.get(tempSS)) + '</font>';

                    ListwrapperIncomingStock.Add(new wStock('IS'+String.ValueOf(incID),incID, fVM.Model_Code__r.Model_Description__c, fVM.Color_Code__r.Color_Description__c, fVM.Trim_Code__r.Trim_Description__c, String.ValueOf(fVM.Model_Year_Code__r.Model_Year__c), tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
            for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                if(fVM.Model_Code__c==selectedModel && fVM.Color_Code__c==selectedColor && fVM.Trim_Code__c==selectedTrim) {
                    String tempSS = String.ValueOf(fVM.Model_Year_Code__c) + String.ValueOf(fVM.Color_Code__c) + String.ValueOf(fVM.Trim_Code__c);

                    String tempQTY = '';
                    if(MapModel_Qty_IndentStock.get(tempSS)>=Threshold) tempQTY = 'Available';
                    else tempQTY = '<font color="red">' + String.ValueOf(MapModel_Qty_IndentStock.get(tempSS)) + '</font>';

                    ListwrapperStock2Indent.Add(new wStock('SI'+String.ValueOf(incID),incID, fVM.Dummy_Model__c, fVM.Dummy_Color__c, fVM.Dummy_Trim__c, fVM.Dummy_Year__c, tempQTY, fVM.Production_Month__c, fVM.Remarks__c, fVM.Model_Year_Code__c, fVM.Color_Code__c, fVM.Trim_Code__c, fVM.id));
                    incID++;
                }
            }
        }
    }

    public void ClearParameter() {
        ListOptions_Color = new List<SelectOption>();
        ListOptions_Trim = new List<SelectOption>();

        selectedModel = ListOptions_Model[0].getValue();
        refresh_Color_Trim_Option();
        selectedColor = '';
        selectedTrim  = '';
    }

    public void AddReservation() {
        showPage = 2;
        //1. check the wID if it's promotion, existing, incoming or stock indent
        //2. get the year model, color, trim of selected list
        //3. now you have the (2) & (1)
        //4. go seach on the map based from those 2 things (2) & (1)
        ID tempModelID = null;
        ID tempModelYearID = null;
        ID tempColorID = null;
        ID tempTrimID = null;
        String tempStatus = '';

        Reservation = new Stock_Reservation__c();
        VehicleMaster = new Vehicle_Master2__c();

        if(ReserveSelectedVehicle.Left(2)=='PS') { //PS=Promotion
            for(wStock fWStock: ListwrapperPromotionStock) {
                if(fWStock.wID==ReserveSelectedVehicle) {
                    tempModelYearID = fWStock.ModelYearID;
                    tempColorID = fWStock.ColorID;
                    tempTrimID = fWStock.TrimID;

                    for(Vehicle_Master2__c fVM: MapModel_VM_PromotionStock.Values()) {
                        if (fWStock.VMID == fVM.id){
                            VehicleMaster = fVM;
                            VehicleMaster.Remarks__c = MapVehicleMasterId_Comment.get(fVM.Id);

                            Reservation.Model_Code__c = fVM.Model_Code__c;
                            Reservation.Model_Year_Code__c = fVM.Model_Year_Code__c;
                            Reservation.Color_Code__c = fVM.Color_Code__c;
                            Reservation.Trim_Code__c = fVM.Trim_Code__c;
                            Reservation.Reservation_Date__c = Date.Today();
                            Reservation.Reservation_Status__c = 'Reserve';
                            Reservation.Employee_Reassign_Code__c = SalesUser.Id;
                            Reservation.Branch_Code__c = SalesUser.Branch_Code__c;
                            Reservation.Franchise_Code__c = SalesUser.Franchise_Code__c;
                            Reservation.Vehicle_Master__c = fVM.Id;
                            break;
                        }
                    }
                    break;
                }
            }
        }
        else if(ReserveSelectedVehicle.Left(2)=='ES') { //ES=Existing
            for(wStock fWStock: ListwrapperExistingStock) {
                if(fWStock.wID==ReserveSelectedVehicle) {
                    tempModelYearID = fWStock.ModelYearID;
                    tempColorID = fWStock.ColorID;
                    tempTrimID = fWStock.TrimID;

                    for(Vehicle_Master2__c fVM: MapModel_VM_ExistingStock.Values()) {
                        if(fVM.Model_Year_Code__c == tempModelYearID && fVM.Color_Code__c == tempColorID && fVM.Trim_Code__c== tempTrimID) {
                            VehicleMaster = fVM;
                            Reservation.Model_Code__c = fVM.Model_Code__c;
                            Reservation.Model_Year_Code__c = fVM.Model_Year_Code__c;
                            Reservation.Color_Code__c = fVM.Color_Code__c;
                            Reservation.Trim_Code__c = fVM.Trim_Code__c;
                            Reservation.Reservation_Date__c = Date.Today();
                            Reservation.Reservation_Status__c = 'Reserve';
                            Reservation.Employee_Reassign_Code__c = SalesUser.Id;
                            Reservation.Branch_Code__c = SalesUser.Branch_Code__c;
                            Reservation.Franchise_Code__c = SalesUser.Franchise_Code__c;
                            Reservation.Vehicle_Master__c = fVM.Id;
                            break;
                        }
                    }
                    break;
                }
            }
        }
        else if(ReserveSelectedVehicle.Left(2)=='IS') { //IS=Incoming
            for(wStock fWStock: ListwrapperIncomingStock) {
                if(fWStock.wID==ReserveSelectedVehicle) {
                    tempModelYearID = fWStock.ModelYearID;
                    tempColorID = fWStock.ColorID;
                    tempTrimID = fWStock.TrimID;

                    for(Vehicle_Master2__c fVM: MapModel_VM_IncomingStock.Values()) {
                        if(fVM.Model_Year_Code__c == tempModelYearID && fVM.Color_Code__c == tempColorID && fVM.Trim_Code__c== tempTrimID) {
                            VehicleMaster = fVM;
                            Reservation.Model_Code__c = fVM.Model_Code__c;
                            Reservation.Model_Year_Code__c = fVM.Model_Year_Code__c;
                            Reservation.Color_Code__c = fVM.Color_Code__c;
                            Reservation.Trim_Code__c = fVM.Trim_Code__c;
                            Reservation.Reservation_Date__c = Date.Today();
                            Reservation.Reservation_Status__c = 'Reserve';
                            Reservation.Employee_Reassign_Code__c = SalesUser.Id;
                            Reservation.Branch_Code__c = SalesUser.Branch_Code__c;
                            Reservation.Franchise_Code__c = SalesUser.Franchise_Code__c;
                            Reservation.Vehicle_Master__c = fVM.Id;
                            break;
                        }
                    }
                    break;
                }
            }
        }
        else if(ReserveSelectedVehicle.Left(2)=='SI') { //SI=StockIndent
            tempStatus = 'Stock To Indent';
            //get the year model, color, trim of selected list
            for(wStock fWStock: ListwrapperStock2Indent) {
                if(fWStock.wID==ReserveSelectedVehicle) {
                    tempModelYearID = fWStock.ModelYearID;
                    tempColorID = fWStock.ColorID;
                    tempTrimID = fWStock.TrimID;
                    for(Vehicle_Master2__c fVM: MapModel_VM_IndentStock.Values()) {
                        if(fVM.Model_Year_Code__c == tempModelYearID && fVM.Color_Code__c == tempColorID && fVM.Trim_Code__c== tempTrimID) {
                            VehicleMaster = fVM;
                            Reservation.Model_Code__c = fVM.Model_Code__c;
                            Reservation.Model_Year_Code__c = fVM.Model_Year_Code__c;
                            Reservation.Color_Code__c = fVM.Color_Code__c;
                            Reservation.Trim_Code__c = fVM.Trim_Code__c;
                            Reservation.Reservation_Date__c = Date.Today();
                            Reservation.Reservation_Status__c = 'Indent';
                            Reservation.Employee_Reassign_Code__c = SalesUser.Id;
                            Reservation.Branch_Code__c = SalesUser.Branch_Code__c;
                            Reservation.Franchise_Code__c = SalesUser.Franchise_Code__c;
                            Reservation.Vehicle_Master__c = fVM.Id;
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }

    public void enableNRIC()
    {
        callfunc    = '';
        showPopUp   = true;
        NRICErr     = '';
        NRICSuccess = '';
        //Updated get NRIC from Stock Reservation itself
        Stock_Reservation__c str = [SELECT Id, Customer_Social_ID__c 
                                    FROM Stock_Reservation__c
                                    WHERE Id =: ReservationId 
                                    AND (Opportunity__r.Contact_Person__c != null OR Opportunity__r.Account__c != null)];
        if( str != null )
        {
            nricfield = str.Customer_Social_ID__c;
        }
    }

    public PageReference navigateToDSA(){
        PageReference pageRef= new PageReference('/c/DSA_DigitalSalesAgreementApp.app');
        pageRef.getParameters().put('recordID', ReservationId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void hidePopUp(){
        showPopUp = false;
    }

    public void updateNRIC(){
        NRICErr = '';
        try
        {
            if( String.isNotBlank(nricfield) ){
                //verify NRIC
                System.debug('nricfield: ' + nricfield);
                
                String nricRegex = '^[STFG]\\d{7}[A-Z]$';
                
                Pattern pt =  Pattern.compile( nricRegex );
                System.debug(pt.matcher(nricfield).matches());

                if(pt.matcher(nricfield).matches())
                {
                    //update the Stock Reservation record NRIC
                    //get Opportunity Owner
                    Stock_Reservation__c sr = [SELECT Id,
                                                    Opportunity__r.Owner.Username2__c,
                                                    Opportunity__r.Account__c,
                                                    Opportunity__r.Account__r.RecordTypeId,
                                                    Customer_Social_ID__c
                                               FROM Stock_Reservation__c
                                               WHERE Id =: ReservationId
                                               AND (Opportunity__r.Contact_Person__c != null OR Opportunity__r.Account__c != null)
                                               LIMIT 1];
                    if( sr != null ){
                        sr.Customer_Social_ID__c = nricfield;
                        update sr;

                        if(sr.Opportunity__r.Account__c != null && AccountUtil.isProspect(sr.Opportunity__r.Account__r.RecordTypeId, null) )
                        {
                            if(String.isNotBlank(sr.Customer_Social_ID__c) && sr.Customer_Social_ID__c.length() > 4){
                                String newNRIC,nricVal;
                                nricVal = sr.Customer_Social_ID__c;
                                Account personAccount = [SELECT Id, PersonBirthdate, NRIC__pc, NRIC_Passport_No__pc FROM Account WHERE Id = :sr.Opportunity__r.Account__c];
                                if(personAccount.PersonBirthdate != null){
                                    Date cusDOB = personAccount.PersonBirthdate;
                                    String dob  = Datetime.newInstance(cusDOB.year(), cusDOB.month(),cusDOB.day()).format('dd/MM/YYYY');
                                    newNRIC     = nricVal.substring(nricVal.length()-4,nricVal.length()) + Dob.replaceAll('/', '');
                                }
                                else{
                                    newNRIC = nricVal.substring(nricVal.length()-4,nricVal.length());
                                }

                                Database.update( new Account(Id = sr.Opportunity__r.Account__c, NRIC__pc = newNRIC),false);
                            }
                        }

                        NRICSuccess = 'NRIC updated Successfully!';
                        callfunc    = '<script> CloseAndReWfresh(); </script>';
                        BusinessRuleHandlerVSMS.updateStocKVSMS( ReservationId, sr.Opportunity__r.Owner.Username2__c, true );
                    }
                }
                else{
                    NRICErr = 'Please enter a valid NRIC value.';
                }
            }
            else{
                NRICErr = 'Please enter an NRIC value.';
            }
        }
        catch(Exception e){
            NRICErr = e.getmessage();
        }
    }
    
    public void cancelNRIC(){
        showPopUp = false;
    }

    public void Reservation_Cancellation() {
        showPage = 3;

        Reservation = new Stock_Reservation__c();
        VehicleMaster = new Vehicle_Master2__c();
        for(Stock_Reservation__c fSR: ListReservation) {

            if(fSR.Id == ReservationId) {
                Reservation = fSR;
                Reservation.Reservation_Status__c = 'Cancel';
                if(fSR.Vehicle_Master__c<>NULL) {
                    VehicleMaster = [SELECT Id, Name, Vehicle_Type_For_Sale__c, Color_Code__c, Color_Code__r.Color_Description__c,
                                        Trim_Code__c, Trim_Code__r.Trim_Description__c, Model_Code__c, Model_Code__r.Model_Description__c,
                                        Model_Year_Code__c, Model_Year_Code__r.Model_Year__c,Dummy_Model__c, Reservation_No__c,
                                        Production_Month__c, Remarks__c, LastModifiedDate,Branch_Code__c,Franchise_Code__c
                                     FROM Vehicle_Master2__c
                                     WHERE Id = :fSR.Vehicle_Master__c LIMIT 1];
                } 
                else {
                    String ss = String.ValueOf(Reservation.Model_Year_Code__c) + String.ValueOf(Reservation.Color_Code__c) + String.ValueOf(Reservation.Trim_Code__c);
                    VehicleMaster = MapModel_VM_IndentStock.get(ss);
                }
            }
        }
    }

    public void SaveReservation() 
    {
        String Vehicle_Type_For_Sale='Stock To Indent';
        if(ReserveSelectedVehicle.Left(2)=='PS') Vehicle_Type_For_Sale='Promotional Stock';
        if(ReserveSelectedVehicle.Left(2)=='ES') Vehicle_Type_For_Sale='Existing Stock';
        if(ReserveSelectedVehicle.Left(2)=='IS') Vehicle_Type_For_Sale='Incoming Stock';
        List<Vehicle_Master2__c> lstVehicleMaster2 = new List<Vehicle_Master2__c>();
        Boolean stockIsEmpty = false;
        Boolean continueProcess = true;

        if( Reservation.Reservation_Status__c <> 'Indent' ) 
        {
            //Search vehicle, check if it the same (also adding for update)
            //if it same then carry on the process
            //if not then query the new vehicle then put it inside temp vehicle master
            //       then let user click submit again.

            lstVehicleMaster2 = [SELECT Id, Name, Vehicle_Type_For_Sale__c, Color_Code__c, Color_Code__r.Color_Description__c,
                                        Trim_Code__c, Trim_Code__r.Trim_Description__c, Model_Code__c, Model_Code__r.Model_Description__c,
                                        Model_Year_Code__c, Model_Year_Code__r.Model_Year__c,Dummy_Model__c, Reservation_No__c,
                                        Production_Month__c, Remarks__c, LastModifiedDate,Branch_Code__c,Franchise_Code__c
                                 FROM Vehicle_Master2__c
                                 WHERE Id = :VehicleMaster.Id FOR UPDATE];

            if( lstVehicleMaster2.size() > 0 ) {
                if( lstVehicleMaster2[0].LastModifiedDate == VehicleMaster.LastModifiedDate ) {
                    continueProcess = true;
                } 
                else {
                    continueProcess = false;
                }
            } 
            else {
                continueProcess = false;
            }

            if( continueProcess == false ) {
                lstVehicleMaster2 = new List<Vehicle_Master2__c>();
                lstVehicleMaster2 = [SELECT Id, Name, Vehicle_Type_For_Sale__c, Color_Code__c, Color_Code__r.Color_Description__c,
                                         Trim_Code__c, Trim_Code__r.Trim_Description__c, Model_Code__c, Model_Code__r.Model_Description__c,
                                         Model_Year_Code__c, Model_Year_Code__r.Model_Year__c,Dummy_Model__c,
                                         Production_Month__c, Remarks__c, LastModifiedDate,Branch_Code__c,Franchise_Code__c
                                     FROM Vehicle_Master2__c
                                     WHERE Exclude_Flag__c = false
                                     AND Reserve_Flag__c = false
                                     AND Franchise_Code__c = :SalesUser.Franchise_Code__c
                                     AND Branch_Code__c = :SalesUser.Branch_Code__c
                                     AND Model_Code__c = :VehicleMaster.Model_Code__c
                                     AND Color_Code__c = :VehicleMaster.Color_Code__c
                                     AND Trim_Code__c = :VehicleMaster.Trim_Code__c
                                     AND Model_Year_Code__c = :VehicleMaster.Model_Year_Code__c
                                     AND Vehicle_Type_For_Sale__c = :Vehicle_Type_For_Sale
                                     ORDER BY Model_Code__r.Model_Description__c, Color_Code__r.Color_Description__c, Trim_Code__r.Trim_Description__c, ProductionMonth__c, Original_Commcase__c];

                if( lstVehicleMaster2.size() > 0 ) {
                    VehicleMaster     = new Vehicle_Master2__c();
                    VehicleMaster     = lstVehicleMaster2[0];
                    lstVehicleMaster2 = new List<Vehicle_Master2__c>();
                    stockIsEmpty      = false;
                } 
                else {
                    stockIsEmpty = true;
                }
            }
        }

        if( Reservation.Reservation_Status__c == 'Indent' || continueProcess ) 
        {
            //create contact if not exist
            //give share permission if contact.owner <> salesPerson.Id
            if (Reservation.Reservation_Status__c != 'Indent' )
            {
                Reservation.Vehicle_Master__c = VehicleMaster.Id;
            }

            Contact tempCon = new Contact();
            Account newProspect = new Account();
            Account personAccount = new Account();

            System.debug('Testing StockRESV - ' + listExistingAccount );
            if( listExistingAccount.size() > 0 )
            {
                personAccount.Id = listExistingAccount.get(0).Id;
                personAccount.Full_Name__pc = Reservation.Customer_Name__c;
                personAccount.FirstName     = custFirstName;
                personAccount.LastName      = custLastName;

                if(Reservation.Customer_Mobile_Number__c.length() <= 8)
                {
                    personAccount.PersonMobilePhone = '65'+Reservation.Customer_Mobile_Number__c;
                } 
                else 
                {
                    personAccount.PersonMobilePhone = Reservation.Customer_Mobile_Number__c;
                }
                
                if(String.isBlank(personAccount.NRIC_Passport_No__pc))
                {
                    if(String.isNotBlank(Reservation.Customer_Social_ID__c))
                    {
                        
                        // String newNRIC, nricVal;
                        // nricVal     = Reservation.Customer_Social_ID__c;
                        // Date cusDOB = custBirthDate;
                        // String dob  = Datetime.newInstance(cusDOB.year(), cusDOB.month(),cusDOB.day()).format('dd/MM/YYYY');

                        // if (Reservation.Customer_Social_ID__c.length() > 4 && Reservation.Customer_Social_ID__c.length() == 9) {
                        //     newNRIC = nricVal.substring(nricVal.length()-4, nricVal.length()) + Dob.replaceAll('/', '');
                        // } else if (Reservation.Customer_Social_ID__c.length() == 12) {
                        //     newNRIC = nricVal.substring(0, 4) + Dob.replaceAll('/', '');
                        // }

                        // personAccount.NRIC_Passport_No__pc = Reservation.Customer_Social_ID__c.subString(5);

                        // Modified by Vu 06/07/2022 - Change format for NRIC_Passport_No__pc field value
                        System.debug('ID:' + Reservation.Customer_Social_ID__c + 'DOB: ' + custBirthDate);
                        personAccount.NRIC_Passport_No__pc = formatNRIC(Reservation.Customer_Social_ID__c, custBirthDate);
                    }
                }

                if (personAccount.NRIC_Passport_No__pc != null && personAccount.NRIC_Passport_No__pc != '')
                {
                    personAccount.PersonEmail = Reservation.Customer_Email__c;
                }

                /** ADDED BY TPHAN ON 03/06/2021 */
                // if (String.isBlank(listExistingAccount.get(0).Drive_Customer_ID__c))
                // {
                //     if (!Test.isRunningTest())
                //     {
                //         String customerID = getDriveCustomerID();

                //         if (String.isNotBlank(customerID))
                //         {
                //             personAccount.Drive_Customer_ID__c = customerID;
                //         }
                //         else
                //         {
                //             personAccount.Pending_Drive_Sync__c = true;
                //         }
                //     }
                // }
                /**          END                 */

                personAccount.PersonBirthdate = custBirthDate;                     // Added by Vu 06/07/2022 - Store value from Date of birth input

                update personAccount;
                
            } else {
                newProspect = new Account(); 
                newProspect.RecordTypeId = AccountUtil.getProspectRecordTypeId();

                if( String.isNotBlank(Reservation.Customer_Social_ID__c) && Reservation.Customer_Social_ID__c.length() > 4 ){
                    Integer nricLen  = Reservation.Customer_Social_ID__c.length();
                    newProspect.NRIC__pc = Reservation.Customer_Social_ID__c.subString( 5 ); 
                }

                newProspect.Full_Name__pc = Reservation.Customer_Name__c;
                newProspect.FirstName     = custFirstName;
                newProspect.LastName      = custLastName;

                if(Reservation.Customer_Mobile_Number__c.length()<=8){
                    newProspect.PersonMobilePhone = '65'+Reservation.Customer_Mobile_Number__c;
                }
                else{
                    newProspect.PersonMobilePhone = Reservation.Customer_Mobile_Number__c;
                }
                newProspect.Branch_Code__pc    = SalesUser.Branch_Code__c;
                newProspect.Franchise_Code__pc = SalesUser.Franchise_Code__c;
                newProspect.PersonEmail        = Reservation.Customer_Email__c;
                newProspect.PersonBirthdate    = custBirthDate;                     // Added by Vu 06/07/2022 - Store value from Date of birth input

                // if (!Test.isRunningTest())
                // {
                //     String customerID = getDriveCustomerID();

                //     if (String.isNotBlank(customerID))
                //     {
                //         newProspect.Drive_Customer_ID__c = customerID;
                //     }
                //     else
                //     {
                //         newProspect.Pending_Drive_Sync__c = true;
                //     }
                // }

                
                // String newNRIC, nricVal;
                // nricVal     = Reservation.Customer_Social_ID__c;
                // Date cusDOB = custBirthDate;
                // String dob  = Datetime.newInstance(cusDOB.year(), cusDOB.month(),cusDOB.day()).format('dd/MM/YYYY');
                // if (String.isNotBlank(Reservation.Customer_Social_ID__c)) {
                //     if (Reservation.Customer_Social_ID__c.length() == 9) {
                //         newNRIC = nricVal.substring(nricVal.length() - 4, nricVal.length()) + Dob.replaceAll('/', '');
                //     }
                //     if (Reservation.Customer_Social_ID__c.length() == 12) {
                //         newNRIC = nricVal.substring(0, 4) + Dob.replaceAll('/', '');
                //     }
                // }

                // newNRIC = nricVal.substring(nricVal.length()-4, nricVal.length()) + Dob.replaceAll('/', '');

                // Added by Vu 06/07/2022 - Format and save value for NRIC_Passport_No__pc
                newProspect.NRIC_Passport_No__pc = formatNRIC(Reservation.Customer_Social_ID__c, custBirthDate);

                insert newProspect;

                newProspect = [SELECT ID, Name, Branch_Code__pc, User_Branch_Code__pc, PersonContactId From Account WHERE Id =: newProspect.Id];
                
                //Added by Khanh: create PA Profiling
                if(newProspect != null && String.isNotBlank(newProspect.Id)){
                    AccountUtil.createProfiling('CCS_Person_Account_Profiling_RT', newProspect);
                }

            }

            Contact NewContact = New Contact();
            Account newPersonAccount = new Account();

            if (listExistingAccount.size() > 0){
                newPersonAccount = [SELECT Id, NRIC_Passport_No__pc, Name, LastName, Full_Name__pc, PersonContactId 
                                    FROM Account 
                                    WHERE Id = :personAccount.Id AND IsPersonAccount = true ];
            }

            promtErrorOnSR = false;
            printErrorOnSR = '';

            modelSelected = [SELECT Model_Description__c FROM Model_master__c WHERE Id = :selectedModel].Model_Description__c;
            List<Model_Master__c> VMList = [SELECT Name FROM Model_Master__c WHERE Id = :VehicleMaster.Model_Code__c];
            Model__c InputModel = new Model__c();
            Variant__c InputVariant = new Variant__c();
            
            if(VMList.size()>0){
                String VarDWHId = SalesUser.Branch_Code__c+','+SalesUser.Franchise_Code__c+','+VMList[0].Name;
                List<Variant__c> VRList = [SELECT Id,Model_ID__c FROM Variant__c WHERE DWH_Variant_ID__c = :VarDWHId];
                if(VRList.size()>0){
                    InputVariant.Id = VRList[0].Id;
                    InputModel.Id = VRList[0].Model_ID__c;
                }
            }

            if( promtErrorOnSR == false ) {
                Id rtid;
                Set<String> SetOppStage = new Set<String>();
                //these are the open opp's
                SetOppStage.Add('Open');
                SetOppStage.Add('Test Driven');
                SetOppStage.Add('Stock Reserved');
                SetOppStage.Add('Contacted'); // new added value as its comes under Open category according to new approach
                Date OppExpectedCloseDate = Date.Today();
                OppExpectedCloseDate = OppExpectedCloseDate.AddDays(1);

                List<Opportunity> ListOppTestDriven = new List<Opportunity>();
        //Code was modified for Oppty standardisation --> NSJ
        boolean isOppUpdate = false;

        if(listExistingAccount.size() > 0)
        {
                    /*ListOppTestDriven = [SELECT Id, StageName, AccountId, Contact_Person__c, Contact_Person__r.OwnerId,
                                            NRIC__c, Franchise_Code__c, Branch_Code__c, CloseDate, Name, Rating__c, OwnerId,
                                            Owner.FirstName, Owner.LastName, Model_c__c, PriceAlert__c, Test_Drive__c, EventRegistration__c,
                                            Amount, Description, ExpectedRevenue, Type, Date_of_Registration__c, Discount__c,
                                            Interest_Rate__c, Register_Date__c, Vehicle_Master__c, Lead__c, Account__c
                                            FROM Opportunity
                                            WHERE
                                            StageName NOT IN ('Booked', 'Lost')
                                            AND OwnerId = :SalesUser.Id
                                            AND Account__c = :newPersonAccount.Id
                                            ORDER BY CreatedDate DESC];*/
                    System.debug('Line 1136>>>>>>>>>>>>>>>>>>>> ' + ListOppTestDriven);

          //Code was modified for Oppty standardisation --> NSJ
          //ListOppTestDriven = OpportunityService.activeOpportunityList(newPersonAccount.PersonContactId, SalesUser.Branch_Code__c);
          ListOppTestDriven =  [SELECT Id, Name, Rating__c, RecordTypeId, Custom_Quote__c, Old_Car_No__c, 
                Date_of_Registration__c, Make_Model__c, Test_Drive__c, Preferred_Model__c , 
                Contact_Person__c, Lead__c, Account__c , StageName, Branch_Code__c, Franchise_Code__c, 
                Model_c__c, Opportunity_Score__c, PriceAlert__c, TotalOpportunityQuantity, 
                EventRegistration__c, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                (SELECT Id, Name,Model__c, Touch_Points__c 
                FROM Models_Interested__r)
                FROM Opportunity 
                WHERE Branch_Code__c = :SalesUser.Branch_Code__c 
                AND Contact_Person__c = :newPersonAccount.PersonContactId 
                AND StageName NOT IN ('Booked', 'Lost')
                AND CloseDate > :Date.today() 
                ORDER BY CreatedDate DESC];

                    System.debug('Line 1140>>>>>>>>>>>>>>>>>>>> ' + ListOppTestDriven + ' ' + String.valueOf(ListOppTestDriven.size()>0));

          if(ListOppTestDriven.size()>0)
          {
            for(Opportunity opp : ListOppTestDriven)
            {
              if(opp.OwnerId ==  SalesUser.Id)
              {
                Opportunity tempUpdateOpp = new Opportunity();
                tempUpdateOpp           = opp;
                tempUpdateOpp.OwnerId   = SalesUser.Id;
                tempUpdateOpp.Rating__c = 'Hot';
                tempUpdateOpp.CloseDate = OppExpectedCloseDate;
                tempUpdateOpp.StageName  = 'Stock Reserved';
                update tempUpdateOpp;

                //code added for the interested model (in case of test drive - model intersed entry will be there)
                String modInterestedOnExOpp = createdModelInterested( tempUpdateOpp.Id, InputModel.Id, SalesUser.Id );

                List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();

                if(listExistingAccount.size() > 0){
                  if( tempUpdateOpp.Account__c <> null ){
                    lstToCreateShare.add(new SharingHelper.generateShare('Read', 'Account', tempUpdateOpp.Account__c, tempUpdateOpp.OwnerId));
                  }
                }                    
                // if(listExistingContact.size()>0 ){
                //   lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', tempUpdateOpp.Contact_Person__c, tempUpdateOpp.OwnerId));
                // }

                createReservation( tempUpdateOpp.Id );
                sharingHelper.creatShare( lstToCreateShare );

                isOppUpdate = true;
                break;
              }
            }
          }
        
        }

                if (isOppUpdate == false)
        {
                    //create opportunity + create SR

          //Code was modified for Oppty standardisation --> NSJ
          rtid = OpportunityService.getStrRecordTypeAssignment(SalesUser.Branch_Code__c);
          string contactId;
          string AccountId;
          string oppName;

            if(listExistingAccount.size() > 0)
          {
                        AccountId = newPersonAccount.Id;
                        contactId = newPersonAccount.PersonContactId;
                        oppName      = newPersonAccount.Name;
            }
                    else
          {                       
                        AccountId = newProspect.Id;
                        contactId = newProspect.PersonContactId;
                        oppName       = newProspect.name;
                    }
            Opportunity tempInsertOpp       = new Opportunity();
            tempInsertOpp = OpportunityService.newOpportunityObject(contactId, AccountId, rtid,
                                        SalesUser.Branch_Code__c, SalesUser.Franchise_Code__c, 'Stock Reserved');        
          
            tempInsertOpp.Name = OpportunityService.getStrOpportunityName(oppName, SalesUser.Franchise_Code__c.substring(0,3));                    
            tempInsertOpp.OwnerId           = SalesUser.Id;
            tempInsertOpp.Rating__c         = 'Hot';
            tempInsertOpp.StageName      = 'Stock Reserved';

                    TriggerExclusion.skipRR = true;
                    insert tempInsertOpp;

                    //code added for the interested model (in case of test drive - model intersed entry will be there)
                    String modInterestedOnOpp = createdModelInterested(tempInsertOpp.Id,InputModel.Id,SalesUser.Id);
                    List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();

                    // if(listExistingContact.size()>0 ){
                    //     lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', tempInsertOpp.Contact_Person__c, tempInsertOpp.OwnerId));
                    // }
                    createReservation( tempInsertOpp.Id );
                    sharingHelper.creatShare( lstToCreateShare );
                }
            }
        } 
        else if(stockIsEmpty) 
        {
            promtErrorOnSR = true;
            printErrorOnSR = 'This vehicle has already been reserved and has no more stock. Please exit the Stock Reservation.';
        } 
        else 
        {
            promtErrorOnSR = true;
            printErrorOnSR = 'The vehicle has already been reserved. Please re-submit the Stock reservation.';
        }
    }

    public void createReservation(Id OppId) {
        //create SR, link SR to Opportunity
        //update related vehicle master
        Reservation.Opportunity__c = OppId;
        system.debug(Reservation.Customer_Social_ID__c);
        insert Reservation;
        custFirstName = '';
        custLastName  = '';

        Stock_Reservation__c tempReservation = new Stock_Reservation__c();
        tempReservation = [SELECT Id, Name, Vehicle_Master__c
                           FROM Stock_Reservation__c
                           WHERE Id= :Reservation.Id
                           LIMIT 1];

        if( tempReservation.Vehicle_Master__c <> null ) {
            Vehicle_Master2__c updateVM = new Vehicle_Master2__c();
            updateVM = [SELECT Id, Name, Reservation_No__c 
                        FROM Vehicle_Master2__c 
                        WHERE Id = :tempReservation.Vehicle_Master__c];
            updateVM.Reservation_No__c = tempReservation.Name;
            update updateVM;
        }
        //add by taufik to remove the trigger VSMS 18 May 2016
        VSMSHelperClass.insertSR(Reservation.id,SalesUser.Username2__c);
        RefreshAndGotoPage1();
    }

    public void UpdateReservation() {
        update Reservation;
        //add by taufik to remove the trigger VSMS 18 May 2016
        VSMSHelperClass.updateSR( Reservation.id, SalesUser.Username2__c );
        RefreshAndGotoPage1();
    }

    public void CancelReservation() {
        RefreshAndGotoPage1();
    }

    public PageReference RefreshAndGotoPage1() {
        showPage = 1;
        initPage();
        return new pagereference('/');
    }


    /************************************************************
    * Method Name: SearchCustomer
    * Description: Method to search existing customer
    *
    * Revision History
    * Developer Name  Date      Description
    * CGaylan      25-06-2019    Added phone number search
    ************************************************************/
    public void SearchCustomer() {
        // listExistingContact = new List<Contact>();
        listExistingAccount = new List<Account>(); 

        //Mobile Phone number
        if(String.isNotBlank(Reservation.Customer_Mobile_Number__c)){
            System.debug('@@@@DEBUG SearchCustomer = Reservation.Customer_Mobile_Number__c = ' + Reservation.Customer_Mobile_Number__c);
            String mobPhone = '65' + Reservation.Customer_Mobile_Number__c;

            // listExistingContact = [SELECT Id, Name, FirstName, LastName, Email, MobilePhone, NRIC__c, OwnerId, Full_Name__c
            //                        FROM Contact
            //                        WHERE MobilePhone = :mobPhone
            //                        AND IsPersonAccount = true];


            listExistingAccount = [SELECT Id, Full_Name__pc, FirstName, LastName, PersonEmail, PersonMobilePhone, NRIC_Passport_No__pc, OwnerId, Name, PersonBirthdate //Drive_Customer_ID__c, Pending_Drive_Sync__c
                                    FROM Account
                                    WHERE PersonMobilePhone = :mobPhone
                                    AND IsPersonAccount = true
                                    ORDER BY RecordType.Name ASC];
        }

        if( listExistingAccount.isEmpty() && String.isNotBlank(Reservation.Customer_Email__c)){

            listExistingAccount = [SELECT Id, Full_Name__pc, FirstName, LastName, PersonEmail, PersonMobilePhone, NRIC_Passport_No__pc, OwnerId, Name, PersonBirthdate //, Drive_Customer_ID__c, Pending_Drive_Sync__c
                                    FROM Account
                                    WHERE PersonEmail = :Reservation.Customer_Email__c
                                    AND IsPersonAccount = true
                                    ORDER BY RecordType.Name ASC];
        }

        //System.debug('@@@@DEBUG SearchCustomer = listExistingContact = ' + listExistingContact);
        System.debug('@@@@DEBUG SearchCustomer = listExistingAccount = ' + listExistingAccount);

        if (listExistingAccount.size() > 0){
            Account acct = listExistingAccount.get(0);
            Reservation.Customer_Name__c  = String.isNotBlank(acct.Full_Name__pc) ? acct.Full_Name__pc : acct.Name;
            Reservation.Customer_Email__c = acct.PersonEmail;
            custFirstName                 = String.isNotBlank(acct.FirstName) ? acct.FirstName : '';
            custLastName                  = String.isNotBlank(acct.LastName) ? acct.LastName : '';
            if( String.isNotBlank(acct.PersonMobilePhone) && acct.PersonMobilePhone.startsWith('65')){
                Reservation.Customer_Mobile_Number__c = acct.PersonMobilePhone.substringAfter('65');
            }
            else if( String.isNotBlank(acct.PersonMobilePhone) ){
                Reservation.Customer_Mobile_Number__c = acct.PersonMobilePhone;
            }
            // Added by Vu 06/07/2022 - Populate Birthdate & NRIC for existing PA
            custBirthDate = acct.PersonBirthdate;
        }
        /*
        else if(listExistingContact.size()>0) {
            Reservation.Customer_Name__c  = String.isNotBlank(listExistingContact[0].Full_Name__c) ? listExistingContact[0].Full_Name__c : listExistingContact[0].Name;
            custFirstName                 = String.isNotBlank(listExistingContact[0].FirstName) ? listExistingContact[0].FirstName : '';
            custLastName                  = String.isNotBlank(listExistingContact[0].LastName) ? listExistingContact[0].LastName : '';
            Reservation.Customer_Email__c = listExistingContact[0].Email;
            if( String.isNotBlank(listExistingContact[0].MobilePhone) && listExistingContact[0].MobilePhone.startsWith('65')){
                Reservation.Customer_Mobile_Number__c = listExistingContact[0].MobilePhone.substringAfter('65');
            }
            else if( String.isNotBlank(listExistingContact[0].MobilePhone) ){
                Reservation.Customer_Mobile_Number__c = listExistingContact[0].MobilePhone;
            }
        }
        */
        else{
            Reservation.Customer_Name__c = '';
            custFirstName = '';
            custLastName  = '';
            custBirthDate = null;
        }
    }

    public PageReference doCancel() {
        return new pagereference('/');
    }

    public String createdModelInterested (String OppId, String ModId, String ownId) {
        try {      
            //Code was modified for Oppty standardisation --> NSJ
            Models_Interested__c createModInt = new Models_Interested__c();
            createModInt = ModelsInterestedService.newModelInterestedObject(OppId, ModId, 'Offline', 'Stock Reserved');
            Database.insert( createModInt );

            return 'Success';
        } catch(Exception e) {
            return 'Exception';
        }
    }

    // public String getDriveCustomerID ()
    // {
    //     String customerID = '';
    //     Map<String, Object> responseMap = new Map<String,Object>();
    //     HttpResponse res = new HttpResponse();
    //     res = makeCallout(true, '');

    //     if (res.getStatusCode() == 200)
    //     {
    //         responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    //         String accessToken = (String) responseMap.get('access_token');

    //         if (String.isNotBlank(accessToken))
    //         {
    //             res = makeCallout(false, accessToken);

    //             if (res.getStatusCode() == 200)
    //             {
    //                 responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
    //                 if (responseMap.get('customers') <> null)
    //                 {
    //                     List<Object> customers = (List<Object>) responseMap.get('customers');
    
    //                     if (customers.size() > 0)
    //                     {
    //                         Map<String,Object> customersMap = (Map<String,Object>) customers[0];
    //                         customerID = (String) customersMap.get('customerId');
    //                     }
    //                 }
    //             }
    //         }
    //     }

    //     return customerID;    
    // }

    // public HttpResponse makeCallout (Boolean is1stCall, String accessToken)
    // {
    //     Http http = new Http();
    //     HttpRequest req  = new HttpRequest();
    //     HttpResponse res = new HttpResponse();
    //     String result = '';

    //     global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
    //     String APIurl = (String)JCC_GlobalVar.APIGateway_url__c;
    //     String APIkey = (String)JCC_GlobalVar.APIGateway_key__c;      
    //     String endPoint = is1stCall ? APIurl + '/drive/oauth/accesstoken' : APIurl + '/drive/oauth/customers?email=' + Reservation.Customer_Email__c;

    //     if (is1stCall) { req.setMethod('POST'); } else {req.setMethod('GET');}
    //     req.setTimeout(12000);
    //     req.setEndpoint(endPoint);
    //     req.setHeader('Accept', 'application/json');
    //     req.setHeader('Content-Type', 'application/json');
    //     if (Test.isRunningTest()) 
    //     {
    //         req.setHeader('APIKey', '9-bMiOlUatsidmlzYSIsIm1hc3RlcmNhcmQiXX1H10JaPE54rGCPzpRFM016pybQvbGk5gOLRkYW15aFaQ14TbF94n5baYBX'); 
    //     }
    //     else 
    //     {
    //         req.setHeader('APIKey', APIkey); 
    //     }
    //     if (!is1stCall) { req.setHeader('Authorization', 'Bearer ' + accessToken); }

    //     res = http.send(req);

    //     if (!is1stCall) { serviceDataPool.buildServiceDataPoolHttp('GetDriveCustomerID', 'StockReservationCon', '', req, res); } 
        
    //     return res;
    // }

    private String formatNRIC(String nric, Date cusDOB) {
        
        String dob     = Datetime.newInstance(cusDOB.year(), cusDOB.month(),cusDOB.day()).format('dd/MM/YYYY');
        String newNRIC = nric.substring(nric.length() - 4, nric.length()) + dob.replaceAll('/', '');

        return newNRIC;
    }
}
@isTest
public class StockReservationConTest {
    static user u;
    static User crUser;
    static profile uprofile;
    static Model_Master__c ModelMaster;
    static Model_Year_Master__c ModelYear1;
    static Model_Year_Master__c ModelYear2;
    static Color_Master__c ColorMaster;
    static Trim_Master__c TrimMaster;
    static Model_Color_Trim_Master__c MCTMaster;
    static Date thisYear;
    static Vehicle_Master2__c IncomingStock;
    static Vehicle_Master2__c PromotionStock;
    static Vehicle_Master2__c ExistingStock;
    static Stock_Promotion__c SP;
    
    static {
        crUser = Test_DataFactory.createUser(true,'test','tst');
        uProfile = new Profile();
        uProfile = [SELECT Id, Name FROM Profile where Name  = 'KIAPC Sales'];
        u = new user();
        u.ProfileId = uProfile.id;
        u.alias = 'KiaPC';
        u.email = 'KiaPC@User.com';
        u.emailencodingkey='UTF-8';
        u.lastname='KiaPC';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US';
        u.timezonesidkey='America/Los_Angeles';
        u.username='KiaPC@User.com';
        u.Branch_Code__c = 'CCK';
        u.Franchise_Code__c = 'KIAPC';
        insert u;
        
        Logo__c a = new Logo__c(filename__c='test' ,Branch_Code__c='',Franchise_Code__c='');
        insert a;
        Logo__c d = new Logo__c(filename__c='test' ,Branch_Code__c='CCA',Franchise_Code__c='MITPC');
        insert d;
        Logo__c b = new Logo__c(filename__c='test2' ,Branch_Code__c='CCK',Franchise_Code__c='KIAPC');
        insert b;
        Logo__c c = new Logo__c(filename__c='test2' ,Branch_Code__c='CCF',Franchise_Code__c='');
        insert c;
        
        ModelMaster = new Model_Master__c();
        ModelMaster.Active__c = TRUE;
        ModelMaster.Branch_Code__c = 'CCK';
        ModelMaster.Franchise_Code__c = 'KIAPC';
        ModelMaster.Name = '000Model1';
        ModelMaster.Model_Description__c = '000Model1';
        insert ModelMaster;
        
        thisYear = date.Today();
        ModelYear1 = new Model_Year_Master__c();
        ModelYear1.Model_Master__c = ModelMaster.Id;
        ModelYear1.Active__c = TRUE;
        ModelYear1.Branch_Code__c = 'CCK';
        ModelYear1.Franchise_Code__c = 'KIAPC';
        ModelYear1.ModelYear__c = thisYear;
        ModelYear1.Name = String.ValueOf(thisYear.Year());
        ModelYear1.Model_Master__c = ModelMaster.Id;
        ModelYear1.VSMS_Compound_Primary_Key__c = '1';
        insert ModelYear1;
        
        ColorMaster = new Color_Master__c();
        ColorMaster.Active__c = TRUE;
        ColorMaster.Branch_Code__c = 'CCK';
        ColorMaster.Franchise_Code__c = 'KIAPC';
        ColorMaster.Name = 'Red';
        ColorMaster.Color_Description__c = 'Red';
        ColorMaster.ColorCode__c = 'ColExtKey';
        insert ColorMaster;
        
        TrimMaster = new Trim_Master__c();
        TrimMaster.Active__c = TRUE;
        TrimMaster.Branch_Code__c = 'CCK';
        TrimMaster.Franchise_Code__c = 'KIAPC';
        TrimMaster.Name = 'Trim1';
        TrimMaster.Trim_Description__c = 'Trim1';
        insert TrimMaster;
        
        MCTMaster = new Model_Color_Trim_Master__c();
        MCTMaster.Active__c = TRUE;
        MCTMaster.Branch_Code__c = 'CCK';
        MCTMaster.Franchise_Code__c = 'KIAPC';
        MCTMaster.Model_Code__c = ModelMaster.Id;
        MCTMaster.Color_Code__c = ColorMaster.Id;
        MCTMaster.Trim_Code__c = TrimMaster.Id;
        MCTMaster.Name = 'MCT1';
        insert MCTMaster;
        
        PromotionStock = Test_DataFactory.createVehicleMaster2(false,ModelMaster.Id,ColorMaster.Id,TrimMaster.Id,ModelYear1.Id,'KIAPC0920050454','KIAPC0920050454');
        PromotionStock.ProductionMonth__c = System.today();
        PromotionStock.Vehicle_Status__c = 'NULL';
        PromotionStock.Branch_Code__c = 'CCK';
        PromotionStock.Franchise_Code__c = 'KIAPC';
        insert PromotionStock;
        
        ExistingStock = Test_DataFactory.createVehicleMaster2(false,ModelMaster.Id,ColorMaster.Id,TrimMaster.Id,ModelYear1.Id,'KIAPC0920050454','KIAPC0920050454');
        ExistingStock.ProductionMonth__c = System.today();
        ExistingStock.Vehicle_Status__c = 'FREE';
        ExistingStock.Branch_Code__c = 'CCK';
        ExistingStock.Franchise_Code__c = 'KIAPC';
        insert ExistingStock;
        
        IncomingStock = Test_DataFactory.createVehicleMaster2(false,ModelMaster.Id,ColorMaster.Id,TrimMaster.Id,ModelYear1.Id,'KIAPC0920050454','KIAPC0920050454');
        IncomingStock.ProductionMonth__c = System.today();
        IncomingStock.Vehicle_Status__c = 'ORD';
        IncomingStock.Branch_Code__c = 'CCK';
        IncomingStock.Franchise_Code__c = 'KIAPC';
        insert IncomingStock;
        
        SP = new Stock_Promotion__c();
        SP.Stock_Vehicle_Master__c = PromotionStock.Id;
        SP.Stock_Promotion_Status__c = 'ADD';
        SP.Comment__c = '';
        SP.Name = 'Promotion1';
        insert SP;
        
        Lead TestLead =  new Lead(LastName='TestRunL',NRIC__c='N1234567P', Email='test@123.com', MobilePhone='6589898989');
        insert TestLead; 
        
        Account acct = Test_DataFactory.createAccount(true,'testRun');
        Contact con =  Test_DataFactory.createContact(false,'testRun','testRun',acct.Id);
        con.MobilePhone = '6591111111';
        con.Birthdate = System.today() -1;
        con.PDPA__c = 'SMS';
        insert con;
        
        
    }
    
    static testMethod void TriggerVehicleMaster2Test() {
        ExistingStock.ProductionMonth__c = date.newInstance(thisYear.Year(),12,12);
        update ExistingStock;
        
        System.runAs(u){
            
            StockReservationCon con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            //con.ListExistingLead = new List<Lead>();
            con.selectedModel = NULL;
            con.selectedColor = NULL;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = NULL;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = NULL;
            con.selectedTrim = TrimMaster.Id;
            
            con.SearchVehicle();
            
            con.Reservation.Customer_Social_ID__c = 'N1234567P';
            con.Reservation.Customer_Name__c = 'Customer';
            con.Reservation.Customer_Email__c = 'test@123.com';
            con.Reservation.Customer_Mobile_Number__c = '89898989';
            
            Account ac = Test_DataFactory.createPerson(false, 'test', 'Prospect');
            ac.PersonMobilePhone = '6589898989';
            insert ac;
            con.listExistingAccount = new List<Account>{ac};
                
            con.ClearParameter();
            //con.SearchCustomer();
            con.doCancel();
        }
    }
    static testMethod void TriggerVehicleMaster2Test1() {
        ExistingStock.ProductionMonth__c = date.newInstance(thisYear.Year(),12,12);
        update ExistingStock;
        
        
        
        System.runAs(u){
            
            StockReservationCon con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            //con.ListExistingLead = new List<Lead>();
            con.selectedModel = NULL;
            con.selectedColor = NULL;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = NULL;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = NULL;
            con.SearchVehicle();
            
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = NULL;
            con.selectedTrim = TrimMaster.Id;
            con.SearchVehicle();
            
            
            con.Reservation.Customer_Social_ID__c = 'N1234567P';
            con.Reservation.Customer_Name__c = 'Customer';
            con.Reservation.Customer_Email__c = 'test@123.com';
            con.Reservation.Customer_Mobile_Number__c = '91111111';

            con.ClearParameter();
            con.SearchCustomer();
            con.doCancel();
        }
    }
    
    static testMethod void PromotionStockTest() {
        System.runAs(u){
            global_var__c jjcVal = Test_DataFactory.createGlobalOrfDefaults(false);
            jjcVal.APIGateway_key__c = '731837873';
            insert jjcVal;

            StockReservationCon con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.custLastName = 'test123';
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            //con.ListExistingLead = new List<Lead>();
            Account ac = Test_DataFactory.createPerson(true, 'test', 'Prospect');   
            ac = [SELECT PersonContactId, Id FROM Account WHERE Id =: ac.Id]; //Pending_Drive_Sync__c
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Testing Opportunity', ac.Id);
            opp.Branch_Code__c = 'CCK';
            opp.StageName = 'Open';
            opp.Contact_Person__c = ac.PersonContactId;
            opp.CloseDate = Date.today() + 15;
            opp.OwnerId = u.Id;
            opp.Account__c = ac.Id;
            insert opp; 
            System.debug('Line 252 >>>>>>>>>>>> ' + opp);
            con.listExistingAccount = new List<Account>{ac};   
            con.ReserveSelectedVehicle = con.ListwrapperPromotionStock[0].wID;
            con.AddReservation();
            
            con.Reservation.Customer_Social_ID__c = 'N1234567P';
            con.Reservation.Customer_Name__c = 'Customer';
            //con.Reservation.LastName = 'Customer';
            con.Reservation.Customer_Mobile_Number__c = '89898989';
            con.custBirthDate = Date.today();

            con.SaveReservation(); 
        }
    }
    
    
    static testMethod void IncomingStockTest() {
        System.runAs(u){
            global_var__c jjcVal = Test_DataFactory.createGlobalOrfDefaults(false);
            jjcVal.APIGateway_key__c = '731837873';
            insert jjcVal;

            StockReservationCon con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.custLastName = 'test123';
            
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            
            con.ReserveSelectedVehicle = con.ListwrapperIncomingStock[0].wID;
            con.AddReservation();
            
            con.Reservation.Customer_Social_ID__c = 'N1234567P';
            con.Reservation.Customer_Name__c = 'Customer';
            con.Reservation.Customer_Mobile_Number__c = '89898989';
            con.custBirthDate = Date.today();
            //con.ListExistingLead = new List<Lead>();
            Account ac = Test_DataFactory.createPerson(true, 'test', 'Prospect');
            ac = [SELECT PersonContactId, Id FROM Account WHERE Id =: ac.Id]; //Pending_Drive_Sync__c
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Testing Opportunity', ac.Id);
            opp.Branch_Code__c = 'CCK';
            opp.StageName = 'Open';
            opp.Contact_Person__c = ac.PersonContactId;
            opp.CloseDate = Date.today() + 15;
            opp.OwnerId = u.Id;
            insert opp; 
            
            con.listExistingAccount = new List<Account>{ac};
            con.SaveReservation();
            con.CancelReservation();
            
            con = new StockReservationCon();
            con.custLastName = 'test123';
            con.ReservationId = con.ListReservation[0].Id;
            con.Reservation_Cancellation();
            
            con.Reservation.Cancellation_Reason__c = 'cancel';
            con.UpdateReservation();
        }
    }
    
    /*
    static testMethod void ExistingStock_N_IndentTest() {
            
            StockReservationCon con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.custLastName = 'test';
            //con.ListExistingLead = new List<Lead>();
            
            Account ac = Test_DataFactory.createPerson(true, 'test', 'Prospect');
            ac = [SELECT PersonContactId, Id FROM Account WHERE Id =: ac.Id]; //Pending_Drive_Sync__c
            Opportunity opp = Test_DataFactory.createOpportunity(false, 'Testing Opportunity', ac.Id);
            opp.Branch_Code__c = 'CCK';
            opp.StageName = 'Open';
            opp.Contact_Person__c = ac.PersonContactId;
            opp.CloseDate = Date.today() + 15;
            opp.OwnerId = u.Id;
            insert opp; 
            con.listExistingAccount = new List<Account>{ac};
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            con.ReserveSelectedVehicle = con.ListwrapperExistingStock[0].wID;
            con.AddReservation();

            con.Reservation.Customer_Social_ID__c = 'N1234567P';
            con.Reservation.Customer_Name__c = 'Customer';
            con.Reservation.Customer_Mobile_Number__c = '89898989';
            con.SaveReservation();
            
            con = new StockReservationCon();
            con.selectedModel = ModelMaster.Id;
            con.selectedColor = ColorMaster.Id;
            con.selectedTrim = TrimMaster.Id;
            con.custLastName = 'test1234';
            con.refresh_Color_Option();
            con.refresh_Trim_Option();
            con.refresh_Color_Trim_Option();
            con.SearchVehicle();
            con.listExistingAccount = new List<Account>();

            con.ReserveSelectedVehicle = con.ListwrapperStock2Indent[0].wID;
            con.AddReservation();
            
            con.Reservation.Customer_Social_ID__c = 'N1234567R';
            con.Reservation.Customer_Name__c = 'Customer2';
            con.Reservation.Customer_Mobile_Number__c = '89898988';
            con.SaveReservation();
            //sometimes we will got some error here Class.VSMSHelperClass.updateSR
            //that's because of the there are an checking on commcase which need to be an actual record (not a test record)
            //for this to pass, need Taufik to deactivate it at a moment
        
    }*/
    // Enable NRIC
    static testMethod void enableNRICTest() {
        //  System.runAs(u){
        StockReservationCon con = new StockReservationCon();
        Lead ld = Test_DataFactory.createLead(false,'test','test');
        ld.NRIC__c = '555555';
        insert ld;
        Model_Master__c mod = Test_DataFactory.createModelCode(true,'test');
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(false,mod.Id);
        mym.VSMS_Compound_Primary_Key__c = '2';
        insert mym; 
        Account ac = Test_DataFactory.createPerson(true, 'test', 'Prospect');
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Lead__c = ld.id;
        opp.Account__c = ac.Id;
        insert opp;
        Stock_Reservation__c stk = Test_DataFactory.StockReservation(false,mod.Id,cm.Id,tm.Id,mym.Id);
        stk.Opportunity__c = opp.Id;
        stk.OwnerId = u.Id;
        stk.Reservation_Status__c = 'Reserve';
        insert stk;
        con.ReservationId = stk.Id;
        con.enableNRIC();
        con.nricfield = 'S6646456A';//66464
        Contact c = Test_DataFactory.createContact(false, 'test', 'test', ac.id);
        /*c.email = 'con@jcc.com';
		c.NRIC_Passport_No__c = '5555555';
		insert c;*/
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mod.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"'+ld.email+'","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'"}';
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        con.updateNRIC();
        con.cancelNRIC();
        con.Reservation_Cancellation();
        //.  }
    }
    // Enable NRIC
    static testMethod void enableNRICTest1() {
        //System.runAs(u){
        StockReservationCon con = new StockReservationCon();
        Account paAcct = Test_DataFactory.createPerson(false, 'paTest1234', 'Prospect');
        paAcct.PersonBirthdate = Date.today().addYears(-25);
        insert paAcct;
        Account ac = Test_DataFactory.createAccount(true, 'test1234Test');
        Contact c = Test_DataFactory.createContact(false, 'test', 'test',ac.Id );
        c.email = 'con@jcc.com';
        c.NRIC_Passport_No__c = '5555555';
        c.Account__c = paAcct.Id;
        insert c;
        Model_Master__c mod = Test_DataFactory.createModelCode(false,'test');
        mod.VSMS_Compound_Primary_Key__c = '1';
        insert mod;
        Color_Master__c cm = Test_DataFactory.createColorCode(true,'test','T69','CCA','MITPC');
        Trim_Master__c tm = Test_DataFactory.createTrimCode(true,'test');
        Model_Year_Master__c mym = Test_DataFactory.createModelYearCode(false,mod.Id); 
        mym.VSMS_Compound_Primary_Key__c = '3';
        insert mym;
        Opportunity opp = Test_DataFactory.createOpportunity(false, 'test', ac.Id);
        opp.Contact_Person__c = c.id;
        opp.Account__c = paAcct.Id;
        insert opp;
        Stock_Reservation__c stk = Test_DataFactory.StockReservation(false,mod.Id,cm.Id,tm.Id,mym.Id);
        stk.Opportunity__c = opp.Id;
        stk.OwnerId = u.Id;
        stk.Reservation_Status__c = 'Reserve';
        insert stk;
        con.ReservationId = stk.Id;
        con.enableNRIC();
        con.nricfield = 'S4444444A';//44444
        Vehicle_Master2__c vm = Test_DataFactory.createVehicleMaster2(false,mod.Id,cm.Id,tm.Id,mym.Id,'KIAPC0920050454','KIAPC0920050454');
        vm.ProductionMonth__c = System.today();
        vm.Vehicle_Status__c = 'RESRV';
        vm.Branch_Code__c = 'CCK';
        vm.Franchise_Code__c = 'KIAPC';
        insert vm;
        string invoiceNumber = 'SG-CCK-'+String.ValueOF(System.Today().month()).leftPad(2,'0')+string.valueof(System.Today().year()).substring(2,4)+'-00000314';
        Showroom__c sh = Test_DataFactory.createShowroom(true);
        Stock_Promotion__c stprom = Test_DataFactory.createstockPromotion(false,'test','KIA Warehouse',vm.Id);
        stprom.Vehicle_Sub_Type__c = 'Display';
        stprom.Stock_Promotion_Status__c = 'ADD';
        stprom.Vehicle_Type__c = 'Demo Cars';
        stprom.Showroom__c = sh.Id;
        stprom.Actual_Price__c = 100;
        stprom.Discounted_Price__c = 90;
        stprom.Mileage__c = 15;
        insert stprom;
        Lead ld = Test_DataFactory.createLead(false,'test','test');
        ld.NRIC__c = '555555';
        insert ld;
        String vms = '{"customerInfo":{"LastName":"'+c.LastName+'", "FirstName":"'+c.FirstName+'", "AccountId":"'+c.AccountId+'","Email":"'+ld.email+'","Id":"'+c.Id+'"},"StockVehicleMasterId":\"'+vm.Id+ '","SalesConsultantId":\"'+crUser.Id+'","TestDriveDate":\"'+System.today()+'","InvoiceNo":\"'+invoiceNumber+'","StockPromotionId":\"'+stprom.Id+'"}';
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,vms));
        con.updateNRIC();
        con.cancelNRIC();
        con.Reservation_Cancellation();
        // }
    }  
}
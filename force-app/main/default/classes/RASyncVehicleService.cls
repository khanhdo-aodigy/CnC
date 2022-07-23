/** *****
 * Description :  Service class to call API from UCS to get vehicle records
 *
 * Change History
 * Date(YYYYMMDD)       Name       		    Description
 * 20210114             huynh.hung          Created Initial Version.
 * 20210310             HS@aodigy           Added "eq" in the existing predefined filter parameters. Added "FreeTextFilter".
 * 20200319             KD@aodigy           Added Vehicle Stock's Status check
 * 20210625             KD@aodigy           Added PA Merging changes
 * 20211015             TPhan@aodigy        Added lookup relationship to Used_Car_Vehicle_Sizing__c obj
** *****/
public class RASyncVehicleService {

    private static RA_Global_Variable__c RA_GlobalVar = RA_Global_Variable__c.getOrgDefaults();
    private final static String CONST_PA_PROFILING_RA = 'RA_Person_Account_Profiling_RT';

    /**
     * USE WITH CARE : Test in Postman before execute the job achocly because the USC API filter format is super-sensitive (ex. spacing, lower/upsert case, etc.)  !!!
     * Set null to other parameters if using "FreeTextFilter"
     * 
     * @param LASTUPDATEDATE  :  String Date YYYY-MM-DD used to filter against the LASTUPDATEDATE in UCS (DEFAULT FILTER)
     * @param REGDATE         :  String Date YYYY-MM-DD used to filter against the REGDATE in UCS
     * @param SOLDDATE        :  String Date YYYY-MM-DD used to filter against the SOLDDATE in UCS
     * @param PRICEUPDATEDATE :  String Date YYYY-MM-DD used to filter against the PRICEUPDATEDATE in UCS
     * @param FreeTextFilter  :  Free Text String for filter (example : LASTUPDATEDATE=eq 2021-03-02)
     * @returns response      :  HttpResponse
    **/
    public static HttpResponse getVehicleFromUCS( String LASTUPDATEDATE, String REGDATE, String SOLDDATE, String PRICEUPDATEDATE, String FreeTextFilter)
    {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    
        try {
            String APIGateway_url = (String)RA_GlobalVar.APIGateway_url__c;
            String APIGateway_key = (String)RA_GlobalVar.APIGateway_key__c;
            
            String filter = '';
            if(String.isNotBlank(LASTUPDATEDATE) || String.isNotBlank(REGDATE) || String.isNotBlank(SOLDDATE) ||String.isNotBlank(PRICEUPDATEDATE)){
                filter += '?';
                if(String.isNotBlank(LASTUPDATEDATE)){
                    filter += 'LASTUPDATEDATE=eq ' + LASTUPDATEDATE ;
                }
                if(String.isNotBlank(REGDATE)){
                    filter += filter.indexOf('?') == (filter.length() - 1) ? 'REGDATE=eq ' + REGDATE : '&REGDATE=eq ' + REGDATE ;
                }
                if(String.isNotBlank(SOLDDATE)){
                    filter += filter.indexOf('?') == (filter.length() - 1) ? 'SOLDDATE=eq ' + SOLDDATE : '&SOLDDATE=eq ' + SOLDDATE ;
                }
                if(String.isNotBlank(PRICEUPDATEDATE)){
                    filter += filter.indexOf('?') == (filter.length() - 1) ? 'PRICEUPDATEDATE=eq ' + PRICEUPDATEDATE : '&PRICEUPDATEDATE=eq ' + PRICEUPDATEDATE ;
                }
            }
            else if( String.isNotBlank( FreeTextFilter )){
                filter += '?'+FreeTextFilter;
            }
            // filter = filter.replace(' ', '%20');
            filter = filter.trim().replaceAll('\\s+','%20');

            request.setEndpoint(APIGateway_url+'/RA/UCS/vehicle' + filter);
            request.setMethod('POST');
            request.setHeader('apikey', APIGateway_key);
            request.setHeader('Content-Type', 'application/json'); 
            request.setTimeout(120000);

            response = http.send(request);
            // if(response.getStatusCode() == 200){
            //     syncVehicleFromUCS(response, null);
            // }
            // else{
            //     System.debug('Error from API');
            //     return null;
            // }
            serviceDataPool.buildServiceDataPoolHttp('getVehicleFromUCS', 'RASyncVehicleService', '', request, response);
        }
        catch(Exception ex) 
        {
            System.debug('@@@@DEBUG getVehicleFromUCS :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            loggerDataPool.buildLogDataPool('getVehicleFromUCS', ex);
        }
        return response;
    }
    
    
    public static void syncVehicleFromUCS( HttpResponse res, String mockResponse) 
    {
        if( res <> null && res.getStatusCode() <> 200){
            System.debug('@@@@DEBUG syncVehicleFromUCS :: res.getStatusCode() = ' + res.getStatusCode());
            return;
        }


        List<Used_Car_Vehicle_Stock__c> lstUsedCarWithNoCustomer = new list<Used_Car_Vehicle_Stock__c>();
        List<Used_Car_Vehicle_Stock__c> lstUsedCar = new list<Used_Car_Vehicle_Stock__c>();
        
        Map<String, Used_Car_Vehicle_Stock__c> mapStockNoWithUsedCar = new Map<String, Used_Car_Vehicle_Stock__c>();
		Set<String> setNewEmails = new Set<String>();
        Set<String> setStockRerv = new Set<String>();
        Map<String, Customer> mapEmailToCustomer = new Map<String, Customer>();
        Map<String, String> mapStockNoWithCustomerEmail = new Map<String, String>();

        Map<String, UsedCarVehicleSizingService.ModelGroup> modelGroupMap = new Map<String, UsedCarVehicleSizingService.ModelGroup>();
        Map<String, Used_Car_Vehicle_Sizing__c> UCSizingMap               = new Map<String, Used_Car_Vehicle_Sizing__c>();
        try
        {   JSONParser parser;
            if(String.isNotBlank(mockResponse)){
                parser = JSON.createParser(mockResponse);
            }
            else{
                parser = JSON.createParser(res.getBody());
            }

            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {     
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            Vehicle veh = (Vehicle)parser.readValueAs(Vehicle.class);
                            System.debug('@@@@DEBUG Vehicle :: veh = ' + veh );
                            if(checkValidEmail(veh.EMAIL) || String.isEmpty(veh.EMAIL)){
                                Used_Car_Vehicle_Stock__c usedCar = new Used_Car_Vehicle_Stock__c();
                                usedCar.Stock_Number__c 	 = String.isNotBlank(veh.VEHDOCNO) ? veh.VEHDOCNO : '';
                                usedCar.Registered_Number__c = String.isNotBlank(veh.VEHNO) ? veh.VEHNO : usedCar.Registered_Number__c;
                                usedCar.Make__c 			 = String.isNotBlank(veh.MAKE) ? veh.MAKE : usedCar.Make__c;
                                usedCar.Model__c			 = String.isNotBlank(veh.MODEL) ? veh.MODEL : usedCar.Model__c;
                                usedCar.Listing_Price__c 	 = String.isNotBlank(veh.LISTINGPRICE) ? Double.valueOf(veh.LISTINGPRICE) : usedCar.Listing_Price__c;
                                usedCar.COE__c 				 = String.isNotBlank(veh.COE) ? Double.valueOf(veh.COE) : usedCar.COE__c;
                                usedCar.OMV__c 				 = String.isNotBlank(veh.OMV) ? Double.valueOf(veh.OMV) : usedCar.OMV__c;
                                usedCar.ARF__c 				 = String.isNotBlank(veh.ARF) ? Double.valueOf(veh.ARF) : usedCar.ARF__c;
                                usedCar.Engine_Capcity__c 	 = String.isNotBlank(veh.ENGINECAPACITY) ? Double.valueOf(veh.ENGINECAPACITY) : usedCar.Engine_Capcity__c;
                                usedCar.Mileage__c			 = String.isNotBlank(veh.MILAGE) ? Double.valueOf(veh.MILAGE) : usedCar.Mileage__c;
                                usedCar.No_owner__c 		 = String.isNotBlank(veh.NOOFOWNDER) ? Decimal.valueOf(veh.NOOFOWNDER) : usedCar.No_owner__c;
                                usedCar.Age_of_Vehicle__c 	 = String.isNotBlank(veh.AGEOFVEHICLE) ? Double.valueOf(veh.AGEOFVEHICLE) : usedCar.Age_of_Vehicle__c;

                                String[] regDates = String.isNotBlank(veh.REGDATE) ? veh.REGDATE.split('-') : null;
                                usedCar.Registration_Date__c = regDates != null ? Date.newinstance(Integer.valueOf(regDates[0]),Integer.valueOf(regDates[1]),Integer.valueOf(regDates[2])) : usedCar.Registration_Date__c;
                                String[] soldDates = String.isNotBlank(veh.SOLDDATE) ? veh.SOLDDATE.split('-') : null;
                                usedCar.Stock_Sold_Date__c 	= soldDates != null ? Date.newinstance(Integer.valueOf(soldDates[0]),Integer.valueOf(soldDates[1]),Integer.valueOf(soldDates[2])) : usedCar.Registration_Date__c;
                                
                                if( String.isNotBlank(veh.EMAIL) ) {
                                    //create Customer
                                    Customer customer = new Customer();
                                    customer.Name  = veh.CUSTOMERNAME;
                                    customer.Email     = veh.EMAIL.toLowerCase();
                                    customer.Mobile    = veh.MOBILE;
                                    customer.Consent   = veh.CONSENT;

                                    mapEmailToCustomer.put(customer.Email, customer);
                                    mapStockNoWithUsedCar.put(usedCar.Stock_Number__c, usedCar);
                                    mapStockNoWithCustomerEmail.put(usedCar.Stock_Number__c, customer.Email);
                                } else {

                                    usedCar.Account__c = null;
                                    usedCar.Contact__c = null;
                                    usedCar.Vehicle_Status__c = 'Open';
                                    lstUsedCarWithNoCustomer.add(usedCar);
                                }
                                setStockRerv.add(usedCar.Stock_Number__c);

                                String modelGroupName = veh.MAKE + ' ' + veh.MODEL;
                                modelGroupMap.put(modelGroupName, new UsedCarVehicleSizingService.ModelGroup(veh.MAKE, veh.MODEL));
                            }
                        }
                    }
                }
            }

            Map<String, Used_Car_Vehicle_Stock__c> mapExistingUsedCar = UsedCarVehicleStockService.getVehicleStockMapByStockNumbers(setStockRerv);
            for(Used_Car_Vehicle_Stock__c uc: lstUsedCarWithNoCustomer)
            {
                uc.Id = mapExistingUsedCar.get(uc.Stock_Number__c) != null? mapExistingUsedCar.get(uc.Stock_Number__c).Id : uc.Id;
                lstUsedCar.add(uc);
            }

            if(mapStockNoWithCustomerEmail.size() > 0)
            {
                //Checking vehicle stock
                Set<String> setExistingStockResv = new Set<String>();
                Set<ID> setIdOfSaleOppts = new Set<ID>();

                Map<String, Vehicle_Stock_Reservation__c> vehStockRsvMap = setStockRerv.size() > 0 ? getMapExistingStockReservations(setStockRerv) : new Map<String, Vehicle_Stock_Reservation__c>();

                if(vehStockRsvMap.size() > 0)
                {
                    setExistingStockResv = vehStockRsvMap.keySet();
                    for(String stockNo : vehStockRsvMap.keySet())
                    {
                        if(mapStockNoWithCustomerEmail.get(stockNo) != null)
                        {
                            System.debug('@@@@DEBUG Close_Date__c = ' + vehStockRsvMap.get(stockNo).Sales_Opportunity__r.Close_Date__c);
                            System.debug('@@@@DEBUG monthsBetween = ' + vehStockRsvMap.get(stockNo).Sales_Opportunity__r.Close_Date__c.monthsBetween(Date.today()));
                            System.debug('@@@@DEBUG stock reservation status = ' + vehStockRsvMap.get(stockNo).Sales_Opportunity__r.Status__c);

                            if(vehStockRsvMap.get(stockNo).Sales_Opportunity__r.Close_Date__c.monthsBetween(Date.today()) < 6 && vehStockRsvMap.get(stockNo).Sales_Opportunity__r.Status__c == 'Stock Reserve')
                            {
                                setIdOfSaleOppts.add(vehStockRsvMap.get(stockNo).Sales_Opportunity__c);
                            }
                        }
                    }
                }
                
                SalesOpportunityService.updateSalesOpptListByIdsAndStatus(setIdOfSaleOppts, 'Booked'); //Update Oppt stage to Booked
              
                Set<String> setCustomerEmails = mapEmailToCustomer.keySet();
                Map<String, Account> existingCustomers = setCustomerEmails.size() > 0 ? getMapEmailPersonAccountsByEmails(setCustomerEmails) : new Map<String, Account>();
                Map<String, Account> upsertedCustomerByEmail = upsertCustomers(mapEmailToCustomer, existingCustomers);

                for(Used_Car_Vehicle_Stock__c uc : mapStockNoWithUsedCar.values())
                {
                    String email = mapStockNoWithCustomerEmail.get(uc.Stock_Number__c);
                    Account customer = upsertedCustomerByEmail.get(email);
                    
                    uc.Id = mapExistingUsedCar.get(uc.Stock_Number__c) != null? mapExistingUsedCar.get(uc.Stock_Number__c).Id : uc.Id;
                    uc.Account__c = customer.Id;
                    uc.Contact__c = customer.PersonContactId;
                    if( uc.Account__c != null ) 
                    {
                        uc.Vehicle_Status__c = 'Sold';
                    }
                    lstUsedCar.add(uc);
                }
            }

            UCSizingMap = UsedCarVehicleSizingService.checkAndCreateNewUCSizing(modelGroupMap);
            for (Used_Car_Vehicle_Stock__c rcd : lstUsedCar)
            {
                String modelGroupName = rcd.Make__c + ' ' + rcd.Model__c;
                rcd.Used_Car_Vehicle_Sizing__c = UCSizingMap.containsKey(modelGroupName) ? UCSizingMap.get(modelGroupName).Id : rcd.Used_Car_Vehicle_Sizing__c;
            }
            
            System.debug('@@@@DEBUG Vehicle :: lstUsedCar = ' + lstUsedCar.size() );
            System.debug('@@@@DEBUG Vehicle :: lstUsedCar = ' + lstUsedCar);
            upsert lstUsedCar;
        }
        catch( Exception ex )
        {
            System.debug('@@@@DEBUG getVehicleFromUCS :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            loggerDataPool.buildLogDataPool('syncVehicleFromUCS', ex);
        }
    }

    //Added by Khanh
    private static Map<String, Account> upsertCustomers(Map<String, Customer> customersToUpsert, Map<String, Account> existingCustomers) {
       
        
        Id default_RA_Owner = (Id) RA_GlobalVar.Default_RA_OwnerId__c;
        Id customerRecTypeId = AccountUtil.getCustomerRecordTypeId();
        Id defaultOwnerId = AccountUtil.getDefaultAccountOwnerId();
        
        Map<String, Account> mapCustomerEmails = new Map<String, Account>();
        List<Account> customers = new List<Account>();


        for(String email: customersToUpsert.keySet()) {            
            Account customer = new Account();
            Customer wrapper = customersToUpsert.get(email);
            if(existingCustomers.containsKey(email)) {
                customer = existingCustomers.get(email);
            } 
            customer.RecordTypeId = customerRecTypeId;
            if(defaultOwnerId != null) {
            	customer.OwnerId      = defaultOwnerId;                
            }
            customer.RA_Owner__c  = default_RA_Owner;
            customer.LastName     = String.isNotBlank(wrapper.Name) ? wrapper.Name : customer.LastName;
            customer.Full_Name__pc = String.isNotBlank(wrapper.Name) ? wrapper.Name : customer.Full_Name__pc;
            customer.PersonEmail       = String.isNotBlank(wrapper.Email) ? wrapper.Email : customer.PersonEmail;
            customer.PersonMobilePhone = String.isNotBlank(wrapper.Mobile) ? wrapper.Mobile : customer.PersonMobilePhone; 
            if(String.isNotBlank(wrapper.Consent) && wrapper.Consent.equalsIgnoreCase('YES')){
                customer.Email__pc = true;
                customer.Call__pc  = true;
                customer.Fax__pc   = true;
                customer.SMS__pc   = true;
            }

            mapCustomerEmails.put(customer.PersonEmail, customer);
            customers.add(customer);
        }
        
        if(customers.size() > 0) {
            upsert customers;
            AccountUtil.createProfilings( CONST_PA_PROFILING_RA, customers);
        }

        System.debug('existing MapPersonAccount :: ' + getMapEmailPersonAccountsByEmails(mapCustomerEmails.keySet()).size() + ' : ' + getMapEmailPersonAccountsByEmails(mapCustomerEmails.keySet()));
        return getMapEmailPersonAccountsByEmails(mapCustomerEmails.keySet());
    }
    
    private static Map<String, Account> getMapEmailPersonAccountsByEmails( Set<String> setOfPAEmails){
        Map<String, Account> mapEmailAccounts = new Map<String, Account> ();

        for( Account acct : AccountUtil.getPersonAccountsByEmails( setOfPAEmails ) ){
            mapEmailAccounts.put( acct.PersonEmail, acct );
        }
       
        return mapEmailAccounts;
    }

    private static Map<String, Vehicle_Stock_Reservation__c> getMapExistingStockReservations( Set<String> setStockRerv){
        Map<String, Vehicle_Stock_Reservation__c> mapStockNoWithStockReservation = new Map<String, Vehicle_Stock_Reservation__c> ();
        List<Vehicle_Stock_Reservation__c> vehStockRsv = VehicleStockReservationService.getReservationByStockNo(setStockRerv);
        if(vehStockRsv.size() > 0){
            for(Vehicle_Stock_Reservation__c vsr : vehStockRsv){
                if(setStockRerv.contains(vsr.Used_Car_Vehicle_Stock__r.Stock_Number__c)){
                    mapStockNoWithStockReservation.put(vsr.Used_Car_Vehicle_Stock__r.Stock_Number__c, vsr);
                    setStockRerv.remove(vsr.Used_Car_Vehicle_Stock__r.Stock_Number__c);
                    //break;
                }
            }
        }
        System.debug('existing StockReservation :: ' + mapStockNoWithStockReservation.size() + ' : ' + mapStockNoWithStockReservation);
        return mapStockNoWithStockReservation;
    }

    private static Boolean checkValidEmail(String email){
        Boolean isValid = false;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

        Pattern EmailPattern = Pattern.compile(emailRegex);
        Matcher EmailMatcher = EmailPattern.matcher( email );
        if (EmailMatcher.matches()) {
            isValid = true;
        }
        return isValid;
    }
    
    public class Vehicle {
        public String VEHDOCNO;
        public String VEHNO;
        public String MAKE;
        public String MODEL;
        public String LISTINGPRICE;
        public String COE;
        public String OMV;
        public String ARF;
        public String ENGINECAPACITY;
        public String REGDATE;
        public String MILAGE;
        public String NOOFOWNDER;
        public String AGEOFVEHICLE;
        public String SOLDDATE;
        public String CUSTOMERNAME;
        public String MOBILE;
        public String EMAIL;
        public String CONSENT;
    }

    private class Customer {
        public String Name;
        public String Mobile;
        public String Email;
        public String Consent;
    }
}
/** *****
 * Description : Service Class to invoke DWH API to sync the vehicle credit data
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                 Description
 * 20200622            HS@aodigy            Created Initial Version 
 * 
** *****/
public inherited Sharing class DWH_CreditTransactionService {
    
    private static RegisteredVehicleSelector registeredVehSelector = new RegisteredVehicleSelector();

    // @future(callout=true)
    public static void getVSMSCreditTransactionDataCount(Datetime fromDate, Datetime toDate)
    {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        DateTime sFromDate = fromDate <> null ? fromDate : ( lastRunDateVar.Credit_Transaction_Sync_From__c	 <> null ? (Datetime)lastRunDateVar.Credit_Transaction_Sync_From__c	 : Datetime.now().addDays( -1 ) );
        DateTime sToDate = toDate <> null ? toDate : ( lastRunDateVar.Credit_Transaction_Sync_To__c <> null ? (Datetime)lastRunDateVar.Credit_Transaction_Sync_To__c : Datetime.now().addDays( -1 ) );        
        String formattedFromDate = sFromDate.format('yyyy-MM-dd');   
        String formattedToDate = sFromDate.format('yyyy-MM-dd');
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        request.setEndpoint(APIGateway_url+'/vSMS/Credit/Count?from=' + formattedFromDate + '&to=' + formattedToDate);
        request.setMethod('GET');
        request.setHeader('apikey', APIGateway_key); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(120000);

        try {   
            response = http.send(request);
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Integer noOfRecords = (Integer)responseMap.get('totalNumberOfRecords');

            System.debug('@@@@DEBUG getVSMSCreditTransactionDataCount :: noOfRecords = ' + noOfRecords );
            lastRunDateVar.Credit_Transaction_NumberOfPages__c = ( noOfRecords > 0 && noOfRecords > lastRunDateVar.Credit_Transaction_NumRecords__c ) ?  (noOfRecords/lastRunDateVar.Credit_Transaction_NumRecords__c).round(System.RoundingMode.CEILING) : 1;
            System.debug('Credit_Transaction_NumberOfPages__c = ' + lastRunDateVar.Credit_Transaction_NumberOfPages__c);
            System.debug('Credit_Transaction_NumRecords__c = ' + lastRunDateVar.Credit_Transaction_NumRecords__c);
            update lastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('getVSMSCreditTransactionDataCount', 'DWH_CreditTransactionService', '', request, response);
        }
        catch(Exception e) 
        {
            System.debug('@@@@DEBUG getVSMSCreditTransactionDataCount :: Error = ' + e );
            loggerDataPool.buildLogDataPool('getVSMSCreditTransactionDataCount', e);
        }
    }


    // @future (callout=true)
    // public static void getVehicleCreditDataFromDWH(Integer pageNum, Datetime p_fromDate, Datetime p_toDate) {
    public static HttpResponse getVehicleCreditDataFromDWH(Integer pageNum, Datetime p_fromDate, Datetime p_toDate) {

        HttpRequest req  = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http        = new Http();
    
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        DateTime sFromDate = p_fromDate <> null ? p_fromDate : ( lastRunDateVar.Credit_Transaction_Sync_From__c <> null ? (Datetime)lastRunDateVar.Credit_Transaction_Sync_From__c : Datetime.now().addDays( -1 ) );
        DateTime sToDate   = p_toDate <> null ? p_toDate : ( lastRunDateVar.Credit_Transaction_Sync_To__c <> null ? (Datetime)lastRunDateVar.Credit_Transaction_Sync_To__c : Datetime.now().addDays( -1 ) );

        String strFromDate = sFromDate.format('yyyy-MM-dd');   
        String strToDate   = sToDate.format('yyyy-MM-dd');
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        String numRecs = lastRunDateVar.Credit_Transaction_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Credit_Transaction_NumRecords__c.intValue()): '2000';
        
        String strEndPoint = APIGateway_url+'/vSMS/Credit?from='+strFromDate+'&to='+strToDate+'&noOfRecords='+numRecs+'&pageNo='+pageNum;

        System.debug('@@@@DEBUG getVehicleCreditDataFromDWH :: strEndPoint = ' + strEndPoint ); 
        req.setEndpoint( strEndPoint );
        req.setMethod('GET');
        req.setHeader('apikey', APIGateway_key);
        req.setHeader('Content-Type', 'application/json'); 
        req.setTimeout(120000);
        
        try {       
            res = http.send(req);
            // syncVehicleCreditDataFromDWH(res);
            System.debug('@@@@DEBUG getVehicleCreditDataFromDWH :: res.getBody() = ' + res.getBody() );
            serviceDataPool.buildServiceDataPoolHttp('getVehicleCreditDataFromDWH', 'DWH_CreditTransactionService', '', req, res);
        }
        catch(exception ex ) {
            System.debug( '@@@@DEBUG getVehicleCreditDataFromDWH ERROR :: ' + ex.getMessage() );
            loggerDataPool.buildLogDataPool('DWH_CreditTransactionService', ex);
        }
        return res;
    }


    public static void syncVehicleCreditDataFromDWH( HttpResponse res ) {

        List<Transaction__c> lstTransactionsToInsert = new list<Transaction__c>();
        Boolean isSuccess = true;
        try
        {
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: res.getBody() = ' + res.getBody() );

            while (parser.nextToken() != null) {             
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {

                            VehicleCreditTransaction var = (VehicleCreditTransaction)parser.readValueAs(VehicleCreditTransaction.class);
                            System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: var = ' + var );

                            Transaction__c vTrxn = new Transaction__c();
                            vTrxn.P__c        = var.preparation_type;
                            vTrxn.SRC__c      = var.source_code;
                            vTrxn.FRAN__c     = var.franchise;
                            vTrxn.VEHMAGIC__c = var.vehicle_magic;
                            vTrxn.REGN__c     = var.vehicle_reg_no;
                            vTrxn.CHASSIS__c  = var.vehicle_chassis;
                            vTrxn.SEQ__c      = var.sequence <> null ? Decimal.valueof( var.sequence ) : null;
                            vTrxn.TARMAGIC__c = var.customer_magic;
                            vTrxn.NRIC__c     = var.nric;
                            vTrxn.FLEET__c    = var.fleet_y;
                            vTrxn.CR_AMT__c   = var.credit_amount <> null ? Decimal.valueof( var.credit_amount ) : null;
                            vTrxn.MISC_REF__c = var.misc_ref;
                            vTrxn.EXPIRY__c   = DWH_CreditTransactionService.isValidDate( var.expiry_date ) ? var.expiry_date.date() : null;
                            vTrxn.COST__c     = var.cost_center_dept;
                            //vTrxn.NLCODE__c   = var.NLCODE;
                            //vTrxn.Customer_Name__c = var.CUSTOMER_NAME;
                            //var.svc_credit_expiry_date
                            //registration_date
                            
                            lstTransactionsToInsert.add( vTrxn );
                        }
                    }
                }
            }

            
            if( !lstTransactionsToInsert.isEmpty() )
            {
                DWH_CreditTransactionService.linkVehicleCreditTrxnRecordType( lstTransactionsToInsert );
                
                System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: lstTransactionsToInsert = ' + lstTransactionsToInsert.size() + ' --- ' + lstTransactionsToInsert );
                Database.SaveResult[] results = Database.insert( lstTransactionsToInsert, false);       
                for(Integer index = 0, size = results.size(); index < size; index++) 
                {
                    System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: results [ '+ index  + ' ]  = '  + results [ index ]  );
                    if( !results[index].isSuccess() ) {
                        isSuccess = false;
                        break;
                    }
                }
            } 
        }
        catch( Exception ex )
        {
            isSuccess = false;
            System.debug('@@@@DEBUG DWH_CreditTransactionService :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            loggerDataPool.buildLogDataPool('DWH_CreditTransactionService', ex);
        }
    }


    private static Boolean isValidDate( DateTime dtValueRef ){
        //For Null Dates
        String nullDate = '0001';
        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
        Pattern myPattern = Pattern.compile(dateRegEx);
        Boolean isValid = false;

        if( dtValueRef != null ) {
            if(String.valueOf( dtValueRef ).startsWith(nullDate)) {
                isValid = false;                                          
            }
            else if(myPattern.matcher(String.valueOf(dtValueRef.date())).matches()) {
                isValid = true;
            }
        }
        return isValid;
    }


    private static void linkVehicleCreditTrxnRecordType( List<Transaction__c> lstVehicleCredits ) {
        Schema.DescribeSObjectResult rvSObj = Schema.SObjectType.Transaction__c; 
        Map<String,Schema.RecordTypeInfo> mapVehicleCreditRecordType = rvSObj.getRecordTypeInfosByDeveloperName();
        for( Transaction__c vc : lstVehicleCredits ){
            String strKey = 'External_SRC_Transaction_RT';
            if( mapVehicleCreditRecordType.containsKey( strKey ) ){
                vc.RecordTypeId = mapVehicleCreditRecordType.get( strKey ).getRecordTypeId();
            }
        }
    }


    public static void updateDWHcustomSetting( Boolean isSuccess ){
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults(); 
        lastRunDateVar.Vehicle_Credit_Sync_Success__c = isSuccess;
        if( isSuccess ) {
            lastRunDateVar.Credit_Transaction_Sync_From__c = Date.Today();
            lastRunDateVar.Credit_Transaction_Sync_To__c   = Date.Today();
        }
        upsert lastRunDateVar;
    }
    

    public class VehicleCreditTransaction {
        public String preparation_type;
        public String source_code;
        public String franchise;
        public String vehicle_magic;
        public String vehicle_reg_no;
        public String vehicle_chassis;
        public String sequence;
        public String customer_magic;
        public String nric;
        public String fleet_y;
        public String credit_amount;
        public String misc_ref;
        public Datetime registration_date;
        public Datetime expiry_date;
        public Datetime svc_credit_expiry_date;
        public String cost_center_dept;
    }
}
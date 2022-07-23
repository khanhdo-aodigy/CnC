/** *****
* Description :  DWH aftersales API.
*
* Change History
* Date(YYYYMMDD)      Name       		Description
* 20200915            huynh.hung       Created Initial Version.
*
** *****/
global class DWH_AftersalesServiceHeader{
    public static List<String> msgs = new List<String>();

    public static Integer noOfRecords = 0;
    
    public DWH_AftersalesServiceHeader() {}

    public static void getPostServiceHeaderDataFromDWHCount(Datetime fromDate, Datetime toDate) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    

        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();
        DateTime requestFromDate = fromDate <> null ? fromDate : ( lastRunDateVar.Post_Service_Sync_From__c	 <> null ? (Datetime)lastRunDateVar.Post_Service_Sync_From__c : Datetime.now().addDays(-1));
        DateTime requestToDate = toDate <> null ? toDate : ( lastRunDateVar.Post_Service_Sync_To__c <> null ? (Datetime)lastRunDateVar.Post_Service_Sync_To__c : Datetime.now().addDays(-1));
        String formattedFromDate   = requestFromDate.format('yyyy-MM-dd');
        String formattedToDate   = requestToDate.format('yyyy-MM-dd');

        request.setEndpoint(APIGateway_url+'/DWHAPI/GetServiceHistory_DWH_Count?fromDate=' + formattedFromDate + '&toDate=' + formattedToDate);
        request.setMethod('GET');
        request.setHeader('apikey', APIGateway_key); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(120000);

        try 
        {   
            response = http.send(request);
            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            noOfRecords = (Integer)responseMap.get('totalNumberOfRecords');

            System.debug('@@@@DEBUG GetServiceHistory_DWH_Count :: noOfRecords = ' + noOfRecords );
            lastRunDateVar.Post_Service_NumberOfPages__c = ( noOfRecords > 0 && noOfRecords > lastRunDateVar.Post_Service_NumRecords__c ) ?  (noOfRecords/lastRunDateVar.Post_Service_NumRecords__c).round(System.RoundingMode.CEILING) : 1;
            System.debug('Post_Service_NumberOfPages__c = ' + lastRunDateVar.Post_Service_NumberOfPages__c);
            System.debug('Post_Service_NumRecords__c = ' + lastRunDateVar.Post_Service_NumRecords__c);
            update lastRunDateVar;
            
            serviceDataPool.buildServiceDataPoolHttp('GetServiceHistory_DWH_Count', 'DWH_AftersalesServiceHeader', '', request, response);
        }
        catch(Exception e) 
        {
            System.debug('@@@@DEBUG GetServiceHistory_DWH_Count :: Error = ' + e );
            loggerDataPool.buildLogDataPool('DWH_AftersalesServiceHeader.getPostServiceHeaderDataFromDWHCount', e);
        }
    }

    
    //@future (callout=true)
    public static HttpResponse getPostServiceHeaderDataFromDWH(Integer pageNum, Datetime fromDate, Datetime toDate)
    {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();    
        
        global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults();      
        String APIGateway_url = (String)JCC_GlobalVar.APIGateway_url__c;
        String APIGateway_key = (String)JCC_GlobalVar.APIGateway_key__c;
        
        DWH_last_run_date__c lastRunDateVar = DWH_last_run_date__c.getOrgDefaults();      
        DateTime requestFromDate = fromDate <> null ? fromDate : ( lastRunDateVar.Post_Service_Sync_From__c	 <> null ? (Datetime)lastRunDateVar.Post_Service_Sync_From__c : Datetime.now().addDays(-1));
        DateTime requestToDate = toDate <> null ? toDate : ( lastRunDateVar.Post_Service_Sync_To__c <> null ? (Datetime)lastRunDateVar.Post_Service_Sync_To__c : Datetime.now().addDays(-1));
        String formattedFromDate   = requestFromDate.format('yyyy-MM-dd');
		String formattedToDate   = requestToDate.format('yyyy-MM-dd');
        
        String numRecs = lastRunDateVar.Post_Service_NumRecords__c <> null ? String.valueOf(lastRunDateVar.Post_Service_NumRecords__c.intValue()): '1000';

        request.setEndpoint(APIGateway_url+'/DWHAPI/GetServiceHistory_DWH?fromDate=' + formattedFromDate + '&toDate=' + formattedToDate + '&noOfRecords='+numRecs+'&pageNo='+pageNum);
		        //request.setEndpoint(APIGateway_url+'/DWHAPI/GetServiceHistory_DWH?fromDate=2020/09/01&toDate=2020/10/01&noOfRecords='+numRecs+'&pageNo='+pageNum);

        request.setMethod('GET');
        request.setHeader('apiKey', APIGateway_key); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setTimeout(120000);
        
        try {   
            response = http.send(request);
            syncPostServiceHeaderDataFromDWH(response);
            serviceDataPool.buildServiceDataPoolHttp('getPostServiceHeaderDataFromDWH', 'DWH_AftersalesServiceHeader', '', request, response);
        }
        catch(Exception e) 
        {
            System.debug('@@@@DEBUG getPostServiceHeaderDataFromDWH :: Error = ' + e );
        }
        return response;
    }
  
    
    public static void syncPostServiceHeaderDataFromDWH( HttpResponse res) {
        List<Post_Service_Header__c> lstPSHToInsert = new list<Post_Service_Header__c>();
        Map<String,Post_Service_Header__c> pshMap = new Map<String,Post_Service_Header__c>();
		Set<String> duplicatedCheckingSet = new Set<String>();
        try
        {
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {     
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            ServiceHeader sh = (ServiceHeader)parser.readValueAs(ServiceHeader.class);
                            System.debug('@@@@DEBUG syncVehicleCreditDataFromDWH :: sh = ' + sh );

                            Post_Service_Header__c psh = new Post_Service_Header__c();
                            psh.Magic_ID__c = sh.MAGIC_CUSTOMER;
                            psh.WDateOut__c = Date.valueOf(sh.WDATEOUT.substring(0, 10));
                            psh.Chasis__c = sh.CHASSIS;
                            psh.REGNO__c = sh.REGNO;
                            psh.OPCREATE__c = sh.OPCREATE;
                            psh.Service_Advisor__c = sh.OPERATOR_NAME;
                            psh.INVNO__c = sh.INVNO;
                            psh.COMPANY_ID__c = sh.COMPANY_ID;
                            psh.SERVCODE__c = sh.SERVCODE;
                            psh.VALUE__c = Double.valueOf(sh.VALUE);
                            
                            if(pshMap.size() > 0){
                                for(Post_Service_Header__c tempPsh : pshMap.values()){
                                    if(psh.Magic_ID__c != tempPsh.Magic_ID__c && psh.Chasis__c != tempPsh.Chasis__c && psh.WDateOut__c == tempPsh.WDateOut__c){
                                           //System.debug(psh);
                                           pshMap.put(sh.CHASSIS, psh);
                                       }
                                } 
                            }
                            else{
                                pshMap.put(sh.CHASSIS, psh);
                            }
                            
                            duplicatedCheckingSet.add(sh.CHASSIS + sh.MAGIC_CUSTOMER + sh.INVNO);
                        }
                    }
                }
            }
            
            noOfRecords = pshMap.size();
            
            if(noOfRecords == 0){
                sendAPINotificationEmail();
                return;
            }

			//Get Service Center by Company_Id
            List<POS_Company__mdt> companyMdt = [SELECT NAME__c, COMPANY_ID__c FROM POS_Company__mdt];
            Map<Double, String> companyMap = new Map<Double, String>();
            for(POS_Company__mdt com : companyMdt){
                companyMap.put(com.COMPANY_ID__c, com.NAME__c);
            }
            
            //Check Duplicate
            List<Post_Service_Header__c>  pshLst= [SELECT Id, Magic_ID__c, Chasis__c, INVNO__c FROM Post_Service_Header__c WHERE DuplicatedChecking__c IN :duplicatedCheckingSet];
            if(pshLst.size() > 0){
                for(Post_Service_Header__c psh : pshLst){
                    if(psh.Magic_ID__c == pshMap.get(psh.Chasis__c).Magic_ID__c && psh.INVNO__c == pshMap.get(psh.Chasis__c).INVNO__c){
                        pshMap.remove(psh.Chasis__c);
                        //msgs.add('PSH record with ID ' + psh.Id + 'is duplicated.');
                    }
                }
                //msgs.add('----------------------');
            }
            
            
            //Link PSH to RV and Account
            RegisteredVehicleSelector rvSelector = new RegisteredVehicleSelector();
            List<Registered_Vehicle__c> regVehLst = rvSelector.selectByChassisNumberAndMagicCustomer(pshMap.keySet());
            //System.debug('RV list : '+regVehLst.size());

            for(Registered_Vehicle__c rv : regVehLst){
                if(rv.MagicCustomer__c == pshMap.get(rv.Chasis_Number__c).Magic_ID__c){
                    Post_Service_Header__c psh = pshMap.get(rv.Chasis_Number__c);
                    psh.Account__c = rv.Account__c;
                    psh.Registered_Vehicle__c = rv.Id;
                    psh.Service_Center__c = companyMap.get(Double.valueOf(psh.COMPANY_ID__c));
                    lstPSHToInsert.add(psh);
                }
            }
            
            
			System.debug('PSH list insert: ' + lstPSHToInsert.size());
            
            if(lstPSHToInsert.size() > 0){
                Database.UpsertResult[] results = Database.upsert(lstPSHToInsert ,false);       
                /*for(Integer index = 0, size = results.size(); index < size; index++) 
                {
                    if(results[index].isSuccess()) 
                    {
                        if(results[index].isCreated()) 
                        {                   
                            msgs.add(lstPSHToInsert[index].Magic_ID__c +' was created.');
                            System.debug(lstPSHToInsert[index].Magic_ID__c +' was created');
                        }                   
                    }
                    else
                    {
                        msgs.add(lstPSHToInsert[index].Magic_ID__c +' had error '+results[index].getErrors());
                    }
                }*/
            }
        }
        catch( Exception ex )
        {
            System.debug('@@@@DEBUG getPostServiceHeaderDataFromDWH :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            //msgs.add('getPostServiceHeaderDataFromDWH :: err cause = '+ ex.getCause() + ' --- err msg = ' + ex.getMessage() + ' --- err line# : ' + ex.getLineNumber()  );
            loggerDataPool.buildLogDataPool('syncPostServiceHeaderDataFromDWH', ex);
        }
    }
    
    public static void sendAPINotificationEmail(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses              = new String[] {'kevin.lee@cyclecarriage.com.sg', 'benjamin.kwek@cyclecarriage.com.sg', 'engtze.tan@cyclecarriage.com.sg'};//'kevin.lee@cyclecarriage.com.sg', 'benjamin.kwek@cyclecarriage.com.sg', 'engtze.tan@cyclecarriage.com.sg'
        mail.setToAddresses(toAddresses);
        
        String body = '';
        DateTime convertedYesterday = Date.today().addDays(-1);
        String formattedYesterday = convertedYesterday.format('yyyy-MM-dd');
        mail.setSubject('Warning: Aftersales Survey ' + formattedYesterday + ' - 0 records found on API sync');
        body = 'Warning, 0 record found on the API Sync for the Aftersales Survey. Please double check whether there are any errors.';
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public class ServiceHeader {
        public String MAGIC_CUSTOMER;
        public String WDATEOUT;
        public String CHASSIS;
        public String REGNO;
        public String OPCREATE;
        public String OPERATOR_NAME;
        public String INVNO;
        public String SERVCODE;
        public String COMPANY_ID;
        public Double VALUE;
    }

}
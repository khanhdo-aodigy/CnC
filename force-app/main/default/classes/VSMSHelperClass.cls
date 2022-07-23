/** ******
 * Description: Domain class used to push data from SFDC to VSMS
 * 
 * Change History:
 * Date(YYYYMMDD)       Name        		        Description
 * 20151118             Billy Cheng                 Created Initial Version. 
 * 20200310             HS@aodigy                   Refactored code; Added PA Migration changes
 * 20200929             Thu@aodigy                  Added PA migration phase 2 changes.
 * 
** ******/
global without sharing class VSMSHelperClass {
    static Boolean justTest = false;
    
    @future (callout=true)
    public static void pushData(String cid,String createby, String nric) {
        
        String custNric =  nric;
        if (cid==null || cid==''){
            return;
        }
        if (createby==null || createby==''){
            return;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string url = Label.VSMS_Webservice;
        
        List<Contact> lstContact = new List<Contact>();
        lstContact = [SELECT Id, Name, NRIC_Passport_No__c, MobilePhone, Email, Birthdate, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c,
                            Unit_No_Floor__c, Postal_Code__r.Name, Country__c,Gender__c
                      FROM Contact 
                      WHERE Id=:cid];
        
        Contact c = ( lstContact <> null && !lstContact.isEmpty() ) ? lstContact.get(0) : null;

        if( c <> null )
        {
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            DateTime dt = c.Birthdate;
            String sbod = '';
            if (dt != null){
                sbod=dt.format('dd/MM/YYYY');
            }
            String Gender = '';
            if (c.Gender__c == 'Male'){
                Gender = 'M';
            }
            if (c.Gender__c == 'Female'){
                Gender = 'F';
            }

            String theBody='strBRM='+
                    '&strCATEGORY='+
                    '&strNRICFLAG='+
                    //'&strNRICPSPTCPY='+ EncodingUtil.urlEncode(c.NRIC_Passport_No__c,'UTF-8') +
                    '&strNRICPSPTCPY='+ EncodingUtil.urlEncode( (String.isNotBlank( custNric ) ? custNric : ''),'UTF-8') +
                    '&strFIRSTNAME='+ EncodingUtil.urlEncode( c.name,'UTF-8') +
                    '&strMAILPHONE1='+ EncodingUtil.urlEncode( (String.isNotBlank( c.MobilePhone ) ? c.MobilePhone : '') ,'UTF-8') +
                    '&strMAILMOBILE='+ EncodingUtil.urlEncode( (String.isNotBlank( c.MobilePhone ) ? c.MobilePhone : '') ,'UTF-8') +
                    '&strCREATEDBY='+ EncodingUtil.urlEncode( (String.isNotBlank( createby ) ? createby : '') ,'UTF-8') +
                    '&strSTATUS='+
                    '&strGENDER='+ EncodingUtil.urlEncode(Gender,'UTF-8') +
                    '&dtDOB='+ EncodingUtil.urlEncode(sbod,'UTF-8');

            System.debug('@@@@DEBUG pushData :: theBody = ' + theBody );

            if (c.Postal_Code__r.Name!=null){
                theBody = theBody + '&strPOSTCODE='+ EncodingUtil.urlEncode(c.Postal_Code__r.Name,'UTF-8');
            }
            else{
                theBody = theBody + '&strPOSTCODE=';
            }
            
            if (c.Unit_No_Floor__c!=null){
                theBody = theBody + '&strUNIT='+ EncodingUtil.urlEncode(c.Unit_No_Floor__c,'UTF-8');
            }
            else{
                theBody = theBody + '&strUNIT=';
            }
            
            if (c.Address_Line_1__c!=null){
                theBody = theBody + '&strADDRESS1='+ EncodingUtil.urlEncode(c.Address_Line_1__c,'UTF-8');
            }
            else{
                theBody = theBody + '&strADDRESS1=';
            }
            
            if (c.Address_Line_2__c!=null){
                theBody = theBody + '&strADDRESS2='+ EncodingUtil.urlEncode(c.Address_Line_2__c,'UTF-8');
            }
            else{
                theBody = theBody + '&strADDRESS2=';
            }
            
            if (c.Address_Line_3__c!=null){
                theBody = theBody + '&strADDRESS3='+ EncodingUtil.urlEncode(c.Address_Line_3__c,'UTF-8');
            }
            else{
                theBody = theBody + '&strADDRESS3=';
            }
            theBody = theBody + '&strADDRESS4='+'&strCITY='+ EncodingUtil.urlEncode('Singapore','UTF-8');
                        
                    
            req.setHeader('Content-Length', theBody.length() +'');
                    
            req.setBody(theBody);
                    
            if (justTest==false){
                //if (!Test.isRunningTest()) res = h.send(req);
                //System.debug(res.getBody());
            }
        }
    }
    
    @future (callout=true)
    public static void insertSR(String srid,String createby) {
        
        if (srid==null || srid==''){
            return;
        }
        if (createby==null || createby==''){
            return;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        //string url = Label.VSMSSRInsert;
        String url = Label.GatewaySRUpsert  + '/ReserveStock';
        String apiKey = (String) global_var__c.getOrgDefaults().APIGateway_key__c;
        System.debug('Debug URL ::: ' + url + ' ' + apiKey);
        
        List<Stock_Reservation__c> lstStockReservation = new List<Stock_Reservation__c>();
        lstStockReservation = [ SELECT Id, Name, Franchise_Code__c, Model_Code__r.name, Model_Year_Code__r.ModelYear__c, Customer_Social_ID__c, 
                                    Trim_Code__r.name, Color_Code__r.Name, Vehicle_Master__r.System_Commcase__c, Downpayment_No__c, Reservation_Status__c, Owner.name,Comment__c, Reservation_Date__c,
                                    Opportunity__r.Contact_Person__c, Opportunity__r.Contact_Person__r.NRIC_Passport_No__c, Opportunity__r.Contact_Person__r.LastName,
                                    Opportunity__r.Account__c, Opportunity__r.Account__r.NRIC_Passport_No__pc, Opportunity__r.Account__r.LastName, Opportunity__r.Account__r.NRIC__pc 
                                FROM Stock_Reservation__c 
                                WHERE Id = :srid ];
        
        Stock_Reservation__c SR = (lstStockReservation<>null && !lstStockReservation.isEmpty()) ? lstStockReservation.get(0) : null;

        if( SR <> null ) 
        {
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('apiKey', apiKey);
            //req.setHeader('SOAPAction','""');
            
            DateTime dt  = SR.Model_Year_Code__r.ModelYear__c;
            DateTime dt2 = SR.Reservation_Date__c;
            String sbod  = (dt!=null) ? dt.format('dd/MM/YYYY'): '';
            String sbod2 = (dt2!=null) ? dt2.format('dd/MM/YYYY'): '';
            
            String frCode    = SR.Franchise_Code__c.toUpperCase();
            String loginSF   = createby.toUpperCase();
            String modelCode = SR.Model_Code__r.name.toUpperCase();
            String trimCode  = SR.Trim_Code__r.name.toUpperCase();
            String colorCode = SR.Color_Code__r.name.toUpperCase();
            String vcoms     = ( String.isBlank(SR.Vehicle_Master__r.System_Commcase__c) ) ? 'TEMP' : SR.Vehicle_Master__r.System_Commcase__c.toUpperCase();
            String custNric  = String.isBlank(sr.Customer_Social_ID__c) ? '' : sr.Customer_Social_ID__c.toUpperCase() ;
            String custName  = '';

            if( SR.Opportunity__r.Contact_Person__c != null){
                custName = SR.Opportunity__r.Contact_Person__r.Lastname.toUpperCase();
            }

            String reserRemark  = (SR.Comment__c==null || SR.Comment__c=='') ? '' : SR.Comment__c.toUpperCase(); 
            String srStatus     = SR.Reservation_Status__c.toUpperCase();
            String ownerName    = SR.Owner.name.toUpperCase();
            String dpNo         = (SR.Downpayment_No__c==null || SR.Downpayment_No__c=='') ? '' : SR.Downpayment_No__c.toUpperCase();
            
            String theBody='Franchise_code='+ EncodingUtil.urlEncode(frCode,'UTF-8') +
                    '&SalesForce_Login='+ EncodingUtil.urlEncode(loginSF,'UTF-8') +
                    '&Model_Code='+ EncodingUtil.urlEncode(modelCode,'UTF-8') +
                    '&Model_Year='+ EncodingUtil.urlEncode(sbod,'UTF-8') +
                    '&Trim_Code='+ EncodingUtil.urlEncode(trimCode,'UTF-8') +
                    '&Color_Code='+ EncodingUtil.urlEncode(colorCode,'UTF-8') +
                    '&Vehicle_Commcase='+ EncodingUtil.urlEncode(vcoms,'UTF-8') +
                    '&Customer_NRIC='+ EncodingUtil.urlEncode(custNric,'UTF-8') +
                    '&Customer_Name='+ EncodingUtil.urlEncode(custName,'UTF-8') +
                    '&Downpaymnt_Number='+ EncodingUtil.urlEncode(dpNo,'UTF-8') +
                    '&Reservation_Remark='+ EncodingUtil.urlEncode(reserRemark,'UTF-8') +
                    '&Status='+ EncodingUtil.urlEncode(srStatus,'UTF-8') +
                    //'&ReAssign_By='+ EncodingUtil.urlEncode(ownerName,'UTF-8') +
                    //'&ReAssign_Date='+ EncodingUtil.urlEncode(sbod2,'UTF-8') +
                    '&ReAssign_By='+
                    '&ReAssign_Date='+
                    '&Cancel_Remarks='+ 
                    '&Agreement_No='+ 
                    '&Salesforce_AutoID='+EncodingUtil.urlEncode(srid,'UTF-8');

            System.debug('The Body ::: ' + theBody);
                                
            req.setHeader('Content-Length', theBody.length() +'');
                    
            req.setBody(theBody);
                    
            if (justTest==false)
            {
                if (!Test.isRunningTest())
                {
                    res = h.send(req);
                    system.debug('Response::: ' + res.getBody());
                }                 
            }
        }
    }
    
    
    @future (callout=true)
    public static void updateSR(String srid,String createby) {
        
        if (srid==null || srid==''){
            return;
        }
        if (createby==null || createby==''){
            return;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        //string url = Label.VSMSSRUpdate;
        String url = Label.GatewaySRUpsert + '/UpdateStock';
        String apiKey = (String) global_var__c.getOrgDefaults().APIGateway_key__c;
        
        List<Stock_Reservation__c> lstStockReservation = new List<Stock_Reservation__c>();
        lstStockReservation = [ SELECT id, name, Franchise_Code__c, Model_Code__r.name, Model_Year_Code__r.ModelYear__c, Customer_Social_ID__c, Trim_Code__r.name, Color_Code__r.name, 
                                    Vehicle_Master__r.System_Commcase__c, Downpayment_No__c, Reservation_Status__c, Owner.name,Comment__c, Agreement_No__c, Cancellation_Reason__c, Reservation_Date__c,
                                    Opportunity__r.Contact_Person__c, Opportunity__r.Contact_Person__r.NRIC_Passport_No__c, Opportunity__r.Contact_Person__r.LastName, 
                                    Opportunity__r.Account__c, Opportunity__r.Account__r.NRIC_Passport_No__pc, Opportunity__r.Account__r.LastName, Opportunity__r.Account__r.NRIC__pc  /** PA MIGRATION : Newly Added */
                                FROM Stock_Reservation__c 
                                WHERE id = :srid ];
        
        Stock_Reservation__c SR = (lstStockReservation<>null && !lstStockReservation.isEmpty()) ? lstStockReservation.get(0) : null;

        if( SR <> null )
        {
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('apiKey', apiKey);
            
            DateTime dt  = SR.Model_Year_Code__r.ModelYear__c;
            DateTime dt2 = SR.Reservation_Date__c;
            String sbod  = (dt!=null) ? dt.format('dd/MM/YYYY'): '';
            String sbod2 = (dt2!=null) ? dt2.format('dd/MM/YYYY'): '';
            
            String frCode    = SR.Franchise_Code__c.toUpperCase();
            String loginSF   = createby.toUpperCase();
            String modelCode = SR.Model_Code__r.name.toUpperCase();
            String trimCode  = SR.Trim_Code__r.name.toUpperCase();
            String colorCode = SR.Color_Code__r.name.toUpperCase();
            String vcoms     = (SR.Vehicle_Master__r.System_Commcase__c==null || SR.Vehicle_Master__r.System_Commcase__c=='') ? 'TEMP' : SR.Vehicle_Master__r.System_Commcase__c.toUpperCase();
            String custNric  = String.isBlank(sr.Customer_Social_ID__c) ? '' : sr.Customer_Social_ID__c.toUpperCase() ;
            String custName;

            if( SR.Opportunity__r.Account__c != null && SR.Opportunity__r.Account__r.Lastname != null ) {
                custName = SR.Opportunity__r.Account__r.Lastname.toUpperCase();
            } else if( SR.Opportunity__r.Contact_Person__c != null){
                custName = SR.Opportunity__r.Contact_Person__r.Lastname.toUpperCase();
            }

            String reserRemark  = (SR.Comment__c==null || SR.Comment__c=='') ? '' : SR.Comment__c.toUpperCase();
            String srStatus     = SR.Reservation_Status__c.toUpperCase();
            String ownerName    = SR.Owner.name.toUpperCase();
            String agreeNo      = (SR.Agreement_No__c==null || SR.Agreement_No__c=='') ? '' : SR.Agreement_No__c.toUpperCase();
            String cancelRemarks= (SR.Cancellation_Reason__c==null || SR.Cancellation_Reason__c=='') ? '' : SR.Cancellation_Reason__c.toUpperCase();
            String dpNo         = (SR.Downpayment_No__c==null || SR.Downpayment_No__c=='') ? '' : SR.Downpayment_No__c.toUpperCase();
            
            String theBody='Franchise_code='+ EncodingUtil.urlEncode(frCode,'UTF-8') +
                    '&SalesForce_Login='+ EncodingUtil.urlEncode(loginSF,'UTF-8') +
                    '&Model_Code='+ EncodingUtil.urlEncode(modelCode,'UTF-8') +
                    '&Model_Year='+ EncodingUtil.urlEncode(sbod,'UTF-8') +
                    '&Trim_Code='+ EncodingUtil.urlEncode(trimCode,'UTF-8') +
                    '&Color_Code='+ EncodingUtil.urlEncode(colorCode,'UTF-8') +
                    '&Vehicle_Commcase='+ EncodingUtil.urlEncode(vcoms,'UTF-8') +
                    '&Customer_NRIC='+ EncodingUtil.urlEncode(custNric,'UTF-8') +
                    '&Customer_Name='+ EncodingUtil.urlEncode(custName,'UTF-8') +
                    '&Downpaymnt_Number='+ EncodingUtil.urlEncode(dpNo,'UTF-8') +
                    '&Reservation_Remark='+ EncodingUtil.urlEncode(reserRemark,'UTF-8') +
                    '&Status='+ EncodingUtil.urlEncode(srStatus,'UTF-8') +
                    //'&ReAssign_By='+ EncodingUtil.urlEncode(ownerName,'UTF-8') +
                    //'&ReAssign_Date='+ EncodingUtil.urlEncode(sbod2,'UTF-8') +
                    '&ReAssign_By='+
                    '&ReAssign_Date='+
                    '&Cancel_Remarks='+ EncodingUtil.urlEncode(cancelRemarks,'UTF-8') +
                    '&Agreement_No='+ EncodingUtil.urlEncode(agreeNo,'UTF-8') +
                    '&Salesforce_AutoID='+EncodingUtil.urlEncode(srid,'UTF-8');
                                
            req.setHeader('Content-Length', theBody.length() +'');
                    
            req.setBody(theBody);
                    
            if (justTest==false)
            {
                if (!Test.isRunningTest()){
                    res = h.send(req);
                } 
            }
        }
        
    }
    
    public static void testSend(String cid,String createby, String nric){
        justTest = true;
        pushData(cid,createby,nric);
    }
}
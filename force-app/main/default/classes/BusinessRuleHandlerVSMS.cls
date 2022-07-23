/**************************************************
 * Class Name: BusinessRuleHandlerVSMS
 * Description: Handler class for VSMS related requests
 * 
 * Revision History:
 * Developer Name		Date			Description
 * HPanneerselvam		28-01-2019		Created.
 * CGaylan				27-06-2019		Refactored.
 **************************************************/ 
public class BusinessRuleHandlerVSMS {
    
    public static Boolean isBatchCall = false;
    
    public static void createStocKVSMS(String srid, String createby, Boolean isFutureCall){
        if(isFutureCall){
            createStockVSMS_ASync(srid, createby);
        }else{
            createStockVSMS_Sync(srid, createby);
        }
    }
    
    public static void updateStocKVSMS(String srid, String createby, Boolean isFutureCall){
        if(isFutureCall){
            updateStockVSMS_ASync(srid, createby);
        }else{
            updateStockVSMS_Sync(srid, createby);
        }
    }
    
    @future(callout = true)
    public static void createStockVSMS_ASync(String srid, String createby){
        stockReservationCreateOrUpdateToVSMS(srid, createby, 'insert');
    }
    
    public static void createStockVSMS_Sync(String srid, String createby){
        stockReservationCreateOrUpdateToVSMS(srid, createby, 'insert');
    }
    
    @future(callout = true)
    public static void updateStockVSMS_ASync(String srid, String createby){
        stockReservationCreateOrUpdateToVSMS(srid, createby, 'update');
    }
    
    public static void updateStockVSMS_Sync(String srid, String createby){
        stockReservationCreateOrUpdateToVSMS(srid, createby, 'update');
    }
    
    public static void stockReservationCreateOrUpdateToVSMS(String srid, String createby, String dmlAction){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        string url = (dmlAction == 'insert') ? Label.VSMSSRInsert : Label.VSMSSRUpdate;
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(url);
        
        Stock_Reservation__c SR = [SELECT Id, 
                                   Name,
                                   Franchise_Code__c,
                                   Model_Code__r.name,
                                   Model_Year_Code__r.ModelYear__c,
                                   Customer_Social_ID__c,
                                   Customer_Name__c, 
                                   Trim_Code__r.name,
                                   Color_Code__r.name,
                                   Vehicle_Master__r.System_Commcase__c,
                                   Downpayment_No__c,
                                   Reservation_Status__c,
                                   Owner.name,
                                   Comment__c,
                                   Reservation_Date__c, 
                                   Customer_Mobile_Number__c, 
                                   Agreement_No__c, Cancellation_Reason__c 
                                   FROM Stock_Reservation__c 
                                   WHERE Id=:srid
                                   LIMIT 1];
        
        DateTime dt = sr.Model_Year_Code__r.ModelYear__c;
        DateTime dt2 = sr.Reservation_Date__c;
        String sbod = (dt!=null) ? dt.format('dd/MM/YYYY'): '';
        String sbod2 = (dt2!=null) ? dt2.format('dd/MM/YYYY'): '';
        
        String frCode = SR.Franchise_Code__c.toUpperCase();
        String loginSF = createby.toUpperCase();
        String modelCode = SR.Model_Code__r.name.toUpperCase();
        String trimCode = SR.Trim_Code__r.name.toUpperCase();
        String colorCode = SR.Color_Code__r.name.toUpperCase();
        String vcoms = String.isBlank(SR.Vehicle_Master__r.System_Commcase__c) ? 'TEMP' : SR.Vehicle_Master__r.System_Commcase__c.toUpperCase();
        String custNric = String.isBlank(sr.Customer_Social_ID__c) ? ( String.isBlank(sr.Customer_Mobile_Number__c) ? 'DUMMYNRIC' :  String.valueOf(sr.Customer_Mobile_Number__c) )    : sr.Customer_Social_ID__c.toUpperCase() ;
        String custName = String.isBlank(sr.Customer_Name__c) ? '' : sr.Customer_Name__c.toUpperCase();        
        String reserRemark = String.isBlank(sr.Comment__c) ? '' : sr.Comment__c.toUpperCase(); 
        String srStatus = sr.Reservation_Status__c.toUpperCase();
        String dpNo = String.isBlank(sr.Downpayment_No__c) ? '' : sr.Downpayment_No__c.toUpperCase();
        
        String theBody = 'Franchise_code='+ EncodingUtil.urlEncode(frCode,'UTF-8') +
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
                           '&ReAssign_Date=';
        if(dmlAction == 'insert'){
            theBody = theBody + '&Cancel_Remarks='+
                               '&Agreement_No='+
                               '&Salesforce_AutoID='+EncodingUtil.urlEncode(srid,'UTF-8');
        }else if(dmlAction == 'update'){
            String agreeNo =  String.isBlank(sr.Agreement_No__c) ? '' : sr.Agreement_No__c.toUpperCase();
            String cancelRemarks = String.isBlank(sr.Cancellation_Reason__c) ? '' : SR.Cancellation_Reason__c.toUpperCase();
            theBody = theBody + '&Cancel_Remarks='+EncodingUtil.urlEncode(cancelRemarks,'UTF-8')+
                               '&Agreement_No='+EncodingUtil.urlEncode(agreeNo,'UTF-8')+
                               '&Salesforce_AutoID='+EncodingUtil.urlEncode(srid,'UTF-8');
        }                     
        req.setHeader('Content-Length', theBody.length() +'');    
        req.setBody(theBody);
        if(!Test.isRunningTest()){
            res = h.send(req);
            if(!isBatchCall){
                serviceDataPool.buildServiceDataPoolHttp('stockReservationCreateOrUpdateToVSMS', 'BusinessRuleHandlerVSMS', '', req, res);
            }
        }
        
    }
        
}
global with sharing class VSMS_Callout {
    
    static VSMSCallout__mdt apiCallout = [SELECT APIKey__c, Endpoint__c, TimeOut__c, Method__c from VSMSCallout__mdt WHERE MasterLabel = 'VSMSCallout_Upsert'];
    static VSMSCallout__mdt apiCallout_CustomerAPI = [SELECT APIKey__c, Endpoint__c, TimeOut__c, Method__c from VSMSCallout__mdt WHERE MasterLabel = 'VSMSCallout_CustomerAPI'];
   
    public static List<String> DebugLogsListSuccess = New List<String>();
    public static List<String> DebugLogsListError = New List<String>();
    public class CalloutException extends Exception {}    

    public static Boolean insertSalesOrderToVSMS (Id saId) {
        Http http = new Http();
        HttpRequest calloutUtil = new HttpRequest();
        calloutUtil.setMethod(apiCallout.Method__c);
        calloutUtil.setTimeout((Integer)apiCallout.TimeOut__c);
        calloutUtil.setHeader('Accept', 'application/json');
        calloutUtil.setHeader('Content-Type', 'application/json');
        calloutUtil.setHeader('apikey', apiCallout.APIKey__c);
        calloutUtil.setEndpoint(apiCallout.Endpoint__c);
        if (saId == null) {
            return false;
        }
        
        try {
            
            String reqBody = VSMS_SalesAgrmntMappingSalesOrder.generateRequestBody(saId, false);
            if (reqBody == 'error') {
                throw new CalloutException('false -- request body error');
            } else {
                calloutUtil.setBody(reqBody);
                Sales_Agreement__c sA = SalesAgreementService.getSalesAgrmnt(saId);
                if (String.isBlank(sA.SOH_SONO__c)) {
                    HttpResponse res = http.send(calloutUtil); 
                    updateSalesAgreementNo(res, saId);
                    
                    DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);   
                    serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                } else {
                    HttpResponse res = http.send(calloutUtil); 
                    updateSA(res, saId);
                    
                    DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                    serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                }     
            }  
        } catch (Exception e) {
            System.debug(e.getMessage());
            loggerDataPool.buildLogDataPool('VSMS_Callout', e);
          	throw new CalloutException('false -- exception error');           
        }
        return true;
    } 
    
    private static Boolean updateSalesAgreementNo (HttpResponse res, Id saId) {
        
        Sales_Agreement__c updatedSA = SalesAgreementService.getSalesAgrmnt(saId);
        List<Accessories_Master__c> newAccMasters = new List<Accessories_Master__c>();
        
        if (res.getStatusCode() == 200) {
            try {
                
                SO_Wrapper sO = (SO_Wrapper)JSON.deserialize(res.getBody(), SO_Wrapper.class);
                
                try {
                    // Callout to Customer API in case Buyer is not Seller of Used Car
                    if(updatedSA.isSellerNotBuyer__c) {
                        upsertSellerDataToCustomerAPI(updatedSA);
                    }
                    
                    // Update SA No and Customer Code on SFDC
                    updatedSA.SOH_SONO__c = sO.SOH_SONO;
                    updatedSA.SOH_CUM_CUSTCD__c = sO.SALESORDER_CUSTOMER.CUM_CUSTCD;
                    update updatedSA;
                    DebugLogsListSuccess.add(updatedSA.SOH_SONO__c + ' has been added');
                 } catch (DmlException e) {
                     System.debug(e.getMessage());
                     loggerDataPool.buildLogDataPool('VSMS_Callout', e);
                     DebugLogsListError.add('Error:' + e);
                     throw new CalloutException('false');       
                 }
                
                // Update related SA Accessories
                List<SA_Accessory__c> updatedSaAccs = SalesAgreementService.getSaAccs(saId);
                if (sO.SALESORDER_ACCS != null || sO.SALESORDER_ACCS.size() > 0) {
                    Accessories_Master__c newAccMaster;
                    List<SO_AccsWrapper> returnedAccs = sO.SALESORDER_ACCS;
                    for (SO_AccsWrapper returnedAcc : returnedAccs) {
                        for (SA_Accessory__c updatedSaAcc : updatedSaAccs) {
                            if (returnedAcc.SAC_ACM_ACCSCD == updatedSaAcc.Acc_Code_Trigger__c && updatedSaAcc.SAC_ACM_ACCSCD__c == null) {
                                Accessories_Master__c existingACM = SalesAgreementService.getACMByVSMSCompoundPrimaryKey(returnedAcc.SAC_SOH_FRNCD, returnedAcc.SAC_ACM_ACCSCD, returnedAcc.SAC_SOH_UNIQUEBRCD);
                                // Create new ACM in case of no existing one 
                                if (existingACM == null) {
                                    if (returnedAcc.SAC_ACM_ACCSCD.substring(0,3) == 'COE') {
                                        newAccMaster = new Accessories_Master__c();
                                        newAccMaster.VSMS_Compound_Primary_Key__c = returnedAcc.SAC_SOH_UNIQUEBRCD + returnedAcc.SAC_SOH_FRNCD + returnedAcc.SAC_ACM_ACCSCD;
                                        newAccMaster.ACM_ACCSCD__c = returnedAcc.SAC_ACM_ACCSCD;
                                        newAccMaster.ACM_BRM_UNIQUEBRCD__c = returnedAcc.SAC_SOH_UNIQUEBRCD;
                                        newAccMaster.ACM_FRN_FRNCD__c = returnedAcc.SAC_SOH_FRNCD;
                                        newAccMaster.ACM_PURPRICE__c = returnedAcc.SAC_PRICE;
                                        newAccMaster.ACM_ACCSCOST__c = 0;
                                        newAccMaster.ACM_ACCSDESC__c = returnedAcc.ACM_ACCSDESC;
                                        newAccMaster.Rate__c =  returnedAcc.SAC_PRICE;
                                        newAccMasters.add(newAccMaster);
                                    }
                                    if (returnedAcc.SAC_ACM_ACCSCD.substring(0,3) == 'SVC' || returnedAcc.SAC_ACM_ACCSCD.substring(0,3) == 'GMS' || returnedAcc.SAC_ACM_ACCSCD.substring(0,3) == 'ACC') {
                                        newAccMaster = new Accessories_Master__c();
                                        newAccMaster.VSMS_Compound_Primary_Key__c = returnedAcc.SAC_SOH_UNIQUEBRCD + returnedAcc.SAC_SOH_FRNCD + returnedAcc.SAC_ACM_ACCSCD;
                                        newAccMaster.ACM_ACCSCD__c = returnedAcc.SAC_ACM_ACCSCD;
                                        newAccMaster.ACM_BRM_UNIQUEBRCD__c = returnedAcc.SAC_SOH_UNIQUEBRCD;
                                        newAccMaster.ACM_FRN_FRNCD__c = returnedAcc.SAC_SOH_FRNCD;
                                        newAccMaster.ACM_PURPRICE__c = returnedAcc.SAC_PRICE;
                                        newAccMaster.ACM_ACCSCOST__c = returnedAcc.SAC_PRICE;
                                        newAccMaster.ACM_ACCSDESC__c = returnedAcc.ACM_ACCSDESC;
                                        newAccMaster.Rate__c =  0;
                                        newAccMasters.add(newAccMaster);  
                                    }
                                    
                                    updatedSaAcc.SAC_LINENO__c = returnedAcc.SAC_LINENO;
                                // Update SA Acc with existing ACM
                                } else if (existingACM != null) {
                                    updatedSaAcc.Accessories_Master__c = existingACM.Id;
                                    updatedSaAcc.SAC_LINENO__c = returnedAcc.SAC_LINENO;
                                }
                            }
                            
                            if (updatedSaAcc.Acc_Code_Trigger__c == null && updatedSaAcc.SAC_ACM_ACCSCD__c == returnedAcc.SAC_ACM_ACCSCD) {
                                updatedSaAcc.SAC_LINENO__c = returnedAcc.SAC_LINENO;
                            }
                        }
                    }
                }

                if (newAccMasters.size() > 0) {
                    insert newAccMasters;
                    DebugLogsListSuccess.add(newAccMasters.size() + ' has been added'); 
                    for (SA_Accessory__c updatedAcc : updatedSaAccs) {
                        for (Accessories_Master__c accMaster : newAccMasters) {
                            String accCode = accMaster.ACM_ACCSCD__c.subString(0,3);
                            if (updatedAcc.Acc_Code_Trigger__c == accMaster.ACM_ACCSCD__c && (accCode == 'COE' || accCode == 'GMS' || accCode == 'SVC' || accCode == 'ACC')) {
                                updatedAcc.Accessories_Master__c = accMaster.Id;
                            }
                        }   
                    }         
                }
                update updatedSaAccs;
                DebugLogsListSuccess.add(updatedSaAccs.size() + ' has been updated'); 
                // End of update related SA Accessories
                            
            } catch (Exception e) { 
                System.debug(e.getMessage());
                loggerDataPool.buildLogDataPool('VSMS_Callout', e);
                DebugLogsListError.add('Error:' + e);
                throw new CalloutException('false');       
            }
        } else {    
            System.debug(res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            DebugLogsListError.add('Error:' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            return false;
        }

        return true;
    }

    private static void upsertSellerDataToCustomerAPI(Sales_Agreement__c sA) {
        
        // Callout to Customer API
        Http http = new Http();
        HttpRequest calloutUtil = new HttpRequest();
        calloutUtil.setMethod(apiCallout_CustomerAPI.Method__c);
        calloutUtil.setTimeout((Integer)apiCallout_CustomerAPI.TimeOut__c);
        calloutUtil.setHeader('Accept', 'application/json');
        calloutUtil.setHeader('Content-Type', 'application/json');
        calloutUtil.setHeader('apikey', apiCallout_CustomerAPI.APIKey__c);
        calloutUtil.setEndpoint(apiCallout_CustomerAPI.Endpoint__c);
        try {
                        
            String reqBody = VSMS_SalesAgrmntMappingSalesOrder.generateSellerDataRequestBody(sA.Id);
            if (reqBody == 'error') {
                throw new CalloutException('false -- request body error');
            } else {
                calloutUtil.setBody(reqBody);    
                HttpResponse res = http.send(calloutUtil);
                
                //Update Seller Account No on SFDC
                updateSellerAccountNo(res, sA);

                DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);   
                serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMSCallout_CustomerAPI', '', calloutUtil, res);
            }
        
        }catch(Exception e) {
            System.debug(e.getMessage());
            loggerDataPool.buildLogDataPool('VSMS_Callout', e);
            DebugLogsListError.add('Error:' + e);
            throw new CalloutException('false');       
        }
    }

    private static void updateSellerAccountNo(HttpResponse res, Sales_Agreement__c sA) {

        if(res.getStatusCode() == 200) {
            try{
                SalesOrder_Customer sO_Customer = (SalesOrder_Customer)JSON.deserialize(res.getBody(), SalesOrder_Customer.class);
                sA.Seller_Account_No__c = sO_Customer.CUM_CUSTCD;
                update sA;

                DebugLogsListSuccess.add(sA.Seller_Account_No__c + ' has been added');
                //return true;
            }catch(Exception e) {
                System.debug(e.getMessage());
                loggerDataPool.buildLogDataPool('VSMS_Callout', e);
                DebugLogsListError.add('Error:' + e);
                throw new CalloutException('false');       
            }
        }
    }
    
    private static Boolean updateSA (HttpResponse res, Id saId) {
        
        if (res.getStatusCode() == 200) {
            try {
                SO_Wrapper sO = (SO_Wrapper)JSON.deserialize(res.getBody(), SO_Wrapper.class);
                List<SO_AccsWrapper> returnedAccs = sO.SALESORDER_ACCS;
                List<SA_Accessory__c> updatedSaAccs = SalesAgreementService.getSaAccs(saId);
                Sales_Agreement__c updatedSA = SalesAgreementService.getSalesAgrmnt(saId);
                                
                // Callout to Customer API in case Buyer is not Seller of Used Car
                if(updatedSA.isSellerNotBuyer__c) {
                    upsertSellerDataToCustomerAPI(updatedSA);
                }

                // Update related SA Accessories
                for (SO_AccsWrapper returnedAcc: returnedAccs) {
                    for (SA_Accessory__c updatedSaAcc : updatedSaAccs) {
                        if (returnedAcc.SAC_ACM_ACCSCD == updatedSaAcc.SAC_ACM_ACCSCD__c || returnedAcc.SAC_ACM_ACCSCD == updatedSaAcc.Acc_Code_Trigger__c) {
                            updatedSaAcc.SAC_LINENO__c = returnedAcc.SAC_LINENO;
                        }
                    }
                }
                update updatedSaAccs; 
                DebugLogsListSuccess.add('SO has been updated to vSMS');      
            } catch (Exception e) { 
                System.debug(e.getMessage());
                loggerDataPool.buildLogDataPool('VSMS_Callout', e);
                throw new CalloutException('false'); 
            }
        } else {
            System.debug(res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            DebugLogsListError.add('Error:' + res.getStatusCode() + ' ' + res.getStatus() + ' ' + res.getBody());
            return false;
        }

        return true;
    }

    /** Method to call API when users click button on UI
     * 
     */
    @AuraEnabled
    public static String syncToVSMSOnDemand(Id saId) {
        Http http = new Http();
        HttpRequest calloutUtil = new HttpRequest();
        calloutUtil.setMethod(apiCallout.Method__c);
        calloutUtil.setTimeout((Integer)apiCallout.TimeOut__c);
        calloutUtil.setHeader('Accept', 'application/json');
        calloutUtil.setHeader('Content-Type', 'application/json');
        calloutUtil.setHeader('apikey', apiCallout.APIKey__c);
		calloutUtil.setEndpoint(apiCallout.Endpoint__c);
        if (saId == null) {
            return null;
        }

        try {
            String reqBody = VSMS_SalesAgrmntMappingSalesOrder.generateRequestBody(saId, false);
            if (reqBody == 'error') {
                system.debug('***');
                throw new CalloutException('false -- request body error');
            } else {
                calloutUtil.setBody(reqBody);
                Sales_Agreement__c sA = SalesAgreementService.getSalesAgrmnt(saId);
                if (String.isBlank(sA.SOH_SONO__c)) {
                    //calloutUtil.setEndpoint(apiCallout.Endpoint__c);
                    HttpResponse res = http.send(calloutUtil);
                    updateSalesAgreementNo(res, saId);
                    if (res.getStatusCode() == 200) {
                        DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                    	serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                        return 'SUCCESS';
                    } else {
                        DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                    	serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                        return 'VSMS Error Message: ' + string.valueOf(res.getBody());
                    }
                } else {
                    //calloutUtil.setEndpoint(apiCallout.Endpoint__c);
                    HttpResponse res = http.send(calloutUtil);
                    updateSA(res, saId);
                    if (res.getStatusCode() == 200) {
                        system.debug('update success');
                        DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                    	serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                        return 'SUCCESS';
                    } else {
                        system.debug('update failed');
                        system.debug(res.getBody());
                        DebugLogs.getDebugLogs('VSMS_Callout',DebugLogsListSuccess,DebugLogsListError);
                    	serviceDataPool.buildServiceDataPoolHttp('SalesforceToVSMSSync', 'VSMS_Callout', '', calloutUtil, res);
                        return 'VSMS Error Message: ' + string.valueOf(res.getBody());
                    }
                }
            }
        } catch (Exception e) {
            system.debug('E');
            System.debug(e.getMessage());
            loggerDataPool.buildLogDataPool('VSMS_Callout', e);
            throw new CalloutException('false -- exception error'); 
        }
        //return res.getBody();
    }
    
    public class SO_Wrapper {
        public String SOH_BRM_COMPCD;
        public String SOH_BRM_LOCCD;
        public String SOH_BRM_BRCD;
        public String SOH_BRM_UNIQUEBRCD;
        public String SOH_FRN_FRNCD;
        public String SOH_SONO;
        public String SOH_SODT;
        public Integer SOH_AMENDNO;
        public String SOH_AMENDDT;
        public String SOH_QPH_QUOTENO;
        public String SOH_RTM_REGTYPECD;
        public String SOH_BAM_DEALERCD;
        public String SOH_PKH_PKGNO;
        public String SOH_CUM_CUSTCD;
        public String SOH_MYM_MODELCD;
        public String SOH_MYM_MODELYEAR;
        public String SOH_MCTM_COLORCD;
        public String SOH_MCTM_TRIMCD;
        public String SOH_WAIVEROFDEPOSIT;
        public String SOH_WAIVERAPPROVED;
        public String SOH_WAIVERAPPROVEDDT;
        public String SOH_AGRCONVDT;
        public Double SOH_DEPOSITAMT;
        public Double SOH_COEDEPOSITAMT;
        public String SOH_VEM_CCNO;
        public String SOH_REGNO;
        public String SOH_IUD_IUDOCNO;
        public String SOH_EMM_SECD;
        public String SOH_FINTYPE;
        public String SOH_CUSTCOE;
        public String SOH_COEREQD;
        public String SOH_COH_DOCNO;
        public String SOH_COENO;
        public Double SOH_QP;
        public String SOH_SUCCESSMONTH;
        public String SOH_EXPIRYMONTH;
        public String SOH_COESUCCESSNOTIFY;
        public String SOH_READYFORPDINOTIFY;
        public String SOH_REGISTRATIONNOTIFY;
        public Double SOH_PKGPRICE;
        public Double SOH_LISTPRICE;
        public Double SOH_OPTIONAMT;
        public Double SOH_OPTIONDISCAMT;
        public Double SOH_OPTIONNETAMT;
        public Double SOH_ADDNLAMT;
        public Double SOH_PKGADDNLAMT;
        public Double SOH_ACCSAMT;
        public Double SOH_ACCSDISCAMT;
        public Double SOH_ACCSNETAMT;
        public Double SOH_PKGACCSAMT;
        public Double SOH_ACCSREBATE;
        public Double SOH_ADDNLREBATE;
        public Double SOH_DISCAMT;
        public Double SOH_TOTDISCAMT;
        public String SOH_DISCAPP;
        public String SOH_DISCAPPDT;
        public Double SOH_COESP;
        public Double SOH_SECOMM;
        public Double SOH_DEALERCOMM;
        public String SOH_EDDDT;
        public String SOH_EDDTODT;
        public String SOH_CUSTPDDDT;
        public Double SOH_GSTAMT;
        public Double SOH_RECDGSTAMT;
        public Double SOH_DBNAMT;
        public Double SOH_CRNAMT;
        public Double SOH_RECDAMT;
        public Double SOH_REFUNDAMT;
        public Double SOH_CUSTRECDAMT;
        public Double SOH_FINRECDAMT;
        public Double SOH_SOVALUE;
        public String SOH_CANCELDT;
        public String SOH_INVNO;
        public String SOH_INVDT;
        public Double SOH_SPVEHDEPAMT;
        public String SOH_BIDEDREGNO;
        public String SOH_STATUS;
        public String SOH_REMARKS;
        public String SOH_CREATEDBY;
        public String SOH_CREATEDDT;
        public String SOH_LASTUPDBY;
        public String SOH_LASTUPDDT;
        public String SOH_CANREMARKS;
        public Double SOH_DEPOSITLTA;
        public String SOH_REGNOTYPE;
        public String SOH_RETENREGNO;
        public String SOH_COECATGCD;
        public String SOH_USEDCARREASON;
        public String SOH_INSREASON;
        public Double SOH_COEREBATE;
        public Double SOH_USEDCAROTAMT;
        public Double SOH_SECOMMPAID;
        public Double SOH_DEALERCOMMPAID;
        public String SOH_COMMPAIDDT;
        public String SOH_VEHALLOCDT;
        public String SOH_REPRINTSTATUS;
        public String SOH_SALESDRAFTSTATUS;
        public Double SOH_PRINTNO;
        public String SOH_SALESREP;
        public String SOH_PRODMTH;
        public String SOH_INSTRUCTION;
        public Double SOH_SPECIALDISC;
        public Integer SOH_MAXIMUMDISC;
        public String SOH_DRAFT_PRINTDT;
        public Double SOH_SECOMM_ADJUST;
        public Double SOH_DEALERCOMM_ADJUST;
        public String SOH_COMMADJUST_REMARK;
        public Double SOH_TRADECOST;
        public String SOH_EMM_CODE;
        public String SOH_OFFPEAKDT;
        public String SOH_FINTYPE_DEALER;
        public String SOH_TOBEAPPROVEDBY;
        public String SOH_USQ_QUOTENO;
        public Double SOH_USEDCARCOMM;
        public String SOH_GMT_PURAGGNO;
        public String SOH_GMSFLAG;
        public Double SOH_COSTTOFULCO;
        public String SOH_COMMVERIFIEDBY;
        public String SOH_COMMVERIFIEDFLG;
        public String SOH_COMMVERIFIEDDT;
        public String SOH_SAID;
        
        public String CUM_NRICPSPTCPY;
        public String CUM_BRM_UNIQUEBRCD;
        public String CUM_CATEGORY;
        public String CUM_CUSTTYPE;
        public String CUM_NRICFLAG;
        public String CUM_FIRSTNAME;
        public String CUM_LASTNAME;
        public String CUM_SALUTATION;
        public String CUM_MAILADDR1;
        public String CUM_MAILADDR2;
        public String CUM_MAILADDR3;
        public String CUM_MAILPOSTAL;
        public String CUM_MAILMOBILE;
        public String CUM_MAILEMAILID;
        public String CUM_REGNAME;
        public String CUM_REGADDR1;
        public String CUM_REGADDR2;
        public String CUM_REGADDR3;
        public String CUM_REGPOSTAL;
        public String CUM_SEX;
        public String CUM_MARITALSTATUS;
        public String CUM_DOB;
        public String CUM_CREATEDBY;
        public String CUM_CREATEDDT;
        public String CUM_LASTUPDBY;
        public String CUM_LASTUPDDT;
        public String CUM_REALFIRSTNAME;
        public String CUM_PDPA;
        public String CUM_NRICCOE;
        public List<SO_AccsWrapper> SALESORDER_ACCS;
        public List<SO_ADCWrapper> SALESORDER_ADDNLCHARGES;
        public List<SO_FDWrapper> SALESORDER_FINANCEDETAIL;
        public List<SO_IDWrapper> SALESORDER_INSURANCEDETAIL;
        public SO_CustWrapper SALESORDER_CUSTOMER;
        //public SO_COEInternalBidWrapper SALESORDER_COEINTERNALBID;
        public SO_StockReservationWrapper SALESORDER_STOCK_RESERVATION;
    }
    
    public class SO_AccsWrapper {
        public String SAC_SOH_UNIQUEBRCD;
        public String SAC_SOH_FRNCD;
        public String SAC_SOH_SONO;
        public Integer SAC_LINENO;
        public String SAC_PACKAGE;
        public Double SAC_REBATE;
        public String SAC_ACM_ACCSCD;
        public Integer SAC_QTY;
        public Integer SAC_ISSQTY;
        public Integer SAC_RETNQTY;
        public Double SAC_PRICE;
        public Double SAC_DISCPER;
        public Double SAC_DISCAMT;
        public Double SAC_ACCSVALUE;
        public String SAC_INCPRICE;
        public String SAC_JCRAISED;
        public Double SAC_SECOMM;
        public Double SAC_ACCSCOST;
        public String SAC_SUPINVOICE;
        public Double SAC_DEALERCOMM;
        public String SAC_ACCSTRADE;
        public Double SAC_SETRADECOST;
        public Double SAC_DEALERTRADECOST;
        public Double SAC_PACKAGE_TRADE_REBATE;
        public String ACM_ACCSDESC;
        public String ACM_SHORTDESC;
    }
    
    public class SO_ADCWrapper {
        public String SAD_SOH_UNIQUEBRCD;
        public String SAD_SOH_FRNCD;
        public String SAD_SOH_SONO;
        public String SAD_PACKAGE;
        public String SAD_ADM_CHRGCD;
        public String SAD_ADM_CHARGTYPE;
        public String SAD_ADM_OTHERTYPE;
        public Double SAD_CHARGES;
        public String SAD_REMOVE;
        public Double SAD_REBATE;
        public String SAD_DISPLAY;
        public String SAD_PRINT;
        public String SAD_INCPRICE;
        public String SAD_SUPINVOICE;
        public Double SAD_PACKAGE_REBATE;
        
    }
    
    public class SO_FDWrapper {
        public String SFD_BRM_COMPCD;
        public String SFD_BRM_LOCCD;
        public String SFD_BRM_BRCD;
        public String SFD_SOH_UNIQUEBRCD;
        public String SFD_SOH_FRNCD;
        public String SFD_SOH_SONO;
        public String SFD_BAM_FINCD;
        public String SFD_FINREASON;
        public String SFD_FPH_PKGCD;
        public Double SFD_FINANCEAMT;
        public Double SFD_DOWNPAYMENT;
        public Integer SFD_TENURE;
        public Double SFD_INTERESTRATE;
        public Double SFD_EMI;
        public String SFD_FIRSTINSTDT;
        public String SFD_RONO;
        public Double SFD_SECOMM;
        public Double SFD_COMPCOMM;
        public String SFD_COMMRECDDT;
        public String SFD_LOANEXPDT;
        public String SFD_STATUS;
        public String SFD_REMARKS;
        public String SFD_CREATEDBY;
        public String SFD_CREATEDDT;
        public String SFD_LASTUPDBY;
        public String SFD_LASTUPDDT;
        public Double SFD_INCENTIVE;
        public Double SFD_FREEINSTAMT;
        public Double SFD_FINANCEAMT_DEALER;
        public Double SFD_DOWNPAYMENT_DEALER;
        public Integer SFD_TENURE_DEALER;
        public Double SFD_INTERESTRATE_DEALER;
        public Double SFD_EMI_DEALER;
        public String SFD_DNNO;
        public String SFD_INVDT;
        
    }
    
    public class SO_IDWrapper {
        public String SID_BRM_COMPCD;
        public String SID_BRM_LOCCD;
        public String SID_BRM_BRCD;
        public String SID_SOH_UNIQUEBRCD;
        public String SID_SOH_FRNCD;
        public String SID_SOH_SONO;
        public String SID_BAM_INSCD;
        public String SID_INSREASON;
        public Double SID_COVERAMT;
        public String SID_PERIOD;
        public Double SID_NCB;
        public String SID_COVERNOTENO;
        public Double SID_PREMIUMAMT;
        public Double SID_GSTAMT;
        public Double SID_TPIS;
        public Double SID_TPISAMT;
        public String SID_INSSTARTDT;
        public String SID_INSEXPDT;
        public String SID_INSPOLICYNO;
        public String SID_SECOMM;
        public String SID_COMMRECDDT;
        public String SID_COMPCOMM;
        public String SID_ENDORSEDT;
        public String SID_ENDORSEINVDT;
        public String SID_REMARKS;
        public String SID_CREATEDBY;
        public String SID_CREATEDDT;
        public String SID_LASTUPDBY;
        public String SID_LASTUPDDT;
        public String SID_GSTONCOMM;
        public String SID_REFNO;
        public Double SID_FREEINSTAMT;
        public Double SID_BASICPREMIUM;
        public String SID_PREVINSURER;
        public String SID_PREVREGNO;
        public String SID_SUBMISSIONDT;
        public Double SID_ADJUSTAMT;
        public String SID_ADJUSTDT;
    }
    
    public class SO_CustWrapper {
        public String CUM_NRICPSPTCPY;
        public String CUM_BRM_UNIQUEBRCD;
        public String CUM_CATEGORY;
        public String CUM_CUSTTYPE;
        public String CUM_NRICFLAG;
        public String CUM_FIRSTNAME;
        public String CUM_LASTNAME;
        public String CUM_SALUTATION;
        public String CUM_MAILADDR1;
        public String CUM_MAILADDR2;
        public String CUM_MAILADDR3;
        public String CUM_MAILPOSTAL;
        public String CUM_MAILMOBILE;
        public String CUM_MAILEMAILID;
        public String CUM_REGNAME;
        public String CUM_REGADDR1;
        public String CUM_REGADDR2;
        public String CUM_REGADDR3;
        public String CUM_REGPOSTAL;
        public String CUM_SEX;
        public String CUM_MARITALSTATUS;
        public String CUM_DOB;
        public String CUM_CREATEDBY;
        public String CUM_CREATEDDT;
        public String CUM_LASTUPDBY;
        public String CUM_LASTUPDDT;
        public String CUM_REALFIRSTNAME;
        public String CUM_PDPA;
        public String CUM_NRICCOE;
        public String CUM_STATUS;
        public String CUM_CUSTCD;
    }
     public class SO_StockReservationWrapper {
        public String STM_STATUS;
        public String STM_SALESFORCE_AUTOID;
    }
    /*
    public class SO_COEInternalBidWrapper {
    
        public String CIB_FRN_FRNCD;
        public String CIB_SOH_SONO;
        public String CIB_CAT;
        public Double CIB_GMS;
        public Double CIB_COE_REBATE;
        public String CIB_GUARANTEE;
        public Double CIB_COMMISSION;
        public String CIB_REMARKS;
        public String CIB_CREATEDBY;
        public String CIB_CREATEDDT;
        public String CIB_LASTUPDBY;
        public String CIB_LASTUPDT;
        public Double CIB_COE_TOPUP;
        public Double CIB_FIRSTBID;
        public Double CIB_SECONDBID;
        public Double CIB_THIRDBID;
        public Double CIB_FOURTHBID;
        public Double CIB_FIFTHBID;
        public Double CIB_SIXTHBID;
        public Double CIB_SEVENTHBID;
        public Double CIB_EIGHTHBID;
        public Double CIB_NINTHBID;
        public Double CIB_TENTHBID;
        public Double CIB_ELEVENTHBID;
        public Double CIB_TWELFTHBID;
        public String CIB_STATUS;
        public String CIB_USED_CAR;
        public String CIB_LOAN_APPROVE;
        public String CIB_LOAN_APPROVE_NAME;
        public Double CIB_FUL_TOTAL_DISCOUNT;
        public String CIB_CANCEL_REMARK;
        public Double CIB_NO_OF_BID;
    }*/
}
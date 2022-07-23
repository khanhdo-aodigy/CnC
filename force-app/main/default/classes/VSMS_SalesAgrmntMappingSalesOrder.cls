global with sharing class VSMS_SalesAgrmntMappingSalesOrder {
    
    public static String generateRequestBody(Id saId, Boolean isUpdateSOStatus) {
        
        SalesOrderWrapper salesOrder = new SalesOrderWrapper();
        Sales_Agreement__c sA = SalesAgreementService.getSalesAgrmnt(saId);
        
        try {
            // Generate sales order data
            salesOrder = generateSalesOrderData(salesOrder, sA, isUpdateSOStatus);
            
            // Generate sales order accessories data
            salesOrder.SALESORDER_ACCS = generateSOAccData(SalesAgreementService.getSaAccs(saId), sA);
            
            // Generate sales order additional charges data
            salesOrder.SALESORDER_ADDNLCHARGES = generateSOAddnlChargeData(SalesAgreementService.getSaAddnlCharges(saId), sA);
            
            // Generate sales order finance detail data
            if (sA.Payment__c == 'Car Loan') {
                salesOrder.SALESORDER_FINANCEDETAIL = generateSOFinanceDetailData(sA);
            }
            
            // Generate sales order insurance detail data
            salesOrder.SALESORDER_INSURANCEDETAIL = generateSOInsuranceDetailData(sA);
            
            //Generate sales order customer data
            salesOrder.SALESORDER_CUSTOMER = generateSOCustomerData(sA);
            
            // Generate stock reservation data
            salesOrder.SALESORDER_STOCK_RESERVATION = generateStockReservationData(sA);
            
            // Generate sales order COE internal bid data
            //salesOrder.SALESORDER_COEINTERNALBID = generateCOEInternalBid(sA);
            
            String reqBody = JSON.serialize(salesOrder);
            //System.debug('TEST CLASS: ' + reqBody);

            return reqBody;  
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            return 'error';
        }
    }
	
    public static String generateSellerDataRequestBody(Id saId) {
        Sales_Agreement__c sA = SalesAgreementService.getSalesAgrmnt(saId);
        SalesOrder_Customer sOCust = new SalesOrder_Customer();
        try {
            sOCust = generateSellerData(sA);
            String reqBody = JSON.serialize(sOCust);
            return reqBody;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return 'error';
        }
    }    
    
    private static SalesOrderWrapper generateSalesOrderData(SalesOrderWrapper salesOrder, Sales_Agreement__c returnedSA, Boolean isUpdateSOStatus) {
        
        salesOrder.SOH_BRM_COMPCD = returnedSA.CompanyCode__c;
        salesOrder.SOH_BRM_BRCD = returnedSA.SOH_BRM_BRCD__c;
        salesOrder.SOH_BRM_UNIQUEBRCD = returnedSA.UniqueBranchCode__c;
        salesOrder.SOH_FRN_FRNCD = returnedSA.FranchiseCode__c; 
        salesOrder.SOH_SONO = returnedSA.SOH_SONO__c;
        salesOrder.SOH_SODT = DateTime.newInstance(returnedSA.Agreement_Date__c.year(), returnedSA.Agreement_Date__c.month(), returnedSA.Agreement_Date__c.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_PKH_PKGNO = returnedSA.Package_Header__r.PKH_PKGNO__c;
        salesOrder.SOH_MYM_MODELCD = returnedSA.ModelCode__c;
        salesOrder.SOH_MCTM_COLORCD = returnedSA.ColorCode__c;
        salesOrder.SOH_MCTM_TRIMCD = returnedSA.TrimCode__c;
        salesOrder.SOH_AGRCONVDT = DateTime.newInstance(returnedSA.Agreement_Date__c.year(), returnedSA.Agreement_Date__c.month(), returnedSA.Agreement_Date__c.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_DEPOSITAMT = returnedSA.Deposit__c;
        salesOrder.SOH_COEDEPOSITAMT = returnedSA.COE_Deposit__c;
        salesOrder.SOH_FINTYPE = returnedSA.Payment__c == 'Car Loan' ? 'HP' : 'SELF';
        /*JMT Start of Adhoc fix on 8th Feb
        salesOrder.SOH_PKGPRICE = returnedSA.VehicleListPrice__c;
        salesOrder.SOH_LISTPRICE = returnedSA.VehicleListPrice__c;
		*/        
        salesOrder.SOH_PKGPRICE = returnedSA.Package_List_Price__c;
        salesOrder.SOH_LISTPRICE = returnedSA.Package_List_Price__c;
        /*JMT End of Adhoc fix on 8th Feb */
        
        salesOrder.SOH_SPVEHDEPAMT = returnedSA.Deposit__c;
        salesOrder.SOH_BIDEDREGNO = returnedSA.Bid_Number__c;
        salesOrder.SOH_CREATEDBY = returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        salesOrder.SOH_CREATEDDT = DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        salesOrder.SOH_LASTUPDDT = DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_REGNOTYPE = returnedSA.SOH_REGNOTYPE__c;
        salesOrder.SOH_RETENREGNO = returnedSA.Used_Car_Registration_Number__c; 
        salesOrder.SOH_INSTRUCTION = returnedSA.RegistrationInstruction__c;
        salesOrder.SOH_FINTYPE_DEALER = returnedSA.Payment__c;
        salesOrder.SOH_SAID = returnedSA.Id;
        salesOrder.SOH_RTM_REGTYPECD = String.isBlank(returnedSA.SOH_RTM_REGTYPECD__c) == true ? 'P' : returnedSA.SOH_RTM_REGTYPECD__c; 
        salesOrder.SOH_MYM_MODELYEAR = returnedSA.ModelYear__c == null ? '0001-01-01T00:00:00' : DateTime.newInstance(returnedSA.ModelYear__c.year(), returnedSA.ModelYear__c.month(), returnedSA.ModelYear__c.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_SOVALUE = returnedSA.Vehicle_Purchase_Price__c == null ? 0 : returnedSA.Vehicle_Purchase_Price__c;
        salesOrder.SOH_SPECIALDISC = returnedSA.Accessories_Discount__c == null ? 0 : Math.abs(returnedSA.Accessories_Discount__c);
        salesOrder.SOH_EDDDT = returnedSA.Expected_Delivery_From__c == null ? '0001-01-01T00:00:00' : DateTime.newInstance(returnedSA.Expected_Delivery_From__c.year(), returnedSA.Expected_Delivery_From__c.month(), returnedSA.Expected_Delivery_From__c.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_EDDTODT = returnedSA.Expected_Delivery_To__c == null ? '0001-01-01T00:00:00' : DateTime.newInstance(returnedSA.Expected_Delivery_To__c.year(), returnedSA.Expected_Delivery_To__c.month(), returnedSA.Expected_Delivery_To__c.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_CANCELDT = returnedSA.SOH_CANCELDT__c == null ? '0001-01-01T00:00:00' : DateTime.newInstance(returnedSA.SOH_CANCELDT__c.year(), returnedSA.SOH_CANCELDT__c.month(), returnedSA.SOH_CANCELDT__c.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        salesOrder.SOH_GMSFLAG = (returnedSA.GMS_Package__c == null || returnedSA.GMS_Package__c == 0) ? 'N' : 'Y';
        salesOrder.SOH_WAIVEROFDEPOSIT = (returnedSA.Deposit__c == 0 || returnedSA.Deposit__c == null) ? 'Y' : 'N';
        salesOrder.SOH_COEREQD = returnedSA.PurchasewithCOE__c == 'Y' ? 'N' : 'Y';
        salesOrder.SOH_BAM_DEALERCD = returnedSA.Finance_Company_In_House__c == true ? returnedSA.Finance_Company_Lookup__r.BAM_ASSOCIATECD__c : ''; 
        salesOrder.SOH_EMM_SECD = returnedSA.Owner_Username__c.substring(0,returnedSA.Owner_Username__c.indexOf('@'));
        salesOrder.SOH_DISCAMT = returnedSA.Promo_Discount__c == null ? 0 : Math.abs(returnedSA.Promo_Discount__c);        
        salesOrder.SOH_AMENDNO = (returnedSA.DSA_Version__c == null || returnedSA.DSA_Version__c == 0) ? 1 : (Integer) returnedSA.DSA_Version__c;
        
        if (isUpdateSOStatus) {
             salesOrder.SOH_STATUS = 'PRN';
        } else {
            salesOrder.SOH_STATUS = returnedSA.SOH_SONO__c == null ? 'P' : '';
        }
        
        if (!String.isBlank(returnedSA.PurchasewithCOE__c))  {
            salesOrder.SOH_CUSTCOE = returnedSA.PurchasewithCOE__c == 'No' ? 'Y' : 'N';
        } else {
            salesOrder.SOH_CUSTCOE = 'Y';  
        }
        
        if (returnedSA.Promo_Discount__c != null && returnedSA.Accessories_Discount__c != null) {
            salesOrder.SOH_TOTDISCAMT = Math.abs(returnedSA.Promo_Discount__c) + Math.abs(returnedSA.Accessories_Discount__c);
        } else if (returnedSA.Promo_Discount__c != null && returnedSA.Accessories_Discount__c == null) {
            salesOrder.SOH_TOTDISCAMT = Math.abs(returnedSA.Promo_Discount__c);
        } else if (returnedSA.Promo_Discount__c == null && returnedSA.Accessories_Discount__c != null) {
            salesOrder.SOH_TOTDISCAMT = Math.abs(returnedSA.Accessories_Discount__c);
        }
        
        salesOrder.SOH_ADDNLREBATE = salesOrder.SOH_ADDNLREBATE == null ? 0 : salesOrder.SOH_ADDNLREBATE;
        for (Package_Additional_Charges__c pkgAddnlCharge : SalesAgreementService.getPackageAddnlCharges(returnedSA.Package_Header__c)) {
            if (pkgAddnlCharge.PKC_REBATE__c != null) {
                salesOrder.SOH_ADDNLREBATE += pkgAddnlCharge.PKC_REBATE__c;  
            }      
        }
        //System.debug('TEST salesOrder.SOH_ADDNLREBATE: ' + salesOrder.SOH_ADDNLREBATE);
        
        List<Package_Accs__c> returnedPkgAcccs = SalesAgreementService.getPkgAccs(returnedSA.Package_Header__c);
        salesOrder.SOH_PKGACCSAMT = salesOrder.SOH_PKGACCSAMT == null ? 0 : salesOrder.SOH_PKGACCSAMT;
        for (Package_Accs__c pkgAcc : returnedPkgAcccs) {
            if (pkgAcc.PKA_VALUE__c != null) {
                salesOrder.SOH_PKGACCSAMT += pkgAcc.PKA_VALUE__c;
            }
        }
        
        List<SA_Additional_Charge__c> sAAddnlCharges = SalesAgreementService.getSaAddnlCharges(returnedSA.Id); 
        salesOrder.SOH_ADDNLAMT = salesOrder.SOH_ADDNLAMT == null ? 0 : salesOrder.SOH_ADDNLAMT;
        Double sADChargeSum = 0;
        Double sADRebateSum = 0;
        for (SA_Additional_Charge__c sAAddnlCharge : sAAddnlCharges) {
            if (sAAddnlCharge.SAD_CHARGES__c != null) {
                sADChargeSum += sAAddnlCharge.SAD_CHARGES__c;
            }   
            if (sAAddnlCharge.SAD_REBATE__c != null) { 
                sADRebateSum += sAAddnlCharge.SAD_REBATE__c;  
            }    
            if (sAAddnlCharge.SAD_ADM_CHRGCD__c == '1000' && sAAddnlCharge.SAD_CHARGES__c != null) {
                salesOrder.SOH_COESP = sAAddnlCharge.SAD_CHARGES__c;
            }
            if (sAAddnlCharge.SAD_PACKAGE__c == 'N' && sAAddnlCharge.SAD_CHARGES__c != null) {
                salesOrder.SOH_ADDNLAMT += sAAddnlCharge.SAD_CHARGES__c;
            }
        }
        //System.debug('TEST SOH_ADDNLAMT: ' + salesOrder.SOH_ADDNLAMT);
        
        salesOrder.SOH_PKGADDNLAMT = salesOrder.SOH_PKGADDNLAMT == null ? 0 : salesOrder.SOH_PKGADDNLAMT;
        for (SA_Additional_Charge__c sAAddnlCharge : sAAddnlCharges) {
            if (sAAddnlCharge.SAD_INCPRICE__c == 'INC' && sAAddnlCharge.SAD_CHARGES__c != null) {
                salesOrder.SOH_PKGADDNLAMT += sAAddnlCharge.SAD_CHARGES__c;
            }
        }
        
        salesOrder.SOH_TRADECOST = salesOrder.SOH_TRADECOST == null ? 0 : salesOrder.SOH_TRADECOST;
        salesOrder.SOH_ACCSAMT = salesOrder.SOH_ACCSAMT == null ? 0 : salesOrder.SOH_ACCSAMT;
        salesOrder.SOH_ACCSREBATE = salesOrder.SOH_ACCSREBATE == null ? 0 : salesOrder.SOH_ACCSREBATE;
        for (SA_Accessory__c sAAcc : SalesAgreementService.getSaAccs(returnedSA.Id)) {           
            if (sAAcc.SACSETRADECOST__c != null && sAAcc.SAC_PACKAGE__c == 'N') {
                salesOrder.SOH_TRADECOST += sAAcc.SACSETRADECOST__c;
            }
           // System.debug('TEST salesOrder.SOH_TRADECOST: ' + salesOrder.SOH_TRADECOST);
            
            if (sAAcc.SAC_PACKAGE__c == 'N' && sAAcc.SAC_ACCSTRADE__c == 'N') {
                Accessories_Master__c returnedAccsMaster = SalesAgreementService.getAccsMaster(saAcc.Accessories_Master__c);
                //System.debug('TEST ACCS MASTER: ' + returnedAccsMaster);
                if (returnedAccsMaster.Accs_Rate_Master__r.size() > 0)  {
                    for (Accs_Rate_Master__c returnedARM : returnedAccsMaster.Accs_Rate_Master__r) {
                        if (returnedARM.ARM_SALEPRICE__c != null) {
                            salesOrder.SOH_ACCSAMT += returnedARM.ARM_SALEPRICE__c;
                        }
                        //System.debug('TEST salesOrder.SOH_ACCSAMT 1: ' + returnedARM.ARM_SALEPRICE__c);
                        //System.debug('TEST salesOrder.SOH_ACCSAMT 1: ' + sAAcc.Name);
                    }
                }          
            }
            
            if (sAAcc.Acc_Code_Trigger__c != null && sAAcc.Acc_Code_Trigger__c.subString(0,3) == 'COE') {
                if (sAAcc.Price_Trigger__c != null) {
                    salesOrder.SOH_ACCSAMT += sAAcc.Price_Trigger__c;
                    //System.debug('TEST salesOrder.SOH_ACCSAMT 2: ' + sAAcc.Price_Trigger__c);
                    //System.debug('TEST salesOrder.SOH_ACCSAMT 2: ' + sAAcc.Name);
                }   
            }
            if (sAAcc.SAC_REBATE__c != null) {
                salesOrder.SOH_ACCSREBATE += sAAcc.SAC_REBATE__c;
            }
        }
        
        
        salesOrder.SOH_ACCSNETAMT = salesOrder.SOH_ACCSAMT;
        //System.debug('TEST salesOrder.SOH_ACCSNETAMT: ' + salesOrder.SOH_ACCSNETAMT);
        
        List<Model_Rate_Master__c> mRM = SalesAgreementService.getModelRateMaster(returnedSA.Stock_Reservation__r.Model_Code__c);
        if (mRM.size() > 0) {
            if (mRM[0].MRM_SECOMM__c != null) {
                salesOrder.SOH_SECOMM = mRM[0].MRM_SECOMM__c;
            } 
            if (mRM[0].MRM_DEALERMARGIN__c != null) {
                salesOrder.SOH_DEALERCOMM = mRM[0].MRM_DEALERMARGIN__c;
            } 
            
        }

        //salesOrder.SOH_SECOMM_ADJUST = returnedSA.SOH_SECOMM_ADJUST__c;
        //salesOrder.SOH_DEALERCOMM_ADJUST = returnedSA.SOH_DEALERCOMM_ADJUST__c;
        //salesOrder.SOH_SALESREP = returnedSA.SOH_SALESREP__c;
        //salesOrder.SOH_REGNO = returnedSA.RegisteredVehicle__c;(?)
        //salesOrder.SOH_EMM_SECD = returnedSA.SOH_EMM_SECD__c;(?)
        
        return salesOrder;
    }
    
    private static List<SalesOrder_AccWrapper> generateSOAccData(List<SA_Accessory__c> returnedSAAccessories, Sales_Agreement__c returnedSA) {
        List<SalesOrder_AccWrapper> result = new List<SalesOrder_AccWrapper>();
        SalesOrder_AccWrapper sO_Acc;
        for (SA_Accessory__c saAcc : returnedSAAccessories) {
            if (String.isBlank(saAcc.Acc_Code_Trigger__c)) {
                sO_Acc = new SalesOrder_AccWrapper();
                sO_Acc.SAC_SOH_UNIQUEBRCD = saAcc.Sales_Agreement__r.UniqueBranchCode__c;
                sO_Acc.SAC_SOH_FRNCD = saAcc.Sales_Agreement__r.FranchiseCode__c;
                sO_Acc.SAC_SOH_SONO = saAcc.SAD_SOH_SONO__c;
                sO_Acc.SAC_PACKAGE = saAcc.SAC_PACKAGE__c;
                sO_Acc.SAC_QTY = saAcc.SACQTY__c;
                sO_Acc.SAC_ACCSTRADE = saAcc.SAC_ACCSTRADE__c == 'Y' ? 'Y' : '';
                sO_Acc.SAC_ACCSCOST = saAcc.SAC_ACCSCOST__c == null ? 0 : saAcc.SAC_ACCSCOST__c;                
                sO_Acc.SAC_INCPRICE = String.isBlank(saAcc.SAC_INCPRICE__c) == true ? '' : saAcc.SAC_INCPRICE__c; 
                sO_Acc.SAC_ACM_ACCSCD = String.isBlank(saAcc.SAC_ACM_ACCSCD__c) == true ? '' : saAcc.SAC_ACM_ACCSCD__c;
                if (saAcc.SAC_PACKAGE__c == 'Y') {
                    sO_Acc.SAC_SETRADECOST = 0;
                    sO_Acc.SAC_DEALERTRADECOST = 0;
                    sO_Acc.SAC_PACKAGE_TRADE_REBATE = saAcc.SAC_PACKAGE_TRADE_REBATE__c == null ? 0 : saAcc.SAC_PACKAGE_TRADE_REBATE__c;
                    sO_Acc.SAC_PRICE = saAcc.PKA_VALUE__c == null ? 0 : saAcc.PKA_VALUE__c;
                    sO_Acc.SAC_ACCSVALUE = saAcc.PKA_VALUE__c == null ? 0 : saAcc.PKA_VALUE__c;
                } else {
                    sO_Acc.SAC_SETRADECOST = saAcc.SACSETRADECOST__c == null ? 0 : saAcc.SACSETRADECOST__c;
                    sO_Acc.SAC_DEALERTRADECOST = saAcc.SAC_DEALERTRADECOST__c == null ? 0 : saAcc.SAC_DEALERTRADECOST__c;
                    if (saAcc.SAC_ACCSTRADE__c == 'Y') {
                        Accessories_Master__c returnedAccsMaster = SalesAgreementService.getAccsMaster(saAcc.Accessories_Master__c);
                        if (returnedAccsMaster.Accs_Rate_Master__r.size() > 0) {
                            for (Accs_Rate_Master__c aRM : returnedAccsMaster.Accs_Rate_Master__r) {
                                if (aRM.ARM_SALEPRICE__c != null) {
                                    sO_Acc.SAC_PACKAGE_TRADE_REBATE = aRM.ARM_SALEPRICE__c;  
                                    //System.debug('TEST SAC_PACKAGE_TRADE_REBATE: ' + aRM.ARM_SALEPRICE__c);
                                    //SYSTEM.debug('TEST ID OF SA ACC: ' + saAcc.Name);
                                }
                            }
                        }           
                    } else {
                        sO_Acc.SAC_PACKAGE_TRADE_REBATE = 0;
                    }
                     
                }
                if (saAcc.SAC_ACCSTRADE__c == 'N') {
                    sO_Acc.SAC_PRICE = saAcc.SAC_PRICE__c == null ? 0 : saAcc.SAC_PRICE__c;
                    sO_Acc.SAC_ACCSVALUE = saAcc.SAC_PRICE__c == null ? 0 : saAcc.SAC_PRICE__c;
                    //System.debug('TEST NULL 1: ' + saAcc.SAC_PRICE__c);            
                }
                result.add(sO_Acc);
            } 
            if (!String.isBlank(saAcc.Acc_Code_Trigger__c)) {  
                if  (saAcc.Acc_Code_Trigger__c.substring(0,3) == 'COE') {
                    sO_Acc = new SalesOrder_AccWrapper();
                    sO_Acc.SAC_SOH_UNIQUEBRCD = saAcc.Sales_Agreement__r.UniqueBranchCode__c;
                    sO_Acc.SAC_SOH_FRNCD = saAcc.Sales_Agreement__r.FranchiseCode__c;
                    sO_Acc.SAC_SOH_SONO = saAcc.SAD_SOH_SONO__c;
                    sO_Acc.SAC_PACKAGE = 'N';
                    sO_Acc.SAC_QTY = 1;
                    sO_Acc.SAC_ACCSTRADE = 'N';
                    sO_Acc.SAC_SETRADECOST = 0;
                    sO_Acc.SAC_ACCSCOST = 0;
                    sO_Acc.SAC_DEALERTRADECOST = 0;
                    sO_Acc.SAC_INCPRICE = '';
                    sO_Acc.SAC_ACM_ACCSCD = saAcc.Acc_Code_Trigger__c;
                    sO_Acc.SAC_PACKAGE_TRADE_REBATE = 0;
                    sO_Acc.SAC_PRICE = saAcc.Price_Trigger__c;
                    sO_Acc.SAC_ACCSVALUE = saAcc.Price_Trigger__c;
                    
                    result.add(sO_Acc);
                } else {
                    sO_Acc = new SalesOrder_AccWrapper();
                    sO_Acc.SAC_SOH_UNIQUEBRCD = saAcc.Sales_Agreement__r.UniqueBranchCode__c;
                    sO_Acc.SAC_SOH_FRNCD = saAcc.Sales_Agreement__r.FranchiseCode__c;
                    sO_Acc.SAC_SOH_SONO = saAcc.SAD_SOH_SONO__c;
                    sO_Acc.SAC_PACKAGE = 'N';
                    sO_Acc.SAC_QTY = 1;
                    sO_Acc.SAC_ACCSTRADE = 'N';
                    sO_Acc.SAC_SETRADECOST = 0;
                    sO_Acc.SAC_ACCSCOST =  saAcc.Price_Trigger__c;
                    sO_Acc.SAC_DEALERTRADECOST = 0;
                    sO_Acc.SAC_INCPRICE = '';
                    sO_Acc.SAC_ACM_ACCSCD = saAcc.Acc_Code_Trigger__c;
                    sO_Acc.SAC_PACKAGE_TRADE_REBATE = 0;
                    sO_Acc.SAC_PRICE = 0;
                    sO_Acc.SAC_ACCSVALUE = 0;

                    result.add(sO_Acc);
                }
            }       
        }
        return result;
    }
    
    private static List<SalesOrder_AddnlChargeWrapper> generateSOAddnlChargeData(List<SA_Additional_Charge__c> returnedSAAddnlCharges, Sales_Agreement__c returnedSA) {
        List<SalesOrder_AddnlChargeWrapper> result = new List<SalesOrder_AddnlChargeWrapper>();
        List<Package_Additional_Charges__c> returnedPAC = SalesAgreementService.getPackageAddnlCharges(returnedSA.Package_Header__c);
        SalesOrder_AddnlChargeWrapper sO_AddnlCharge;
        Boolean hasR004 = false;
        Boolean hasR002 = false;
        SalesOrder_AddnlChargeWrapper r004AddnlCharge = new SalesOrder_AddnlChargeWrapper();
        SalesOrder_AddnlChargeWrapper r002AddnlCharge = new SalesOrder_AddnlChargeWrapper();
        if (returnedSA.Road_Tax_Top_Up__c) {
            for (SA_Additional_Charge__c saAddnlCharge : returnedSAAddnlCharges) {
                if (saAddnlCharge.SAD_ADM_CHRGCD__c != 'R002') {
                    sO_AddnlCharge = new SalesOrder_AddnlChargeWrapper();
                    sO_AddnlCharge.SAD_SOH_UNIQUEBRCD = saAddnlCharge.Sales_Agreement__r.UniqueBranchCode__c;
                    sO_AddnlCharge.SAD_SOH_FRNCD = saAddnlCharge.Sales_Agreement__r.FranchiseCode__c;
                    sO_AddnlCharge.SAD_SOH_SONO = saAddnlCharge.SAD_SOH_SONO__c;
                    sO_AddnlCharge.SAD_PACKAGE = saAddnlCharge.SAD_PACKAGE__c;
                    sO_AddnlCharge.SAD_REMOVE = saAddnlCharge.SAD_REMOVE__c;           
                    sO_AddnlCharge.SAD_SUPINVOICE = saAddnlCharge.SAD_SUPINVOICE__c;
                    sO_AddnlCharge.SAD_REBATE = saAddnlCharge.SAD_REBATE__c == null ? 0 : saAddnlCharge.SAD_REBATE__c;
                    sO_AddnlCharge.SAD_CHARGES = saAddnlCharge.SAD_CHARGES__c == null ? 0 : saAddnlCharge.SAD_CHARGES__c;
                    sO_AddnlCharge.SAD_PRINT = String.isBlank(saAddnlCharge.SAD_PRINT__c) == true ? 'Y' : saAddnlCharge.SAD_PRINT__c;
                    sO_AddnlCharge.SAD_DISPLAY = String.isBlank(saAddnlCharge.SAD_DISPLAY__c) == true ? 'Y' : saAddnlCharge.SAD_DISPLAY__c;
                    sO_AddnlCharge.SAD_INCPRICE = String.isBlank(saAddnlCharge.SAD_INCPRICE__c) == true ? 'WP' : saAddnlCharge.SAD_INCPRICE__c;
                    sO_AddnlCharge.SAD_ADM_CHRGCD = saAddnlCharge.SAD_ADM_CHRGCD__c;
                    
                    //sO_AddnlCharge.SAD_PACKAGE_REBATE = saAddnlCharge.SAD_PACKAGE_REBATE__c == null ? 0 : saAddnlCharge.SAD_PACKAGE_REBATE__c;   
                    for (Package_Additional_Charges__c pkgAddnlCharge : returnedPAC) {
                        if (saAddnlCharge.SAD_ADM_CHRGCD__c == pkgAddnlCharge.PKC_ADM_CHRGCD__c && pkgAddnlCharge.PKC_REBATE__c != null) {
                            sO_AddnlCharge.SAD_PACKAGE_REBATE = pkgAddnlCharge.PKC_REBATE__c;
                        }      
                    }
                    result.add(sO_AddnlCharge);
                }          
            }
        } else {
            for (SA_Additional_Charge__c saAddnlCharge : returnedSAAddnlCharges) {
                if (saAddnlCharge.SAD_ADM_CHRGCD__c != 'R002' && saAddnlCharge.SAD_ADM_CHRGCD__c != 'R004') {
                    sO_AddnlCharge = new SalesOrder_AddnlChargeWrapper();
                    sO_AddnlCharge.SAD_SOH_UNIQUEBRCD = saAddnlCharge.Sales_Agreement__r.UniqueBranchCode__c;
                    sO_AddnlCharge.SAD_SOH_FRNCD = saAddnlCharge.Sales_Agreement__r.FranchiseCode__c;
                    sO_AddnlCharge.SAD_SOH_SONO = saAddnlCharge.SAD_SOH_SONO__c;
                    sO_AddnlCharge.SAD_PACKAGE = saAddnlCharge.SAD_PACKAGE__c;
                    sO_AddnlCharge.SAD_REMOVE = saAddnlCharge.SAD_REMOVE__c;           
                    sO_AddnlCharge.SAD_SUPINVOICE = saAddnlCharge.SAD_SUPINVOICE__c;
                    sO_AddnlCharge.SAD_REBATE = saAddnlCharge.SAD_REBATE__c == null ? 0 : saAddnlCharge.SAD_REBATE__c;
                    sO_AddnlCharge.SAD_CHARGES = saAddnlCharge.SAD_CHARGES__c == null ? 0 : saAddnlCharge.SAD_CHARGES__c;
                    sO_AddnlCharge.SAD_PRINT = String.isBlank(saAddnlCharge.SAD_PRINT__c) == true ? 'Y' : saAddnlCharge.SAD_PRINT__c;
                    sO_AddnlCharge.SAD_DISPLAY = String.isBlank(saAddnlCharge.SAD_DISPLAY__c) == true ? 'Y' : saAddnlCharge.SAD_DISPLAY__c;
                    sO_AddnlCharge.SAD_INCPRICE = String.isBlank(saAddnlCharge.SAD_INCPRICE__c) == true ? 'WP' : saAddnlCharge.SAD_INCPRICE__c;
                    sO_AddnlCharge.SAD_ADM_CHRGCD = saAddnlCharge.SAD_ADM_CHRGCD__c;
                    
                    //sO_AddnlCharge.SAD_PACKAGE_REBATE = saAddnlCharge.SAD_PACKAGE_REBATE__c == null ? 0 : saAddnlCharge.SAD_PACKAGE_REBATE__c;   
                    for (Package_Additional_Charges__c pkgAddnlCharge : returnedPAC) {
                        if (saAddnlCharge.SAD_ADM_CHRGCD__c == pkgAddnlCharge.PKC_ADM_CHRGCD__c && pkgAddnlCharge.PKC_REBATE__c != null) {
                            sO_AddnlCharge.SAD_PACKAGE_REBATE = pkgAddnlCharge.PKC_REBATE__c;
                        }      
                    }
                    result.add(sO_AddnlCharge);
                } else {
                    if (saAddnlCharge.SAD_ADM_CHRGCD__c == 'R004') {
                        hasR004 = true;
                        r004AddnlCharge.SAD_SOH_UNIQUEBRCD = saAddnlCharge.Sales_Agreement__r.UniqueBranchCode__c;
                        r004AddnlCharge.SAD_SOH_FRNCD = saAddnlCharge.Sales_Agreement__r.FranchiseCode__c;
                        r004AddnlCharge.SAD_SOH_SONO = saAddnlCharge.SAD_SOH_SONO__c;
                        r004AddnlCharge.SAD_PACKAGE = saAddnlCharge.SAD_PACKAGE__c;
                        r004AddnlCharge.SAD_REMOVE = saAddnlCharge.SAD_REMOVE__c;           
                        r004AddnlCharge.SAD_SUPINVOICE = saAddnlCharge.SAD_SUPINVOICE__c;
                        r004AddnlCharge.SAD_REBATE = saAddnlCharge.SAD_REBATE__c == null ? 0 : saAddnlCharge.SAD_REBATE__c;
                        r004AddnlCharge.SAD_CHARGES = saAddnlCharge.SAD_CHARGES__c == null ? 0 : saAddnlCharge.SAD_CHARGES__c;
                        r004AddnlCharge.SAD_PRINT = String.isBlank(saAddnlCharge.SAD_PRINT__c) == true ? 'Y' : saAddnlCharge.SAD_PRINT__c;
                        r004AddnlCharge.SAD_DISPLAY = String.isBlank(saAddnlCharge.SAD_DISPLAY__c) == true ? 'Y' : saAddnlCharge.SAD_DISPLAY__c;
                        r004AddnlCharge.SAD_INCPRICE = String.isBlank(saAddnlCharge.SAD_INCPRICE__c) == true ? 'WP' : saAddnlCharge.SAD_INCPRICE__c;
                        r004AddnlCharge.SAD_ADM_CHRGCD = saAddnlCharge.SAD_ADM_CHRGCD__c;
                        
                        //sO_AddnlCharge.SAD_PACKAGE_REBATE = saAddnlCharge.SAD_PACKAGE_REBATE__c == null ? 0 : saAddnlCharge.SAD_PACKAGE_REBATE__c;   
                        for (Package_Additional_Charges__c pkgAddnlCharge : returnedPAC) {
                            if (saAddnlCharge.SAD_ADM_CHRGCD__c == pkgAddnlCharge.PKC_ADM_CHRGCD__c && pkgAddnlCharge.PKC_REBATE__c != null) {
                                r004AddnlCharge.SAD_PACKAGE_REBATE = pkgAddnlCharge.PKC_REBATE__c;
                            }      
                        }
                    }
                    if (saAddnlCharge.SAD_ADM_CHRGCD__c == 'R002') {
                        hasR002 = true;
                        r002AddnlCharge.SAD_SOH_UNIQUEBRCD = saAddnlCharge.Sales_Agreement__r.UniqueBranchCode__c;
                        r002AddnlCharge.SAD_SOH_FRNCD = saAddnlCharge.Sales_Agreement__r.FranchiseCode__c;
                        r002AddnlCharge.SAD_SOH_SONO = saAddnlCharge.SAD_SOH_SONO__c;
                        r002AddnlCharge.SAD_PACKAGE = saAddnlCharge.SAD_PACKAGE__c;
                        r002AddnlCharge.SAD_REMOVE = saAddnlCharge.SAD_REMOVE__c;           
                        r002AddnlCharge.SAD_SUPINVOICE = saAddnlCharge.SAD_SUPINVOICE__c;
                        r002AddnlCharge.SAD_REBATE = saAddnlCharge.SAD_REBATE__c == null ? 0 : saAddnlCharge.SAD_REBATE__c;
                        r002AddnlCharge.SAD_CHARGES = saAddnlCharge.SAD_CHARGES__c == null ? 0 : saAddnlCharge.SAD_CHARGES__c;
                        r002AddnlCharge.SAD_PRINT = String.isBlank(saAddnlCharge.SAD_PRINT__c) == true ? 'Y' : saAddnlCharge.SAD_PRINT__c;
                        r002AddnlCharge.SAD_DISPLAY = String.isBlank(saAddnlCharge.SAD_DISPLAY__c) == true ? 'Y' : saAddnlCharge.SAD_DISPLAY__c;
                        r002AddnlCharge.SAD_INCPRICE = String.isBlank(saAddnlCharge.SAD_INCPRICE__c) == true ? 'WP' : saAddnlCharge.SAD_INCPRICE__c;
                        r002AddnlCharge.SAD_ADM_CHRGCD = saAddnlCharge.SAD_ADM_CHRGCD__c;
                        
                        //sO_AddnlCharge.SAD_PACKAGE_REBATE = saAddnlCharge.SAD_PACKAGE_REBATE__c == null ? 0 : saAddnlCharge.SAD_PACKAGE_REBATE__c;   
                        for (Package_Additional_Charges__c pkgAddnlCharge : returnedPAC) {
                            if (saAddnlCharge.SAD_ADM_CHRGCD__c == pkgAddnlCharge.PKC_ADM_CHRGCD__c && pkgAddnlCharge.PKC_REBATE__c != null) {
                                r002AddnlCharge.SAD_PACKAGE_REBATE = pkgAddnlCharge.PKC_REBATE__c;
                            }      
                        }
                    }
                }
            }
            if ((hasR004 && hasR002) || (!hasR004 && hasR002)) {
                 result.add(r002AddnlCharge);
            }
            if (hasR004 && !hasR002) {
                 result.add(r004AddnlCharge);
            }
        }
       
        return result;
    }
    
    private static List<SalesOrder_FinanceDetailWrapper> generateSOFinanceDetailData (Sales_Agreement__c returnedSA) {
        List<SalesOrder_FinanceDetailWrapper> result = new List<SalesOrder_FinanceDetailWrapper>();
        SalesOrder_FinanceDetailWrapper sO_FinanceDetail = new SalesOrder_FinanceDetailWrapper();
        sO_FinanceDetail.SFD_BRM_COMPCD = returnedSA.CompanyCode__c;
        sO_FinanceDetail.SFD_BRM_BRCD = returnedSA.SOH_BRM_BRCD__c;
        sO_FinanceDetail.SFD_SOH_UNIQUEBRCD = returnedSA.UniqueBranchCode__c;
        sO_FinanceDetail.SFD_SOH_SONO = returnedSA.SOH_SONO__c;   
        sO_FinanceDetail.SFD_SOH_FRNCD = returnedSA.FranchiseCode__c;
        sO_FinanceDetail.SFD_CREATEDBY = returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        sO_FinanceDetail.SFD_CREATEDDT = DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_FinanceDetail.SFD_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        sO_FinanceDetail.SFD_LASTUPDDT = DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_FinanceDetail.SFD_BAM_FINCD = String.isBlank(returnedSA.Finance_Company_Lookup__r.BAM_ASSOCIATECD__c) == true ? '' : returnedSA.Finance_Company_Lookup__r.BAM_ASSOCIATECD__c;
        sO_FinanceDetail.SFD_FINANCEAMT = returnedSA.Amount_to_Finance__c == null ? 0 : returnedSA.Amount_to_Finance__c;
        
        if (returnedSA.Finance_Company_In_House__c) {
            sO_FinanceDetail.SFD_DOWNPAYMENT = returnedSA.DownPayment__c == null ? 0 : returnedSA.DownPayment__c;
            sO_FinanceDetail.SFD_TENURE = returnedSA.Terms_months__c == null ? 0 : returnedSA.Terms_months__c;
            sO_FinanceDetail.SFD_INTERESTRATE = returnedSA.Rate_p_a__c == null ? 0 : returnedSA.Rate_p_a__c;
            sO_FinanceDetail.SFD_EMI = returnedSA.MonthlyInstalment__c == null ? 0 : returnedSA.MonthlyInstalment__c;
            
        } else {
            sO_FinanceDetail.SFD_FINANCEAMT_DEALER = returnedSA.Amount_to_Finance__c == null ? 0 : returnedSA.Amount_to_Finance__c;
            sO_FinanceDetail.SFD_DOWNPAYMENT_DEALER = returnedSA.DownPayment__c == null ? 0 : returnedSA.DownPayment__c;
            sO_FinanceDetail.SFD_TENURE_DEALER = returnedSA.Terms_months__c == null ? 0 : returnedSA.Terms_months__c;
            sO_FinanceDetail.SFD_INTERESTRATE_DEALER = returnedSA.Rate_p_a__c  == null ? 0 : returnedSA.Rate_p_a__c;
            sO_FinanceDetail.SFD_EMI_DEALER = returnedSA.MonthlyInstalment__c == null ? 0 : returnedSA.MonthlyInstalment__c;
        }
        
        result.add(sO_FinanceDetail);
        
        return result;
    }
    
    private static List<SalesOrder_InsuranceDetailWrapper> generateSOInsuranceDetailData (Sales_Agreement__c returnedSA) {
        List<SalesOrder_InsuranceDetailWrapper> result = new List<SalesOrder_InsuranceDetailWrapper>();
        SalesOrder_InsuranceDetailWrapper sO_InsuranceDetail = new SalesOrder_InsuranceDetailWrapper();
        sO_InsuranceDetail.SID_BRM_COMPCD = returnedSA.CompanyCode__c;
        sO_InsuranceDetail.SID_BRM_BRCD = returnedSA.SOH_BRM_BRCD__c;
        sO_InsuranceDetail.SID_SOH_UNIQUEBRCD = returnedSA.UniqueBranchCode__c;
        sO_InsuranceDetail.SID_SOH_FRNCD = returnedSA.FranchiseCode__c;
        sO_InsuranceDetail.SID_SOH_SONO = returnedSA.SOH_SONO__c;
        sO_InsuranceDetail.SID_CREATEDBY = returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        sO_InsuranceDetail.SID_CREATEDDT = DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_InsuranceDetail.SID_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        sO_InsuranceDetail.SID_LASTUPDDT = DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_InsuranceDetail.SID_NCB = returnedSA.NCD__c == null ? 0 : returnedSA.NCD__c;
        sO_InsuranceDetail.SID_PREMIUMAMT = returnedSA.Premium_Payable__c == null ? 0 : returnedSA.Premium_Payable__c;
        sO_InsuranceDetail.SID_BAM_INSCD = String.isBlank(returnedSA.Insurance_Company_Lookup__r.BAM_ASSOCIATECD__c) == true ? '' : returnedSA.Insurance_Company_Lookup__r.BAM_ASSOCIATECD__c;
        sO_InsuranceDetail.SID_PERIOD = String.isBlank(returnedSA.Insurance_Package__c) == true ? 0 : Integer.valueOf(returnedSA.Insurance_Package__c);
        result.add(sO_InsuranceDetail);
        
        return result;
    }
    
    private static SalesOrder_Customer generateSOCustomerData (Sales_Agreement__c returnedSA) {
        SalesOrder_Customer sOCust = new SalesOrder_Customer();
        sOCust.CUM_BRM_UNIQUEBRCD = returnedSA.UniqueBranchCode__c;
        // sOCust.CUM_CUSTTYPE = 'NORM';
        sOCust.CUM_CUSTTYPE = returnedSA.Customer_Type__c;
        sOCust.CUM_LASTNAME = returnedSA.Surname__c;
        sOCust.CUM_SALUTATION = returnedSA.Salutation__c;
        sOCust.CUM_TITLE = returnedSA.Salutation__c;
        sOCust.CUM_MAILADDR1 = returnedSA.Street_NameMA__c == null ? returnedSA.Street_NameRA__c : returnedSA.Street_NameMA__c;
        sOCust.CUM_MAILADDR2 = returnedSA.Floor_UnitMA__c == null ? returnedSA.Floor_UnitRA__c : returnedSA.Floor_UnitMA__c;
        sOCust.CUM_MAILADDR3 = returnedSA.Building_NameMA__c == null ? returnedSA.Building_NameRA__c : returnedSA.Building_NameMA__c;
        sOCust.CUM_MAILPOSTAL = returnedSA.Postal_CodeMA__c == null ? returnedSA.Postal_CodeRA__c : returnedSA.Postal_CodeMA__c;
        sOCust.CUM_MAILMOBILE = returnedSA.MobileSA__c;
        sOCust.CUM_MAILEMAILID = returnedSA.emailaddress__c;        
        sOCust.CUM_REGADDR1 = returnedSA.Street_NameRA__c;
        sOCust.CUM_REGADDR2 = returnedSA.Floor_UnitRA__c;
        sOCust.CUM_REGADDR3 = returnedSA.Building_NameRA__c;
        sOCust.CUM_REGPOSTAL = returnedSA.Postal_CodeRA__c;
        sOCust.CUM_SEX = returnedSA.Gender__c == 'M' ? 'M' : 'F';
        sOCust.CUM_MARITALSTATUS = returnedSA.Marital_Status__c == 'Married' ? 'MAR' : 'SIN';
        sOCust.CUM_DOB = returnedSA.Date_Of_Birth__c == null ? '' : Datetime.newInstance(returnedSA.Date_Of_Birth__c.year(), returnedSA.Date_Of_Birth__c.month(), returnedSA.Date_Of_Birth__c.day(), 0, 0, 0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        sOCust.CUM_CREATEDBY =  returnedSA.SOH_CREATEDBY__c == null ? '' : returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        sOCust.CUM_CREATEDDT = returnedSA.CreatedDate == null ? '' : DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        sOCust.CUM_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c == null ? '' : returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        sOCust.CUM_LASTUPDDT = returnedSA.LastModifiedDate == null ? '' : DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss'); 
        sOCust.CUM_PDPA = returnedSA.AcknowledgementPersonalData__c == true ? 'Y' : 'N';
        sOCust.CUM_CUSTCD = returnedSA.SOH_CUM_CUSTCD__c == null ? '' : returnedSA.SOH_CUM_CUSTCD__c;
        sOCust.CUM_INVNAME = returnedSA.Customer_Full_Name__c;
        
        if (returnedSA.Registration_Type__c == 'P') {
            sOCust.CUM_NRICPSPTCPY = (returnedSA.NRIC_Number__c == null || returnedSA.Date_Of_Birth__c == null) ? '' : returnedSA.NRIC_Number__c.subString(5) + 
                DateTime.newInstance(returnedSA.Date_Of_Birth__c.year(), returnedSA.Date_Of_Birth__c.month(), returnedSA.Date_Of_Birth__c.day())
                .format('ddMMyyyy');
            //System.debug('Test  aaaaaaaa: ' + sOCust.CUM_NRICPSPTCPY);
            sOCust.CUM_CATEGORY = 'INDIV';
            sOCust.CUM_NRICFLAG = 'IDNO';
            sOCust.CUM_REALFIRSTNAME = returnedSA.FirstName__c;
            sOCust.CUM_REGNAME = returnedSA.Customer_Full_Name__c;
            sOCust.CUM_FIRSTNAME = returnedSA.Customer_Full_Name__c;
            sOCust.CUM_NRICCOE = returnedSA.NRIC_Number__c;
        } else if (returnedSA.Registration_Type__c == 'C') {
            sOCust.CUM_NRICPSPTCPY = returnedSA.ARCA_Number__c == null ? '' : returnedSA.ARCA_Number__c ;
            sOCust.CUM_REALFIRSTNAME = returnedSA.Company_Name__c == null ? '' : returnedSA.Company_Name__c;
            sOCust.CUM_REGNAME = returnedSA.Company_Name__c;
            sOCust.CUM_CATEGORY = 'COMP';
            sOCust.CUM_NRICFLAG = 'CPY';
            sOCust.CUM_FIRSTNAME = returnedSA.Company_Name__c;
            sOCust.CUM_NRICCOE = returnedSA.ARCA_Number__c == null ? '' : returnedSA.ARCA_Number__c ;
        }
        
      return sOCust;  
    }

    private static SalesOrder_Customer generateSellerData (Sales_Agreement__c returnedSA) {
        SalesOrder_Customer sOCust = new SalesOrder_Customer();
        sOCust.CUM_BRM_UNIQUEBRCD = returnedSA.UniqueBranchCode__c;
        // sOCust.CUM_CUSTTYPE = 'NORM';
        sOCust.CUM_CUSTTYPE = returnedSA.Seller_Type__c;
        sOCust.CUM_MAILADDR1 = returnedSA.Seller_Street_Name__c == null ? '' : returnedSA.Seller_Street_Name__c;
        sOCust.CUM_MAILADDR2 = returnedSA.Seller_Floor_Unit__c == null ? '' : returnedSA.Seller_Floor_Unit__c;
        sOCust.CUM_MAILADDR3 = returnedSA.Seller_Building_Name__c == null ? '' : returnedSA.Seller_Building_Name__c;
        sOCust.CUM_MAILPOSTAL = returnedSA.Seller_Postal_Code__c == null ? '' : returnedSA.Seller_Postal_Code__c;
        sOCust.CUM_REGADDR1 = returnedSA.Seller_Street_Name__c == null ? '' : returnedSA.Seller_Street_Name__c;
        sOCust.CUM_REGADDR2 = returnedSA.Seller_Floor_Unit__c == null ? '' : returnedSA.Seller_Floor_Unit__c;
        sOCust.CUM_REGADDR3 = returnedSA.Seller_Building_Name__c == null ? '' : returnedSA.Seller_Building_Name__c;
        sOCust.CUM_REGPOSTAL = returnedSA.Seller_Postal_Code__c == null ? '' : returnedSA.Seller_Postal_Code__c;
        sOCust.CUM_MAILMOBILE = returnedSA.Seller_Mobile_Number__c; 
        sOCust.CUM_CREATEDBY =  returnedSA.SOH_CREATEDBY__c == null ? '' : returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        sOCust.CUM_CREATEDDT = returnedSA.CreatedDate == null ? '' : DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss');
        sOCust.CUM_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c == null ? '' : returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        sOCust.CUM_LASTUPDDT = returnedSA.LastModifiedDate == null ? '' : DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0)
            .format('yyyy-MM-dd\'T\'HH:mm:ss'); 
        sOCust.CUM_PDPA = returnedSA.AcknowledgementPersonalData__c == true ? 'Y' : 'N';
        sOCust.CUM_CUSTCD = returnedSA.Seller_Account_No__c	 == null ? '' : returnedSA.Seller_Account_No__c	;    
        sOCust.CUM_MAILEMAILID = returnedSA.Seller_Email_Address__c;        

        if (returnedSA.isUsedCarUnderCompany__c) {
            sOCust.CUM_NRICPSPTCPY = returnedSA.Seller_Company_UEN__c == null ? '' : returnedSA.Seller_Company_UEN__c ;
            sOCust.CUM_REALFIRSTNAME = returnedSA.Seller_Company_Name__c == null ? '' : returnedSA.Seller_Company_Name__c;
            sOCust.CUM_REGNAME = returnedSA.Seller_Company_Name__c;
            sOCust.CUM_CATEGORY = 'COMP';
            sOCust.CUM_NRICFLAG = 'CPY';
            sOCust.CUM_FIRSTNAME = returnedSA.Seller_Company_Name__c;
            sOCust.CUM_NRICCOE = returnedSA.Seller_Company_UEN__c == null ? '' : returnedSA.Seller_Company_UEN__c ;
        } else {
            sOCust.CUM_NRICPSPTCPY = (returnedSA.Seller_NRIC__c == null || returnedSA.Seller_Date_Of_Birth__c == null) ? '' : returnedSA.Seller_NRIC__c.subString(5) + 
                                    DateTime.newInstance(returnedSA.Seller_Date_Of_Birth__c.year(), returnedSA.Seller_Date_Of_Birth__c.month(), returnedSA.Seller_Date_Of_Birth__c.day())
                                    .format('ddMMyyyy');
            //System.debug('Test  SELLER: ' + sOCust.CUM_NRICPSPTCPY);
            sOCust.CUM_CATEGORY = 'INDIV';
            sOCust.CUM_NRICFLAG = 'IDNO';
            sOCust.CUM_INVNAME = returnedSA.Seller_Full_Name__c;
            sOCust.CUM_REGNAME = returnedSA.Seller_Full_Name__c;
            sOCust.CUM_FIRSTNAME = returnedSA.Seller_Full_Name__c;
            sOCust.CUM_NRICCOE = returnedSA.Seller_NRIC__c;
            sOCust.CUM_DOB = returnedSA.Seller_Date_Of_Birth__c == null ? '' : Datetime.newInstance(returnedSA.Seller_Date_Of_Birth__c.year(), returnedSA.Seller_Date_Of_Birth__c.month(), returnedSA.Seller_Date_Of_Birth__c.day(), 0, 0, 0)
                                                                              .format('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        
        return sOCust;  
    }
   
    private static SalesOrderWrapper.SalesOrder_StockReservation generateStockReservationData  (Sales_Agreement__c returnedSA) {
        Map<Id, Stock_Reservation__c> stockResMap = SalesAgreementService.getStockReservationInformation(new Set<Id> {returnedSA.Stock_Reservation__c});
        SalesOrderWrapper.SalesOrder_StockReservation sO_StockRes = new SalesOrderWrapper.SalesOrder_StockReservation();
        
        sO_StockRes.STM_SALESFORCE_AUTOID = returnedSA.Stock_Reservation__c;
        sO_StockRes.STM_STATUS = stockResMap.get(returnedSA.Stock_Reservation__c).Reservation_Status__c;
        
        return sO_StockRes;
    }
    
    /**
    private static SalesOrder_COEInternalBidWrapper generateCOEInternalBid(Sales_Agreement__c returnedSA) {
        SalesOrder_COEInternalBidWrapper sO_COEIB = new SalesOrder_COEInternalBidWrapper();
        sO_COEIB.CIB_SOH_SONO = returnedSA.SOH_SONO__c == null ? '' : returnedSA.SOH_SONO__c;
        sO_COEIB.CIB_FRN_FRNCD = returnedSA.FranchiseCode__c;
        sO_COEIB.CIB_CAT = returnedSA.COECategory__c;
        sO_COEIB.CIB_GMS = returnedSA.GMS_Package__c == null ? 0 : returnedSA.GMS_Package__c;
        sO_COEIB.CIB_COE_REBATE = returnedSA.COE_Charged_Rebate__c == null ? 0 : returnedSA.COE_Charged_Rebate__c;
        sO_COEIB.CIB_GUARANTEE = returnedSA.COE_Package__c == 'Guaranteed COE' ? 'Guaranteed' : 'Non-Guaranteed';
        sO_COEIB.CIB_COMMISSION = returnedSA.Proposed_Commision__c == null ? 0 : returnedSA.Proposed_Commision__c;
        sO_COEIB.CIB_REMARKS = returnedSA.RegistrationInstruction__c;
        sO_COEIB.CIB_CREATEDBY = returnedSA.SOH_CREATEDBY__c.substring(0,returnedSA.SOH_CREATEDBY__c.indexOf('@'));
        sO_COEIB.CIB_CREATEDDT = DateTime.newInstance(returnedSA.CreatedDate.year(), returnedSA.CreatedDate.month(), returnedSA.CreatedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_COEIB.CIB_LASTUPDBY = returnedSA.SOH_LASTUPDBY__c.substring(0,returnedSA.SOH_LASTUPDBY__c.indexOf('@'));
        sO_COEIB.CIB_LASTUPDT = DateTime.newInstance(returnedSA.LastModifiedDate.year(), returnedSA.LastModifiedDate.month(), returnedSA.LastModifiedDate.day(),0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss');
        sO_COEIB.CIB_USED_CAR = returnedSA.Used_Car_Registration_Number__c == null ? 'No' : 'Yes';
        sO_COEIB.CIB_NO_OF_BID = returnedSA.Number_of_COE_Bids__c == null ? 0 : Double.valueOf(returnedSA.Number_of_COE_Bids__c);
        sO_COEIB.CIB_LOAN_APPROVE = returnedSA.Stage__c == 'COE Bidding' ? 'Yes' : 'No';
        
        return sO_COEIB;
    }**/
}
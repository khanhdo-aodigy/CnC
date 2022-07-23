public class SalesOrderWrapper {
    
    public String SOH_BRM_COMPCD;
	public String SOH_BRM_LOCCD;
	public String SOH_BRM_BRCD;
	public String SOH_BRM_UNIQUEBRCD;
	public String SOH_FRN_FRNCD;
	public String SOH_SONO;
	public String SOH_SODT;
	public Integer SOH_AMENDNO;
	public String SOH_RTM_REGTYPECD;
	public String SOH_BAM_DEALERCD;
	public String SOH_PKH_PKGNO;
	public String SOH_MYM_MODELCD;
	public String SOH_MYM_MODELYEAR;
	public String SOH_MCTM_COLORCD;
	public String SOH_MCTM_TRIMCD;
	public String SOH_WAIVEROFDEPOSIT;
	public String SOH_AGRCONVDT;
	public Double SOH_DEPOSITAMT;
	public Double SOH_COEDEPOSITAMT;
	public String SOH_EMM_SECD;
	public String SOH_FINTYPE;
	public String SOH_CUSTCOE;
	public String SOH_COEREQD;
	public Double SOH_PKGPRICE;
	public Double SOH_LISTPRICE;
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
	public Double SOH_SECOMM;
	public Double SOH_DEALERCOMM;
	public String SOH_EDDDT;
	public String SOH_EDDTODT;
	public Double SOH_SOVALUE;
	public String SOH_CANCELDT;
	public Double SOH_SPVEHDEPAMT;
	public String SOH_BIDEDREGNO;
	public String SOH_STATUS;
	public String SOH_CREATEDBY;
	public String SOH_CREATEDDT;
	public String SOH_LASTUPDBY;
	public String SOH_LASTUPDDT;
	public String SOH_REGNOTYPE;
	public String SOH_RETENREGNO;
	public String SOH_INSTRUCTION;
	public Double SOH_SPECIALDISC;
	public Double SOH_TRADECOST;
    public Double SOH_COESP;
	public String SOH_FINTYPE_DEALER;
	public String SOH_GMSFLAG;
    public String SOH_SAID;
  
	//public Double SOH_COSTTOFULCO;
	//public String SOH_COMMVERIFIEDBY;
	//public String SOH_COMMVERIFIEDFLG;
	//public String SOH_COMMVERIFIEDDT;
	//public String SOH_AMENDDT;
    //public String SOH_USQ_QUOTENO;
	//public Double SOH_USEDCARCOMM;
	//public String SOH_GMT_PURAGGNO;
    //public String SOH_OFFPEAKDT;
    //public String SOH_EMM_CODE;
    //public Double SOH_SECOMM_ADJUST;
	//public Double SOH_DEALERCOMM_ADJUST;
	//public String SOH_COMMADJUST_REMARK;  
    //public Double SOH_SECOMMPAID;
	//public Double SOH_DEALERCOMMPAID;
	//public String SOH_VEHALLOCDT;
	//public String SOH_SALESREP;
    //public String SOH_CANREMARKS;
    //public String SOH_INVNO;
	//public String SOH_INVDT;
    //public String SOH_CUSTPDDDT;
	//public Double SOH_RECDGSTAMT;
	//public Double SOH_DBNAMT;
	//public Double SOH_CRNAMT;
	//public Double SOH_RECDAMT;
	//public Double SOH_REFUNDAMT;
	//public Double SOH_CUSTRECDAMT;
	//public Double SOH_FINRECDAMT;
	//public String SOH_COH_DOCNO;
	//public Double SOH_QP;
	//public String SOH_SUCCESSMONTH;
	//public String SOH_EXPIRYMONTH;
	//public String SOH_COESUCCESSNOTIFY;
	//public String SOH_READYFORPDINOTIFY;
	//public String SOH_REGISTRATIONNOTIFY;
    //public String SOH_VEM_CCNO;
	//public String SOH_REGNO;
	//public String SOH_IUD_IUDOCNO;
	//public String SOH_CUM_CUSTCD;
    
    public List<SalesOrder_AddnlChargeWrapper> SALESORDER_ADDNLCHARGES;
    public List<SalesOrder_AccWrapper> SALESORDER_ACCS;
    public List<SalesOrder_FinanceDetailWrapper> SALESORDER_FINANCEDETAIL;
    public List<SalesOrder_InsuranceDetailWrapper> SALESORDER_INSURANCEDETAIL;
    public SalesOrder_Customer SALESORDER_CUSTOMER;
    //public SalesOrder_COEInternalBidWrapper SALESORDER_COEINTERNALBID;
    public SalesOrder_OptionWrapper SALESORDER_OPTIONS;
    public SalesOrder_StockReservation SALESORDER_STOCK_RESERVATION;
    
    public SalesOrderWrapper() {
        
        SOH_BRM_LOCCD = 'SGD';
        SOH_AMENDNO = 0;
        //SOH_STATUS = 'P';
        SOH_ACCSDISCAMT = 0;
        SOH_TRADECOST = 0.0;
        SOH_COESP = 0.0;
      
        // default values in case of null    
        SOH_SECOMM = 0.0;
        SOH_DEALERCOMM = 0.0;
        SOH_ACCSNETAMT = 0.0;
        SOH_SOVALUE = 0.0;
        SOH_TOTDISCAMT = 0.0;
        SOH_SPECIALDISC = 0.0;
        SOH_PKGADDNLAMT = 0.0;
        SOH_PKGACCSAMT = 0.0;
        SOH_DISCAMT = 0.0;
        SOH_ACCSREBATE = 0.0;
        SOH_ACCSAMT = 0.0;
        
        SOH_EMM_SECD = 'kevin.lee';
        //SOH_SECOMM_ADJUST = 0.0;
        //SOH_DEALERCOMM_ADJUST = 0.0;
        //SOH_OFFPEAKDT = '0001-01-01T00:00:00';
        //SOH_AMENDDT = '0001-01-01T00:00:00';
    }
    
    public class SalesOrder_OptionWrapper {
        
    }
    
    public class SalesOrder_StockReservation {
        public String STM_STATUS;
        public String STM_SALESFORCE_AUTOID;
    }
}
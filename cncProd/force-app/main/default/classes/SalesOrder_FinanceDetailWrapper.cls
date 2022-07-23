public class SalesOrder_FinanceDetailWrapper {
    
    public String SFD_BRM_COMPCD;
    public String SFD_BRM_LOCCD;
    public String SFD_BRM_BRCD;
    public String SFD_SOH_UNIQUEBRCD;
    public String SFD_SOH_FRNCD;
    public String SFD_SOH_SONO;
    public String SFD_BAM_FINCD;
    public Double SFD_FINANCEAMT;
    public Double SFD_DOWNPAYMENT;
    public Double SFD_TENURE;
    public Double SFD_INTERESTRATE;
    public Double SFD_EMI;
    public String SFD_STATUS;
    public String SFD_CREATEDBY;
    public String SFD_CREATEDDT;
    public String SFD_LASTUPDBY;
    public String SFD_LASTUPDDT;
    public Double SFD_FINANCEAMT_DEALER;
    public Double SFD_DOWNPAYMENT_DEALER;
    public Double SFD_TENURE_DEALER;
    public Double SFD_INTERESTRATE_DEALER;
    public Double SFD_EMI_DEALER;
    //public String SFD_FIRSTINSTDT;
    //public String SFD_LOANEXPDT;
   
    public SalesOrder_FinanceDetailWrapper() {
        SFD_BRM_LOCCD = 'SGD';
        SFD_STATUS = 'APR';
        
        SFD_FINANCEAMT = 0;
        SFD_FINANCEAMT_DEALER = 0;
        SFD_DOWNPAYMENT = 0;
        SFD_DOWNPAYMENT_DEALER = 0;
        SFD_TENURE = 0;
        SFD_TENURE_DEALER = 0;
        SFD_INTERESTRATE = 0;
        SFD_INTERESTRATE_DEALER = 0;
        SFD_EMI = 0;
        SFD_EMI_DEALER = 0;
    }
}
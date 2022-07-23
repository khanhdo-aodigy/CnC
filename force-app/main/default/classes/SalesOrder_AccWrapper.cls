public class SalesOrder_AccWrapper {
    
    public String SAC_SOH_UNIQUEBRCD;
    public String SAC_SOH_FRNCD;
    public String SAC_SOH_SONO;
    //public Integer SAC_LINENO;
    public String SAC_PACKAGE;
    public String SAC_ACM_ACCSCD;
    public Double SAC_QTY;
    public Double SAC_PRICE;
    public Integer SAC_DISCPER;
    public Integer SAC_DISCAMT;
    public Double SAC_ACCSVALUE;
    public String SAC_INCPRICE;
    public String SAC_JCRAISED;
    public Double SAC_ACCSCOST;
    public Integer SAC_DEALERCOMM;
    public String SAC_ACCSTRADE;
    public Double SAC_SETRADECOST;
    public Double SAC_DEALERTRADECOST;
    public Double SAC_PACKAGE_TRADE_REBATE;
    public Double SAC_REBATE;
    //public Double SAC_SECOMM;
    
    public SalesOrder_AccWrapper() {
        
        SAC_QTY = 1;
        SAC_DISCPER = 0;
        SAC_DISCAMT = 0;
        SAC_JCRAISED = 'N';
        SAC_DEALERCOMM = 0;
        
        // default values for api 
        SAC_PACKAGE_TRADE_REBATE =  0;
        SAC_PRICE = 0;
        SAC_ACCSVALUE = 0;
        SAC_REBATE =0;
    }

}
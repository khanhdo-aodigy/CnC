public class SalesOrder_AddnlChargeWrapper {
    
    public String SAD_SOH_UNIQUEBRCD;
    public String SAD_SOH_FRNCD;
    public String SAD_SOH_SONO;
    public String SAD_PACKAGE;
    public String SAD_ADM_CHRGCD;
    public String SAD_ADM_CHARGTYPE;
    public String SAD_ADM_OTHERTYPE;
    public Double SAD_CHARGES;
    public String SAD_REMOVE;
    public String SAD_DISPLAY;
    public String SAD_PRINT;
    public String SAD_INCPRICE;
    public String SAD_SUPINVOICE;
    public Double SAD_PACKAGE_REBATE;
    public Double SAD_REBATE;
    
    public SalesOrder_AddnlChargeWrapper() {
        
       SAD_ADM_CHARGTYPE = 'ADDNL';
       SAD_ADM_OTHERTYPE = 'FIN';
       SAD_PACKAGE_REBATE = 0;
    }

}
/** *****
 * Description : Wrapper class for restDigitalPayment request body
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name                     Description
 * 20200608            thu.phan@aodigy          Created Initial Version 
 * 20210205            khanh.do@aodigy          Updated Request body for RA
 * 
** *****/
public class DigitalPaymentWrapper {

    public String ReservationNumber; //RA Used Car
    public String VehicleRegistrationNumber;
    public String EshopOrderId;
	public String EshopOrderNumber;
    public String Branch;
    public String SiteName;
    public String TransactionStatus;
    public String TransactionID;
    public String MaskedCCNo;    
    public Double NetAmount; //RA Used Car
    public String CardType;
    public String Event;
	public Decimal TransactionAmountBySource;

}
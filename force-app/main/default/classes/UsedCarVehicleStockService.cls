/** *****
 * Description : Service Class for Used Car Vehicle Stock object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                    Description
 * 20210105             khanh.do@aodigy         Created Initial Version. 
 * 20210121				hung.huynh@aodigy	    Added getVehicleStockMapByStockNumbers method
 * 20210309             HS@aodigy               Added 
** *****/
public with sharing class UsedCarVehicleStockService {

    private static UsedCarVehicleStockSelector selector = new UsedCarVehicleStockSelector();
    
    public static Used_Car_Vehicle_Stock__c getVehicleStockByStockNumber(String stockNumber) 
    {
        List<Used_Car_Vehicle_Stock__c> stockList = getVehicleStockListByStockNumbers(new Set<String>{stockNumber});
        return !stockList.isEmpty() ? stockList.get(0) : null;
    }

    public static List<Used_Car_Vehicle_Stock__c> getVehicleStockListByStockNumbers( Set<String> stockNumbers) 
    {
        return selector.getVehicleStockListByStockNumbers( stockNumbers );
    }
    
    public static Map<String, Used_Car_Vehicle_Stock__c> getVehicleStockMapByStockNumbers( Set<String> stockNumbers) 
    {
        return selector.getVehicleStockMapByStockNumbers( stockNumbers );
    }

    public static Boolean checkIsValidDocNo( String stockNumber )
    {
        return !( getVehicleStockByStockNumber( stockNumber ) == null );
    }

}
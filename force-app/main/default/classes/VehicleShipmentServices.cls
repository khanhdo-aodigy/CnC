/*==========================================================================================================================================================================
 * Service class for Vehicle Shipment Entity
 * Created By: Aodigy Team
 * Create Date: Aug 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *          18 Aug 2022                         dangphap.mai@aodigy.com             US-Ship-000008                                       init
 *          24 Aug 2022                         phan.thu@aodigy.com                 US-Ship-000027                                       Added getByIds method
 *          27 Aug 2022                         phan.thu@aodigy.com                 US-Ship-000035                                       Added getByIdWithInvoicesAndLineItems
 * ========================================================================================================================================================================== 
 */
public inherited sharing class VehicleShipmentServices
{
    /**
     * ============================================================================================
     * Auto match the shipment line item with eligible stock vehicle master
     * @param shipmentIds: target vehicle shipment ids
     * @return String indicate the status of auto matching: FULL for all line items matched, PARTIAL for part of line items matched and FAIL for no line item matched
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    public static String shipmentsAutoMatching(Set<String> shipmentIds)
    {
        // TODO: use selector

        if (shipmentIds == null || shipmentIds.size() == 0)
        {
            throw new VehicleShipmentException('Invalid id for shipment matching: ' + shipmentIds);
        }
        
        // 1. get matched stock vehicle master related to @shipmentIds
        List<Vehicle_Master2__c> shipmentMatchedStocks = [  SELECT Name, Shipment_Line_Item__c
                                                            FROM Vehicle_Master2__c
                                                            WHERE Shipment_Line_Item__r.Vehicle_Shipment__c IN :shipmentIds
                                                        ];
        
        // 2. get set of matched line item ids
        Set<Id> matchedShipmentLineItemIds = new Set<Id>();
        for (Vehicle_Master2__c shipmentMatchedStock : shipmentMatchedStocks)
        {
            matchedShipmentLineItemIds.add(shipmentMatchedStock.Shipment_Line_Item__c);
        }

        //3.  get shipment line items need to match = all shipment's line items - matched line items
        // line item with manufaturer ref no populated will be prioritised for matching
        List<Shipment_Line_Item__c> shipmentLineItems = [   SELECT  Name, Model__c, Colour_Code__c, Trim__c, Manufacturer_Ref_No__c, Production_Month__c, Vehicle_Shipment__c,
                                                                    FOB_Amount__c, FOB_Amount_Currency_Code__c, Franchise_Code__c, Freight_Charges__c, Freight_Charges_Currency_Code__c,
                                                                    Insurance_Charges__c, Insurance_Charges_Currency_Code__c, Ex_Factory_Charges__c, Ex_Factory_Charges_Currency_Code__c,
                                                                    Transport_Charges__c, Transport_Charges_Currency_Code__c, Other_Charges__c, Other_Charges_Currency_Code__c,
                                                                    TN_HS_Code__c, Product_Code_Description__c, Engine_No__c, Chassis_No__c, Invoice_No__c, Vessel_Name__c, Invoice_No__r.Invoice_No__c
                                                            FROM Shipment_Line_Item__c
                                                            WHERE Vehicle_Shipment__c IN :shipmentIds
                                                            AND Id NOT IN :matchedShipmentLineItemIds
                                                            ORDER BY Manufacturer_Ref_No__c ASC NULLS LAST
                                                        ];
        //
        if (shipmentLineItems.size() == 0)
        {
            throw new VehicleShipmentException('There is no eligible shipment line item for matching');
        }

        // 4. get eligible stocks for matching
        List<Vehicle_Master2__c> eligibleVehicleMasterStocks = [SELECT  Id, Model_Code__c, Color_Code__c, Trim_Code__c, Production_Month__c, Shipment_Line_Item__c, Vehicle_Shipment__c,
                                                                        Vehicle_Purchase_Status__c, Purchase_Order_Status__c, Vehicle_Status__c, CreatedDate, Reservation_Start_Date__c,
                                                                        Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name, Manufacturer_Ref_No__c,
                                                                        FOB_Amount__c, FOB_Amount_Currency_Code__c, Franchise_Code__c, Freight_Charges__c, Freight_Charges_Currency_Code__c,
                                                                        Insurance_Charges__c, Insurance_Charges_Currency_Code__c, Ex_Factory_Charges__c, Ex_Factory_Charges_Currency_Code__c,
                                                                        Transport_Charges__c, Transport_Charges_Currency_Code__c, Other_Charges__c, Other_Charges_Currency_Code__c, Vehicle_Purchase_Order_Line_Items__c,
                                                                        TN_HS_Code__c, Product_Code__c, Engine_No__c, Chassis__c, Invoice_No__c, Inward_Declaration_Invoice__c, Vessel_Name__c
                                                                FROM Vehicle_Master2__c
                                                                WHERE Shipment_Line_Item__c = NULL
                                                                AND (
                                                                        (
                                                                            Vehicle_Purchase_Order_Line_Items__c != null
                                                                            AND
                                                                            Vehicle_Purchase_Status__c = 'Confirmed'
                                                                        )
                                                                        OR
                                                                        (
                                                                            Vehicle_Status__c = 'RESRV'
                                                                        )
                                                                    )
                                                                ORDER BY CreatedDate ASC, Reservation_Start_Date__c ASC];
        //
        if (eligibleVehicleMasterStocks.size() == 0)
        {
            throw new VehicleShipmentException('There is no eligible stock vehicle master for matching');
        }

        // 5. arrange eligible stocks into top priority -> least priority
        Map<Id, Vehicle_Master2__c> tier1 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> tier2 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> tier3 = new Map<Id, Vehicle_Master2__c>();
        Map<Id, Vehicle_Master2__c> tier4 = new Map<Id, Vehicle_Master2__c>();

        for (Vehicle_Master2__c stock : eligibleVehicleMasterStocks)
        {
            if (isTier1(stock))
            {
                tier1.put(stock.Id, stock);
            }
            else if (isTier2(stock))
            {
                tier2.put(stock.Id, stock);
            }
            else if (isTier3(stock))
            {
                tier3.put(stock.Id, stock);
            }
            else
            {
                tier4.put(stock.Id, stock);
            }
        }

        // 6. sort stocks in each tier (if needed) and combine into a single list for matching
        List<Vehicle_Master2__c> matchableStocks = new List<Vehicle_Master2__c>();
        matchableStocks.addAll( sortTier1(tier1.values()) );
        matchableStocks.addAll( sortTier2(tier2.values()) );
        matchableStocks.addAll( sortTier3(tier3.values()) );
        matchableStocks.addAll( sortTier4(tier4.values()) );

        // 7. start matching
        Map<Id, Vehicle_Master2__c> updatingStockVehicleMasters     = new Map<Id, Vehicle_Master2__c>();

        Map<Id, Shipment_Line_Item__c> matchedShipmentLineItems     = new Map<Id, Shipment_Line_Item__c>();

        // Map<Id, Shipment_Line_Item__c> unmatchedShipmentLineItems   = new Map<Id, Shipment_Line_Item__c>();

        // TODO: increase the efficiency of matching
        for (Shipment_Line_Item__c shipmentLineItem : shipmentLineItems)
        {
            for (Vehicle_Master2__c stock : matchableStocks)
            {
                // a stock can be matched only once
                if (updatingStockVehicleMasters.keySet().contains(stock.Id))
                {
                    continue;
                }

                Boolean matchRefNo              = String.isNotBlank(stock.Manufacturer_Ref_No__c) && String.isNotBlank(shipmentLineItem.Manufacturer_Ref_No__c) && stock.Manufacturer_Ref_No__c == shipmentLineItem.Manufacturer_Ref_No__c;
                Boolean matchModel              = stock.Model_Code__r.Name == shipmentLineItem.Model__c;
                Boolean matchColor              = stock.Color_Code__r.ColorCode__c == shipmentLineItem.Colour_Code__c;
                Boolean matchTrim               = stock.Trim_Code__r.Name == shipmentLineItem.Trim__c;
                Boolean matchProductionMonth    = stock.Production_Month__c == shipmentLineItem.Production_Month__c;

                // if (stock.Id == 'a0K0T000005WPiaUAG')
                // {
                //     System.debug(shipmentLineItem.Name);
                //     System.debug('matchRefNo :: ' + matchRefNo);
                //     System.debug('matchModel :: ' + matchModel);
                //     System.debug('matchColor :: ' + matchColor);
                //     System.debug('matchTrim :: ' + matchTrim);
                //     System.debug('matchProductionMonth :: ' + matchProductionMonth);
                // }
                

                // if manufacturer ref no is matched can ignore other matching conditions
                if (matchRefNo)
                {
                    beginShipmentMatching(stock, shipmentLineItem);
                    updatingStockVehicleMasters.put(stock.Id, stock);
                    matchedShipmentLineItems.put(shipmentLineItem.Id, shipmentLineItem);
                    break;
                }
                // else need to match model & color & trim & production month
                else if (matchModel && matchColor && matchTrim && matchProductionMonth)
                {
                    // make sure only stock without manufacturer ref no can be matched via model/color/trim combinations
                    if (String.isBlank(stock.Manufacturer_Ref_No__c))
                    {
                        beginShipmentMatching(stock, shipmentLineItem);
                        updatingStockVehicleMasters.put(stock.Id, stock);
                        matchedShipmentLineItems.put(shipmentLineItem.Id, shipmentLineItem);
                        break;
                    }
                    // this block handle stock that matched via model/color/trim combinations but do not match ref no. For example: typo in ref no
                    // currently we do not apply any handler for these stocks. User can match via manual assign from Shipment Matching component
                    else
                    {

                    }
                    
                }
            }

            // after matching, check if shipment line item is matched
            // if (!matchedShipmentLineItems.keySet().contains(shipmentLineItem.Id))
            // {
            //     unmatchedShipmentLineItems.put(shipmentLineItem.Id, shipmentLineItem);
            // }
        }


        // update SVM
        if (updatingStockVehicleMasters.size() > 0)
        {
            update updatingStockVehicleMasters.values();
        }

        // TODO: Create Task to Sales Admin from the shipment record if shipment line items are not completely matched

        if (matchedShipmentLineItems.size() == 0)
        {
            return 'FAIL';
        }
        else if (matchedShipmentLineItems.size() == shipmentLineItems.size())
        {
            return 'FULL';
        }
        else
        {
            return 'PARTIAL';
        }

        // return matchedShipmentLineItems.size() == shipmentLineItems.size()? 'FULL' : 'PARTIAL';
    }

    /**
     * ============================================================================================
     * Manual match shipment line item and stock vehicle master by Id
     * @param shipmentLineItemId: shipment line item id for matching
     * @param stockVehicleMasterId: stock vehicle master id for matching
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    public static void shipmentManualMatchById(String shipmentLineItemId, String stockVehicleMasterId)
    {
        System.Savepoint sp = Database.setSavepoint();

        try
        {
            List<Vehicle_Master2__c> updatingStocks = new List<Vehicle_Master2__c>();

            // get shipment line item for matching
            // TODO: use selector
            Shipment_Line_Item__c shipmentLineItem = [  SELECT  Name, Model__c, Colour_Code__c, Trim__c, Manufacturer_Ref_No__c, Production_Month__c, Vehicle_Shipment__c,
                                                                FOB_Amount__c, FOB_Amount_Currency_Code__c, Franchise_Code__c, Freight_Charges__c, Freight_Charges_Currency_Code__c,
                                                                Insurance_Charges__c, Insurance_Charges_Currency_Code__c, Ex_Factory_Charges__c, Ex_Factory_Charges_Currency_Code__c,
                                                                Transport_Charges__c, Transport_Charges_Currency_Code__c, Other_Charges__c, Other_Charges_Currency_Code__c,
                                                                TN_HS_Code__c, Product_Code_Description__c, Engine_No__c, Chassis_No__c, Invoice_No__c, Vessel_Name__c, Invoice_No__r.Invoice_No__c
                                                        FROM Shipment_Line_Item__c
                                                        WHERE Id =:shipmentLineItemId
                                                    ];
            // get stock for matching
            // TODO: use selector
            Vehicle_Master2__c matchingstock = [SELECT  Id, Model_Code__c, Color_Code__c, Trim_Code__c, Production_Month__c, Shipment_Line_Item__c, Vehicle_Shipment__c,
                                                        Vehicle_Purchase_Status__c, Purchase_Order_Status__c, Vehicle_Status__c, CreatedDate, Reservation_Start_Date__c,
                                                        Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name, Manufacturer_Ref_No__c,
                                                        FOB_Amount__c, FOB_Amount_Currency_Code__c, Franchise_Code__c, Freight_Charges__c, Freight_Charges_Currency_Code__c,
                                                        Insurance_Charges__c, Insurance_Charges_Currency_Code__c, Ex_Factory_Charges__c, Ex_Factory_Charges_Currency_Code__c,
                                                        Transport_Charges__c, Transport_Charges_Currency_Code__c, Other_Charges__c, Other_Charges_Currency_Code__c,
                                                        TN_HS_Code__c, Product_Code__c, Engine_No__c, Chassis__c, Invoice_No__c, Inward_Declaration_Invoice__c, Vessel_Name__c
                                                FROM Vehicle_Master2__c
                                                WHERE Id =:stockVehicleMasterId
                                                ];
            // get matched stock of @shipmentLineItem
            // TODO: use selector
            List<Vehicle_Master2__c> matchedStocks = [  SELECT  Id, Model_Code__c, Color_Code__c, Trim_Code__c, Production_Month__c, Shipment_Line_Item__c, Vehicle_Shipment__c,
                                                                Vehicle_Purchase_Status__c, Purchase_Order_Status__c, Vehicle_Status__c, CreatedDate, Reservation_Start_Date__c,
                                                                Model_Code__r.Name, Color_Code__r.ColorCode__c, Trim_Code__r.Name, Manufacturer_Ref_No__c,
                                                                FOB_Amount__c, FOB_Amount_Currency_Code__c, Franchise_Code__c, Freight_Charges__c, Freight_Charges_Currency_Code__c,
                                                                Insurance_Charges__c, Insurance_Charges_Currency_Code__c, Ex_Factory_Charges__c, Ex_Factory_Charges_Currency_Code__c,
                                                                Transport_Charges__c, Transport_Charges_Currency_Code__c, Other_Charges__c, Other_Charges_Currency_Code__c
                                                        FROM Vehicle_Master2__c
                                                        WHERE Shipment_Line_Item__c =:shipmentLineItem.Id
                                                    ];
            // clear current matched stock of @shipmentLineItem (if any)
            if (matchedStocks.size() > 0)
            {
                // updatingStocks.addAll(matchedStocks);
                beginShipmentUnmatching(matchedStocks, shipmentLineItem);
            }
            
            // match shipment line item with new stock
            // updatingStocks.add(stock);
            beginShipmentMatching(matchingstock, shipmentLineItem);

            // commit changes on unmatching stocks first then to new matched stock to prevent 1-1 validation to trigger
            update matchedStocks;
            update matchingstock;
        }
        catch (Exception e)
        {
            Database.rollback(sp);
            System.debug('VehicleShipmentServices :: shipmentManualMatchById :: Exception Message > ' + e.getMessage());
            System.debug('VehicleShipmentServices :: shipmentManualMatchById : :Exception Stack Trace > ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * ============================================================================================
     * Check if stock vehicle master is tier 1 for matching
     * @param stock: stock vehicle master for checking
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static Boolean isTier1(Vehicle_Master2__c stock)
    {
        return String.isNotBlank(stock.Manufacturer_Ref_No__c);
    }

    /**
     * ============================================================================================
     * Check if stock vehicle master is tier 2 for matching
     * @param stock: stock vehicle master for checking
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static Boolean isTier2(Vehicle_Master2__c stock)
    {
        return stock.Vehicle_Purchase_Order_Line_Items__c != null && stock.Vehicle_Purchase_Status__c == 'Confirmed';
    }

    /**
     * ============================================================================================
     * Check if stock vehicle master is tier 3 for matching
     * @param stock: stock vehicle master for checking
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static Boolean isTier3(Vehicle_Master2__c stock)
    {
        return stock.Vehicle_Status__c == 'RESRV';
    }

    /**
     * ============================================================================================
     * Sort tier 1 stocks
     * @param stocks: stock vehicle masters for sorting
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<Vehicle_Master2__c> sortTier1(List<Vehicle_Master2__c> stocks)
    {
        // tier 1 is sorted by CreatedDate which is already implemented at querying
        // reserved for future use
        return stocks;
    }

    /**
     * ============================================================================================
     * Sort tier 2 stocks
     * @param stocks: stock vehicle masters for sorting
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<Vehicle_Master2__c> sortTier2(List<Vehicle_Master2__c> stocks)
    {
        // tier 2 is sorted by CreatedDate which is already implemented at querying
        // reserved for future use
        return stocks;
    }

    /**
     * ============================================================================================
     * Sort tier 3 stocks
     * @param stocks: stock vehicle masters for sorting
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<Vehicle_Master2__c> sortTier3(List<Vehicle_Master2__c> stocks)
    {
        // tier 3 is sorted by Reservation_Start_Date__c ASC and then by Created Date ASC
        

        Map<Id, Vehicle_Master2__c> unsortedStockById = new Map<Id, Vehicle_Master2__c> (stocks);

        // dirty hack: leveraging SOQL sorting on @stock instead of applying sorting on current list
        Map<Id, Vehicle_Master2__c> sortedStockById = new Map<Id, Vehicle_Master2__c> ([SELECT Id, Reservation_Start_Date__c, CreatedDate FROM Vehicle_Master2__c WHERE Id IN :unsortedStockById.keySet() ORDER BY Reservation_Start_Date__c ASC, CreatedDate ASC]);

        // replace simple sorted stock with original value from @stocks

        for (Id stockId : sortedStockById.keySet())
        {
            if (unsortedStockById.get(stockId) != null)
            {
                sortedStockById.put(stockId, unsortedStockById.get(stockId));
            }
        }

        return sortedStockById.values();
    }

    /**
     * ============================================================================================
     * Sort tier 4 stocks
     * @param stocks: stock vehicle masters for sorting
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static List<Vehicle_Master2__c> sortTier4(List<Vehicle_Master2__c> stocks)
    {
        // tier 2 is sorted by CreatedDate which is already implemented at querying
        // reserved for future use
        return stocks;
    }

    /**
     * ============================================================================================
     * Perform the logic on matching between shipment line item and stock
     * @param stocks: stock vehicle masters for sorting
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static void beginShipmentMatching(Vehicle_Master2__c stock, Shipment_Line_Item__c shipmentLineItem)
    {
        // advance stock status
        stock.Vehicle_Purchase_Status__c    = 'In Shipment';
        
        // link SVM to shipment & shipment line item
        stock.Shipment_Line_Item__c         = shipmentLineItem.Id;
        stock.Vehicle_Shipment__c           = shipmentLineItem.Vehicle_Shipment__c;

        postMatching(stock, shipmentLineItem);
    }

    /**
     * ============================================================================================
     * Perform the logic on unmatching stock vehicle master from @shipmentLineItem
     * @param matchedStocks: matched stocks for unmatching
     * @param shipmentLineItem: shipment line item for unmatching
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static void beginShipmentUnmatching(List<Vehicle_Master2__c> matchedStocks, Shipment_Line_Item__c shipmentLineItem)
    {
        for (Vehicle_Master2__c matchedStock : matchedStocks)
        {
            matchedStock.Vehicle_Purchase_Status__c = 'Confirmed';
            matchedStock.Shipment_Line_Item__c = null;
            matchedStock.Vehicle_Shipment__c = null;

            postUnmatching(matchedStock, shipmentLineItem);
        }
    }

    /**
     * ============================================================================================
     * Perform the logic on post matching between shipment line item and stock
     * @param stocks: stock vehicle masters for processing
     * @param shipmentLineItem: shipment line item for processing
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static void postMatching(Vehicle_Master2__c stock, Shipment_Line_Item__c shipmentLineItem)
    {
        // copy franchise code
        stock.Franchise_Code__c             = shipmentLineItem.Franchise_Code__c;

        // ex-factory charges
        stock.Ex_Factory_Charges__c = shipmentLineItem.Ex_Factory_Charges__c;

        if (shipmentLineItem.Ex_Factory_Charges__c != null && shipmentLineItem.Ex_Factory_Charges__c > 0)
        {
            stock.Ex_Factory_Charges_Currency_Code__c = shipmentLineItem.Ex_Factory_Charges_Currency_Code__c;
        }

        // transport charges
        stock.Transport_Charges__c = shipmentLineItem.Transport_Charges__c;

        if (shipmentLineItem.Transport_Charges__c != null && shipmentLineItem.Transport_Charges__c > 0)
        {
            stock.Transport_Charges_Currency_Code__c = shipmentLineItem.Transport_Charges_Currency_Code__c;
        }

        // FOB price
        stock.FOB_Amount__c = shipmentLineItem.FOB_Amount__c;

        if (shipmentLineItem.FOB_Amount__c != null && shipmentLineItem.FOB_Amount__c > 0)
        {
            stock.FOB_Amount_Currency_Code__c = shipmentLineItem.FOB_Amount_Currency_Code__c;
        }
        
        // freight charges
        stock.Freight_Charges__c = shipmentLineItem.Freight_Charges__c;

        if (shipmentLineItem.Freight_Charges__c != null && shipmentLineItem.Freight_Charges__c > 0)
        {
            stock.Freight_Charges_Currency_Code__c = shipmentLineItem.Freight_Charges_Currency_Code__c;
        }

        // insurance charges
        stock.Insurance_Charges__c = shipmentLineItem.Insurance_Charges__c;

        if (shipmentLineItem.Insurance_Charges__c != null && shipmentLineItem.Insurance_Charges__c > 0)
        {
            stock.Insurance_Charges_Currency_Code__c = shipmentLineItem.Insurance_Charges_Currency_Code__c;
        }

        // other charges
        stock.Other_Charges__c = shipmentLineItem.Other_Charges__c;

        if (shipmentLineItem.Other_Charges__c != null && shipmentLineItem.Other_Charges__c > 0)
        {
            stock.Other_Charges_Currency_Code__c = shipmentLineItem.Other_Charges_Currency_Code__c;
        }

        // HS code
        stock.TN_HS_Code__c = shipmentLineItem.TN_HS_Code__c;

        // product code
        stock.Product_Code__c = shipmentLineItem.Product_Code_Description__c;

        // engine number
        stock.Engine_No__c = shipmentLineItem.Engine_No__c;

        // chassis number
        stock.Chassis__c = shipmentLineItem.Chassis_No__c;

        // invoice information
        stock.Inward_Declaration_Invoice__c = shipmentLineItem.Invoice_No__c;
        stock.Invoice_No__c                 = shipmentLineItem.Invoice_No__r.Invoice_No__c;
        stock.Vessel_Name__c                = shipmentLineItem.Vessel_Name__c;
    }

    /**
     * ============================================================================================
     * Perform the logic on post unmatching between shipment line item and stock
     * @param stocks: stock vehicle masters for processing
     * @param shipmentLineItem: shipment line item for processing
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          18 Aug 2022                         dangphap.mai@aodigy.com             init
     * ============================================================================================
     */
    private static void postUnmatching(Vehicle_Master2__c matchedStock, Shipment_Line_Item__c shipmentLineItem)
    {
        // reset franchise code
        matchedStock.Franchise_Code__c = null;

        // reset ex-factory charges
        matchedStock.Ex_Factory_Charges__c = null;
        matchedStock.Ex_Factory_Charges_Currency_Code__c = null;

        // reset transport charges
        matchedStock.Transport_Charges__c = null;
        matchedStock.Transport_Charges_Currency_Code__c = null;

        // reset FOB price
        matchedStock.FOB_Amount__c = null;
        matchedStock.FOB_Amount_Currency_Code__c = null;
        
        // reset freight charges
        matchedStock.Freight_Charges__c = null;
        matchedStock.Freight_Charges_Currency_Code__c = null;

        // reset insurance charges
        matchedStock.Insurance_Charges__c = null;
        matchedStock.Insurance_Charges_Currency_Code__c = null;

        // reset other charges
        matchedStock.Other_Charges__c = null;
        matchedStock.Other_Charges_Currency_Code__c = null;

        // reset HS code
        matchedStock.TN_HS_Code__c = null;

        // reset production code
        matchedStock.Product_Code__c = null;

        // reset engine number
        matchedStock.Engine_No__c = null;

        // reset chassis number
        matchedStock.Chassis__c = null;

        // reset invoice information
        matchedStock.Invoice_No__c = null;
        matchedStock.Inward_Declaration_Invoice__c = null;
        matchedStock.Vessel_Name__c = null;
    }

    private static VehicleShipmentSelector sel = new VehicleShipmentSelector();

    /**
     * ============================================================================================
     * Get Vehicle Shipment records by Ids
     * @param shipmentIds: target vehicle shipment ids
     * @param withLineItems: include shipment line items
     * @param withMatchedVehicle: include matched stock vehicle master
     * @return list of vehicle shipments
     * History
     *          DATE::                              BY::                                CHANGELOG
     *          24 Aug 2022                         phan.thu@aodigy.com                   init
     * ============================================================================================
     */
    public static List<Vehicle_Shipment__c> getByIds (Set<Id> shipmentIds, Boolean withLineItems, Boolean withMatchedVehicle)
    {
        return sel.selectByIds(shipmentIds, withLineItems, withMatchedVehicle);
    }

     /**
     * Select Vehicle Shipment by Id with @withInvoices and @withLineItems and @withSVMs as optional
     * @param Id: Vehicle Shipment Id
     * @param withLineItems: include Shipment Line Items
     * @param withInvoices: include Manufacturer Invoices
     * @param withSVMs: include Stock Vehicle Masters
     * History
     *          DATE::                              BY::                                CHANGELOG
     *       27 Aug 2022                         phan.thu@aodigy.com                       init
     * ============================================================================================
    */

    public static Vehicle_Shipment__c getByIdWithInvoicesAndLineItemsAndSVMs (String Id, Boolean withInvoices, Boolean withLineItems, Boolean withSVMs)
    {
        return sel.selectByIdWithInvoicesAndLineItemsAndSVMs(Id, withInvoices, withLineItems, withSVMs);
    }

    // private static void createTaskOnPartialMatching(Map<Id, Shipment_Line_Item__c> unmatchedShipmentLineItems)
    // {
    //     Set<Id> shipmentIds = new Set<Id>();

    //     for (Shipment_Line_Item__c shipmentLineItems : unmatchedShipmentLineItems.values())
    //     {
    //         shipmentIds.add(shipmentLineItem.Vehicle_Shipment__c);
    //     }

    //     List<Task> tasks = new List<Task>();

    //     for (Id shipmentId : shipmentIds)
    //     {
    //         tasks.add(new Task(
    //             ActivityDate = Date.today().addDays(3),
    //             Description = 'Shipment not completely matched',
    //             // OwnerId
    //             Priority
    //         ));
    //     }
    // }
    public class VehicleShipmentException extends Exception{}
}
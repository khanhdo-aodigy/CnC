/**
 * 
 */
public with sharing class StockReservationCancellingBatchJob implements Database.Batchable<sObject>, Database.Stateful
{
    Set<Id> stockReservationIds = new Set<Id>();

    public StockReservationCancellingBatchJob(Set<Id> stockReservationIds)
    {
        this.stockReservationIds = stockReservationIds;
    }

    public StockReservationCancellingBatchJob()
    {

    }

    /**
     * 
     */
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        String soql = 'SELECT Id, Reservation_Status__c, Cancellation_Reason__c, Franchise_Code__c, CreatedDate FROM Stock_Reservation__c WHERE Reservation_Status__c != \'Cancel\' AND Reservation_Status__c != \'Print\'';

        if (this.stockReservationIds != null && this.stockReservationIds.size() > 0)
        {
            soql += ' AND Id IN :stockReservationIds';
        }

        return Database.getQueryLocator(soql);
    }

    /**
     * 
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<Id, Stock_Reservation__c> stockReservationById = new Map<Id, Stock_Reservation__c> ((List<Stock_Reservation__c>) scope);
        
        List<Sales_Agreement__c> salesAgreements = [SELECT Id, Stock_Reservation__c, Stage__c FROM Sales_Agreement__c WHERE Stock_Reservation__c IN :stockReservationById.keySet()];

        Map<Id, Sales_Agreement__c[]> salesAgreementByStockReservationId = new Map<Id, Sales_Agreement__c[]>();

        // arrange sales agreements by stock reservation id
        for (Sales_Agreement__c salesAgreement : salesAgreements)
        {
            if (salesAgreementByStockReservationId.keySet().contains(salesAgreement.Stock_Reservation__c))
            {
                salesAgreementByStockReservationId.get(salesAgreement.Stock_Reservation__c).add(salesAgreement);
            }
            else
            {
                salesAgreementByStockReservationId.put(salesAgreement.Stock_Reservation__c, new List<Sales_Agreement__c> { salesAgreement });
            }
        }

        // array to store stock reservation for cancelling
        List<Stock_Reservation__c> cancellingStockReservations = new List<Stock_Reservation__c>();

        for (Stock_Reservation__c stockReservation : stockReservationById.values())
        {
            // no logic for blank Franchise Code
            if (String.isBlank(stockReservation.Franchise_Code__c))
            {
                continue;
            }

            List<Sales_Agreement__c> relatedSalesAgreements = salesAgreementByStockReservationId.get(stockReservation.Id);
            
            
            if (this.isCancellable_CV(stockReservation, relatedSalesAgreements))
            {
                stockReservation.Reservation_Status__c = 'Cancel';
                stockReservation.Cancellation_Reason__c = 'Cancelled by system due to no DSA within retention period';
                cancellingStockReservations.add(stockReservation);
            }
            else if (this.isCancellable_PC(stockReservation, relatedSalesAgreements))
            {
                stockReservation.Reservation_Status__c = 'Cancel';
                stockReservation.Cancellation_Reason__c = 'Cancelled by system due to no DSA at end of reserved day';
                cancellingStockReservations.add(stockReservation);
            }
            else
            {
                // reserve for future use
            }
        }

        if (cancellingStockReservations.size() > 0)
        {
            Database.update(cancellingStockReservations, false);

            // TODO: what to do when DML failed
        }
    }

    /**
     * 
     */
    public void finish(Database.BatchableContext BC)
    {
        // do nothing
    }

    /**
     * Check if stock reservation (PC) is valid for cancellation
     * This batch job is schedule to run at 23:59 daily so no need for end of day checking
     * @param stockReservation stock reservation to check
     * @param relatedSalesAgreements related sales agreements of @stockReservation
     */
    private Boolean isCancellable_PC(Stock_Reservation__c stockReservation, List<Sales_Agreement__c> relatedSalesAgreements)
    {
        if (!stockReservation.Franchise_Code__c.endsWith('PC'))
        {
            return false;
        }

        if (relatedSalesAgreements != null && relatedSalesAgreements.size() > 0)
        {
            return false;
        }
        
        // get the local day when record created
        Date createdDate = stockReservation.CreatedDate.date();

        // get the local day of now
        Date today = Date.today();

        return today >= createdDate;
    }

    /**
     * Check if stock reservation (CV) is valid for cancellation
     * This batch job is schedule to run at 23:59 daily so no need for end of day checking
     * @param stockReservation stock reservation to check
     * @param relatedSalesAgreements related sales agreements of @stockReservation
     */
    private Boolean isCancellable_CV(Stock_Reservation__c stockReservation, List<Sales_Agreement__c> relatedSalesAgreements)
    {
        if (!stockReservation.Franchise_Code__c.endsWith('CV'))
        {
            return false;
        }
        
        if (relatedSalesAgreements != null && relatedSalesAgreements.size() > 0)
        {
            return false;
        }

        // check if x days has passed

        // get the local day when record created
        Date createdDate = stockReservation.CreatedDate.date();

        // get the local day of retention end day
        // plus 6 since the created date is already counted as 1 day
        // TODO: use custom setting
        Date retentionEndDate = createdDate.addDays(6);

        // get the local day of now
        Date today = Date.today();

        // compare
        return today >= retentionEndDate;
    }
}
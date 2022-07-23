/**************************************************
 * Class Name: TriggerHandlerStockReservation
 * Description: Handler Class for Stock Reservation Trigger
 * 
 * Revision History:
 * Developer Name		Date			Description
 * CGaylan				27-06-2019		Refactored.
 **************************************************/ 
public without sharing class TriggerHandlerStockReservation{
    
    public List<Stock_Reservation__c> srTrigNew {get; set;}
    public Map<Id, Stock_Reservation__c> srOldMap {get; set;}
    public BRHandlerStockReservation sRev {get; set;}
    
    //constructor
    public TriggerHandlerStockReservation(List<Stock_Reservation__c> srList, 
                                          Map<Id, Stock_Reservation__c> oldMap)
    {
        sRev = new BRHandlerStockReservation(this);
        
        srTrigNew = new List<Stock_Reservation__c>();
        srOldMap = new Map<Id, Stock_Reservation__c>();
        
        srTrigNew = srList;
        srOldMap = oldMap;
        
        //CGaylan: This is commented-out, for future purposes, please add logic
        //[MASTER SOQL]Prefetch all the content needed for the trigger to process. 
        //sRev.preFetchTriggerContent();
        
        //Context-Based business rule.
    	defineContext();           
    }
    
    
    
    //Context-Based business rule.
    public void defineContext(){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                sRev.srAfterUpdate();
            }
        }
    }    
}
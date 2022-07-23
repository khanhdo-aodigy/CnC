/**************************************************
* Class Name: Constants
* Description: Handler Class for Stock Reservation Trigger
* 
* Revision History:
* Developer Name		Date			Description
* CGaylan				27-06-2019		Created.
**************************************************/ 
public without sharing class Constants {
    
    /**************** Stock Reservation ****************/
    public static final String CANCEL = 'Cancel';
    
    /*************** For Running Schedule Purge NRIC Values ****************/
    public static final List<String> SOBJ_PURGE_NRIC = new List<String>{'Invoice__c',
                														'Opportunity',
        																'Test_Drive__c',
        																'Stock_Reservation__c'};
	/*************** Payment ****************/
    public static final String STAT_VOID = 'Void';
    
    /*************** Delinking of Vehicles ****************/          
    public static final String DELINK_REGNUM = 'UNKNOWN';
}
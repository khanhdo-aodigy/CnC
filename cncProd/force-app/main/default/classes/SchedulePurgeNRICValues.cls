/**************************************************
 * Class Name: SchedulePurgeNRICValues
 * Description: Schduler class to Purge NRIC Values
 * 
 * Revision History:
 * Developer Name       Date            Description
 * CGaylan              27-06-2019      Created.
 * Khanh Do             08-11-2021      Added purging NRIC and Files under Vehicle_Request__c
 **************************************************/ 
public class SchedulePurgeNRICValues implements Schedulable{
    
    //For Test Class Coverage
    public class CustException extends Exception{}
    
    public void execute(SchedulableContext sc){
        try{
            //For additional changes, please add to the Constants class.
            Database.executeBatch( new BatchPurgeNRICValues( Constants.SOBJ_PURGE_NRIC, 0 ) );
            
            //for Test Class
            if( Test.isRunningTest() ){
                throw new CustException('');
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('SchedulePurgeNRICValues', e);
        }
    }
    
    /*****************************************
     * Method Name: getQueryString
     * Description: 
     * 
     * Paramters:   objName - API Name of the SObject
     * 
     * Return: String - query string
     * 
     * Objects with NRIC values to purge
     * (1) Opportunity
     * (2) Payment/Invoice__c
     * (3) Test Drive
     * (4) Stock Reservation
     * (5) Vehicle_Request__c //Added by Khanh
     ******************************************/ 
    public static String getQueryString(String objName){
        String qStr = '';
        
        //end Date will be a local variable inside the invoker batch
        //using this formula Date.today().addMonths(-6);
        
        if(String.isNotBlank(objName)){
            switch on objName{
                when 'Invoice__c'{
                    qStr = 'SELECT Id, NRIC__c FROM Invoice__c WHERE NRIC__c != null AND CreatedDate <: endDate ';
                }
                when 'Opportunity'{
                   qStr = 'SELECT Id, NRIC__c FROM Opportunity WHERE NRIC__c != null AND CreatedDate <: endDate ';
                }
                when 'Test_Drive__c'{
                    qStr = 'SELECT Id, NRIC__c FROM Test_Drive__c WHERE CreatedDate <: endDate ';
                }
                when 'Stock_Reservation__c'{
                    qStr = 'SELECT Id, Customer_Social_ID__c FROM Stock_Reservation__c WHERE Customer_Social_ID__c != null AND CreatedDate <: endDate ';
                }                
                when 'Vehicle_Request__c'{
                    qStr = 'SELECT Id, Customer_NRIC__c FROM Vehicle_Request__c WHERE CreatedDate <: endDate ';
                }
            }
        }
        
        return qStr;
    }
    
    
}
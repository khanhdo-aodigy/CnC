/** *****
* Description : Daily Batch 
*
* Change History
* Date(YYYYMMDD)        Name                         Description
* 20220523              khanh.do@aodigy.com          Created Initial Version.
*
** *****/
global with sharing class RAP_CheckCOEBiddingExpirationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    public RAP_CheckCOEBiddingExpirationBatch() {}

    public void execute(SchedulableContext ctx)
    {
        Database.executebatch(new RAP_CheckCOEBiddingExpirationBatch(), 200);
    }

    public Iterable<sObject> start(Database.BatchableContext bc)
    {
        List<COE_Bid_Period__c> biddingList = [ SELECT Id, From_Date__c, To_Date__c
                                                FROM COE_Bid_Period__c
                                                WHERE To_Date__c = YESTERDAY
                                                AND Bid_Status__c = 'Active'
                                            ];

        System.debug('biddingList = ' + biddingList);
        if(biddingList.size() == 0) {
            return new NullIterable();
        }

        String queryString =  ' SELECT Id, CreatedDate, Inspection_Date__c, Status__c'
                            + ' FROM Used_Car_Quote__c'
                            + ' WHERE Status__c = \'Open\''
                            + ' AND Inspection_Date__c = null'
                            ;

        System.debug('@@@ DEBUG ==== RAP_CheckCOEBiddingExpirationBatch.start() queryString = ' + queryString);
        return Database.getQueryLocator( queryString );
    }

    public void execute(Database.BatchableContext BC, List<Used_Car_Quote__c> scope) {

        System.debug('scope size = ' + scope.size());
        System.debug('scope = ' + scope);
        try {
            List<Used_Car_Quote__c> expiredQuotes = new List<Used_Car_Quote__c>();

            for(Used_Car_Quote__c quote: scope) {
                quote.Status__c = 'Expired';
                expiredQuotes.add(quote);                
            }
    
            System.debug('expiredQuotes = ' + expiredQuotes);
            if(expiredQuotes.size() > 0) {
                update expiredQuotes;
            }
        } catch(Exception ex) {
            System.debug('@@@ DEBUG ==== RAP_CheckCOEBiddingExpirationBatch.start() exception = ' + ex);            
            loggerDataPool.buildLogDataPool('RAP_CheckCOEBiddingExpirationBatch', ex);
        }

    }

    public void finish(Database.BatchableContext bc){
    }

    global class NullIterable implements Iterable<sObject>{
        global Iterator<sObject> Iterator(){
           return new NullIterator();
        }
     }
    
    global class NullIterator implements Iterator<sObject> {
        public NullIterator(){}

        global Boolean hasNext(){ 
            return false;
        }    
     
        global Used_Car_Quote__c next(){ 
            return null;
        } 
     
    }


    
      
}
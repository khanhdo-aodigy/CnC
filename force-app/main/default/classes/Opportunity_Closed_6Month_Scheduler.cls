public class Opportunity_Closed_6Month_Scheduler implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
  
    public String queryString = '';
    public String batchForDataPool = '';
    Date before180days = Date.today().addDays(-180);
    
    public Opportunity_Closed_6Month_Scheduler(){
        batchForDataPool = 'Opportunity_Closed_6Month_Scheduler';
        queryString = 'Select Id, StageName from Opportunity where LastModifiedDate <= :before180days AND StageName!=\'Booked\' AND StageName!=\'Lost\' ';
        System.debug('@@@'+queryString);
      }
      
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator(queryString);
      }
      
    public void execute(Database.BatchableContext bc, list<Opportunity> OppsToClose){ 
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Models_Interested__c> mIUpdList = new List<Models_Interested__c>();
        List<Opportunity> oppList= new List<Opportunity>();
       
        if(!OppsToClose.isEmpty()){
            for(Opportunity opp : OppsToClose)
                {
                    oppMap.put(opp.id,opp);  
                }
            if(!oppMap.isEmpty()){
                 for(Models_Interested__c mi :[SELECT id,Opportunity__c,Status__c from Models_Interested__c where Opportunity__c!=null and Opportunity__c IN : oppMap.KeySet() and LastModifieddate >= : before180days ]){
                        if(oppMap.ContainsKey(mi.Opportunity__c)){
                            oppMap.remove(mi.Opportunity__c);    
                        }
                    }             
                 for(Event_Registration__c er : [SELECT id,Opportunity__c from Event_Registration__c where Opportunity__c!=null and Opportunity__c IN : oppMap.KeySet() and LastModifieddate >= : before180days]){
                     if(oppMap.ContainsKey(er.Opportunity__c)){
                            oppMap.remove(er.Opportunity__c);    
                        }
                  }                                
                 for (Opportunity opp : oppMap.values())
                    {
                        opp.StageName = 'Lost';
                        oppList.add(opp);
                    }
            
             TriggerExclusion.excludeTrigger('Opportunity', true);
                 DataBase.Update(oppList);
             TriggerExclusion.excludeTrigger('Opportunity', false);
             if(!oppList.isEmpty()){
                    for(Models_Interested__c mi : [SELECT id,Opportunity__c,Status__c from Models_Interested__c where Opportunity__c!=null and Opportunity__c IN : OppList]){
                        if(oppMap.ContainsKey(mi.Opportunity__c)){
                            mi.Status__c = 'Lost';   
                            mIUpdList.add(mi);                     
                        }
                    }
                    DataBase.Update(mIUpdList);                 
             }
           }
        }         
    }
  
     public void finish(Database.BatchableContext bc){
         batchDataPool.buildBatchDataPool(batchForDataPool, bc.getJobId());    
     }
     
     public void execute(SchedulableContext sc){
            new BatchManager('Opportunity_Closed_6Month_Scheduler', null);
     }
     
}
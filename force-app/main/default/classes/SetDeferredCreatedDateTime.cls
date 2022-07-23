public class SetDeferredCreatedDateTime {

    @InvocableMethod
    public static void AssignDeferredCreatedDateTime(List<String> vCaseId){
            system.debug('Input value of Case ID ->' + vCaseID);
            List<Case> caselist = new List<Case>();
            
            for(Case c : [SELECT ID, CreatedDate, Deferred_Created_Date_Time__c, Origin, Is_Not_Business_Day_Created__c
                          FROM CASE where ID=:vCaseID]){
            system.debug('case details ->' + c) ;
         
           //if(c.Origin=='Email' && c.Deferred_Created_Date_Time__c==NULL){
                              
                if(c.Deferred_Created_Date_Time__c==NULL){
                        system.debug('Case Created Date/Time  ->' + c.CreatedDate);
                        c.Is_Not_Business_Day_Created__c = BusinessHoursUtility.IsBusinessDtTm(c.CreatedDate);
                        System.debug('Is Business Day check -> ' + c.Is_Not_Business_Day_Created__c);
                     
                        if(!c.Is_Not_Business_Day_Created__c)
                            c.Deferred_Created_Date_Time__c = BusinessHoursUtility.GetNextBusinessDtTm(c.CreatedDate);
                        else 
                            c.Deferred_Created_Date_Time__c = c.CreatedDate; 
                    
                        caseList.add(c);
                        System.debug('Case Created Date/time -> ' + c.Deferred_Created_Date_Time__c); 
                }
            }
        
                if(!caseList.isempty()){
                    update caseList;
                }
        }
    }
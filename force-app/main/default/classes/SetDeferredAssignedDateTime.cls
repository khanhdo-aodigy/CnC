public class SetDeferredAssignedDateTime {

    @InvocableMethod
    public static void AssignDeferredAssignedDateTime(List<String> vCaseId){
            List<Case> caselist = new List<Case> ();
            system.debug('Input value of Case ID ->' + vCaseID);
        
            for( Case c : [SELECT ID, Deferred_Created_Date_Time__c, Assigned_Date_Time__c, Deferred_Assigned_Date_Time__c, Origin, 
                                Is_Not_Business_Day_Assigned__c, Is_Case_Assigned_to_SA__c
                           FROM CASE where ID=:vCaseID]){
                system.debug('case details ->' + c) ;
            
    //                              if(c.Origin=='Email' && c.Deferred_Assigned_Date_Time__c == NULL && c.Assigned_Date_Time__c!=null 
    //               && c.Is_Case_Assigned_to_SA__c==true){
                         
                if(c.Deferred_Assigned_Date_Time__c == NULL && c.Assigned_Date_Time__c!=null 
                   && c.Is_Case_Assigned_to_SA__c==true){
                        system.debug('Case Assigned Date/Time  ->' + c.Assigned_Date_Time__c);
                        c.Is_Not_Business_Day_Assigned__c = BusinessHoursUtility.IsBusinessDtTm(c.Assigned_Date_Time__c);
                        System.debug('Is Business Day check -> ' + c.Is_Not_Business_Day_Assigned__c);
                     
                        if(!c.Is_Not_Business_Day_Assigned__c){
                            c.Deferred_Assigned_Date_Time__c = BusinessHoursUtility.GetNextBusinessDtTm(c.Assigned_Date_Time__c);
                        }else{ 
                            c.Deferred_Assigned_Date_Time__c = c.Assigned_Date_Time__c; }
                    
                        long BusinessHrsMgr = BusinessHoursUtility.GetBusinessHrs(c.Deferred_Created_Date_Time__c,  c.Deferred_Assigned_Date_Time__c);
                        system.debug('Calculated Hrs b/w two dates Manager SLA in millisecs' + BusinessHrsMgr);
                       
                        Decimal vMgrSLAinMins = BusinessHrsMgr / 60000.00;
                        system.debug('Manager SLA mins and secs ->' + vMgrSLAinMins);
                       
                        decimal MgrSLAvar = vMgrSLAinMins.round(System.RoundingMode.DOWN);
                       
                        c.Manager_SLA_in_Mins__c = MgrSLAvar.intValue();
                        system.debug('Manager SLA in Mins ->' + c.Manager_SLA_in_Mins__c);
                        
                        caselist.add(c);
                       
                        System.debug('Case assigned Date/time -> ' + c.Assigned_Date_Time__c); 
                }
            }
        
                if(!caselist.isEmpty())
                    update caselist;
    }
    
}
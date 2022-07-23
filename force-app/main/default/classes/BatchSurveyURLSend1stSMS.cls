/** *****
* Description : Batch class to tick checkbox Send survey url through SMS.
*
* Change History
* Date(YYYYMMDD)      Name       		Description
* 20200824            huynh.hung       Created Initial Version.
*
** *****/
global class BatchSurveyURLSend1stSMS implements Database.Batchable<sObject>, Schedulable{
    Set<Id> setPSHIds = new Set<Id>();
    
    global BatchSurveyURLSend1stSMS(){}
    
    global BatchSurveyURLSend1stSMS( Set<Id> setOfPSHIds ){
        this.setPSHIds = setOfPSHIds;
    }
    
    global void execute(SchedulableContext sc){
        Database.executebatch(new BatchSurveyURLSend1stSMS());
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strSOQL = 'SELECT Id, PDPA__c, Account__c, Registered_Vehicle__c, Post_Service_Survey__c,'
            + ' Post_Service_Survey_Date__c, WDateOut__c, Send_First_SMS__c, Send_Second_SMS__c, DuplicatedChecking__c'
            + ' From Post_Service_Header__c'
            + ' WHERE Post_Service_Survey__c != true AND Account__c != null AND Registered_Vehicle__c != null AND PDPA__c LIKE \'%SMS%\' AND Service_Advisor__c != null';
        return Database.getQueryLocator( setPSHIds != null && !setPSHIds.isEmpty() ? strSOQL + ' AND Id IN :setPSHIds' : strSOQL);
    }
    
    global void Execute(Database.BatchableContext bc, List<Post_Service_Header__C> pshList){
        try{
            List<Post_Service_Header__C> newPSHUpdate = new List<Post_Service_Header__C>();
            List<String> paIDToCheck = new List<String>();
            List<String> paIDNotToSendSMS = new List<String>();
            
            List<Post_Service_Header__C> sendSMS = new List<Post_Service_Header__C>();
            
            for(Post_Service_Header__C psh : pshList){
                //Send 1st SMS
                if(!psh.Send_First_SMS__c){
                    if(Date.today() > psh.WDateOut__c && !psh.Post_Service_Survey__c){
                        paIDToCheck.add(psh.Account__c);
                    }
                }
            }
            List<Post_Service_Header__C> didSurveyPSHList = [SELECT Id, Account__c, Post_Service_Survey_Date__c, DuplicatedChecking__c 
                                                             From Post_Service_Header__c 
                                                             WHERE Post_Service_Survey__c = true AND Account__c IN :paIDToCheck];
            for(Post_Service_Header__C didSurveyPSH : didSurveyPSHList){
                if(Date.today().addDays(-30) < didSurveyPSH.Post_Service_Survey_Date__c){
                    paIDNotToSendSMS.add(didSurveyPSH.Account__c);
                }
            }
            
            for(Post_Service_Header__C psh : pshList){
                //Send 1st SMS
                if(!psh.Send_First_SMS__c){
                    if(Date.today() > psh.WDateOut__c && !paIDNotToSendSMS.contains(psh.Account__c)){
                        System.debug('Sent 1st SMS');
                        psh.Send_First_SMS__c = true;
                        newPSHUpdate.add(psh);
                    }
                }
                /*else{//send 2nd SMS
                    if(!psh.Send_Second_SMS__c && !paIDNotToSendSMS.contains(psh.Account__c)){
                        System.debug('Sent 2nd SMS');
                        psh.Send_Second_SMS__c = true;
                        newPSHUpdate.add(psh);
                    }
                }*/
            }
            if(newPSHUpdate.size() > 0)
            {
                Database.SaveResult[] results = Database.update(newPSHUpdate, false);         
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
   
    
}
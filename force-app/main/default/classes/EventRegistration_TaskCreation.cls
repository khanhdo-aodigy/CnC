global class EventRegistration_TaskCreation implements Schedulable{
    
    //void execute method
    global void execute (SchedulableContext ctx)
    {   
        EventRegistration_TaskCreation.taskCreation(); 
    }
    
	public static void taskCreation()
    {
        List<Event_Registration__c> evtRgtList = new List <Event_Registration__c>();
        Date today = Date.today();
        date actionDate = today.addDays(2);
        List<Task> tsk = new List<Task>();        
        try
        {
            evtRgtList =[SELECT Id, ContactId__c, Account__c, Account__r.PersonContactId, Event_Date__c, Event_Status__c, LeadId__c, ModelCode__c, 
                                NumberOfGuests__c, Opportunity__c,PromoID__c, TimeSlot__c,Opportunity__r.OwnerId 
                         FROM Event_Registration__c 
                         WHERE Event_Date__c =: actionDate];
            for(Event_Registration__c evtR: evtRgtList)
            {
                Task thisTask = new Task();
                thisTask.OwnerId = evtR.Opportunity__r.OwnerId;
                System.debug('evtR.Opportunity__r.OwnerId = '+ evtR.Opportunity__r.OwnerId);
                thisTask.Description = 'Please update the Event registration record with appropriate status';
                thisTask.ActivityDate = actionDate;
                thisTask.Status = 'Open';
                thisTask.WhatId = evtR.Id;
                /** PA Migration : Newly Added -- Start **/
                if (evtR.Account__c != null){
                    thisTask.WhoId = evtR.Account__r.PersonContactId;                    
                } /** PA Migration : Newly Added -- End **/
                
                /** PA Migration : To Remove Part-1 start */
                // else if(evtR.ContactId__c != null){
                //     thisTask.WhoId = evtR.ContactId__c;
                // }
                // else if(evtR.LeadId__c !=null){
                //     thisTask.WhoId = evtR.LeadId__c;
                //}
                /** PA Migration : To Remove Part-1 end */
                
                thisTask.IsReminderSet = true;
                thisTask.Priority = 'High';
                tsk.add(thisTask);
            }
            
            Database.UpsertResult[] results = Database.upsert(tsk);
            System.debug('upsert tasks result = ' + results.size());
            for(Integer index = 0; index < results.size(); index++) 
            {
                if(results[index].isSuccess()) 
                {         
                    if(results[index].isCreated()) {
                        System.debug(tsk[index].id +' was created');
                    } 
                }
                else
                {
                    system.debug(tsk[index].id +' had error');
                }
            }
            
        }
        catch(exception e)
        {
            System.debug('An Error Occured: '+e.getMessage());
        }
    }
    
}
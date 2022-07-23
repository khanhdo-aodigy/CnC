//Apex Trigger to change owner of Test Drives related to a Lead if Owner of the Lead changes
trigger Trigger_TestDrive_Lead_OwnerUpdate on Lead (after update) {
    
    //Exclude this trigger
    if(TriggerExclusion.isTriggerExclude('Lead') ||  TriggerExclusion.isBypassTriggerExecution('Lead')){
        return;
    }	
    
    List<Test_Drive__c> listToUpdate = new List<Test_Drive__c>();
    Test_Drive__c TestDrive_toUpdate;
    
    public static DateTime todaytime = datetime.now();
    List<User> OwnerId= new List<User>();
    //Check if Owner is changed
    if(Trigger.New[0].OwnerId!=Trigger.Old[0].OwnerId)
    {
        List<Task> lTask = new List<Task>();
        
        //Get all Test Drives related to the LeadId updated whose status id Pending
        listToUpdate = [SELECT Test_Drive__c.Id , Test_Drive__c.Date__c, Test_Drive__c.Name, Test_Drive__c.TModel__r.Name, Test_Drive__c.TVariant__r.Name, Test_Drive__c.Showroom__r.Name 
                        FROM Test_Drive__c 
                        WHERE Status__c =:'Pending'
                        AND Test_Drive__c.Lead__c IN :Trigger.New];
        //OwnerId=[Select User__r.Id From Lead Where Lead.Id=:Trigger.New];
        if(listToUpdate.size() > 0)
        {       
            for (Test_Drive__c TDobj : listToUpdate) 
            {
                TestDrive_toUpdate = new Test_Drive__c();
                TestDrive_toUpdate = TDobj;
                //i++;
                //For each test Drive change the owner of test Drive to Owner of Lead
                for (Lead Lobj : Trigger.new) {
                    //user objuser = new user(Id = Lobj.Owner.Id);
                    //listToUpdate.Owner.Id=objuser.Id;
                    TestDrive_toUpdate.OwnerId = Lobj.OwnerId;                
                    User[] users = [SELECT Id, Name, UserRole.Name FROM User WHERE Id = :Lobj.OwnerId];
                    System.debug('==='+users[0]);
                    if(users!=null && users.size()>0){
                        System.debug('==='+users[0].UserRole.Name);
                        if(users[0].UserRole.Name.containsIgnoreCase('Sales Consultant'))
                        {
                            System.debug('========='+users[0].UserRole.Name);
                            Task tk = new Task();
                            tk.OwnerId  = Lobj.OwnerId;
                            tk.WhatId   = TestDrive_toUpdate.Id;
                            tk.Type     = 'Other';
                            tk.Subject  = TestDrive_toUpdate.Name;
                            Date tdDate = TestDrive_toUpdate.Date__c.date(); 
                            tk.ActivityDate = tdDate;
                            
                            lTask.add(tk);
                            insert tk; 
                            System.debug('called send email=========');
                            try{
                                SendEmailToSalesConsultant.sendEmail(Lobj.OwnerId,TDobj.TModel__r.name,TDobj.TVariant__r.name,TDobj.Showroom__r.name,String.valueOf(tdDate));
                            }
                            catch(Exception e){
                            }
                            
                            system.debug('called after send email=========');
                        }
                    }
                }
                //Update test Drive and task
                //insert lTask;
                update TestDrive_toUpdate;
                //update Lobj;
            }
        }
        
        for (Lead LeadToUpdateObj :[SELECT Id, Assignment_Date__c FROM Lead WHERE Id in :Trigger.new]) 
        {
            LeadToUpdateObj.Assignment_Date__c = todaytime;
            update LeadToUpdateObj;
        } 
        
        
    }
    
}
/** ******
 * Description: 
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        		        Description
 * YYYYMMDD            C&C                      Created Initial Version.
 * 20201111			   khanh.do@aodigy		    Added PA phase 2 changes 
 * 
** ******/
global class TestDrive_Notofications_SalesManager implements Schedulable
{
    //Variable declaration 
    public static List <Test_Drive__c> TestDriveObj {get;set;}
    public static List <User> tempId {get;set;}
    public static Date today = Date.today();
    
    global void execute(SchedulableContext ctx){
        TestDrive_Notofications_SalesManager();
    }

    public static void TestDrive_Notofications_SalesManager()
    {         
        try
        {            
            //fetching list of all users with role Sales Admin             
            tempId = [SELECT Id, Name FROM User WHERE UserRole.Name LIKE '%Sales Admin%'];
            
            TestDriveObj  = [SELECT Id, TestDrive_Notofications_SalesManager__c, OwnerId, Date__c 
                             FROM Test_Drive__c 
                             WHERE Status__c = 'Pending' 
                             AND (NOT Prospect__r.Owner.UserRole.Name LIKE '%Sales Consultant%') 
                             AND Date__c = NEXT_N_DAYS:3 ];           

            if(TestDriveObj.size()>0) 
            {
                List<Test_Drive__c> TestDrive_toUpdateObj = new List<Test_Drive__c>();
                List<Task> Task_toUpdateObj = new List<Task>();
                
                for(Test_Drive__c rvc : TestDriveObj)
                {
                    if (rvc.Date__c.date() == today.addDays(2))
                    {
                        rvc.TestDrive_Notofications_SalesManager__c = true;  
                        rvc.OwnerId = rvc.OwnerId;                   
                        TestDrive_toUpdateObj.add(rvc);
                    }
                    else if (rvc.Date__c.date() == today.addDays(3))
                    {
                        rvc.TestDrive_Notofications_SalesManager__c = false;                                        
                        TestDrive_toUpdateObj.add(rvc);
                        
                        for(User AdminUser:tempId) 
                        {   
                            Task tsk    = new Task();
                            tsk.Subject = 'T-3 - Last day to assign the leads due for test drive after 3 days';
                            tsk.WhatId  = rvc.Id;                    
                            tsk.OwnerId = AdminUser.Id;
                            tsk.Status  = 'New';
                            tsk.Type    = 'Call';
                            Task_toUpdateObj.add( tsk );                            
                        }
                    }
                    
                }
                if(TestDrive_toUpdateObj.size()>0)
                {
                    Database.SaveResult[] results = Database.update( TestDrive_toUpdateObj, false);
                    for(Integer index = 0, size = results.size(); index < size; index++) 
                    {
                        if(results[index].isSuccess()) {               
                            System.debug(TestDrive_toUpdateObj[index].Id +' was updated');               
                        }
                        else {
                            System.debug(TestDrive_toUpdateObj[index].Id +' had error '+results[index].getErrors());
                        }
                    }
                }
                
                if(Task_toUpdateObj.size()>0)
                {
                    Database.UpsertResult[] resultsTask = Database.Upsert(Task_toUpdateObj, False);
                    for(Integer index = 0, size = resultsTask.size(); index < size; index++) 
                    {
                        if(resultsTask[index].isSuccess()) 
                        {               
                            System.debug(Task_toUpdateObj[index].Id +' was updated');               
                        }
                        else
                        {
                            System.debug(Task_toUpdateObj[index].Id +' had error '+resultsTask[index].getErrors());
                        }
                    }
                }
                
            }
            
            //pass customer list to upsert function  create customer alert  

        }
        catch(Exception e)
        {            

        }
   }    
   
}
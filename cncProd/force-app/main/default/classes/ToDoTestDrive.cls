/***********************************
 * Class Name: ToDoTestDrive
 * Description: Controller of Public Site
 *              used to create Task record
 *              for an Opportunity
 ***********************************/ 
public without sharing class ToDoTestDrive{

    /***************************************
     * Method Name: createTask
     * Description: onload action
     *              to create To-Dos(Task)
     ***************************************/
    public void createTask(){
        String oppId = System.currentPageReference().getParameters().get('opp');
        
        try{
            String sysLabel = System.Label.CITPromoLabel;
            //check first if there is an existing task for the Opportunity
            List<Task>  tskList = new List<Task>();
            tskList = [SELECT Id 
                       FROM Task 
                       WHERE Status='Open' 
                       AND Subject =: sysLabel 
                       AND WhatId =: oppId 
                       LIMIT 1];
            
            //create only task if there are no Open task to call the customer
            if(tskList.isEmpty()){
                Task newTask = new Task();
                newTask.Subject = sysLabel ;
                newTask.ActivityDate = Date.today().addDays(2);
                newTask.OwnerId = [SELECT Id, OwnerId 
                                   FROM Opportunity 
                                   WHERE Id =: oppId 
                                   LIMIT 1].OwnerId;
                newTask.WhatId = oppId;
                newTask.Status = 'Open';
                newTask.Priority = 'Normal';  
                insert newTask;
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('ToDoTestDrive', e);
        }
    }
}
global class BatchScheduleRegVehicleNewOwner implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<Registered_Vehicle__History> rcNewOwner = Database.query('SELECT CreatedById, CreatedDate, Field, Id, IsDeleted, NewValue, OldValue, ParentId FROM Registered_Vehicle__History where CreatedDate = today and Field = \'Contact_c\' '); 
        if(!rcNewOwner.isEmpty()){
            Set<Id> regvehicleIds = new Set<Id>();
            for(Registered_Vehicle__History rcParent :rcNewOwner){
                regvehicleIds.add(rcParent.ParentId);
                
            }
            database.executebatch(new BatchRegisteredVehicleNewOwner(regvehicleIds),1);
        }
        // We now call the batch class to be scheduled
        //BatchEventReminder b = new BatchReminderCall ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        //database.executebatch(b,200);
    }
   
}
global class ScheduleReferralProgram implements Schedulable{
    
   global void execute(SchedulableContext sc) {
      BatchReferralProgram batchJob = new BatchReferralProgram();
      database.executebatch(batchJob, 1);
   }
    
}
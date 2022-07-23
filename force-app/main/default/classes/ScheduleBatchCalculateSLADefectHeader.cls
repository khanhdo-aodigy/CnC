global class ScheduleBatchCalculateSLADefectHeader implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCalculateSLADefectHeader b = new BatchCalculateSLADefectHeader(); 
        Database.executebatch(b, 200);
    }
}
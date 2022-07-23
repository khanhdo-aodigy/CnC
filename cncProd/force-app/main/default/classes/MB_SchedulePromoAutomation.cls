global class MB_SchedulePromoAutomation implements Schedulable {
    global void execute(SchedulableContext sc) {
        MB_BatchPromoAutomation b = new MB_BatchPromoAutomation(); 
        Database.executebatch(b, 200);
    }
}
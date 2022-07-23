global class MB_ScheduleBatchSVMSpecHighlightOptions implements Schedulable {
	global void execute(SchedulableContext sc) {
        MB_BatchSVMSpecHighlightOptions b = new MB_BatchSVMSpecHighlightOptions(); 
        Database.executebatch(b, 200);
    }
}
/*
	Author: Hari Panneerselvam
*/
public class loggerDataPool {
	
	public static void buildLogDataPool(String instance, Exception exce){ 
		Logger_Data_Pool__c newLogDataPool = new Logger_Data_Pool__c();
		newLogDataPool.Instance__c = instance;
		newLogDataPool.Cause__c = String.valueOf(exce.getCause());
		newLogDataPool.Line_Number__c = exce.getLineNumber();
		newLogDataPool.Message__c = exce.getMessage();
		newLogDataPool.Stack_Trace__c = exce.getStackTraceString();
		newLogDataPool.Type__c = exce.getTypeName();
		insert newLogDataPool;
	}
    
}
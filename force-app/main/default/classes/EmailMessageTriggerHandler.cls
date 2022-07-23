public without sharing class EmailMessageTriggerHandler {

     //Recursive Trigger flags.
    public static Boolean isRunAfterUpdate = false;
    public static Boolean isRunBeforeInsert = true;
    public static Boolean isRunAfterInsert = true;
    
    public static void handleAfterInsert(List<EmailMessage> EMList){
        if(isRunAfterInsert){
            System.debug('@@@@DEBUG EmailMessageTriggerHandler >>> handleAfterInsert !!! ');
         	EmailMessageBL.createChildCase(EMList);
            system.debug('EM List ->' + EMList);
            isRunAfterInsert = false;
        }        
    }
    
}
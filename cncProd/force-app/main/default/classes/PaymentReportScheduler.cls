/*******************************************************
 * Class Name: PaymentReportScheduler
 * Description: Scheduler of Payment Reports to be sent as 
 *              attachment to the finance team.
 *******************************************************/ 
public class PaymentReportScheduler implements Schedulable{
    //Schedule
    public void execute(SchedulableContext ctx){
        paymentsRunner();
    }
    
    public static void paymentsRunner(){
        try{
            Set<String> warehouseRep = new Set<String>{'WarehousePaymentInfo_MIT','WarehousePaymentInfo_KIA','WarehousePaymentInfo_CIT',
                                                        'EventsPaymentInfo_KIA','EventsPaymentInfo_MIT','EventsPaymentInfo_CIT'};
                //get email templates
                List<EmailTemplate> tempList = [SELECT Id, Name, DeveloperName 
                                                FROM EmailTemplate 
                                                WHERE DeveloperName IN :warehouseRep ];

            //BCC Addresses
            List<String> bccAddress = new List<String>();
            
            //CC Addresses
            List<String> MIT_ccAddress = new List<String>();            
            List<String> genericCCAddress = new List<String>();
            
            //Cashier's Email
            String cashierEmail = '';
            
            //max limit of BCC Addresses is 25
            for( EmailRecipient__mdt emt : [SELECT Id,
                                            RecipientEmailAddress__c,
                                            MasterLabel, 
                                            IsBCC__c,
                                            IsCC__c,
                                            IsRecipient__c 
                                            FROM EmailRecipient__mdt 
                                            WHERE EventType__c='PaymentReport'
                                            LIMIT 25])
            {
                if(emt.isBCC__c){
                    bccAddress.add(emt.RecipientEmailAddress__c);
                }else if(emt.IsCC__c){
                    MIT_ccAddress.add(emt.RecipientEmailAddress__c);
                    if(emt.MasterLabel.contains('SFDCLead')){
                        genericCCAddress.add(emt.RecipientEmailAddress__c);
                    }
                }else if(emt.IsRecipient__c){
                    //Main Recipient of the Email
                    cashierEmail = emt.RecipientEmailAddress__c; 
                }
            }
            
            //get Cashiers
            User u;
            if(Test.isRunningTest()){
                u = new User(Id=UserInfo.getUserId(), 
                             Email=UserInfo.getUserEmail());
            }else{
                u =  [SELECT Id 
                      FROM 
                      User 
                      WHERE isActive=true 
                      AND Email=:cashierEmail
                      LIMIT 1];                
            }
            
            
            
            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            //Loop through email Reports and templates.            
            for(EmailTemplate em : [SELECT Id, Name, DeveloperName 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName IN :warehouseRep ])
            {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(em.Id, null,null);
                email.setTargetObjectId(u.Id);
                
                //send specific for MIT
                if( em.name.contains('MIT' )){
                    email.setCCAddresses(MIT_ccAddress); 
                }else{
                    email.setCcAddresses(genericCCAddress);
                }
                
                email.setBccAddresses(bccAddress);
                email.setSubject(email.getSubject());
                email.sethtmlBody(email.gethtmlBody());
                email.saveAsActivity = false;
                
                msgList.add(email);
                
            }
            
            if( !msgList.isEmpty() ){
                Messaging.sendEmail(msgList);
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('PaymentReportScheduler', e);
        }
    }
}
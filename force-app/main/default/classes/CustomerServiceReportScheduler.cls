/** *******
 * 
 * Class Name: CustomerServiceReportScheduler
 * Description : Scheduler of Service Reports (build v1 = MB)
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20190522             Christian Gaylan            Created Initial version
 * 20200325             huynh.hung@aodigy           Added PA Migration - Phase 1 Changes
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes
 * 
 ******* **/
public class CustomerServiceReportScheduler implements Schedulable{
    
    //Schedule
    public void execute(SchedulableContext ctx){
        customerServiceReportRunner();
    }
    
   public static void customerServiceReportRunner(){
        try
        {
            List<String> bccAddress = new List<String>();
            List<String> getRecipientsList = new List<String>();

			//get recipients
            for( EmailRecipient__mdt emt : [SELECT Id, RecipientEmailAddress__c, MasterLabel, IsBCC__c, IsCC__c, IsRecipient__c 
                                            FROM EmailRecipient__mdt 
                                            WHERE EventType__c = 'MBCustomerService'
                                            AND RecipientEmailAddress__c != null
                                            LIMIT 25])
            {
				if(emt.IsRecipient__c){
                    //Main Recipient of the Email
                    getRecipientsList.add(emt.RecipientEmailAddress__c); 
                }
                else if(emt.isBCC__c){
                    bccAddress.add(emt.RecipientEmailAddress__c);
                }
            }            
            
            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            //Loop through email Reports and templates.            
            for(EmailTemplate em : [SELECT Id, Name, DeveloperName 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName ='MBCustomerServiceReport' ])
            {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(em.Id, null,null);
                

				email.setToAddresses(getRecipientsList);    //Set Recipients
                email.setSubject(email.getSubject());
                email.setBccAddresses(bccAddress);          //Set BCC
                email.sethtmlBody(email.gethtmlBody());
                email.saveAsActivity = false;
                
                msgList.add(email);
            }
            
            if( !msgList.isEmpty() ){
                Messaging.sendEmail(msgList);
            }
        }
        catch(Exception e){
            loggerDataPool.buildLogDataPool('CustomerServiceReportScheduler', e);
        }    
    }

    /** *****
     * Method Name: updateCustomerAlerts 
     * Description: Given a list of Service Appt Ids, update the Customer Alerts record.
     * Note: This method will be invoked by a process.
     ***** */
    @InvocableMethod
    public static void updateCustomerAlerts(List<Id> servAppIds){
    	try{
    		if(servAppIds!=null && !servAppIds.isEmpty()){
    			Map<Id, Id> servAppToConMap = new Map<Id, Id>();
    			Map<Id, String> contactToAction = new Map<Id, String>();

    			//get Contacts from Service Appt
    			for(Service_Appointment__c srev : [ SELECT Id, Contact__c, Account__c, Action__c 
    												FROM Service_Appointment__c 
    												WHERE Id IN: servAppIds 
    												AND Contact__c != null ])
				{
					servAppToConMap.put(srev.Id, srev.Contact__c);
                    contactToAction.put(srev.Contact__c, srev.Action__c);
                }
  
				if( servAppToConMap != null && !servAppToConMap.isEmpty() && 
                        servAppToConMap.values()!=null && !(servAppToConMap.values()).isEmpty() )
                {
                    List<CustomerAlerts__c> custAlertForUpdate = new List<CustomerAlerts__c>();
                    for(CustomerAlerts__c cs : [SELECT Id, HasServiceAppointment__c, Contact__c  
                                                FROM CustomerAlerts__c 
                                                WHERE Contact__c != null 
                                                AND Contact__c IN: servAppToConMap.values() 
                                                AND Name = 'Subsequent Service Due 2nd Reminder' 
                                                AND CreatedDate >= :Date.today().addDays(-8) 
                                                ORDER BY CreatedDate DESC])
                    {
                        if( cs.HasServiceAppointment__c ) {
                            if( contactToAction.containsKey(cs.Contact__c) && contactToAction.get(cs.Contact__c) == 'Cancel' ) {
                                cs.HasServiceAppointment__c = false;
                            }
                        }
                        else {
                            cs.HasServiceAppointment__c = true;
                        }
                        custAlertForUpdate.add(cs);
                    }
                    Database.update( custAlertForUpdate , false );    
                }
            }
        }
        catch(Exception e){
    		loggerDataPool.buildLogDataPool('CustomerServiceReportScheduler.updateCustomerAlerts', e);
    	}
    } 
}
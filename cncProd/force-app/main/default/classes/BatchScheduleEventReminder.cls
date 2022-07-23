/** *******
 * Description :Schedule Batch Job to invoke BatchEventReminder to update Event Registrations
 *
 * Change History:
 * Date(YYYYMMDD)       Developer                   Description
 * 20190524             Varinder Kaur               Created Initial version
 * 20200831             khanh.do@aodigy.com         Added PA Migration - Phase 2 Changes
 * 
 ******* **/
global class BatchScheduleEventReminder implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        //List<Event_Registration__c> testDrive = Database.query('Select Id,NumberOfGuests__c,LeadId__c,Remarks__c,ContactId__c,ContactId__r.Email,ContactId__r.Name,LeadId__r.Email,LeadId__r.Name,ModelCode__r.Branch_Code__c,ModelCode__r.name,Opportunity__r.Owner.FirstName,Opportunity__r.Owner.LastName,Opportunity__r.Owner.MobilePhone,TimeSlot__c,FirstName__c,Email__c,DateRange__c,ImageURL__c,Location_Name__c,TemplateName__c,Preffered_Date__c,Preffered_Time__c,Location__c,Waitlist__c,Event_Date__c,Name FROM Event_Registration__c WHERE Event_Date__c = NEXT_N_DAYS:2'); //PA Phase 2: Remove Lead
        List<Event_Registration__c> testDrive = Database.query( 'SELECT Id, NumberOfGuests__c, Remarks__c, '
                                                              + 'ContactId__c, ContactId__r.Email, ContactId__r.Name, '
                                                              + 'ModelCode__r.Branch_Code__c, ModelCode__r.name, '
                                                              + 'Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName, Opportunity__r.Owner.MobilePhone, '
                                                              + 'TimeSlot__c, FirstName__c, Email__c, DateRange__c, ImageURL__c, Location_Name__c, TemplateName__c, '
                                                              + 'Preffered_Date__c, Preffered_Time__c,Location__c,Waitlist__c,Event_Date__c, Name '
                                                              + 'FROM Event_Registration__c '
                                                              + 'WHERE Event_Date__c = NEXT_N_DAYS:2');
        if(!testDrive.isEmpty()){
            database.executebatch(new BatchEventReminder(testDrive),1);
        }
        // We now call the batch class to be scheduled
        //BatchEventReminder b = new BatchReminderCall ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        //database.executebatch(b,200);
    }
   
}
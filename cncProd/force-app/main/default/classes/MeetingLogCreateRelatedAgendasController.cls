public class MeetingLogCreateRelatedAgendasController 
{
    private static Agenda__c createAgenda(String Name, String id, String duration, Time timeStart, Time timeEnd)
    {
        Agenda__c agenda= new Agenda__c();
        agenda.Agenda__c = Name;
        agenda.Meeting_Log_V2__c = id;
        agenda.Duration__c = duration;
        agenda.Start_Time__c = timeStart;
        agenda.End_Time__c = timeEnd;
        return agenda;
    }
    
    public static void createAgendas(List<Meeting_Log_V2__c> meetingList)
    {
        List<Agenda__c> agendasList = new List<Agenda__c>();
        for(Meeting_Log_V2__c meeting : meetingList)             
        {
            Agenda__c agendas1 = new Agenda__c();
            Agenda__c agendas2 = new Agenda__c();
            Agenda__c agendas3 = new Agenda__c();
            Agenda__c agendas4 = new Agenda__c();
            Agenda__c agendas5 = new Agenda__c();
            Agenda__c agendas6 = new Agenda__c();
            if(meeting.Type_of_Meeting_Logs__c == 'Morning Briefing')
            {              
                agendas1 = createAgenda('Sales Issues',meeting.Id,'2',Time.newInstance(08, 30, 0, 0),Time.newInstance(08, 32, 0, 0));
                agendasList.add(agendas1);
                agendas2 = createAgenda('Operational Issues',meeting.Id,'10',Time.newInstance(08, 47, 0, 0),Time.newInstance(08, 57, 0, 0));
                agendasList.add(agendas2);
                agendas3 = createAgenda('Previous duty day sales activity review',meeting.Id,'15',Time.newInstance(08, 32, 0, 0),Time.newInstance(08, 47, 0, 0));
                agendasList.add(agendas3);
                agendas4 = createAgenda('Appointment for the day',meeting.Id,'2',Time.newInstance(08, 57, 0, 0),Time.newInstance(08, 59, 0, 0));
                agendasList.add(agendas4);
                agendas5 = createAgenda('Performance variance (Once a week)',meeting.Id,'15',Time.newInstance(08, 59, 0, 0),Time.newInstance(09, 14, 0, 0));
                agendasList.add(agendas5);
                agendas6 = createAgenda('Other',meeting.Id,null,null,null);
                agendasList.add(agendas6);
            }
            else if(meeting.Type_of_Meeting_Logs__c == 'Debrief')
            {
                agendas1 = createAgenda('Sales Issues',meeting.Id,'5',Time.newInstance(12, 00, 0, 0),Time.newInstance(12, 05, 0, 0));
                agendasList.add(agendas1);
                agendas2 = createAgenda('Operational Issues',meeting.Id,'5',Time.newInstance(12, 05, 0, 0),Time.newInstance(12, 10, 0, 0));
                agendasList.add(agendas2);
                agendas3 = createAgenda('Previous duty day sales activity review',meeting.Id,'5',Time.newInstance(12, 10, 0, 0),Time.newInstance(12, 15, 0, 0));
                agendasList.add(agendas3);
                agendas4 = createAgenda('Appointment for the day',meeting.Id,'5',Time.newInstance(12, 15, 0, 0),Time.newInstance(12, 20, 0, 0));
                agendasList.add(agendas4);
                agendas5 = createAgenda('Performance variance (Once a week)',meeting.Id,'5',Time.newInstance(12, 20, 0, 0),Time.newInstance(12, 25, 0, 0));
                agendasList.add(agendas5);
                agendas6 = createAgenda('Other',meeting.Id,null,null,null);
                agendasList.add(agendas6);
            }
            else if(meeting.Type_of_Meeting_Logs__c == 'Biweekly Sales Marketing')
            {
                agendas1 = createAgenda('Executive message',meeting.Id,'30',Time.newInstance(10, 30, 0, 0),Time.newInstance(10, 30, 0, 0));
                agendasList.add(agendas1);
                agendas2 = createAgenda('Sales performance & targets',meeting.Id,'30',Time.newInstance(10, 30, 0, 0),Time.newInstance(11, 00, 0, 0));
                agendasList.add(agendas2);
                agendas3 = createAgenda('Trading memo',meeting.Id,'4',Time.newInstance(12, 00, 0, 0),Time.newInstance(12, 04, 0, 0));
                agendasList.add(agendas3);
                agendas4 = createAgenda('Marketing updates',meeting.Id,'30',Time.newInstance(11, 30, 0, 0),Time.newInstance(12, 00, 0, 0));
                agendasList.add(agendas4);
                agendas5 = createAgenda('Industry updates, if applicable',meeting.Id,'32',Time.newInstance(12, 04, 0, 0),Time.newInstance(12, 36, 0, 0));
                agendasList.add(agendas5);
                agendas6 = createAgenda('Operational issues',meeting.Id,'30',Time.newInstance(11, 00, 0, 0),Time.newInstance(11, 30, 0, 0));
                agendasList.add(agendas6);
            }
        } 
        
        try
        {
            IF(agendasList.size()>0)
                insert agendasList;
            
        }
        catch(System.Exception ex)
        {
            System.debug('>>>>> Error Message From MeetingLogCreateRelatedAgendasController: '+ex.getMessage()+' at Line: '+ex.getLineNumber());
        }
    }
}
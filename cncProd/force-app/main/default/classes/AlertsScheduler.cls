global class AlertsScheduler implements Schedulable {
    global void execute (SchedulableContext ctx)
    { 
        firstServiceNoticeReminder.firstServiceNoticeNReminder();
        firstServiceNoticeReminder.firstServiceSecondReminder();
        ServiceAppointmentReminders.ServiceAppointmentReminder();
        ServiceReminders.serviceReminders();
        serviceCreditExpirationReminder.serviceCreditExpirationReminder();
        subsequentServiceOverdueReminder.subsequentServiceOverdueReminder();
        planPackageReminder.planPackageReminder();
        batteryChange.customerAlert();
        accessoriesCreditExpirationReminder.accessoriesCreditExpirationReminder();
    }  
        
    public static void manualRunAlerts(){ 
        // firstServiceNoticeReminder.firstServiceNoticeNReminderTEST();
        // firstServiceNoticeReminder.firstServiceSecondReminderTEST();
        // ServiceAppointmentReminders.ServiceAppointmentReminderTEST();
        // ServiceReminders.serviceRemindersTest();
        // serviceCreditExpirationReminder.serviceCreditExpirationReminderTest();
        // subsequentServiceOverdueReminder.subsequentServiceOverdueReminderTest();
        // planPackageReminder.planPackageReminderTest();
        // batteryChange.customerAlertTest();
    }
}
trigger MeetingLogV2_Trigger on Meeting_Log_V2__c (After insert) {
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            MeetingLogCreateRelatedAgendasController.createAgendas(Trigger.New);
        }
    }
}
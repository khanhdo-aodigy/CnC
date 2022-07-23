/** *****
 * Class Name: Opportunity_Owner_Assignment
 * Description : Trigger to update Opportunity and Lead Owner based upon Round Robin rules.
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * YYYYMMDD            Cycle&Carriage                Created Initial Version.
 * 20210512            khanh.do@aodigy               Changed Leadsorce Chat to be included in RR logic
 * 
** *****/ 

trigger Opportunity_Owner_Assignment on Opportunity (after insert) {
    //Exclude this trigger
    Bypass_Automation_Settings__c automationSetting = Bypass_Automation_Settings__c.getOrgDefaults();
    if(TriggerExclusion.isTriggerExclude('Opportunity') 
        || TriggerExclusion.skipRR
            || automationSetting.Bypass_Triggers__c
    ){
        return;
    }
    
    String RoleName = '';
    List<User> RRUsersLst = new List<User>();
    Map<Integer,User> RRUsersLstMap = new Map<Integer,User>();  
    Decimal Seq = 0;    
    List<Opportunity>  oppoToInsert = new List<Opportunity>(); 
    List<Lead> LstLead = new List<Lead>();
    
    if(trigger.isInsert && trigger.isAfter)
    {
        for(Opportunity Oppc : trigger.new)
        {   
            if(Oppc.Branch_Code__c != null && Oppc.Branch_Code__c != '' && Oppc.LeadSource != 'Stock Reserved' 
               && Oppc.LeadSource != 'Walk-in')
            {
                try
                {
                    Opportunity newOpp = new Opportunity(Id = Oppc.Id);
                    global_var__c JCC_GlobalVar = global_var__c.getOrgDefaults(); 
                    
                    If(Oppc.Branch_Code__c == 'CCK'){
                        RoleName='KIAPC Sales Consultant'; 
                        Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_KIA__c;
                        if(Seq == null) {
                            Seq = 1;
                        } else {
                            Seq = Seq + 1;
                        }
                        JCC_GlobalVar.Opportunity_Seq_KIA__c = Seq;
                    }
                    else if(Oppc.Branch_Code__c == 'CCA'){
                        RoleName='MITPC Sales Consultant'; 
                        Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MIT__c;
                        if(Seq == null) {
                            Seq = 1;
                        } else {
                            Seq = Seq + 1;
                        }
                        JCC_GlobalVar.Opportunity_Seq_MIT__c = Seq;
                    }
                    else if(Oppc.Branch_Code__c == 'CCI'){
                        RoleName='MBP Sales Consultant'; 
                        Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_MB__c;
                        if(Seq == null) {
                            Seq = 1;
                        } else {
                            Seq = Seq + 1;
                        }
                        JCC_GlobalVar.Opportunity_Seq_MB__c = Seq;
                    }
                    else if(Oppc.Branch_Code__c == 'CCF'){
                        RoleName='CITPC Sales Consultant'; 
                        Seq = (Integer)JCC_GlobalVar.Opportunity_Seq_CIT__c;
                        if(Seq == null) {
                            Seq = 1;
                        } else {
                            Seq = Seq + 1;
                        }
                        JCC_GlobalVar.Opportunity_Seq_CIT__c = Seq;
                    }
                    upsert JCC_GlobalVar;
                    
                    If(RoleName=='')
                    {
                        RoleName='Management';
                    }
                    RRUsersLst = [Select Id, Name from User where UserRole.Name =:RoleName AND Is_Eligible_Opp_Owner__c=True AND IsActive = TRUE ORDER BY Id ASC];                
                    System.debug(RRUsersLst.size());
                    If(RRUsersLst.size()>0)
                    {
                        for (Integer i = 0; i < RRUsersLst.size(); i++) 
                        {
                            RRUsersLstMap.put(i, RRUsersLst[i]);                       
                        }                   
                        
                        newOpp.OwnerId = RRUsersLstMap.get(Math.MOD(Integer.valueOf(Seq),RRUsersLst.size())).Id;  
                        System.debug(newOpp);
                        oppoToInsert.add(newOpp);
                        
                        //Update Lead owner to Opportunit owner here.  
                        /*if(Oppc.Lead__c != null)
                        {
                        for (Lead currentLead : [Select Id,OwnerId,CreatedDate from Lead where CreatedDate >:Datetime.now().addMinutes(-4)]) 
                        { 
                        If(currentLead.Id == Oppc.Lead__c)
                        {
                        currentLead.OwnerId = newOpp.OwnerId;
                        LstLead.add(currentLead);
                        }
                        }   
                        }*/
                        
                    }
                }
                catch(Exception e)
                {
                    system.debug('System Exception has occured: '+e.getMessage());
                }
            }
        }
        
        if(oppoToInsert.size()>0)
        {
            /*If(LstLead.size()>0)
            {
            update LstLead;
            }*/
            update oppoToInsert;            
        }
    }
    
    /*if(trigger.isInsert && trigger.isBefore){
for(Opportunity opp : trigger.new){
if(opp.Lead__c != NULL){

}
}
}*/
}
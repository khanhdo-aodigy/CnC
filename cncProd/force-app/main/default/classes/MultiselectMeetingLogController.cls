public with sharing class MultiselectMeetingLogController {
    
    public String currentRecordId {get;set;}
    public String parameterValue {get;set;}
    
    public SelectOption[] selectedUser { get; set; }
    public SelectOption[] allUser { get; set; }
    
    public String message { get; set; }
    //public List<String> ParticipantsName = new List<String>();
    
    
    public MultiselectMeetingLogController(ApexPages.StandardController controller) {
        try {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
        
        selectedUser = new List<SelectOption>();
        allUser = new List<SelectOption>();
        List<String> ParticipantsList = new List<String>();
        List<String> selectedName = new List<String>();
        List<String> allName = new List<String>();
        List<String> allUserId = new List<String>();
        List<String> remainingName = new List<String>();
        
            
        Set<String> availableProfile = new Set<String>{'KIAPC Sales',
                                                        'KIAPC Sales Manager',
                                                        'MITPC Sales',
                                                        'MITPC Sales Manager',
                                                        'CITPC Sales',
                                                        'CITPC Sales Manager'
                                                        };
        //Get Profile Id
        String userProfileName = [SELECT Name FROM Profile WHERE Id=: UserInfo.getProfileId() LIMIT 1].Name;
        Set<Id> ProfileId = new Set<Id>();
        for(Profile item : [SELECT Id, Name 
                            FROM Profile WHERE 
                            Name IN: availableProfile])
        {
            if(userProfileName.contains('KIAPC') && item.Name.contains('KIAPC')){
                ProfileId.add(item.Id);
            }else if(userProfileName.contains('MITPC') && item.Name.contains('MITPC')){
                ProfileId.add(item.Id);
            }else if(userProfileName.contains('CITPC') && item.Name.contains('CITPC')){
                ProfileId.add(item.Id);
            }else if(userProfileName.contains('System Administrator')){
                //bypass for Admins, can see both Kia and MIT
                ProfileId.add(item.Id);
            }
            
        }
        
        List<User> mUser =[SELECT Id,name FROM User
                             WHERE ProfileId IN :ProfileId 
                             AND isActive = TRUE
                             AND ExcludeFromMeetingLog__c = False
                             ORDER BY Name ASC];
                             
        System.debug('+++++++++--user : '+mUser);
        if(mUser.size()>0)
        {
            for(User activeUser: mUser)
            {
                
                allName.add(activeUser.Name);
                allUserId.add(activeUser.Id);
                //allUser.add(new SelectOption(activeUser.Name, activeUser.Name));
            }
        }
        
        List<Meeting_Log_V2__c> pickedListValue = [SELECT Participant_Name__c,Participants_Name_List__c From Meeting_Log_V2__c WHERE Id = :currentRecordId];
        System.debug('ID : '+currentRecordId);
        System.debug('Record : '+pickedListValue);
        For(Meeting_Log_V2__c meeting: pickedListValue)
        {
            if(meeting.Participants_Name_List__c != null)
            {
                ParticipantsList = meeting.Participants_Name_List__c.split(';');
                if(ParticipantsList.size()>0)
                {
                    for(Integer i =0; i<ParticipantsList.size(); i++)
                    {
                        selectedName.add(ParticipantsList[i]);
                        selectedUser.add(new SelectOption(selectedName.get(i), selectedName.get(i)));
                    }
                    
                }
            }
        }
        
        if(selectedName.size()>0)
        {
                System.debug('All user > 0 - '+selectedName.size());
                List<User> mRemainUser =[SELECT name FROM User WHERE Id IN :allUserId AND name NOT IN:selectedName ORDER BY Name ASC];
            
            System.debug('All user > 0 - '+mRemainUser.size());
            if(mRemainUser.size()>0)
            {
                for(Integer i=0; i<mRemainUser.size(); i++)
                    {
                        allUser.add(new SelectOption(mRemainUser.get(i).name, mRemainUser.get(i).name));
                    }
            }
                    
                
        }
        else
        {
                for(Integer i=0; i<allname.size(); i++)
                {
                    allUser.add(new SelectOption(allName.get(i), allName.get(i)));
                }
        }
    }
        catch (Exception e) {
            System.debug('Exception >>> ' + e.getMessage() + ' >>> ' + e.getLineNumber());
        }
    }
    
    public PageReference save() {
        message = '';
        Boolean first = true;
        for ( SelectOption so : selectedUser ) {
            if (!first) {
                message += ';';
            }
            message += so.getValue();
            first = false;
        }
        
        Meeting_Log_V2__c item = new Meeting_Log_V2__c(Id = currentRecordId);
        item.Participants_Name_List__c = message;
        item.Participant_Name__c =  message;
        update item;
        
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage;
    }
}
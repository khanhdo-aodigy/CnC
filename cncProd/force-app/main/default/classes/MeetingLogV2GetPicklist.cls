public class MeetingLogV2GetPicklist {
    

    @AuraEnabled 
    public static List<User> getUserList(){
        List<Profile> SalesId =  [SELECT Id FROM Profile WHERE name='KIAPC Sales' or name='KIAPC Sales Manager'];
        List<Id> ProfileId = new List<Id>();
        
        for(Profile item : SalesId)
        {
            ProfileId.add(item.Id);
        }
        List<User> ParticipantList =[SELECT name FROM User WHERE ProfileId IN :ProfileId AND isActive = TRUE ORDER BY Name ASC];
        return ParticipantList;     
    } 
    
  
    
    @AuraEnabled 
    public static void saveValueButton(Id caseId, List<string> pickListValue){
        Meeting_Log_V2__c item = new Meeting_Log_V2__c(Id = caseId);
    
        String participantName ='' ;
        if(pickListValue.size()>0){
            for( integer i=0 ; i< pickListValue.size();i++){
            	if( i < pickListValue.size()-1){
                  	participantName += pickListValue[i]+ ';';
            }
                else{
                	participantName += pickListValue[i];
            }
          }
        }
        
        item.Participants_Name_List__c = participantName;
        item.Participant_Name__c =  participantName;
        update item;
    }
    
    @AuraEnabled 
   public static List<Meeting_Log_V2__c> getPicklistValues(Id caseId){ 
		
       List<Meeting_Log_V2__c> pickedListValue = [SELECT Participant_Name__c,Participants_Name_List__c From Meeting_Log_V2__c WHERE Id =: caseId];
		
  			return pickedListValue;
   }
    

}
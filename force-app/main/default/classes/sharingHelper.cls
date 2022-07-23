/** ******
 * Description : Sharing Helper class to initiate & create Share__c object, which then will be used for record MANUAL SHARING 
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                        Description
 * 20190222             Hari Panneerselvam          Created initial version
 * 20200310             HS                          Added record sharing for Account/PersonAccount 
 * 
** ******/
public class sharingHelper {
    
    public static void creatShare(List<generateShare> lstGenerateShare){
        Map<String, Share__c> mapShareToCreate = new Map<String, Share__c>(); //Key is the external Id
        Set<String> setId = new Set<String>();
        Map<String, User> mapUser = new Map<String, User>();
        Map<String, Group> mapPublicGroup = new Map<String, Group>();
        Set<String> setShareId = new Set<String>();
        
        for(generateShare itrShare : lstGenerateShare){
            setId.add( itrShare.userOrGroupId );
        }

        mapUser = new Map<String, User>( [SELECT Id, Name FROM User WHERE Id IN :setId] );

        mapPublicGroup = new Map<String, Group>([SELECT Id, Name FROM Group WHERE Id IN :setId]);
        
        for(generateShare itrShare : lstGenerateShare)
        {
            Share__c newShare = new Share__c();
            newShare.Access_Level__c = itrShare.accessLevel;
            newShare.Object__c = itrShare.objectName;
            newShare.Record_Id__c = itrShare.parentId;
            newShare.User_or_Group_Id__c = itrShare.userOrGroupId;
            
            if(itrShare.userOrGroupId.startsWith('005')){
                newShare.Type__c = 'Users';
                newShare.User_or_Group_Name__c = mapUser.get(itrShare.userOrGroupId).Name;
            }
            else if(itrShare.userOrGroupId.startsWith('00G')){
                newShare.Type__c = 'Public Groups';
                newShare.User_or_Group_Name__c = mapPublicGroup.get(itrShare.userOrGroupId).Name;   
            }
            newShare.Share_Unique_Id__c = itrShare.parentId + itrShare.userOrGroupId; 

            /*
            if(itrShare.objectName == 'Lead'){
                newShare.Lead__c = itrShare.parentId;
            }
            else */ 
            if(itrShare.objectName == 'Contact'){
                newShare.Contact__c = itrShare.parentId;
            }
            else if(itrShare.objectName == 'Opportunity'){
                newShare.Opportunity__c = itrShare.parentId;
            }
            else if(itrShare.objectName == 'Account'){
                newShare.Account__c = itrShare.parentId;
            }
            mapShareToCreate.put(newShare.Share_Unique_Id__c + itrShare.userOrGroupId, newShare);
        }

        System.debug('mapShareToCreate::' +mapShareToCreate);
        if( mapShareToCreate != null && mapShareToCreate.size() > 0 ){
            Database.UpsertResult[] results = Database.upsert( mapShareToCreate.values(), Share__c.Fields.Share_Unique_Id__c, false);           
            for(Share__c itrShare : mapShareToCreate.values()){
                setShareId.add(itrShare.id);
            }
            if(setShareId != null && setShareId.size() > 0){
                if(System.isBatch() || System.isFuture()){
                    createRecordShare_Sync( setShareId );
                }
                else{
                    createRecordShare_ASync( setShareId );
                }
            }
        }
    }
    
    public class generateShare{
        String accessLevel;
        String objectName;
        String parentId;
        String userOrGroupId;
        public generateShare (String varAccessLevel, String varObjectName, String varParentId, String varUserOrGroupId){
            accessLevel     = varAccessLevel;
            objectName      = varObjectName;
            parentId        = varParentId;
            userOrGroupId   = varUserOrGroupId;
        }
    }
    
    @future
    public static void createRecordShare_ASync( Set<String> setShareId ){
    	createRecordShare( setShareId );
    }
    
    public static void createRecordShare_Sync( Set<String> setShareId ){
    	createRecordShare( setShareId );
    }
    
    //@future
    public static void createRecordShare( Set<String> setShareId ){
        List<Share__c> lstToCreateShare = new List<Share__c>();
        List<LeadShare> lstLeadShare = new List<LeadShare>();
        List<ContactShare> lstContactShare = new List<ContactShare>();
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        try{

            lstToCreateShare = Database.query('SELECT ' +Utility.getFields('Share__c') +' , Account__r.RecordTypeId FROM Share__c WHERE Id IN :setShareId');
            if(lstToCreateShare != null && lstToCreateShare.size() > 0){
                for(Share__c itrShare : lstToCreateShare)
                {
                    /*
                    if(itrShare.Object__c == 'Lead')
                    {
                        LeadShare tempLeadShare = new LeadShare();
                        //tempLeadShare.LeadAccessLevel = itrShare.Access_Level__c;
                        tempLeadShare.LeadAccessLevel = 'Edit';
                        tempLeadShare.LeadId = itrShare.Record_Id__c;
                        //tempLeadShare.RowCause = 'Manual';
                        tempLeadShare.UserOrGroupId = itrShare.User_or_Group_Id__c;
                        lstLeadShare.add(tempLeadShare);
                    }
                    else*/
                    if(itrShare.Object__c == 'Contact')
                    {
                        ContactShare tempContactShare = new ContactShare();
                        tempContactShare.ContactAccessLevel = itrShare.Access_Level__c;
                        tempContactShare.ContactId = itrShare.Record_Id__c;
                        //tempContactShare.RowCause = 'Manual';
                        tempContactShare.UserOrGroupId = itrShare.User_or_Group_Id__c;
                        lstContactShare.add(tempContactShare);
                    }
                    else if(itrShare.Object__c == 'Opportunity')
                    {
                        OpportunityShare tempOpportunityShare = new OpportunityShare();
                        tempOpportunityShare.OpportunityAccessLevel = itrShare.Access_Level__c;
                        tempOpportunityShare.OpportunityId = itrShare.Record_Id__c;
                        //tempContactShare.RowCause = 'Manual';
                        tempOpportunityShare.UserOrGroupId = itrShare.User_or_Group_Id__c;
                        lstOpportunityShare.add(tempOpportunityShare);
                    }
                    else if(itrShare.Object__c == 'Account')
                    {
                        String str_account_access = itrShare.Access_Level__c;
                        if( itrShare <> null && AccountUtil.isProspect( itrShare.Account__r.RecordTypeId, null ) ) {
                            str_account_access = 'Edit';
                        }
                        
                        AccountShare tempAccountShare = new AccountShare();
                        tempAccountShare.AccountAccessLevel     = str_account_access;
                        tempAccountShare.ContactAccessLevel     = str_account_access;
                        tempAccountShare.CaseAccessLevel        = 'Read';
                        tempAccountShare.OpportunityAccessLevel = str_account_access;
                        tempAccountShare.AccountId              = itrShare.Record_Id__c;
                        tempAccountShare.UserOrGroupId          = itrShare.User_or_Group_Id__c;
                        lstAccountShare.add(tempAccountShare);
                    }
                }
            }

            System.debug('@@@@DEBUG createRecordShare :: lstLeadShare = ' + lstLeadShare );
            System.debug('@@@@DEBUG createRecordShare :: lstContactShare = ' + lstContactShare );
            System.debug('@@@@DEBUG createRecordShare :: lstOpportunityShare = ' + lstOpportunityShare );
            System.debug('@@@@DEBUG createRecordShare :: lstAccountShare = ' + lstAccountShare );
            // if(lstLeadShare != null && lstLeadShare.size() > 0){
            //     Database.upsert(lstLeadShare, false);
            // }
            if(lstContactShare != null && lstContactShare.size() > 0){
                Database.upsert(lstContactShare, false);
            }
            if(lstOpportunityShare != null && lstOpportunityShare.size() > 0){
                Database.upsert(lstOpportunityShare, false);
            }
            if(lstAccountShare != null && lstAccountShare.size() > 0){
                Database.upsert(lstAccountShare, false);
            }
        }
        catch(Exception ex){
            System.debug('@@@@DEBUG createRecordShare :: ERROR = ' + ex );
        }
    }
  
}
/** *****
 * Class name : BulkFileUploadResController.
 * Description : Controller for BulkFileUploadResults component.
 * 
 * Change History:
 * Date(YYYYMMDD)      Name                          Description
 * YYYYMMDD            Aodigy                        Created Initial Version. 
 * 20201008            khanh.do@aodigy.com           PA - Phase 2 Changes: Removed Lead, Added PA
 * 
** *****/
public class BulkFileUploadResController {
	
    @AuraEnabled  
    public static List<BulkFileUpload__c> getResults(string sdocumentId){ 
     try{
        system.debug('Selected Document Id-->' + sdocumentId);
        List<BulkFileUpload__c> resList = [SELECT DocumentId__c, Total_No_of_Recs__c, No_of_Prospects_Created__c, No_of_Prospects_Failed__c, No_of_Opp_Created__c, No_of_Opp_Failed__c, No_of_Recs_Failed__c, No_of_Recs_Updated__c from BulkFileUpload__c WHERE DocumentId__c=:sdocumentId AND Type__c='S'];       
        system.debug('results list' + resList);
        system.debug(resList[0].Total_No_of_Recs__c);
        return resList; 
    }catch(Exception e){throw new AuraHandledException(e.getMessage());}
}
}
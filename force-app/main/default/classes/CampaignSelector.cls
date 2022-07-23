/** *****
 * Description :Selector class for Campain object
 * 
 * Change History:
 * Date(YYYYMMDD)       Developer                  Details
 * 20210417             khanh.do@aodigy            Created initial version
 ** *****/
public class CampaignSelector extends ADGLIB_SObjectSelector  {

    public Schema.SObjectType getSObjectType() {
        return Campaign.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return ADGLIB_UtilityHelper.getSObjectFieldListByObj('Campaign');
    }

    public List<Campaign> getCampaignListByIds(Set<String> campaignIds) {
        List<Campaign> campaignList = new List<Campaign>();

        if( !campaignIds.isEmpty() ) {
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Id IN :campaignIds '; 
            query.setCondition( str_filter );
            campaignList = Database.query( query.toSOQL() );
        }
        return campaignList;
    }
    public List<Campaign> getCampaignListByBrandAndBranchCode (String brand, String branchCode){
        List<Campaign> campaignList = new List<Campaign>();
            adglib_QueryFactory query = newQueryFactory();    
            String str_filter = ' Status = \'Planned\' AND Target_Audience__c = \'Public And Targeted\' AND isActive = True AND Brand__c =:Brand AND Branch_Code__c =: BranchCode AND Budgeted_Cost_in_Campaign__c != NULL '; 
            str_filter += ' AND EndDate >= TODAY';
            query.setCondition( str_filter );
            campaignList = Database.query( query.toSOQL() );
        return campaignList;

    }
    
}
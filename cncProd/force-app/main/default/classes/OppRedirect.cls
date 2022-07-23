/****************************************
 * Class Name: OppRedirect
 * Description: Controller of OppRedirect.vfp
****************************************/ 
public without sharing class OppRedirect {

    public Boolean renderError {get; set;}    
    public OppRedirect(ApexPages.StandardController controller) {
    }

    public Pagereference redirectToQuickContact()
    {
        // Sys admin standard new button page, rest profiles custom page = OppRedirect.vfp
        PageReference pg;
        NewOverride__c ov = NewOverride__c.getInstance();
        String noOvverideLink = '/'+ Opportunity.sObjectType.getDescribe().getKeyPrefix() +'/e?nooverride=1';
        if(!ov.AllowNew__c){
            renderError = true;
        }else{
            renderError = false;
            pg = new PageReference(noOvverideLink); 
        }
        return pg;
    }
}
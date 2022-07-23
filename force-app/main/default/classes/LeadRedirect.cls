/****************************************
 * Class Name: LeadRedirect
 * Description: Controller of LeadRedirect.vfp
****************************************/ 
public without sharing class LeadRedirect {
    
    public Lead leadVal {get; set;}
    public Boolean renderError {get; set;}    
    
    
    //constructor
    public LeadRedirect(ApexPages.StandardController sc){
        leadVal = (Lead) sc.getRecord();
    }
    
    //if System Admin, redirect to the Lead Creation page.
    public PageReference redirectToError(){
        //check permission
        PageReference rf;
        NewOverride__c ov = NewOverride__c.getInstance();
		String linkOverride = '/'+ Lead.sObjectType.getDescribe().getKeyPrefix() +'/e?nooverride=1';
        if(!ov.AllowNew__c){
            //does not have new
            renderError = true;
        }else{
            renderError = false;
            //New functionality prevent override
            rf = new PageReference( linkOverride ); 
        }
        return rf;
    }
}
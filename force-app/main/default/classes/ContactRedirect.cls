/****************************************
 * Class Name: ContactRedirect
 * Description: Controller of ContactRedirect.vfp
****************************************/ 
public without sharing class ContactRedirect {
    
    public Contact conVal {get; set;}
    public Boolean renderError {get; set;}    
    
    //constructor
    public ContactRedirect(ApexPages.StandardController sc){
        conVal = (Contact) sc.getRecord();
    }
    
    //if System Admin, redirect to the Lead Creation page.
    public PageReference redirectToError(){
        //check permission
        PageReference rf;
        NewOverride__c ov = NewOverride__c.getInstance();
		String linkOverride = '/'+ Contact.sObjectType.getDescribe().getKeyPrefix() +'/e?nooverride=1';
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
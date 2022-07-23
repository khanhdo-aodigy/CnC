public with sharing class ReCaptchaController {
    public String siteKey {get;set;}
    public String secretKey {get;set;}
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}

    public ReCaptchaController() {
        system.debug(' -- Begin Constructor --');
        ReCaptcha_Credential__mdt reCaptchaMdt = [SELECT Active__c, Site_Key__c, Secret_Key__c FROM ReCaptcha_Credential__mdt WHERE Active__c = true][0];
        siteKey = reCaptchaMdt.Site_Key__c;
        secretKey = reCaptchaMdt.Secret_Key__c;
        system.debug(reCaptchaMdt);
    }
}
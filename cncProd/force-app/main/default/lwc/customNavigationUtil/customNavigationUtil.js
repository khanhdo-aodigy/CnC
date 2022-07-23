//Configuration file for defining navigation logic.

export class Navigation {
    constructor(recordId, attributes){
        this.__recordId = recordId;
        this.__navigationAction = attributes.Action_Type__c;
        this.__attributes = attributes;
    }

    generateNavigationPath(){
        let navigationPath = {type:'',attributes: {}};

        navigationPath.type = this.__attributes.type;
        switch(this.__navigationAction){
            case "navExternalURL" : {
                navigationPath.type = 'standard__webPage';
                navigationPath.attributes.url = this.__attributes.Action_Callout_Name__c;
                navigationPath.attributes.replace = false;
                break;
            }
            case "navFlow" || "navVFP":{
                navigationPath.attributes.url = `${window.location.protocol}//${window.location.hostname}${this.__attributes.Action_Callout_Name__c}`;
                navigationPath.attributes.apiName = this.__attributes.Action_Callout_Name__c;
                break;
            }
            case "navLightningCmp" || "navLightningPage" || "navTab":{
                navigationPath.attributes.apiName = this.__attributes.Action_Callout_Name__c;
                break;
            }
            case "nanavHomevTab" : {
                navigationPath.attributes.apiName = this.__attributes.Target_Object__c;
                navigationPath.attributes.actionName = 'home';
                break;
            }
            case "navCreation" : {
                navigationPath.attributes.apiName = this.__attributes.Target_Object__c;
                navigationPath.attributes.actionName = 'new';
                break;
            } 
            case "navListView" : {
                navigationPath.attributes.apiName = this.__attributes.Target_Object__c;
                navigationPath.attributes.actionName = 'list';
                navigationPath.state.filterName = 'Recent';
                break;
            }
            case "navLightningApp" : {
                navigationPath.type = 'standard__webPage';
                navigationPath.attributes.url = `${window.location.protocol}//${window.location.hostname}${this.__attributes.Action_Callout_Name__c}?recordID=${this.__recordId}`;
                navigationPath.attributes.replace = false;
                break;
            }
            default: {
                navigationPath.type = 'None';
                break;
            }
        }

        return navigationPath;
    }
}
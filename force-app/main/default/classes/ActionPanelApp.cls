public with sharing class ActionPanelApp {

   @AuraEnabled(cacheable=true)
    public static LIST<Action_Panel__mdt> getActiveButtonsFromMDT(String objName){
        ActionPanelSelector selector = new ActionPanelSelector();
        return selector.getButtonsByPage(objName);

    }
}
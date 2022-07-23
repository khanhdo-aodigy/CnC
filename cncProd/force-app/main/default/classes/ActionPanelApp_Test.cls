@isTest
public class ActionPanelApp_Test {
    
    @isTest
    static void ActionPanelApp_Test() {
        LIST<Action_Panel__mdt> testResult = ActionPanelApp.getActiveButtonsFromMDT('SalesAgreement');
        System.assertNotEquals(0, testResult.size());
    }

    @isTest
    static void actionPanelComponentDesign(){
        ActionPanelComponentDesign apcDesignLookup = new ActionPanelComponentDesign();
        
        VisualEditor.DataRow testDefaultValue = apcDesignLookup.getDefaultValue();
        System.assertNotEquals(null, testDefaultValue);
        
        VisualEditor.DynamicPickListRows testListRows = apcDesignLookup.getValues();
        System.assertNotEquals(0, testListRows.size());
        
        
    }
}
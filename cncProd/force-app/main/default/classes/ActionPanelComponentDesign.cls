global class ActionPanelComponentDesign extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return this.getIntegrationComponentPickList();
    }

    private VisualEditor.DynamicPickListRows getIntegrationComponentPickList() {
        VisualEditor.DynamicPickListRows listForSelection = new VisualEditor.DynamicPickListRows();
        String queryCondition = 'Visible__c = true';
        LIST<Action_Panel__mdt> customMetadataList = ADGLIB_UtilityHelper.getSObjectRecords('Action_Panel__mdt', queryCondition, false);

        for (Action_Panel__mdt pickVal : customMetadataList) {
            listForSelection.addRow(new VisualEditor.DataRow(pickVal.Object__c, (String) pickVal.Object__c));
        }
        listForSelection.addRow(new VisualEditor.DataRow('None', 'None'));

        return listForSelection;
    }
    
}
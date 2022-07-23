public with sharing class LookUpComponentDesignAttribute extends VisualEditor.DynamicPickList {

    public override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow('User', 'User');
    }    
    
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        Set<String> nonApplicableSObjs = new Set<String>{'feed', 'history', 'share', 'tag'};
        
        Map<String, SObjectType> allSObjects = Schema.getGlobalDescribe();
        List<String> sObjectNames = new List<String>();
        for(String key: allSObjects.keySet()) {
            String sObjName = allSObjects.get(key).getDescribe().getName();
            Schema.DescribeSObjectResult result = allSObjects.get(key).getDescribe();
            
            if( result.isQueryable() && result.isSearchable() && !nonApplicableSObjs.contains(sObjName) ) {
                sObjectNames.add(sObjName);
            }
        }

        if(!sObjectNames.isEmpty()) {
            sObjectNames.sort();
            for(String name: sObjectNames) {
                myValues.addRow( new VisualEditor.DataRow(name, name) );
            }
        }

        return myValues;
    }
}
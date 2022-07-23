({
    startCreateQuoteFlow : function(component)
    {
        let flow = component.find("flowData");
        let recordTypeId = component.get( "v.pageReference" ).state.recordTypeId != null ? component.get( "v.pageReference" ).state.recordTypeId : '';
        console.log('recordTypeId =' + recordTypeId);
        let inputVariables = [
            {
                name: "recordTypeId",
                type: "String",
                value: recordTypeId
            }
        ]
        
        flow.startFlow("Create_New_Used_Car_Quote", inputVariables);
    }
})
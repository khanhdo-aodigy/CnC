({
    init : function(component, event, helper) {
        // console.log(helper.getProp(component, 'recordId'));
        helper.getRecord(component);
    },

    docusign : function(component, event, helper) {
        helper.docusign(component)
    },

    cancel : function(component, event, helper) {
        helper.cancel();    
    },

    preview : function(component, event, helper) {
        helper.preview(component);
    },
})
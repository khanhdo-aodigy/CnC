({
    doInit : function(component, event, helper)
    {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.parentId", context.attributes.recordId);
        
        helper.getVPO(component.get("v.parentId"), component);
    },

    closeModal : function(component, event, helper) 
    {
        helper.cancelDialog(component);
    },
})
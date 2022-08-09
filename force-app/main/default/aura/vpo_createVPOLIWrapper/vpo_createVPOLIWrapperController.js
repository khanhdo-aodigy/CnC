({
    doInit : function(component, event, helper)
    {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        console.log('###context : ' + JSON.stringify(context));
        component.set("v.parentId", context.attributes.recordId);      
    },

    cancelDialog : function(component, helper) 
    {
        $A.get('e.force:refreshView').fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.parentId")
        });
        navEvt.fire();
    }
    
})
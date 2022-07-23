({
    callApex : function(component, event, helper) {
        const params = event.getParam("arguments");
        return helper.callServer(params.action, params.params);
    },
})
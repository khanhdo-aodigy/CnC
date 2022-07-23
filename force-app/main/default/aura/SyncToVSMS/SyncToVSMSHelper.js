({
    syncToVSMS: function (component, event, helper) {
        var saId = component.get("v.recordId");
        const action = component.get("c.syncToVSMSOnDemand");
        action.setParams({"saId" : saId});
        action.setCallback(this, function(response) {
            var msg = response.getReturnValue();
            setTimeout($A.getCallback(() => component.set("v.hideSpinner", true)), 1000);
            if (msg === 'SUCCESS') {
                component.set("v.isError", false);
                console.log('saId ' + saId);
            }
            else {
                component.set("v.isError", true);
                //var errors = response.getError();
                component.set("v.errorMsg", msg);
                /*if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }*/
            }
        });
        $A.enqueueAction(action);
    },
})
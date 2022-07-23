({
    sendFinanceEmail : function(component) {
        var saId = component.get("v.recordId");
        const action = component.get("c.sendFinanceEmail");
        action.setParams({"saId" : saId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            setTimeout($A.getCallback(() => component.set("v.hideSpinner", true)), 1000);
            if (state === 'SUCCESS') {
                component.set("v.isError", false);
                // $A.get("e.force:closeQuickAction").fire();
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg", errors[0].message);
                    }
                }
                component.set("v.isError", true);
                
            }
        });
        $A.enqueueAction(action);
    }
})
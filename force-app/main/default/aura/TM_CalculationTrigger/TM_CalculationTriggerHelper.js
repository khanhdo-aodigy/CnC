({
    calculate : function(component) {
        let contractId = component.get("v.recordId");
        const action = component.get("c.reCalculateAmounts");
        action.setParams({"contractId" : contractId});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.isError", false);
                $A.get('e.force:refreshView').fire();
                setTimeout($A.getCallback(() => this.dismissAction()), 1000);
            }
            else {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.message", errors[0].message);
                    }
                } else {
                    component.set("v.message", "Unknown error");
                }
                component.set("v.isError", true);
            }
        });
        $A.enqueueAction(action);
    },

    dismissAction: function() {
        const action = $A.get("e.force:closeQuickAction");
        action.fire();
    }
})
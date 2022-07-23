({
    init : function(component, event) {
        // Set progess step
        component.set("v.progressStep", "1");
        // Populate Validity Date for MB SA
        let recordId = component.get("v.recordId");
        const action = component.get("c.updateValidityDate");
        action.setParams({
            recordID : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // NOT SHOWING ANYTHING
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // component.set("v.errorMsg", errors[0].message);'
                        console.log(errors);
                        this.showToast('ERROR!', errors[0].message, 'error', 'dismissible');
                    }
                }                
            }
        });
        $A.enqueueAction(action);
    },

    navPage : function(component, event) {
        let btnNm = event.getSource().get("v.name");
        let currentStage = component.get("v.progressStep");
        console.log(currentStage);
        switch (currentStage) {
            case "1":
                component.set("v.progressStep", "2");
                break;
            case "2":
                btnNm == 'previous' && component.set("v.progressStep", "1");
                break;
            default: break;
        }
    },

    cancel : function(component, event) {
        const action = $A.get("e.force:closeQuickAction");
        action.fire();
    },

    showToast : function(title, errorMsg, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": errorMsg,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    }
})
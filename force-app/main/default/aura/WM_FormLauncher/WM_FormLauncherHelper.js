({
    getForms : function(component) {
        this.setProp(component, 'spin', true);
        const action = component.get('c.getForms');
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let results = [...response.getReturnValue()];
                if (results) {
                    if (results.length == 0) {
                        this.setProp(component, 'message', 'No available forms found. Please contact your Administrator!');
                    } else {
                        // If only 1 form returned then set default value
                        if (results.length == 1) this.setProp(component, 'formCode', results[0].Form_Code__c);
                        // Reserve all info of LTA Forms
                        this.setProp(component, 'forms', results);
                        // Construct LTA Forms radio button options for UI
                        let formOptions = [];
                        results.forEach(form => {
                            formOptions.push({'label': form.Form_Name__c, 'value': form.Form_Code__c});
                        })
                        this.setProp(component, 'formOptions', formOptions);
                    }
                }
                console.log('lta forms:: ' + JSON.stringify(component.get("v.forms")));
                console.log('form options:: ' + JSON.stringify(component.get("v.formOptions")));
                this.setProp(component, 'spin', false);
            } else {
                this.toastError(response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    generateForm : function(component) {
        let formCode = component.get("v.formCode");
        let formInfo = component.get("v.forms").filter(form => form.Form_Code__c == formCode)[0];
        console.log('form Code == ' + formCode);
        console.log('form Info == ' + JSON.stringify(formInfo));
        this.setProp(component, 'spin', true);
        const action = component.get('c.generateForm');
        action.setParams({
            recordId: component.get("v.recordId"),
            mappingId: formInfo.WM_Mapping_Id__c
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let mergeSuccess = response.getReturnValue();
                console.log('Result:: ' + mergeSuccess);
                // this.setProp(component, 'formOptions', formOptions);
                if (mergeSuccess) {
                    this.setProp(component, 'message', 'Generated successfully! Please refresh the page and check in Files.');
                } else {
                    this.setProp(component, 'message', 'Error occurred during generation! Please contact your Administrator.');
                }
                this.setProp(component, 'spin', false);
            } else {
                this.toastError(response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    setProp : function(component, prop, value) {
        component.set('v.' + prop, value);
    },

    toast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title, message, type, mode
        });
        toastEvent.fire();
    },

    toastError : function(error) {
        console.log('error', error);
        let message = 'unknow error';
        if (Array.isArray(error)) {
            this.haveValue(error) && (message = error[0].message);
        } else {
            this.haveValue(error) && (message = error.message);
        }
        
        this.toast('ERROR', message, 'error', 'sticky');
    },

    haveValue : function(data) {
        return (data != undefined && data != null);
    },
})
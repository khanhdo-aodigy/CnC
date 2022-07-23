({
    /**
     * get sales agreement and process
     * @param {*} component 
     */
    getRecord : function(component) {
        this.setProp(component, 'spin', true);
        this.setProp(component, 'vfp', '/apex/MB_WebmergeWizardContainer?id=' + this.getProp(component, 'recordId'));
        const action = component.get('c.getRecords');
        
        action.setParams({
            recordID : this.getProp(component, 'recordId'),
            additionalConditions : '',
        });

        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                let record = JSON.parse(JSON.stringify(response.getReturnValue()[0]))
                let docTypes = JSON.parse(JSON.stringify(component.get("v.documentTypes")));
                this.validateDocTypes(component, record, docTypes);
                console.log(component.get("v.documentOptions"));
                this.setProp(component, 'record', record);
                this.addEmailToUI(component, record);
                this.setProp(component, 'spin', false);
            } else {
                this.toastError(response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * entry point for Docusign signing button
     * @param {*} component 
     */
    docusign : function(component) {
        let document = this.getProp(component, 'document');
        if (document == '') {
            this.toast('Warning', 'Please select Document Type.', 'warning', 'dismissible');
            return;
        }
        let confirm = window.confirm('Are you sure to Generate a Docusign?');
        if (confirm) {
            this.setProp(component, 'spin', true);

            /** ADDED BY TPHAN ON 26/07/2021 - PA MERGING */
            let recordId = this.getProp(component, 'recordId');
            const action = component.get('c.updateRelatedPA');            
            action.setParams({
                recordId : recordId
            });                  
            action.setCallback(this, function(response) {});
            $A.enqueueAction(action);
            /** ADDED BY TPHAN ON 26/07/2021 - PA MERGING */
            
            let scenario = this.getProp(component, 'scenario');
            switch (scenario) {
                case 'IP':
                    this.signInplace(component);
                    break;
                case 'EM':
                    this.signViaEmail(component);
                    break;
                default:
                    break;
            }
        }
    },

    /**
     * call Docusign if user choose to sign in-place
     * @param {*} component 
     */
    signInplace : function(component) {
        let document = this.getProp(component, 'document');
        let recordId = this.getProp(component, 'recordId');

        const action = component.get('c.signInPlace');
        
        action.setParams({
            recordID : recordId,
            docType : document,
        });
        
        action.setCallback(this, function(response) {
            this.setProp(component, 'spin', false);
            this.processSignInPlace(component, response);
        });
        
        $A.enqueueAction(action);
    },

    /**
     * call Docusign if user choose to sign via email
     * @param {*} component 
     */
    signViaEmail : function(component) {
        let document = this.getProp(component, 'document');
        let recordId = this.getProp(component, 'recordId');

        const action = component.get('c.signViaEmail');
        
        action.setParams({
            recordID : recordId,
            docType : document,
        });
        
        action.setCallback(this, function(response) {
            this.setProp(component, 'spin', false);
            this.processSignViaEmail(component, response);
        });
        
        $A.enqueueAction(action);
    },

    /**
     * open embedded sign link response from Docusign
     * @param {*} component 
     * @param {*} response 
     */
    processSignInPlace : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            this.cancel();
            window.open(response.getReturnValue(), '_blank');
        } else {
            this.toastError(response.getError());
        }
    },

    /**
     * process response of signing via email
     * @param {*} component 
     * @param {*} response 
     */
    processSignViaEmail : function(component, response) {
        let state = response.getState();

        if (state === 'SUCCESS') {
            this.cancel();
            this.toast('Success', 'Email has been sent to ' + this.getProp(component, 'record').CEmail_Address__c, 'success', 'dismissible');
        } else {
            this.toastError(response.getError());
        }
    },

    /**
     * generate a preview version of chosen document
     * @param {*} component 
     */
    preview : function(component) {
        let document = this.getProp(component, 'document');
        if (document == '') {
            this.toast('Warning', 'Please select Document Type.', 'warning', 'dismissible');
            return;
        }
        this.setProp(component, 'spin', true);

        let recordID = this.getProp(component, 'recordId');

        const action = component.get('c.getPreview');

        action.setParams({
            recordID : recordID,
            docType : document,
        });

        action.setCallback(this, function(response) {

            this.setProp(component, 'spin', false);
            this.processPreview(component, response);
        });

        $A.enqueueAction(action);
    },

    processPreview : function(component, response) {
        let state = response.getState();
        if (state === 'SUCCESS') {
            // GOOGLE VIEWER
            // this.setProp(component, 'spin', false);
            // window.open('https://docs.google.com/viewer?url=' + response.getReturnValue(), '_blank');
            // console.log('https://docs.google.com/viewer?url=' + response.getReturnValue());
            

            // DOWNLOAD
            this.setProp(component, 'previewLink', response.getReturnValue());
            this.setProp(component, 'modal', true);
            this.toast('SUCCESS', 'Generating preview version, please wait few seconds for the start to download', 'success', 'sticky');
        } else {
            this.toastError(response.getError());
        }
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

    cancel : function() {
        const action = $A.get("e.force:closeQuickAction");
        action.fire();
    },

    /**
     * add customer's email to UI for better UX
     * @param {*} component 
     * @param {*} record 
     */
    addEmailToUI : function(component, record) {
        let cEmail = record.CEmail_Address__c;

        if (this.haveValue(cEmail)) {
            this.getProp(component, 'options')[1].label = 'Customer sign via email (' + cEmail + ')';
        } else {
            // this.toast('WARNING', 'This Sales Agreement has no customer email', 'warning', 'sticky');
        }
    },

    getProp : function(component, prop) {
        return component.get('v.' + prop);
    },

    setProp : function(component, prop, value) {
        component.set('v.' + prop, value);
    },

    haveValue : function(data) {
        return (data != undefined && data != null);
    },

    validateDocTypes : function(component, record, docTypes) {
        console.log(record);
        docTypes.forEach(type => {
            switch (type.value) {
                case 'SA':
                    if (record.Lock_SA_Generated__c) type.disabled = true;
                    if (this.haveValue(record.Used_Car_Registration_Number__c) && !record.Seller_is_Not_Buyer__c) type.disabled = true;
                    break;
                case 'SAUCA':
                    if (record.Lock_SA_Generated__c) type.disabled = true;
                    if (this.haveValue(record.Used_Car_Registration_Number__c) && record.Seller_is_Not_Buyer__c) type.disabled = true;
                    if (!this.haveValue(record.Used_Car_Registration_Number__c)) type.disabled = true;
                    break;
                case 'UCA':
                    if (this.haveValue(record.Used_Car_Registration_Number__c) && !record.Seller_is_Not_Buyer__c) type.disabled = true;
                    if (!this.haveValue(record.Used_Car_Registration_Number__c)) type.disabled = true;
                    break;
            }
        })
        component.set("v.documentOptions", docTypes);
    }
})
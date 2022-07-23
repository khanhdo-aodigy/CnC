({
    doInit:function(component, event, helper){
        component.get("v.recordId");
        component.set("v.header", 'New Debit Reward Usage');
        helper.checkAuthorizedUser(component);
    },

    onSave: function(component){
        let el = component.find('usagedetails');
        component.set("v.isLoading", true);
        el.onCreate();
    },

    onCancel: function(){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        //window.querySelector("toastContainer slds-notify_container slds-is-relative")
        var elements = document.getElementsByClassName("lightning-input_input");
        console.log('elements = ' + elements);
        console.log('elements.length = ' + elements.length);
    },

    onDownload: function(component){
        var attachmentId = component.get("v.attachmentId");
        window.open('/servlet/servlet.FileDownload?file=' + attachmentId);
    },

    turnOffLoader: function(component){
        component.set("v.isLoading", false);
    },

    handleSubmitRecord: function(component,event){
        component.set("v.isLoading", false);
        var message = event.getParam('message');
        var resultsToast = $A.get("e.force:showToast");
        if (message == 'SUCCESS') {
            component.set("v.header", "Debit Reward Usage Successful");
            component.set("v.attachmentId", event.getParam('attachmentId'));
            component.set("v.isSuccess", true);
            var evt = $A.get('e.force:refreshView');
            evt.fire();          
            resultsToast.setParams({
                "message": 'Debit reward usage(s) has/have been created!',
                "type": 'success',
                "title": message,
                "mode": "dismissable"
            });
        } else {
            resultsToast.setParams({
                "message": message,
                "type": 'error',
                "title": 'FAILED',
                "mode": "sticky"
            }); 
        }
        resultsToast.fire();          
    }
})
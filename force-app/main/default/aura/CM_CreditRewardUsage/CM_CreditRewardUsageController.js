({
    doInit:function(component, event, helper){
        component.get("v.recordId");
        component.set("v.header", "New Credit Reward Usage");
        helper.checkAuthorizedUser(component);
    },

    onSubmit: function(component){
        let element = component.find('creditUsage');
        component.set("v.isLoading", true);
        element.onSubmit();
    },

    onCancel: function(){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
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
            component.set("v.header", "Credit Reward Usage Successful");
            component.set("v.attachmentId", event.getParam('attachmentId'));
            component.set("v.isSuccess", true);
            var evt = $A.get('e.force:refreshView');
            evt.fire();          
            resultsToast.setParams({
                "message": 'Credit Reward Usage Record has been Created!',
                "type": 'success',
                "title": message,
                "mode": "dismissable"
            });            
        } else {
            component.set("v.isSuccess", false);
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
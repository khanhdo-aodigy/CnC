({
    doInit:function(component,event,helper){
        component.get("v.recordId");
        component.set("v.header", 'Credit Adjustment');
        helper.checkAuthorizedUser(component.get("v.recordId"), component);
    },

    onSave: function(component,event,helper){
        let el = component.find('adjustmentdetails');
        if (el.validateInput())
        {
            component.set("v.isLoading", true);
            el.onCreate();
        }        
    },

    onCancel: function(component,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    handleSubmitRecord: function(component,event){
        component.set("v.isLoading", false);
        var message = event.getParam('message');
        var resultsToast = $A.get("e.force:showToast");
        if (message == 'SUCCESS') {
            component.set("v.header", "Adjustment Successful");
            component.set("v.isSuccess", true);
            var evt = $A.get('e.force:refreshView');
            evt.fire();          
            resultsToast.setParams({
                "message": 'Adjustment is successful!',
                "type": 'success',
                "title": message
            });            
        } else {
            resultsToast.setParams({
                "message": message,
                "type": 'error',
                "title": 'FAILED'
            });     
        }
        resultsToast.fire();          
    }
})
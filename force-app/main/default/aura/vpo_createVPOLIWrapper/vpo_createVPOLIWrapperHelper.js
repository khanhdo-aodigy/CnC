({
    getVPO : function(recordId, component) 
    {
        const getVPOController = component.get("c.getVPO");
        getVPOController.setParams({ recordId: recordId});
        this.executeAction(component, getVPOController)
        .then(result => 
        {      
            if(result) 
            {
                var currentStage = result.Stage__c;
                console.log('Stage: ' + currentStage);
                if (currentStage === 'Closed' || currentStage === 'Cancelled' || currentStage === 'Submitted for Approval')
                {
                    component.set("v.validStage", false);     
                    this.cancelDialog(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Sorry!",
                        "message": "You can\'t create new Vehicle Purchase Order Line Items when Vehicle Purchase Order stage is Closed or Cancelled or Submitted for Approval! Please contact your Administrator.",
                        "type": 'warning',
                        "mode": 'sticky'
                    });
                    toastEvent.fire();
                }
                else
                {
                    component.set("v.validStage", true);
                }
            }
        }).catch(error => 
        {
            console.log('Error occurred getting VPO : ' + error.message);
        });
    },

    cancelDialog: function(component)
    {
        component.set("v.validstage", false);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.parentId")
        });
        navEvt.fire();
    },

    getParameterByName: function(component, event, name, url) 
    {
            name = name.replace(/[\[\]]/g, "\\$&");
            var url = window.location.href;
            var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
            var results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    executeAction : function(component, action) 
    {
        const p = new Promise($A.getCallback((resolve, reject) => 
        { 
            action.setCallback(this, callbackResult => 
                {
                if (callbackResult.getState() == 'SUCCESS') 
                {
                    resolve(callbackResult.getReturnValue());
                } 
                else if (callbackResult.getState() == 'ERROR') 
                {
                    const error = callbackResult.getError()[0];
                    if (error.message != undefined) {
                    	reject(error);
                	} else if (error.pageErrors != undefined) {
                    	reject(error.pageErrors[0]);
                	} else {
                    	reject(new Error("An unknown error has occurred."));
                	}
        		}
			});
			$A.enqueueAction(action);
		}));  

		return p;
    },
})
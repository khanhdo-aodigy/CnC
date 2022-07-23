({
    callApex : function(component, apexAction, params) {
        let p = new Promise($A.getCallback(function(resolve, reject) { 
            let action = component.get("c." + apexAction);
            action.setParams(params);
            action.setCallback(this, function(callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                } else if (callbackResult.getState() == 'ERROR') {
                    console.log('Error: ', callbackResult.getError()); 
                    reject(callbackResult.getError());
                }
            });
            $A.enqueueAction(action);
        }));            
        return p;
    }
})
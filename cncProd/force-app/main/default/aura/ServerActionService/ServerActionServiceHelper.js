({
	callServer : function(action, params) {
		const p = new Promise($A.getCallback((resolve, reject) => { 
            if (params) {action.setParams(params);}
            action.setCallback(this, callbackResult => {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                } else if (callbackResult.getState() == 'ERROR') {
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
({
    initializeSalesAgreement: function (recordId, cmp) {
        const intializeSalesAgreementForm = cmp.get("c.initializeSalesAgreement");
        intializeSalesAgreementForm.setParams({ recordId: recordId });
        this.executeAction(cmp, intializeSalesAgreementForm)
            .then(result => {
                cmp.set('v.salesAgreementObject', result);
                cmp.set('v.finishedLoading', true);
            }).catch(error => {
                console.log('Error occurred submitting order : ' + error.message);
            });
    },

    executeAction : function(cmp, action) {
        const p = new Promise($A.getCallback((resolve, reject) => { 
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

    getURLRecordId : function(param){
        var result=decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        console.log('Param ' + param + ' from URL = ' + result);
        return result;
    }
    
})
({
    initializeSalesAgreement : function(recordId, cmp) {

        //This matter will call apex to check recordId type if it is salesAgreement or Reserveration
        //Return parameter of this must return salesAgreement.
        const intializeSalesAgreementForm = cmp.get("c.initializeSalesAgreement");
        intializeSalesAgreementForm.setParams({ recordId: recordId});
        this.executeAction(cmp, intializeSalesAgreementForm)
        .then(result => {      
            if(result.Stock_Reservation__c) {
                cmp.set('v.salesAgreementObject', result);  
                cmp.set("v.deltaChangesObj", cmp.get("v.salesAgreementObject.Id"));
                cmp.set("v.recipientEmail", cmp.get("v.salesAgreementObject.emailaddress__c"));
                typeof result.Last_save_on_form__c === 'undefined' ? (cmp.set('v.currentStage', 'Customer')): (cmp.set('v.currentStage', result.Last_save_on_form__c));
                result.Lock__c === true && (cmp.set('v.isLocked', result.Lock__c), cmp.set('v.currentStage', 'Review'));
                cmp.set('v.finishedLoading', true);
            } else {
                cmp.set('v.stockResObject', result);  
                //console.log('TEST SR PAGE: ' + result.Id);
                cmp.set('v.currentStage', 'RegistrationType');
                cmp.set('v.finishedLoading', true);
            }   
        }).catch(error => {

            cmp.set('v.hasErrors', true);
            cmp.set("v.errorMsg", 'Error: '  + error.message );
            console.log('Error occurred submitting order : ' + error.message);

        });
    },

    createInitialSalesAgreement : function(recordId, cmp)
    {
        const createInitialSalesAgreementForm = cmp.get("c.createInitialSalesAgreement");

        let preConfigurations = cmp.get("v.deltaChangesObj");

        console.log('Pre configurations', preConfigurations);

        createInitialSalesAgreementForm.setParams({
            recordId : recordId,
            preConfigurations : preConfigurations
        });
        
        this.executeAction(cmp, createInitialSalesAgreementForm)
        .then(result => 
            {
                cmp.set('v.salesAgreementObject', result);

                // set delta changes object again so it will forget Sales Agreement pre-configurations
                cmp.set("v.deltaChangesObj", cmp.get("v.salesAgreementObject.Id"));

                cmp.set("v.recipientEmail", cmp.get("v.salesAgreementObject.emailaddress__c"));
                
                typeof result.Last_save_on_form__c === 'undefined' ? (cmp.set('v.currentStage', 'Customer')): (cmp.set('v.currentStage', result.Last_save_on_form__c));
                
                result.Lock__c === true && (cmp.set('v.isLocked', result.Lock__c), cmp.set('v.currentStage', 'Review'));  
                
                cmp.set('v.finishedLoading', true);
            })
        .catch(error =>
            {
            cmp.set('v.hasErrors', true);
            cmp.set("v.errorMsg", 'Error: '  + error.message );
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
({
    setTemplateId: function(component){
        const action = component.get("c.getTemplateID");
        action.setParams({SArecordID : component.get("v.recordId")});
        action.setCallback (this, function(response) {
            response.getState() === 'SUCCESS' && component.set('v.templateID', response.getReturnValue());
        });
        $A.enqueueAction(action);
        
    },

    setTemplateIdForUsedCarAgmnt: function(component){
        const action = component.get("c.getUCATemplateID");
        action.setParams({SArecordID : component.get("v.recordId")});
        action.setCallback (this, function(response) {
            response.getState() === 'SUCCESS' && component.set('v.templateIDForUCA', response.getReturnValue());
            //console.log('TEST ID: ' + component.get('v.templateIDForUCA'));
        });
        $A.enqueueAction(action);     
    },

    fireVSMSAndDocu : function(component){
        component.set("v.isError", false);
        component.set("v.errorMsg", '');
        component.set("v.spinner", true);
        this.callOutToVSMS(component); 
    },

    callOutToVSMS : function(component) {
        this.callApex(component.get("c.createSalesOrder"), {SalesAgreementId : component.get("v.recordId")})
        .then($A.getCallback(result=>{
            //component.set("v.requestGenerateDocuUrl", true); 
            console.log(component.get("v.isUsedCarAgmnt"));
            if(component.get("v.isUsedCarAgmnt") === true) {
                component.set("v.requestGenerateDocuUrlForUCA", true); 
            } else {
                component.set("v.requestGenerateDocuUrl", true); 
                console.log(component.get("v.requestGenerateDocuUrl"));
            }
        })).catch(error => {
            component.set("v.spinner", false);
            component.set("v.isError", true);
            component.set("v.errorMsg", 'VSMS' + error.message);
            console.log('callOutToVSMS result: ' + error.message);
        })
    },
    
    signingProcess : function(component) {
    
    component.set('v.isSignUpCalled', true);

    this.callApex(component.get("c.signingProcess"), {mySAId : component.get("v.recordId"), signViaEmail :component.get('v.signViaEmail')})
        .then(result=>{
            console.log('**1*');
            const finishedText = component.get('v.signViaEmail') === true ? 'The Docusign PDF has been emailed out to the customer for their signature. Please check that they have received the email.' : 
                                                                          'The Docusign PDF has been generated.';
            component.set("v.signingURL", result.payload); //signingURL            
            component.set("v.spinner", false);
            component.set('v.isSignUpCalled', false);
            component.set('v.finishedText', finishedText);
            component.set('v.finishedGenerating', false);
            component.set('v.requestGenerateDocuUrl', false);
            component.get('v.signViaEmail') === false && window.open( component.get("v.signingURL") , '_blank');
            
        }).catch(error => {
            console.log('**2*');
            component.set("v.isError", true);
            component.set("v.errorMsg", 'PDF Generation Error: '+error.message);
            component.set('v.isSignUpCalled', false);
            component.set("v.spinner", false);
            console.log(error.message);
        })

    },

    signingProcessForUCA : function(component) {
        component.set('v.isSignUpCalled', true);
        this.callApex(component.get("c.UCA_SigningProcess"), {mySAId : component.get("v.recordId"), signViaEmail :component.get('v.signViaEmail')})
        .then(result=>{
            const finishedText = component.get('v.signViaEmail') === true ? 'The Docusign PDF has been emailed out to the customer for their signature. Please check that they have received the email.' : 
                                                                          'The Docusign PDF has been generated.';
            component.set("v.signingURL", result.payload); //signingURL         
            console.log('TEST: ' + result.payload);   
            component.set("v.spinner", false);
            component.set('v.isSignUpCalled', false);
            component.set('v.finishedText', finishedText);
            component.set('v.finishedGeneratingForUCA', false);
            component.set('v.requestGenerateDocuUrlForUCA', false);
            component.get('v.signViaEmail') === false && window.open( component.get("v.signingURL") , '_blank');
            
        }).catch(error => {
            component.set("v.isError", true);
            component.set("v.errorMsg", 'PDF Generation Error: '+error.message);
            component.set('v.isSignUpCalled', false);
            component.set("v.spinner", false);
            console.log(error.message);
        })
    },

	// In helper
	callApex : function(action, params) {
        action.setParams(params);
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
})
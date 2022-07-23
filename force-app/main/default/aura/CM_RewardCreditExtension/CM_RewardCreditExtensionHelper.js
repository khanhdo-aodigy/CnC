({   
    checkAuthorizedUser : function(recordId, cmp) {
        const checkAuthUser = cmp.get("c.isAuthorizedUser");
        checkAuthUser.setParams({customPermission: 'CM_Issue_Extension'});
        this.executeAction(cmp, checkAuthUser)
        .then(result => {
            if (result) {
                this.retrieveReward(recordId, cmp);
            } else {
                cmp.set("v.showModal", false);
                cmp.set("v.isSuccess", true);
                cmp.set("v.errorMsg", "Sorry. You do not have permission to Extend Expiry.");
            }
        }).catch(error => {
            cmp.set("v.showModal", false);
            cmp.set("v.isSuccess", true);
            cmp.set("v.errorMsg", error.message);
        });
    },
    
    retrieveReward : function(recordId, cmp) {
        const retrieveRewardRec = cmp.get("c.retrieveReward");
        retrieveRewardRec.setParams({rewardId: recordId});
        this.executeAction(cmp, retrieveRewardRec)
        .then(result => {
            if (result.Status__c == 'Expired') {
                cmp.set("v.showModal", true);
            } 
            else {
                cmp.set("v.showModal", false);
                cmp.set("v.isSuccess", true);
                cmp.set("v.errorMsg", "Sorry. Only Reward with Expired status can be extended.");
            }
        }).catch(error => {
            cmp.set("v.showModal", false);
            cmp.set("v.isSuccess", true);
            cmp.set("v.errorMsg", error.message);
        });
    },

    executeAction : function(cmp, action) {
        const p = new Promise($A.getCallback((resolve, reject) => { 
            action.setCallback(this, callbackResult => {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                else if (callbackResult.getState() == 'ERROR') 
                {
                    const error = callbackResult.getError()[0];
                    if (error.message != undefined) {
                    	reject(error);
                    } 
                    else if (error.pageErrors != undefined) {
                    	reject(error.pageErrors[0]);
                    } 
                    else {
                    	reject(new Error("An unknown error has occurred."));
                	}
        		}
			});
			$A.enqueueAction(action);
		}));            
		return p;
    },
})
({
    calltocbs: function(component, event, helper, myFromDate, myToDate, mysvcctrs, myBtype1, myBtype2, myBtype3, myBtype4, mySvcType, mySCR, myIncx, mychoice) 
    {	
        let p = new Promise($A.getCallback(function(resolve, reject) 
        {   		
            let action = component.get("c.getfromcbs");
            action.setParams({ 
                    "FromDate" : myFromDate, 
                    "ToDate"  : myToDate,
                    "svcctrs" : mysvcctrs,
                    "vBType1" : myBtype1,
                    "vBType2" : myBtype2,
                    "vBType3" : myBtype3,
                    "vBType4" : myBtype4,
                    "vSCR" :  mySCR, 
                    "SvcType" : mySvcType,
                    "IncTx" :  myIncx, 
                    "filterby" : mychoice 
            }); 
            // setting the arguments of server action
            //   alert('after set params');
                   
            action.setCallback(this, function(callbackResult) 
            {
                if (callbackResult.getState() == 'SUCCESS') 
                {
                    resolve(callbackResult.getReturnValue());
                } 
                else if (callbackResult.getState() == 'ERROR') 
                {
                    console.log('Error: ', callbackResult.getError()); 
                    reject(callbackResult.getError());
                }
            });
            
            $A.enqueueAction(action);
        }));            
        
        return p;
    }
})
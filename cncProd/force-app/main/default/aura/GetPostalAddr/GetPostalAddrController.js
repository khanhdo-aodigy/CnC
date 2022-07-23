({
getSelectedAddr: function(component, event, helper) {	
    		     var selectedValue = component.get("v.postalcode");
         		 var action = component.get("c.getAddr");
                 action.setParams({ "vpostalcode" : selectedValue }); // setting the arguments of server action 
    			action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS"){
                    component.set("v.selectedAddr",response.getReturnValue());
                }
           		else{alert('incomplete ' + state);}
            
       		 });
        	$A.enqueueAction(action);   
        }
})
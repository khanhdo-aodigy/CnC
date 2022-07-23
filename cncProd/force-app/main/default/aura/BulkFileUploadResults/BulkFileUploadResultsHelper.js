({
	getUploadedResults : function(component, docuId) {
            let action = component.get("c.getResults");
            action.setParams({
            	"sdocumentId":docuId            
        	});  
    		action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.results",result);  
            }  
        });  
        $A.enqueueAction(action);  
	}
})
({
	init : function(component, event, helper) {
        component.set('v.isOpen', true);
       	var flow = component.find("sfuflow");
        var inputVar = [
          {name:"vCaseId", type:"String", value:component.get("v.CaseId")}
        ];
        flow.startFlow("SFU_Survey_Main_Screen",inputVar);
	},

     closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
         var navigateEvent = $A.get("e.force:navigateToComponent");
  			navigateEvent.setParams({
   				componentDef:"c:SurveySFUAgent",
       		}); 
        	navigateEvent.fire(); 
    },

    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
            var navigateEvent = $A.get("e.force:navigateToComponent");
  			navigateEvent.setParams({
   				componentDef:"c:SurveySFUAgent",
       		}); 
        	navigateEvent.fire(); 
        	}
    },
})
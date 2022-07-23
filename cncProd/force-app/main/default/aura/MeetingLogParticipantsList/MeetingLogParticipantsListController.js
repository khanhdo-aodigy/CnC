({
    doInit: function (component, event, helper) {
       
        var action = component.get("c.getUserList");    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
                var resultArray = response.getReturnValue();
                var options = [];
                resultArray.forEach(function(result)  { 
                    options.push({ value: result.Name, label: result.Name});
                });
                component.set("v.listOptions", options);
            } else {
                console.log('Failed with state: ' + state);  
            }
        });
        $A.enqueueAction(action);  
        
        var getSelectedList = component.get("c.getPicklistValues");
        
        getSelectedList.setParams({"caseId":component.get("v.recordId")});
        getSelectedList.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {   
                var resultArray = response.getReturnValue();
               
                var options = [];
                
                resultArray.forEach(function(result)  { 
                   if(result.Participants_Name_List__c!= null){
                    result.Participants_Name_List__c.split(';').forEach(function(xresult){
                        
                        options.push(xresult);
                    });}
          
                });
                
                component.set("v.defaultOptions" , options ) ;

            } else {
                console.log('Failed with state: ' + state);             
            }        
        });
        $A.enqueueAction(getSelectedList); 
    },
    
    handleChange: function (component, event) {
        var selectedOptionsList = event.getParam("value");
        console.log(selectedOptionsList);
        component.set("v.selectedArray", selectedOptionsList);
        
        
    },
   
    
    
    saveButton : function(component, event, helper) 
    {
		
        var caseId = component.get("v.recordId");
        var saveValue = component.get("v.selectedArray");
        var action = component.get("c.saveValueButton");
        action.setParams({"caseId": caseId, "pickListValue": saveValue});            
        action.setCallback(component,function(response) 
                           {
                               var state = response.getState();
                               if (state === 'SUCCESS'){
                                   $A.get('e.force:refreshView').fire();
                               }
                           }
                          );
        $A.enqueueAction(action);
	} 
    
})
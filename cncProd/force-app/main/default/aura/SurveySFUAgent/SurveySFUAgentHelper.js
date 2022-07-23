({
    getData : function(component){
        // call apex class method
        var action = component.get("c.getSFURecords");
        action.setParams({
            "initialRows" : component.get("v.initialRows"),
            "vLocation" : "All"
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var toastReference = $A.get("e.force:showToast");
            if(state == "SUCCESS"){
                var sfuWrapper = response.getReturnValue();
                if(sfuWrapper.success){
                    // set total rows count from response wrapper
                    component.set("v.totalRows",sfuWrapper.totalRecords);  
                    component.set("v.vFromDate", sfuWrapper.FromDate);
                    component.set("v.vToDate", sfuWrapper.ToDate);
                    
                    var sfuList = sfuWrapper.sfusList;
           		
                    component.set("v.sfuData",sfuList);
                }
                else{ // if any server side error, display error msg from response
                    toastReference.setParams({
                        "type" : "Error",
                        "title" : "Error",
                        "message" : sfuWrapper.message,
                        "mode" : "sticky"
                    }); 
                    toastReference.fire();
                }
            }
            else{ // if any callback error, display error msg
                toastReference.setParams({
                    "type" : "Error",
                    "title" : "Error",
                    "message" : 'An error occurred during Initialization '+state,
                    "mode" : "sticky"
                });
                toastReference.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    loadData : function(component){
         
        return new Promise($A.getCallback(function(resolve){
            var limit = component.get("v.initialRows");
            var offset = component.get("v.currentCount");
            var totalRows = component.get("v.totalRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
          	var pLocation = component.get("v.activeFilter");
             
            var action = component.get("c.loadSFURecords");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset,
                "vLocation" : pLocation,
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = component.get("v.currentCount");
                currentCount += component.get("v.initialRows");
                // set the current count with number of records loaded 
                component.set("v.currentCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    },
    
    getDataByLoc : function(component){
        
        var action = component.get("c.getSFUByLoc");
        action.setParams({
            "initialRows" : component.get("v.initialRows"),
            "vLocation" : component.get("v.activeFilter")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var toastReference = $A.get("e.force:showToast");
            if(state == "SUCCESS"){
                var sfuWrapper = response.getReturnValue();
                if(sfuWrapper.success){
                    component.set("v.totalRows",sfuWrapper.totalRecords);  
                  	var sfuList = sfuWrapper.sfusList;
           			component.set("v.sfuData",sfuList);
                }
                else{ // if any server side error, display error msg from response
                    toastReference.setParams({
                        "type" : "Error",
                        "title" : "Error",
                        "message" : sfuWrapper.message,
                        "mode" : "sticky"
                    }); 
                    toastReference.fire();
                }
            }
            else{ // if any callback error, display error msg
                toastReference.setParams({
                    "type" : "Error",
                    "title" : "Error",
                    "message" : 'An error occurred during Initialization '+state,
                    "mode" : "sticky"
                });
                toastReference.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
})
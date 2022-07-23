({
	/* Calling the server side controller to get the list of record types accessible to the logged in user */
	getRecordTypes : function(component,event) {
        //console.log('getRecordTypes Called');
		var action=component.get("c.getRecordTypes");
        action.setParams({
            ObjectApiName : component.get("v.objectApiName")
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                var rtlist=response.getReturnValue();
                if(rtlist.length===0){
                	component.set("v.noRecordTypeAvailable",true);
                    this.getPicklistValueswoRT(component,event);
                }
                else{
                    //Check for Invalid Api Name
                    if(rtlist[0].incorrectApiName===true){
                        component.set("v.invalidApiName",true);
                    }
                    else{
                        component.set("v.noRecordTypeAvailable",false);
                        component.set("v.recordtypeList",rtlist);
                        
                    }
                }
                component.set("v.showSpinner",false); //hide Spinner      
            }
            else{
                console.log('State: '+state);
                if(state==="ERROR")
                    console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    
    /* Checking if the dependent picklist is a MultiSelect picklist or not */
    checkifMSP : function(component,event){
        //console.log('checkifMSP Called');
    	var action=component.get("c.isfieldMSPtype");
        action.setParams({
            objectApiName: component.get("v.objectApiName"),
            fieldName : component.get("v.dependentFieldApiName")
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                component.set("v.isMSPtype",response.getReturnValue());
                this.getRecordTypes(component,event);
            }
            else{
                console.log('State: '+state);
                if(state==="ERROR")
                    console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    /* Calling the server side controller to get the Picklist fields dependency map
     * &  on successful response, calling 'getRecordTypes' helper method 
     * to get the list of record types accessible to the logged in user
    */
    getFieldDependencyMap : function(component,event) {
        //console.log('getFieldDependencyMap Called');
        var action=component.get("c.getFieldDependencyMap");
        action.setParams({
            ObjectApiName : component.get("v.objectApiName"),
            CfieldApiName : component.get("v.controllingFieldApiName"),
            DfieldApiName : component.get("v.dependentFieldApiName")            
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                component.set("v.fieldDependencMap",response.getReturnValue());
                this.checkifMSP(component,event);
            }
            else{
                console.log('State: '+state);
                if(state==="ERROR")
                    console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    /* Getting Controlling picklist values when no record type is available */
    getPicklistValueswoRT : function(component,event){
        //console.log('getPicklistValueswoRT Called');
        var fieldDependencMap = component.get("v.fieldDependencMap");
        var controllingPicklistValues=[];
        for(var key in fieldDependencMap)
            controllingPicklistValues.push(key);
        component.set("v.controllingPicklistValues",controllingPicklistValues);
    },
    
    
    /* Calling server side controller to get picklist values based on the chosen record type */
    getPicklistValuesforRT : function(component,event, fieldApiName,fieldtype){
        //console.log(' getPicklistValuesforRT Called: '+ fieldtype);
        var action=component.get("c.getPicklistValues");
		action.setParams({
            recordTypeId : component.get("v.selectedRecordTypeId"),
            ObjectApiName : component.get("v.objectApiName"),
            fieldApiName : fieldApiName
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                if(fieldtype==='Controlling')
                	component.set("v.controllingPicklistValues",response.getReturnValue());
                if(fieldtype==='Dependent')
                    component.set("v.dependentPicklistValuesCache",response.getReturnValue());
                component.set("v.showSpinner",false); //hide Spinner
            }
            else{
                console.log('State: '+state);
                if(state==="ERROR")
                    console.log(response.getError());
            }
        });
        
       $A.enqueueAction(action); 
    }
})
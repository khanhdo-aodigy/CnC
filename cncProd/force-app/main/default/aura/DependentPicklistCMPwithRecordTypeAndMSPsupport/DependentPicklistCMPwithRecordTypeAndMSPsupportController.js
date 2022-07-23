({
	/* Calling helper method to get the field dependency map at initialization of component */
	doInit : function(component, event, helper) {
        component.set("v.showSpinner",true); //show Spinner
        //Setting labels for the picklist
        if(!component.get("v.controllingPicklistLabel")){
            var cFieldLabel=component.get("v.controllingFieldApiName");
            cFieldLabel=cFieldLabel.replace('__c','');
            component.set("v.controllingPicklistLabel",cFieldLabel.replace('_',' '));
        }
        if(!component.get("v.dependentPicklistLabel")){
            var dFieldLabel=component.get("v.dependentFieldApiName");
            dFieldLabel=dFieldLabel.replace('__c','');
            component.set("v.dependentPicklistLabel",dFieldLabel.replace('_',' '));
        }
        helper.getFieldDependencyMap(component,event);
        //component.set("v.showSpinner",false); //hide Spinner
    },
    
    /* Calling helper methods on Record type picklist change to get the Picklist values based on the record type */
    handleRecordTypeChange : function(component, event, helper) {
        //console.log('handleRecordTypeChange Called' );
        if(component.get("v.selectedRecordTypeId")){
            component.set("v.showSpinner",true); //show Spinner
            
            helper.getPicklistValuesforRT(component,event,component.get("v.controllingFieldApiName"),'Controlling');
            helper.getPicklistValuesforRT(component,event,component.get("v.dependentFieldApiName"),'Dependent');
            var dependentPicklistValues=[];
            component.set("v.dependentPicklistValues",dependentPicklistValues);
            component.set("v.selectedControllingPicklistValue",null);
        }
        //component.set("v.showSpinner",false); //hide Spinner
    },
    
    /* Based on the selected value in controlling picklist, getting the dependent picklist values from the field dependency map */
    handleControllingPicklistChange : function(component, event, helper) {
        component.set("v.showSpinner",true);
        //console.log('handleControllingPicklistChange Called' );
        component.set("v.selectedDependentPicklistValue",null);
        component.set("v.selectedMSPValues",null);
        
        var dependentPicklistValues=[];
		var selectedControllingPicklistValue=component.get("v.selectedControllingPicklistValue");
        if(!selectedControllingPicklistValue)
            component.set("v.dependentPicklistValues",dependentPicklistValues);
        else{
            var dependencyMap=component.get("v.fieldDependencMap");
            if(component.get("v.noRecordTypeAvailable")){
                var dependentPicklistValuescache=dependencyMap[selectedControllingPicklistValue];	
                if(component.get("v.isMSPtype")){
                    for(var i=0;i<dependentPicklistValuescache.length;i++){
                        var obj={};
                        obj.label= dependentPicklistValuescache[i];
                        obj.value= dependentPicklistValuescache[i];
                        dependentPicklistValues.push(obj);
                    }
                }
                else{
                    dependentPicklistValues=dependentPicklistValuescache;
                }
                component.set("v.dependentPicklistValues",dependentPicklistValues);
            }
            else{
                var availablePicklistValuesCacheSet=[];
                availablePicklistValuesCacheSet=component.get("v.dependentPicklistValuesCache");
                
                var availablePicklistValuesMapSet=dependencyMap[component.get("v.selectedControllingPicklistValue")];
                if(availablePicklistValuesCacheSet.length>0){
                    for(var i=0;i<availablePicklistValuesCacheSet.length;i++){
                        if(availablePicklistValuesMapSet.includes(availablePicklistValuesCacheSet[i])){
                            if(component.get("v.isMSPtype")){
                                var obj={};
                                obj.label= availablePicklistValuesCacheSet[i];
                                obj.value= availablePicklistValuesCacheSet[i];
                                dependentPicklistValues.push(obj);
                            }
                            else{
                                dependentPicklistValues.push(availablePicklistValuesCacheSet[i]);
                            }
                        }
                    }
                }
                component.set("v.dependentPicklistValues",dependentPicklistValues);
            }
        }
		
		component.set("v.showSpinner",false); //hide Spinner
    },
    
    /* Convert the selected dependent values array to string  */
    handleDependentPicklistValueChange : function(component, event, helper){
        var selectedMSPValues='';
        if(component.get("v.selectedMSPValues")){
        	var arrayMSPvalues=component.get("v.selectedMSPValues");
        	for(var i=0; i<arrayMSPvalues.length;i++){
               if(i===arrayMSPvalues.length-1)
                   selectedMSPValues+=arrayMSPvalues[i];
                else
                    selectedMSPValues=selectedMSPValues+arrayMSPvalues[i]+';';
            }
        }
        component.set("v.selectedDependentPicklistValue",selectedMSPValues);
    }    
})
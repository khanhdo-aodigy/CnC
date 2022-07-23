({
    callApex : function(component, actionName, params) {
        const serverService = component.find("serverService");
        const action = component.get("c." + actionName);
        return serverService.callApex(action, params);
    },
    
    refreshFilesPerRequirements : function(component, fileReq, file) {
        const filesPerRequirements = component.get("v.filesPerRequirements");
        const filesPerReqToRefresh = filesPerRequirements.find(
            filesPerReq => filesPerReq.fileReq.Document_Name__c == fileReq.Document_Name__c
        );

        if (!filesPerReqToRefresh) {
            return;
        }
        
        if (!filesPerReqToRefresh.files) {
            filesPerReqToRefresh.files = new Array(file);
            component.set("v.filesPerRequirements", filesPerRequirements);
            this.showToastSuccess();
            return;
        }
        
		const matchedIndex = filesPerReqToRefresh.files.findIndex(existingFile => existingFile.Id == file.Id);
        if (matchedIndex > -1) {
            filesPerReqToRefresh.files.splice(matchedIndex, 1);
        } else {
			filesPerReqToRefresh.files.push(file);
            this.showToastSuccess();
        }
        
        component.set("v.filesPerRequirements", filesPerRequirements);
    },
    
    showToastSuccess : function() {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The file has been uploaded successfully."
        });
        toastEvent.fire();
    },
    
    updateRecord : function(component, checkboxFieldName, fieldValue) {
        console.log('updating in container');
        const toastHandler = component.find("toastHandler");
        console.log('toastHandler in container', toastHandler);
        const record = component.get("v.record");
        console.log('record in container', record);
        record[checkboxFieldName] = fieldValue;
        
        // Both recordHandler components could be on the page at one time - this behavior is indeterminate
        const recordHandler = Array.isArray(component.find("recordHandler")) ?
            component.find("recordHandler")[0] :
        	component.find("recordHandler");
        console.log('recordHandler in container', recordHandler);

        recordHandler.saveRecord($A.getCallback(saveResult => {
            switch(saveResult.state) {
            case "SUCCESS":
            	// TODO: Any success action
            	break;
            case "INCOMPLETE":
            	toastHandler.showToastError("Error:", "User is offline, device doesn't support drafts.");
            	break;
            case "ERROR":
            	console.log('Error has occurred in the container');
            	console.log(JSON.stringify(saveResult));
            	//toastHandler.showToastError("Error:", JSON.stringify(saveResult.error));
            	break;
            default:
            	//toastHandler.showToastError("Error:", `Unknown problem, state: ${saveResult.state}, error: ${JSON.stringify(saveResult.error)}`);
        	}            
		}));            
    }
})
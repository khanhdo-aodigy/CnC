({
    callApex : function(component, actionName, params) {
        const serverService = component.find("serverService");
        const action = component.get("c." + actionName);
        return serverService.callApex(action, params);
    },

    getSectionedFilesPerRequirements : function(allFilesPerRequirements) {
        const sectionedFilesPerReqMap = new Map();
        for (const filesPerReq of allFilesPerRequirements) {
            const section = filesPerReq.fileReq.Section__c;
            if (sectionedFilesPerReqMap.has(section)) {
                sectionedFilesPerReqMap.get(section).push(filesPerReq);
            } else {
                sectionedFilesPerReqMap.set(section, new Array(filesPerReq));
            }
        }        

        const sectionedFilesPerReqArr = new Array();
        for (const [sectionName, filesPerReqs] of sectionedFilesPerReqMap) {
            sectionedFilesPerReqArr.push({sectionName: sectionName, filesPerReqs: filesPerReqs});
        }

        return sectionedFilesPerReqArr;
    },
    
    refreshFilesPerRequirements : function(component, fileReq, file) {
        const sectionedFilesPerRequirements = component.get("v.sectionedFilesPerRequirements");

        const filesPerReqToRefresh = sectionedFilesPerRequirements
        	.find(sectionedFilesPerReq => {                                                     
				return sectionedFilesPerReq.filesPerReqs.find(existingFileReq => {
					return existingFileReq.fileReq.Document_Name__c == fileReq.Document_Name__c;
				})
			})
    		.filesPerReqs
    		.find(filesPerReq => filesPerReq.fileReq.Document_Name__c == fileReq.Document_Name__c);

        if (!filesPerReqToRefresh.files) {
            filesPerReqToRefresh.files = new Array(file);
            component.set("v.sectionedFilesPerRequirements", sectionedFilesPerRequirements);
            return;
        }
        
		const matchedIndex = filesPerReqToRefresh.files.findIndex(existingFile => existingFile.Id == file.Id);
        if (matchedIndex > -1) {
            filesPerReqToRefresh.files.splice(matchedIndex, 1);
        } else {
			filesPerReqToRefresh.files.push(file);
        }
        
        component.set("v.sectionedFilesPerRequirements", sectionedFilesPerRequirements);
    },    
    
    updateRecord : function(component, checkboxFieldName, fieldValue) {
        console.log('updating in overview');
        const toastHandler = component.find("toastHandler");
        console.log('toastHandler in overview', toastHandler);
        const record = component.get("v.record");
        console.log('record in overview', record);
        record[checkboxFieldName] = fieldValue;

        // Both recordHandler components could be on the page at one time - this behavior is indeterminate
        const recordHandler = Array.isArray(component.find("recordHandler")) ?
            component.find("recordHandler")[0] :
        	component.find("recordHandler");
        
        console.log('recordHandler in overview', recordHandler);
        
        recordHandler.saveRecord($A.getCallback(saveResult => {
            switch(saveResult.state) {
                case "SUCCESS":
                    // TODO: Any success action
                    break;
                case "INCOMPLETE":
                    toastHandler.showToastError("Error:", "User is offline, device doesn't support drafts. No action required");
                    break;
                case "ERROR":
                    console.log('Error has occurred in the overview');
                    console.log(JSON.stringify(saveResult));
                    toastHandler.showToastError("Error:", JSON.stringify(saveResult.error) + '. No action required');
                	break;
                default:
                	toastHandler.showToastError("Error:", `Unknown problem, state: ${saveResult.state}, error: ${JSON.stringify(saveResult.error)}. No action required`);
                    break;
            }

            // This is a temporary solution for tracking the issue
            /** ---------------------------------- START ----------------------------------*/
            if (saveResult.state !== 'SUCCESS' && saveResult.state !== 'DRAFT') {
                let log = {
                            recordId        : record.Id,
                            checkboxField   : checkboxFieldName,
                            fieldValue      : fieldValue,
                            saveResult      : JSON.stringify(saveResult),
                            reUpdateMBSA    : true
                          };

                this.callApex(component, 'log', { details: log })
                .then(result => {
                    console.log('done');
                }).catch(error => {
                    console.log(error);
                })
            }
            /** ---------------------------------- END ----------------------------------*/
		}));
    },
})
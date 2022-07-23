({  
    handleUploadFinished : function(component, event, helper) {
        const fileId = event.getParam("files")[0].documentId;
        const fileRequirement = component.get("v.fileRequirement");
        helper.callApex(component, 'renameAndTagFile', {fileId: fileId,
                                                        parentId: component.get("v.recordId"),
                                                        fileReq: fileRequirement})
        .then(result => {
            return helper.callApex(component, 'getFileAfterUpload', {fileId: fileId});
        })
        .then($A.getCallback(result => {
			helper.fireFileUploadEvent(component.get("v.fileRequirement"), result, true);
        }))       
        .catch(error => {
            console.log('error in row' , error);
            const toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",
                "message": error.message,
                "type": 'error'
            });
            toastEvent.fire();  
        })
    },   

    previewFile : function(component, event) {
        const fileId = event.currentTarget.dataset.id;
        const navService = component.find("navService");
        const pageRef = {
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview',
            },
            state : {
                recordIds: fileId,
                selectedRecordId: fileId
            }
        }
        navService.navigate(pageRef);
    },
    
    removeFile : function(component, event, helper) {
        
        // Prevent default onclick from firing
        event.preventDefault();

        if (!component.get("v.userIsSysAdmin")) {
            return;
        }

        const fileId = event.getSource().get("v.title");
        helper.callApex(component, 'deleteFile', {fileId: fileId})
        .then($A.getCallback(() => {
            helper.fireFileUploadEvent(component.get("v.fileRequirement"), {Id: fileId}, false);      
        }))
        .catch(error => {
            const toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",
                "message": error.message,
                "type": 'error'
            });
            toastEvent.fire();  
        })
    },    

})
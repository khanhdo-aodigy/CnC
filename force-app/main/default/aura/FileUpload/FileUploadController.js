({
	handleUploadFinished : function(component, event, helper) {
        let uploadedFiles = event.getParam("files");
        let userId = uploadedFiles[0].recordId;     
        let surveyType = component.get("v.chosenType");
                
        helper.callApex(component, 'getFileAfterUpload', {fileId : uploadedFiles[0].documentId})
        .then(function(result) {
            return helper.callApex(component, 'createSurvey', {fileLatestVersionId : result.LatestPublishedVersionId,
                                                               userId : '00G0l000001tuwcEAA',
                                                               surveyType : surveyType
                                                              })                  
        }).then(function(result) {
            console.log(result);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success:",
                "message": result+" cases have been created",
                "mode": "sticky",
                "type": "success"
            });
            toastEvent.fire();            
        }).catch(function(error) {
            helper.callApex(component, 'deleteFile', {parentId : userId, fileTypes : ['csv', 'CSV']})
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error:",
                "message": error[0].message,
                "mode": "sticky",
                "type": "error"
            });
            toastEvent.fire();
        })
    },
    removeFile : function(component, event, helper) {
        helper.callApex(component, 'deleteFile', {fileId : component.get("v.file").Id})
        .then(function(result) {
            component.set("v.isFileUploaded", false);
        })
    },
    handleButton: function(component, event){
        component.set("v.surveyType", event.getParam("chosenType"));
    }
})
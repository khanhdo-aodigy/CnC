({
    doInit : function(component, event, helper) {
        console.log('the record in overview on init is', component.get("v.record"));
        const toastHandler = component.find("toastHandler");
        helper.callApex(component, 'getAllFilesRequirementDetails', {recordId: component.get("v.recordId")})
        .then(result => {
            result = JSON.parse(result);        // MODIFIED ON 14/06/2021 - Workaround for wrapper response returned empty issue
            component.set("v.userIsSysAdmin", result.userIsSysAdmin);
            const filesPerRequirements = result.filesPerRequirements;
            component.set("v.sectionedFilesPerRequirements", helper.getSectionedFilesPerRequirements(filesPerRequirements));
            const associatedCheckboxFields = filesPerRequirements.filter(eachRes => eachRes.fileReq.Associated_Checkbox_Field_API_Name__c).map(eachRes => eachRes.fileReq.Associated_Checkbox_Field_API_Name__c);
            component.set("v.associatedCheckboxFields", associatedCheckboxFields);
            component.set("v.isInit", true);
        })
        .catch(error => {
            toastHandler.showToastError('Error:', error.message);
        });
    },
    
    handleFileUploadEvent : function(component, event, helper) {
        // const toastHandler = component.find("toastHandler");
		const fileReq = event.getParam("fileReq");
        const file = event.getParam("file");

        helper.refreshFilesPerRequirements(component, fileReq, file);

        const uploadedOrDeleted = event.getParam("uploadedOrDeleted");

        console.log('in overview ', component);
        console.log('in overview ', fileReq.Associated_Checkbox_Field_API_Name__c);
        console.log('in overview ', uploadedOrDeleted);

        if (fileReq.Associated_Checkbox_Field_API_Name__c) {
            try {
                helper.updateRecord(component, fileReq.Associated_Checkbox_Field_API_Name__c, uploadedOrDeleted);
            } catch (err) {
                console.log('Error occurred updating record in overview', err);
            }
        } else {
            // This is a temporary solution for tracking the issue
            /** ---------------------------------- START ----------------------------------*/
            let log = {
                        recordId        : component.get("v.recordId"),
                        file            : JSON.stringify(file),
                        fileReq         : JSON.stringify(fileReq),
                        fieldValue      : uploadedOrDeleted,
                        reUpdateMBSA    : false
                      };
            helper.callApex(component, 'log', { details: log })
            .then(result => {
                // toastHandler.showToastError('Error', 'File deleted/uploaded successfully but checkbox field not populated. Please contact System Administrator to rectify!');
                console.log('logging done..');
            })
            .catch(error => {
                console.log('logging error..');
            });
            /** ---------------------------------- END ----------------------------------*/
        }
    }
})
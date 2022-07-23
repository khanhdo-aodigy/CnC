({
    doInit : function(component, event, helper) {
        console.log('the record in container on init is', component.get("v.record"));
        const toastHandler = component.find("toastHandler");
        helper.callApex(component, 'getConditionalFilesRequirementDetails', {recordId: component.get("v.recordId")}) 
        .then(result => {
            result = JSON.parse(result);        // MODIFIED ON 14/06/2021 - Workaround for wrapper response returned empty issue 
            component.set("v.userIsSysAdmin", result.userIsSysAdmin);
            const filesPerRequirements = result.filesPerRequirements;
            component.set("v.filesPerRequirements", filesPerRequirements);  
            const associatedCheckboxFields = filesPerRequirements.filter(eachRes => eachRes.fileReq.Associated_Checkbox_Field_API_Name__c).map(eachRes => eachRes.fileReq.Associated_Checkbox_Field_API_Name__c);
            component.set("v.associatedCheckboxFields", associatedCheckboxFields);
            console.log('associated checkbox fields in container', associatedCheckboxFields);
        })
        .catch(error => {
            toastHandler.showToastError('Error:', error.message);
        });
    },
    
    handleFileUploadEvent : function(component, event, helper) {
		const fileReq = event.getParam("fileReq");
        const file = event.getParam("file");
        
        helper.refreshFilesPerRequirements(component, fileReq, file);
        
        const uploadedOrDeleted = event.getParam("uploadedOrDeleted");
        console.log('in container ', component);
        console.log('in container ', fileReq.Associated_Checkbox_Field_API_Name__c);
        console.log('in container ', uploadedOrDeleted);
        
        if (fileReq.Associated_Checkbox_Field_API_Name__c) {
            try {
                helper.updateRecord(component, fileReq.Associated_Checkbox_Field_API_Name__c, uploadedOrDeleted);
            } catch (err) {
                console.log('Error occurred updating record in container', err);
            }
        }
    }
})
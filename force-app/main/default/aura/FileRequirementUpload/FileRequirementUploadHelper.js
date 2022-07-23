({
    callApex : function(component, actionName, params) {
        const serverService = component.find("serverService");
        const action = component.get("c." + actionName);
        return serverService.callApex(action, params);
    },      
    
    fireFileUploadEvent : function(fileReq, file, uploadedOrDeleted) {
        const fileUploadEvent = $A.get("e.c:FileUploadEvent");
        fileUploadEvent.setParams({
            "fileReq": fileReq,
            "file": file,
            "uploadedOrDeleted": uploadedOrDeleted
        });
		fileUploadEvent.fire();
    },
})
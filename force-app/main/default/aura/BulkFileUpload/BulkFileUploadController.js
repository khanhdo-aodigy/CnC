({
   	doInit:function(component,event,helper){  
       helper.getuploadedFiles(component);
    },    
    
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        if(uploadedFiles.length>0)
        {
        	var uploadedFileName = uploadedFiles[0].name;
        	helper.getuploadedFiles(component);
			component.find('notifLib').showToast({
            	"variant": "Success",
            	"title": uploadedFileName,
            	"message": " - File Uploaded successfully!!",
            	closeCallback: function() {}
        	});
        	$A.get("e.force:refreshView").fire();
        }
      },
    
    processFile: function(component,event,helper){	
 		var versionid = event.currentTarget.id;
        helper.processContent(component, versionid)
        .then(function(result){
            console.log(result);
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success:",
                "message": result+" Records submitted for processing. Please check your email for completion.",
                "mode": "sticky",
                "type": "success"
            });
            toastEvent.fire(); 
        }).catch(function(error){
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
    
    deleteFile: function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    },
    
    viewResults: function(component,event,helper){
        var selecteddocumentId = event.currentTarget.id;        
       	var evt = $A.get("e.force:navigateToComponent");
    	evt.setParams({
        	componentDef : "c:BulkFileUploadResults",
        	componentAttributes: {
            	docuId : selecteddocumentId
       	 	}
	    });
    evt.fire();	
    },
    
    ExportResults:function(component,event,helper){  
        var documentId = event.currentTarget.id;      
        helper.ExportToCSV(component, documentId);
    },    
    
})
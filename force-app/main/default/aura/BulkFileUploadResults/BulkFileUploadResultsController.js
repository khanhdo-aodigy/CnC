({
	doInit:function(component,event,helper){  
        let docuId = component.get("v.docuId");
       	helper.getUploadedResults(component, docuId);
    },  
})
({
    onInit : function(component, event, helper) {
        document.title = "C&C Vehicle Delivery Certificate";
        component.set("v.recordID", helper.getURLRecordId('recordID'));
        component.set("v.finishedLoading", true);
    },
})
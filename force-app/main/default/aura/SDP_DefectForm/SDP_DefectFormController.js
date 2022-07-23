({
    doInit: function (component, event, helper) {
        document.title = "C&C Defect Form";
        let device = $A.get("$Browser.formFactor");
        component.set("v.deviceType", device);
        component.set("v.recordID", helper.getURLRecordId('recordID'));
        helper.initializeSalesAgreement(component.get("v.recordID"), component);
        console.log('Device: ' + device);
    },

    scriptsLoaded: function () {
        console.log('javaScript files loaded successful');
    },

    processStepChange: function (component, event, helper) {
        const processStepChanged = event.getParams();
        component.set("v.currentStage", processStepChanged.stage);
    }

})
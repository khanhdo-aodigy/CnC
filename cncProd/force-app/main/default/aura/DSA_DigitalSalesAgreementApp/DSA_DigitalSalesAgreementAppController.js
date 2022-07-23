({
    doInit: function (component, event, helper) {
        document.title = "C&C Digital Sales Agreement";
        component.set("v.recordID", helper.getURLRecordId('recordID'));
        helper.initializeSalesAgreement(component.get("v.recordID"), component);

//        helper.initializeSalesAgreement("a1qO000000207WJIAY", component);

    },

    handleChange: function (component, event, helper) {
        const dataReturn = event.getParams();
        dataReturn.Id = component.get("v.salesAgreementObject.Id");
        component.set("v.deltaChangesObj", dataReturn);
        component.find('processHeader').updateChangeList(dataReturn);
    },

    handleChangePage0: function(component, event, helper) {
        const dataReturn = event.getParams();
        dataReturn.Id = component.get("v.stockResObject.Id");
        component.set("v.deltaChangesStockResObj", dataReturn);
    },

    processStepChange: function(component, event, helper){
        const processStepChanged = event.getParams();

       
        if (processStepChanged.stage === 'RegistrationType') {
            processStepChanged.stage && component.set("v.currentStage", 'Customer');
            helper.createInitialSalesAgreement(processStepChanged.Id, component);
        } else {
            processStepChanged.stage && ( component.set("v.currentStage", processStepChanged.stage),
            component.find('processHeader').getElement().setCurrentStage(processStepChanged.stage));
        }

        typeof processStepChanged.isUsedCarAgrmnt !== 'undefined' && component.set("v.isUsedCarAgrmnt", processStepChanged.isUsedCarAgrmnt);

        typeof processStepChanged.recipientEmailForUCA !== 'undefined' && component.set("v.recipientEmailForUCA", processStepChanged.recipientEmailForUCA);

        typeof processStepChanged.recipientEmail !== 'undefined' && component.set("v.recipientEmail", processStepChanged.recipientEmail);

        typeof processStepChanged.enableDocuBtn !== 'undefined' && component.set("v.enableDocuButton", processStepChanged.enableDocuBtn);


    },

    updateDocuSignURL: function(component, event, helper){
        const generatedURL = event.getParams().generatedURL;
        component.set("v.docuSignURLLink", generatedURL);
    },

    handleErrors : function(component, event, helper){
        const errorMsg = event.getParams();
        component.set("v.hasErrors", true);
    },

    clearErrors : function(component,event, helper){
        component.set("v.hasErrors", false);
        component.set("v.errorMsg", '');
    },
    closeWindow : function(component,event, helper){
        window.close();
    }

})
({
    doInit : function(component, event, helper) {
        helper.init(component, event);
    },

    handleNavPage : function(component, event, helper) {
        helper.navPage(component, event);
    },

    handleCancel  : function(component, event, helper) {
        helper.cancel();
    },

    handleStep : function(component, event, helper) {
        let stage = event.getSource().get("v.value");
        console.log('value ' + stage);
        switch (stage) {
            case "1":
                component.set("v.progressStep", stage);
                break;
            case "2":
                // btnNm == 'previous' && component.set("v.progressStep", "1");
                component.set("v.progressStep", stage);
                break;
            default: break;
        }
    }
})
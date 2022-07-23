({
    doInit: function (component, event, helper) {
        //component.set("v.requestGenerateDocuUrl", false);
        helper.setTemplateIdForUsedCarAgmnt(component);
        helper.setTemplateId(component);
    },

    onGenerateDocuSign: function (component, event, helper) {
        component.set("v.signViaEmail", false);
        if (component.get("v.isUsedCarAgmnt") === true) {
            helper.fireVSMSAndDocu(component);
        } else {
            if (component.get("v.salesAgreementRecord.Proposed_Commission__c") === undefined || component.get("v.salesAgreementRecord.Proposed_Commission__c") === '') {
                component.set("v.openComissionPopUp", true);
            } else {
                console.log('fireVSMS')
                helper.fireVSMSAndDocu(component);
            }
        }
    },

    continueToDocuSign: function (component, event, helper) {
        component.set("v.openComissionPopUp", false);
        helper.fireVSMSAndDocu(component);
    },

    closeCommissionPopUp: function (component, event, helper) {
        component.set("v.openComissionPopUp", false);
    },

    onGenerateDocuSignViaEmail: function (component, event, helper) {
        component.set("v.signViaEmail", true);
        if (component.get("v.isUsedCarAgmnt") === true) {
            helper.fireVSMSAndDocu(component);
        } else {
            if (component.get("v.salesAgreementRecord.Proposed_Commission__c") === undefined || component.get("v.salesAgreementRecord.Proposed_Commission__c") === '') {
                component.set("v.openComissionPopUp", true);
            } else {
                console.log('fireVSMS')
                helper.fireVSMSAndDocu(component);
            }
        }
    },

    openDocuLink: function (component, event, helper) {
        window.open(component.get("v.signingURL"));
    },

    closeSalesAgreement: function (component, event, helper) {
        window.close();
    },


    generateDocuSign: function (component, event, helper) {
        //component.get('v.isSignUpCalled') === false && helper.signingProcess(component);
        if (component.get('v.isSignUpCalled') === false && component.get("v.finishedGenerating") === true) {
            helper.signingProcess(component);
        }  
    },

    generateDocuSignForUCA: function (component, event, helper) {
        if (component.get('v.isSignUpCalled') === false && component.get("v.finishedGeneratingForUCA") === true) {
            helper.signingProcessForUCA(component);
        }
    },

    handleTextDisplay: function (component, event, helper) {
        component.set("v.finishedText", ""); 
    },

    processStepChange: function (component, event, helper) {

        const cmpEvent = component.getEvent("navigationEvent");
        cmpEvent.setParams({
            "stage": event.getParams().stage
        });

        cmpEvent.fire();
    },

    callGenerator: function(cmp, event, helper) {
        console.log('***');
        $A.createComponent(
            "dfsle:Generator",
            {
                "templateId": "a1nO00000010TbXIAU",
                "recordId": "a1qO000000203G1IAI",
            },
            function(newCmp, status, errorMessage) {
                if (status === 'SUCCESS') {
                    console.log('Success calling Docusign Generator');
                } else {
                    console.log('Error calling Docusign Generator');
                }
            }
        )
    },

     // summonGEN118: function(component, event, helper) {
    //     $A.createComponent(
    //         "dsgen:generator",
    //         {
    //             "templateId": "a1nO00000010TbXIAU",
    //             "recordId": "a1qO000000203G1IAI",
    //         },
    //         function(newCmp, status, errorMessage) {
    //             if (status === 'SUCCESS') {
    //                 var docusignPlaceHolder = component.get("v.body");
    //                 docusignPlaceHolder.push(newCmp);
    //                 component.set("v.body", docusignPlaceHolder);
    //             } else {
    //                 $A.createComponent(
    //                     "aura:text", 
    //                     {"value": errorMessage},
    //                     function(textCmp, status, errorMessage) {
    //                         var docusignPlaceHolder = component.get("v.body");
    //                         docusignPlaceHolder.push(textCmp);
    //                         component.set("v.body", docusignPlaceHolder);
    //                     }
    //                 )
    //             }
    //         }
    //     );
    // },

    // summonGEN211: function(component, event, helper) {
    //     $A.createComponent(
    //         "dfsle:Generator",
    //         {
    //             "templateId": "a1nO00000010TbXIAU",
    //             "recordId": "a1qO000000203G1IAI",
    //         },
    //         function(newCmp, status, errorMessage) {
    //             if (status === 'SUCCESS') {
    //                 var docusignPlaceHolder = component.get("v.body");
    //                 docusignPlaceHolder.push(newCmp);
    //                 component.set("v.body", docusignPlaceHolder);
    //             } else {
    //                 $A.createComponent(
    //                     "aura:text", 
    //                     {"value": errorMessage},
    //                     function(textCmp, status, errorMessage) {
    //                         var docusignPlaceHolder = component.get("v.body");
    //                         docusignPlaceHolder.push(textCmp);
    //                         component.set("v.body", docusignPlaceHolder);
    //                     }
    //                 )
    //             }
    //         }
    //     );
    // },
})
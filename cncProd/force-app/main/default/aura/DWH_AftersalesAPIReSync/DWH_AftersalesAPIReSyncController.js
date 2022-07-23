({
    doInit: function (cmp, event, helper) {

    },

    handleDateChange: function (cmp, event, helper) {
        var fromDate = cmp.find('fromDate').get('v.value');
        var toDate = cmp.find('toDate').get('v.value');
		console.log(fromDate + ','+ toDate);
        if(fromDate != '' && toDate != ''){
            var fromDateValue = new Date(fromDate);
            var toDateValue = new Date(toDate);
            
            var formattedFromDateValue = fromDateValue.getDate() + '-' + (fromDateValue.getMonth() + 1) + '-' + fromDateValue.getFullYear();
            if(toDateValue.getTime() < fromDateValue.getTime()){
                cmp.set("v.errorMsg","Value must be " + formattedFromDateValue + " or later.");
                cmp.set('v.disabledBtn', true);
            }
            else{
                cmp.set("v.errorMsg","");
                cmp.set('v.disabledBtn', false);
            }
        }
        
    },

    callAPI: function (cmp, event, helper) {
        var fromDate = cmp.find('fromDate').get('v.value');
        var toDate = cmp.find('toDate').get('v.value');

        cmp.set("v.inputMode", false);
        cmp.set("v.spinner", true);
        cmp.set("v.errorfound", false);
        var action = cmp.get("c.getSyncAPIAgain");
        action.setParams({
            'fromDate' : fromDate,
            'toDate' : toDate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.spinner", false);
            }
            else if (state === "ERROR") {
                cmp.set("v.spinner", false);
                cmp.set("v.errorfound", true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }

})
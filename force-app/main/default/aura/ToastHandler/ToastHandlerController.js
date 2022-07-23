({
    handleResponse: function(component, event, helper) {
        let params = event.getParam('arguments');
        let response = params.response;
        let successHandler = params.successHandler;
        let errorHandler = params.errorHandler;

        let state = response.getState();

        if(state == 'SUCCESS') {
            if (successHandler) {successHandler(response);}
        }
        else {
            let message = helper.getErrorMessage(component, state, response);
            helper.showToast('Error', 'error', message);
            if(errorHandler) {errorHandler(response);}
        }
    },

    showToast: function(component, event, helper) {
        let params = event.getParam('arguments');
        let title = params.title;
        // can be error, warning, success, or info
        let type = params.type;
        let message = params.message;
        helper.showToast(title, type, message);
    },

    showToastError: function(component, event, helper) {
        let params = event.getParam('arguments');
        let title = params.title;
        let type = 'error';
        let message = params.message;
        helper.showToast(title, type, message);
    },

    showToastSuccess: function(component, event, helper) {
        let params = event.getParam('arguments');
        let title = params.title;
        let type = 'success';
        let message = params.message;
        helper.showToast(title, type, message);
    }
})
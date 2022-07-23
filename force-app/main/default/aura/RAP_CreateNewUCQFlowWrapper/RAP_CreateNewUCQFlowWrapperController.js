({
    init : function (component, event, helper) {
        
        helper.startCreateQuoteFlow(component);
    },

    handlePageChange : function(component, event, helper)
    {
        component.set('v.flowReady', false);

        window.setTimeout(
            $A.getCallback(function() {
                component.set('v.flowReady', true);
                helper.startCreateQuoteFlow(component);
            }), 500)
    },

    
})
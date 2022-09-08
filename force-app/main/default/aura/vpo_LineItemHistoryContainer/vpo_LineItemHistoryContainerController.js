({
    refreshView : function(component, event, helper) {
        console.log('mint');
        $A.get('e.force:refreshView').fire()
    }
})
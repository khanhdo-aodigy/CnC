({
    doInit: function(component, event, helper) {
        var myselected = component.get("v.fieldname"); // getting the value of component attribute using c notifier
        myselected = myselected.toString();
        var myrecordtype = component.get("v.recordtype");
        myrecordtype = myrecordtype.toString();
        
        var action = component.get("c.getPiklistValues");  
        action.setParams({ "casefieldname" : myselected, 
                          "recordtype" : myrecordtype}); // setting the arguments of server action
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.GenreList", plValues);
            }
        });
        $A.enqueueAction(action);
    },
     
    handleGenreChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.selectedGenreList", selectedValues);       
    },
     
    getSelectedGenre : function(component, event, helper){
        //Get selected Genre List on button click 
        var selectedValues = component.get("v.selectedGenreList");
        component.set("v.selectedGenreString", selectedValues.toString());       
       // console.log('Selected Genre-' + v.selectedGenreString);
    }
})
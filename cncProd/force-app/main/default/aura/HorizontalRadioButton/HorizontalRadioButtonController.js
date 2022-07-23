({
    doInit : function(component) {
        let optionLabelStr = component.get("v.optionLabels").split(',');
        let optionValueStr = component.get("v.optionValues").split(',');
        let options = component.get("v.options");

        for (let i = 0; i < optionLabelStr.length; i++) {
            let option = {};
            option.label = optionLabelStr[i];
            option.value = optionValueStr[i];
            options.push(option);
		}     
        component.set("v.options", options);
    },
    
    handleChangeButtonGroup:function(component, event){
          var selectedVal = component.get("v.selectedVal");
       	  console.log('selectedVal',selectedVal);
          component.set("v.selectedVal", selectedVal);     
    },
})
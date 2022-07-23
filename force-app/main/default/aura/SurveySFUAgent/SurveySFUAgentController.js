({
    onInit : function(component,event,helper){
         var headerActions = [
            {
                label: 'All',
                checked: true,
                name:'All'
            },
            {
                label: 'ELSC',
                checked: false,
                name:'ELSC'
            },
            {
                label: 'MBC',
                checked: false,
                name:'MBC'
            },
            {
                label: 'PLSC',
                checked: false,
                name:'PLSC'
            }, 
        ];
        //Setting up colum information
        component.set("v.sfuColums",
                      [
                          {
                              label: 'Action', type: 'button', initialWidth: 125, 
             					typeAttributes: 
             					{ 	label: 'Start Survey', 
              						name: 'start', 
              						title: 'Start Survey',
              						variant: 'Brand'}
                          },
                          {
                              label : 'Location',
                              fieldName : 'Loca',
                              type : 'text',
             				  actions: headerActions
                          },
                          {
                              label : 'CaseNumber',
                              fieldName : 'CaseNo',
                              type : 'text',
                          },
                          {
                            label : 'DoNotCallSurvey',
                            fieldName : 'DoNotCallSurvey',
                            type : 'boolean',
                            cellAttributes: { alignment: 'center' }
                          },
                          {
                              label : 'SurveyStatus',
                              fieldName : 'SurveyStatus',
                              type : 'text',
                          },
                          {
                              label : 'AdditionalRemarks',
                              fieldName : 'AddiRemarks',
                              type : 'text',
                          },
                          {
                              label : 'CallbackDate',
                              fieldName : 'CallbackDate',
                              type : 'date',
                          },
                          {
                              label : 'CallbackTime',
                              fieldName : 'CallbackTime',
                              type : 'Text',
                          },
                          {
                              label : '1st Call Date',
                              fieldName : 'firstCallDate',
                              type : 'Date',
                          },
                          {
                              label : '1st Call Time',
                              fieldName : 'firstCallTime',
                              type : 'Text',
                          },
                            {
                              label : '1st Call Status',
                              fieldName : 'firstCallStatus',
                              type : 'Text',
                          },
                        {
                              label : '2nd Call Date',
                              fieldName : 'secondCallDate',
                              type : 'Date',
                          },
                        
                          
                          {
                              label : '2nd Call Time',
                              fieldName : 'secondCallTime',
                              type : 'Text',
                          },
                            {
                              label : '2nd Call Status',
                              fieldName : 'secondCallStatus',
                              type : 'Text',
                          }
                      ]);
        // Call helper to set the data for case sfu table
        helper.getData(component);
    },
    
    handleLoadMore : function(component,event,helper){
        
        if(!(component.get("v.currentCount") >= component.get("v.totalRows"))){
            //To display the spinner
            event.getSource().set("v.isLoading", true); 
            //To handle data returned from Promise function
            helper.loadData(component).then(function(data){ 
                var currentData = component.get("v.sfuData");
                var newData = currentData.concat(data);
                component.set("v.sfuData", newData);
                //To hide the spinner
                event.getSource().set("v.isLoading", false); 
            });
        }
        else{
            //To stop loading more rows
            component.set("v.enableInfiniteLoading",false);
            event.getSource().set("v.isLoading", false);
            var toastReference = $A.get("e.force:showToast");
            toastReference.setParams({
                "type":"Success",
                "title":"Success",
                "message":"All SFU Survey records are loaded",
                "mode":"dismissible"
            });
            toastReference.fire();
        }
    },
    
    StartSurvey: function (component, event, helper) {
        var actionName = event.getParam('action').name;
        if ( actionName == 'start') {
            component.set("v.CaseIdForFlow", event.getParam('row').CaseId);
            var navigateEvent = $A.get("e.force:navigateToComponent");
  			navigateEvent.setParams({
   				componentDef:"c:SurveySFUFlow",
         		componentAttributes:{
            		CaseId: component.get("v.CaseIdForFlow")
            	} 
       		}); 
        	navigateEvent.fire(); 
         //   component.set("v.isOpen", true);
         //   var flow = component.find("sfuflow");
        //	var inputVar = [
        //  	{name:"vCaseId", type:"String", value:component.get("v.CaseIdForFlow")}
       // 	];
        //	flow.startFlow("SFU_Survey_Main_Screen",inputVar);
        }
    },
 
  
      handleHeaderAction: function (component, event, helper) {
        var actionName = event.getParam('action').name;
        var colDef = event.getParam('columnDefinition');
        var columns = component.get('v.sfuColums');
        var activeFilter = component.get('v.activeFilter');
        
        if (actionName !== activeFilter) {
            var idx = columns.indexOf(colDef);
            var actions = columns[idx].actions;
            actions.forEach(function (action) {
                action.checked = action.name === actionName;
            });
            component.set('v.activeFilter', actionName);
            if (actionName == 'All') {
              helper.getData(component);
        	}
        	if (actionName !== 'All') {
             helper.getDataByLoc(component);
            }
        }
    },
})
({
	FromdateChange: function(component, event, helper){
		console.warn("dateChange - from date");
		var vfromdate = component.get("v.fromdate");
		console.warn("from date is: ", vfromdate);
	},

	TodateChange: function(component, event, helper){
		console.warn("dateChange - to date");
		var vtodate = component.get("v.todate");
		console.warn("to date is: ", vtodate);
	}, 


	// this function automatic call by aura:waiting event  
	showSpinner: function(component, event, helper) {
		// make Spinner attribute true for display loading spinner 
		component.set("v.Spinner", true); 
	},

	// this function automatic call by aura:doneWaiting event 
	hideSpinner : function(component,event,helper){
		// make Spinner attribute to false for hide loading spinner    
		component.set("v.Spinner", false);
	},


	clickCreateItem : function(component, event, helper) 
	{       
		var vfromdate = component.get("v.fromdate");
		var vtodate = component.get("v.todate");
		
		var myFromDate=vfromdate;
		var myToDate=vtodate;
		var mysvcctrs="";
		var myBtype1="";
		var myBtype2="";
		var myBtype3="";
		var myBtype4="";
		var mySvcType="";
		var mySCR="";
		var myIncx = "0";
		var mychoice="";
		var vsvcctrs;
		var vbtype;
		
		
		var opts = component.get("v.radioValue");
		
		if ((opts === "Create") || (opts === "Booking"))
		{
			var els1 = document.querySelectorAll('input[name="svcctrschoice"]:checked');
			
			for(var i = 0; i< els1.length; i++)
			{
				if (els1[i].value === "checkbox-1")
					{
						vsvcctrs="MBEL";
					}
					
				if (els1[i].value === "checkbox-2")
					{
						vsvcctrs="MBMBC";
								
					}
				
				if (els1[i].value === "checkbox-3")
					{
						vsvcctrs="MBPL";
					}
				
				if (i===0)
				{
					mysvcctrs = vsvcctrs;		
				}
				else
				{
					mysvcctrs = mysvcctrs + ',' + vsvcctrs;
				}
			}
		
			if (opts === "Create")
			{
				mychoice = opts;
				
				// SCR Selection here...
				var els2 = document.querySelectorAll('input[name="SCROption1"]:checked');
				for(var i = 0; i< els2.length; i++)
				{
					if (els2[i].value === "radio-13")
					{
						mySCR="1";
					}
					
					if (els2[i].value === "radio-14")
					{
						mySCR="2";
					}
				
					if (els2[i].value === "radio-15")
					{
						mySCR="3";
					}
				}
				
				// Booking Type Selection here...
				var els3 = document.querySelectorAll('input[name="btypesel"]:checked');
				if(els3.length===0)
				{
					myBtype1="All";
					helper.calltocbs(component, event, helper, myFromDate, myToDate, mysvcctrs, myBtype1, myBtype2, myBtype3, myBtype4, mySvcType, mySCR, myIncx, mychoice)               		
					.then(function(result) 
					{
						console.log(result);
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Success:",
							"message": result+" cases have been created",
							"mode": "sticky",
							"type": "success"
						});
						toastEvent.fire();            
					})
					.catch(function(error) 
					{
						console.log(error);
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error:",
							"message": error[0].message,
							"mode": "sticky",
							"type": "error"
						});
						toastEvent.fire();
					})
				} 	
				else 
				{
					for(var i = 0; i< els3.length; i++)
					{
						if (els3[i].value === "checkbox-16")
						{
							//vbtype="Internet";
							myBtype1="Internet";
						}
						if (els3[i].value === "checkbox-17")
						{
							//vbtype="iOS App";
							myBtype2="iOSApp";
						}		
						if (els3[i].value === "checkbox-18")
						{
							//vbtype="Android App";
							myBtype3="AndroidApp";
						}
						if (els3[i].value === "checkbox-19")
						{
							myBtype4="CI";
						}
						//   if (i===0){
						//     myBtype = vbtype;
						// 	}else{
						// 		myBtype = myBtype + ',' + vbtype;} 
					}
			
					helper.calltocbs(component, event, helper, myFromDate, myToDate, mysvcctrs, myBtype1, myBtype2, myBtype3, myBtype4, mySvcType, mySCR, myIncx, mychoice)               		
					.then(function(result) 
					{
						console.log(result);
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Success:",
							"message": result+" cases have been created",
							"mode": "sticky",
							"type": "success"
						});
						toastEvent.fire();            
					})
					.catch(function(error) 
					{
						console.log(error);
						let toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error:",
							"message": error[0].message,
							"mode": "sticky",
							"type": "error"
						});
						toastEvent.fire();
					})	
				}
			}  
				
			if (opts === "Booking")
			{
				mychoice = opts;
				myBtype1="All";
				
				// SCR Selection here...
				var els4 = document.querySelectorAll('input[name="SCROption2"]:checked');
				for(var i = 0; i< els4.length; i++)
				{
					if (els4[i].value === "radio-23")
					{
						mySCR="1";
					}
					
					if (els4[i].value === "radio-24")
					{
						mySCR="2";
					}
				
					if (els4[i].value === "radio-25")
					{
						mySCR="3";
					}
				} 
				
				helper.calltocbs(component, event, helper, myFromDate, myToDate, mysvcctrs, myBtype1, myBtype2, myBtype3, myBtype4, mySvcType, mySCR, myIncx, mychoice) 
				.then(function(result) 
				{
					console.log(result);
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Success:",
						"message": result+" cases have been created",
						"mode": "sticky",
						"type": "success"
					});
					toastEvent.fire();            
				})
				.catch(function(error) 
				{
					console.log(error);
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Error:",
						"message": error[0].message,
						"mode": "sticky",
						"type": "error"
					});
					toastEvent.fire();
				})	
			}
		}  
	}
});
({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    
    getuploadedFiles:function(component){
        var action = component.get("c.getFiles");  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "sdocumentId":documentId            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getuploadedFiles(component);
                component.set("v.Spinner", false); 
            }  
        });  
        $A.enqueueAction(action);  
    },  
    
    processContent : function(component, versionid) {
        component.set("v.Spinner", true); 
        let p = new Promise($A.getCallback(function(resolve, reject) { 
        let action = component.get("c.processdata");           
        action.setParams({
            "sversionId":versionid            
        });  
        action.setCallback(this,function(response){  
            if(response.getState()=='SUCCESS'){
               	 component.set("v.Spinner", false); 
                 resolve(response.getReturnValue());
            }else if(response.getState() == 'ERROR'){
                console.log('Error: ', response.getError()); 
                reject(response.getError());
            }
         });  
        $A.enqueueAction(action);  
        }));
    	return p;
     }, 
    
     ExportToCSV:function(component, documentId){
        var action = component.get("c.fetchResults");  
        action.setParams({
            "sdocumentId":documentId            
        });   
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();     
                console.log(result);
                component.set("v.failresults",result);
                var objectRecords = component.get("v.failresults");
                console.log(objectRecords);
                var csv = this.convertArrayOfObjectsToCSV(component,objectRecords);
                if (csv == null){return;} 

        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
         		var hiddenElement = document.createElement('a');
          		hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          		hiddenElement.target = '_self'; // 
          		hiddenElement.download = 'BulkFileUpload_Failed.csv';  // CSV file Name* you can change it.[only name not .csv] 
          		document.body.appendChild(hiddenElement); // Required for FireFox browser
          		hiddenElement.click(); // using click() js function to download csv file
            }else if(response.getState() == 'ERROR'){
                console.log('Error: ', response.getError()); 
                reject(response.getError());
            }
         });  
        $A.enqueueAction(action);  
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
     //   var objRecords = objRecordsParm;
        var csvStringResult, counter, keys, columnDivider, lineDivider;
      // 	var objectRecords = component.get("v.failresults");
      //  alert(component.get("v.failresults"));
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['DocumentId__c','Name', 'Lead_Source__c', 
                'First_Name__c','Last_Name__c','Mobile__c','Email__c','Models_interested__c', 
                'Event_Date__c', 'Event_Time__c', 'Branch_Code__c', 'Preferred_Sales_Consultant__c',
                'Showroom__c', 'No_of_Pax__c', 'Event_Name__c', 'Reason__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               //csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               if(objectRecords[i][skey] != undefined){
					csvStringResult += '"'+ objectRecords[i][skey]+'"';
				}else{
					csvStringResult += '"'+ '' +'"';	
				}
                 
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
})
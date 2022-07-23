/*
	Author: Hari Panneerselvam
	Description: TriggerHandlerCase is a handler class for Case trigger.
*/
public class TriggerHandlerCase {
	
	public list<Case> lstCaseInContext {get; set;}
    public map<Id, Case> mapOldCaseInContext {get; set;}
    public BusinessRulesHandlerCase caseBR {get; set;}
    
   
    //Constructor defined from Case trigger.
    public TriggerHandlerCase(list<Case> lstCaseFromTrigger, map<Id, Case> mapCaseFromTrigger){
        //Pass TriggerHandlerCase reference to BusinessRulesHandlerCase class
        caseBR = new BusinessRulesHandlerCase(this);
        
        lstCaseInContext = new list<Case>();
        mapOldCaseInContext = new map<Id, Case>();
        
        lstCaseInContext = lstCaseFromTrigger;
        mapOldCaseInContext = mapCaseFromTrigger;
        
        //[MASTER SOQL]Prefetch all the content needed for the trigger to process. 
        caseBR.preFetchTriggerContent();
        
        //Context-Based business rule.
		defineContext();   
    }
    
    //Context-Based business rule.
    public void defineContext(){
        if(trigger.isBefore){
            if(trigger.isInsert){ 
            	caseBR.caseBeforeInsert();
            }
            if(trigger.isUpdate){
            	caseBR.caseBeforeUpdate();
            }
        }
        
        if(trigger.isAfter){
            if(trigger.isInsert){
             	caseBR.caseAfterInsert();
            }
            if(trigger.isUpdate){
            	caseBR.caseAfterUpdate();
            }
        }
        
    }
    
}
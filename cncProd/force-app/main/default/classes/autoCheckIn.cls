/****************************************
* Class Name: autoCheckIn
* Description: Used for Test Drives to auto check-in,
* 				in case the consultants forgot to.
* 
* Revision History:
* Developer Name		Date 			Description
* CGaylan				05-July-2019	Auto-checkin for SC only
***************************************/ 
public without sharing class autoCheckIn Implements Schedulable
{
    //Scheduler
    public void execute(SchedulableContext sc){
        autoCheck();
    }
    
    /****************************************
    * Method Name: autoCheck
    * Description: Auto-checkin the Test Drive vehicle
    * 
    * Parameter: N/A
    * Return:	N/A
    ***************************************/ 
    public void autoCheck(){
        try{
            Set<String> excludeSet = new Set<String>();
            //get profiles to exclude
            for(ExclusionList__mdt exC : [SELECT Id, Label, Module__c 
                                          FROM ExclusionList__mdt 
                                          WHERE Module__c='autoCheckin'])
            {
                excludeSet.add(exC.Label);
            }
            
            Date today=date.today();
            List<Test_Drive__c> tstDriveList = new List<Test_Drive__c>();
            tstDriveList = [SELECT Id, 
                            Status__c, 
                            Check_In__c ,
                            Owner.Profile.Name
                            FROM Test_Drive__c 
                            WHERE Date__c= :today 
                            AND Status__c !='In' 
                           	AND Owner.Profile.Name NOT IN :excludeSet];
            
            if(!tstDriveList.isEmpty()){
                for(Test_drive__c temp : tstDriveList){
                    temp.Status__c= 'In';
                    temp.Check_In__c = DateTime.now();
                }
                update tstDriveList;
            }
        }catch(Exception e){
            loggerDataPool.buildLogDataPool('autoCheckIn', e);
        }
        
    }
}
/** ******
* Description: Tool Actions
* 
* Change History:
* Date(YYYYMMDD)      Name        		    Description
* yyyymmdd            nguyen.thang          Created Initial Version.
* 
** ******/

public class specialToolController {
    
    @AuraEnabled
    public static User getRunningUser(){
        User runningUsr = [Select Name, UserRole.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];  
        return runningUsr;
    }
    
    @AuraEnabled
    public static Workshop_Technician__c getUserInfo(String accessCode){
        try{     
            Workshop_Technician__c userInfo = [Select Name, Department__c, Location__c From Workshop_Technician__c 
                                               Where Access_code__c = :accessCode LIMIT 1];  
            return userInfo;         
        }
        catch(Exception e){
            return null;  
        }
    }
    
    /*@AuraEnabled
    public static Object getTool(String partNo){
        try{
            Special_Tool__c tool = [Select Id, Part_Number__c, Name, Remarks__c, Available__c, Service_Centre__c From Special_Tool__c 
                                    Where Part_Number__c = :partNo LIMIT 1];  
            if(tool.Available__c){      
                return tool;
            }else{
                return 'ToolNotAvailable';
            }    
        }
        catch(Exception e){
            return 'Empty';  
        }
    }*/

    /**
     * ADDED BY THIEU DANG VU - 22/10/2021
     * Part No is not unique identifier anymore
     */
    @AuraEnabled
    public static List<Special_Tool__c> getTool(String partNo) {

        return [SELECT Id, Part_Number__c, Name, Remarks__c, Available__c, Service_Centre__c 
                FROM Special_Tool__c 
                WHERE Part_Number__c = :partNo AND Available__c = true AND Status__c = 'VALID'
                ORDER BY Id];
    }
    
    @AuraEnabled
    public static List<Special_Tool_Booking__c> borrowTools(String userId, List<Special_Tool__c> tools){
        try{
            List<Special_Tool_Booking__c> stbToInsert = new List<Special_Tool_Booking__c>();
            Set<Id> toolIds = new Set<Id>();
            for(Special_Tool__c tool: tools){
                if(tool.Available__c){
                    Special_Tool_Booking__c stb = new Special_Tool_Booking__c();
                    stb.Borrowed_By__c = userId;
                    stb.Loan_Status__c = 'Borrowed';
                    stb.Special_Tool__c = tool.Id;
                    stb.Borrowed_Location__c = tool.Service_Centre__c;
                    stb.Borrow_DateTime__c = system.now();
                    stbToInsert.add(stb);
                    toolIds.add(tool.Id);
                }
            }
            
            if(!stbToInsert.isEmpty()){
                insert stbToInsert;   
                List<Special_Tool__c> stl = [SELECT Id, Available__c FROM Special_Tool__c WHERE Id IN: toolIds];
                for(Special_Tool__c st: stl){
                    st.Available__c = false;
                }
                update stl;
            }
            
            List<Special_Tool_Booking__c> toolsBorrowedByUser = [SELECT Id, Borrowed_By__r.Name, Borrow_DateTime__c, Borrowed_Location__c,
                                                                 Special_Tool__r.Id, Special_Tool__r.Part_Number__c, Special_Tool__r.Name, Special_Tool__r.Remarks__c
                                                                 FROM Special_Tool_Booking__c 
                                                                 WHERE Borrowed_By__c = : userId AND Loan_Status__c = 'Borrowed' 
                                                                 AND Special_Tool__r.Id IN: toolIds];
            return toolsBorrowedByUser;
        }
        catch(Exception e){
            return null;  
        }    
    }
    
    /*@AuraEnabled
    public static Object getToolBooking(String partNo){
        try{        
            Special_Tool__c tool = [Select Id, Part_Number__c, Name, Available__c From Special_Tool__c Where Part_Number__c = :partNo LIMIT 1]; 
            if(tool.Available__c){
                return 'ToolIsAvailable';
            }
            Special_Tool_Booking__c toolBooking = [SELECT Id, Borrowed_By__r.Name, Borrow_DateTime__c, Borrowed_Location__c,
                                                   Special_Tool__r.Id, Special_Tool__r.Part_Number__c, Special_Tool__r.Name, Special_Tool__r.Remarks__c
                                                   FROM Special_Tool_Booking__c 
                                                   WHERE Special_Tool__r.Part_Number__c = : partNo AND Loan_Status__c = 'Borrowed' LIMIT 1];
            return toolBooking; 
        }
        catch(Exception e){
            return 'Empty';  
        }
    }*/

    /**
     * ADDED BY THIEU DANG VU - 22/10/2021
     * Part No is not unique identifier anymore
    */
    @AuraEnabled
    public static List<Special_Tool_Booking__c> getToolBooking(String partNo, String userId) {

        return [SELECT Id, Borrowed_By__r.Name, Borrow_DateTime__c, Borrowed_Location__c,
                        Special_Tool__r.Id, Special_Tool__r.Part_Number__c, Special_Tool__r.Name, Special_Tool__r.Remarks__c
                FROM Special_Tool_Booking__c 
                WHERE Special_Tool__r.Part_Number__c = : partNo AND Loan_Status__c = 'Borrowed' AND Borrowed_By__r.Id = :userId];
    }
    
    @AuraEnabled
    public static void returnTool(String userId, List<Special_Tool_Booking__c> toolBookings, String location){
        Set<Id> toolIds = new Set<Id>();
        for(Special_Tool_Booking__c stb: toolBookings){
            stb.Loan_Status__c = 'Returned';
            stb.Returned_By__c = userId;
            stb.Return_DateTime__c = system.now();
            stb.Returned_Location__c = location;
            toolIds.add(stb.Special_Tool__r.Id);
        }
        update toolBookings;
        
        if(!toolIds.isEmpty()){
            List<Special_Tool__c> stls = [SELECT Id, Available__c FROM Special_Tool__c WHERE Id IN :toolIds];
            for(Special_Tool__c tool:stls){
                tool.Available__c = true;
            } 
            update stls;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPickListLocation(){
        List<String> values = new List<String>();
        Schema.DescribeFieldResult fieldResult = Special_Tool__c.Service_Centre__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            values.add(pickListVal.getLabel());
        }     
        return values;
    }   
    
}
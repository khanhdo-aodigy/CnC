/** ******
* Description: Tess Class for specialToolController
* 
* Change History:
* Date(YYYYMMDD)      Name        		    Description
* 20210827            nguyen.thang          Created Initial Version.
* 
** ******/

@isTest
public class SpecialToolControllerTest {
    
    @isTest
    private static void test_SpecialTool(){
        
        //get Location of Service Centre (global picklist)
        List<String> locations = specialToolController.getPickListLocation();
        
        // create Data
        Workshop_Technician__c wt = new Workshop_Technician__c(Name = 'TestWT', Access_Code__c = '123456', Location__c= locations[1]);
        insert wt;
        //Special_Tool_Type__c stt = new Special_Tool_Type__c(Name='hammer');
        //insert stt;
        Special_Tool__c st = new Special_Tool__c(Part_Number__c='12321', /*Special_Tool_Type__c = stt.Id,*/ Service_Centre__c= locations[1], Status__c ='VALID', Available__c = true);
        insert st;
        Special_Tool__c st2 = new Special_Tool__c(Part_Number__c='12345', /*Special_Tool_Type__c = stt.Id,*/ Service_Centre__c= locations[1], Status__c ='VALID', Available__c = false);
        insert st2;
        Special_Tool__c st3 = new Special_Tool__c(Part_Number__c='10101', /*Special_Tool_Type__c = stt.Id,*/ Service_Centre__c= locations[1], Status__c ='VALID', Available__c = true);
        insert st3;
        
        Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%'];
        User runningUser = new User(Alias = 'ksa2', Branch_Code__c='CCK',Franchise_Code__c='KIAPC',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo2@andomdemodomain.com');
        insert runningUser;
        
        System.RunAs(runningUser) {
            //get Administrator Information
            specialToolController.getRunningUser();
            
            //get Technician Information with Wrong Access Code
            Workshop_Technician__c technician = specialToolController.getUserInfo('12345');
            System.assertEquals(null, technician, 'technician should be null');

            //get Technician Information
            technician = specialToolController.getUserInfo('123456');
            System.assertNotEquals(null, technician, 'technician should not be null');

            //get Tool with Wrong Part No.
            List<Special_Tool__c> toolAvailable = specialToolController.getTool('11111');
            System.assertEquals(0, toolAvailable.size(), 'no tool returned');

            //get Unavailable Tool - Toast Error
            specialToolController.getTool('12345');
            System.assertEquals(0, toolAvailable.size(), 'no tool returned');

            Special_Tool__c toolReturned = (Special_Tool__c)specialToolController.getTool('12321')[0];
            
            List<Special_Tool__c> stListToBorrow = new List<Special_Tool__c>();
            stListToBorrow.add(toolReturned);
            
            //borrow Tools successfully
            List<Special_Tool_Booking__c> bookedTools = specialToolController.borrowTools(technician.Id,stListToBorrow);
            System.assertNotEquals(0, bookedTools.size(), 'tool booking made');

            //1 new Special Tool Booking is created after 1 tool is borrowed
            List<Special_Tool_Booking__c> toolsBorrowed = [SELECT Id FROM Special_Tool_Booking__c];
            System.assertEquals(1, toolsBorrowed.size());
            
            //get Tool Booking with Wrong Part No.
            List<Special_Tool_Booking__c> returnedBookings = specialToolController.getToolBooking('11111', technician.Id);
            System.assertEquals(0, returnedBookings.size(), 'no booking returned');
            
            //get Tool Booking which is still available - Toast Error
            returnedBookings = specialToolController.getToolBooking('10101', technician.Id);
            System.assertEquals(0, returnedBookings.size(), 'no booking returned');

            Special_Tool_Booking__c stb = (Special_Tool_Booking__c) specialToolController.getToolBooking('12321', technician.Id)[0];
            List<Special_Tool_Booking__c> stbListToReturn = new List<Special_Tool_Booking__c>();
            stbListToReturn.add(stb);
            
            //return Tools
            specialToolController.returnTool(technician.Id, stbListToReturn, locations[0]);
            
        }
        Test.StopTest();
    }
}
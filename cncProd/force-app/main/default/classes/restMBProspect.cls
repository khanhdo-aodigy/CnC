/*******
 * Description : API class for MB prospect creation
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200624             NSJ       Created Initial Version 
*******/

@RestResource (urlMapping = '/upsertMBProspect/*')
global class restMBProspect 
{
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static mbProspectWrapper reqBody = new mbProspectWrapper();
    //private static MB_Prospect__c mbProspectObj = new MB_Prospect__c();
    private static Map<String, Object> responseMap = new Map<String, Object>();
    
    @HttpPost
    global static void doPost() 
	{
        res.addHeader('Content-Type', 'application/json');
        
        try 
		{  
            
            createMBProspect();    
            
        }
		catch(Exception e) 
		{
            loggerDataPool.buildLogDataPool('restMBProspect', e);
            errorResponse = new Utility.httpErrorResponse('Failed', e.getMessage());
            
        }
        
        if(errorResponse != null && errorResponse.status == 'Failed') 
		{    
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('MBProspect', 'restMBProspect', '', req, res);
    }
    
    public static void createMBProspect() {
        reqBody = (mbProspectWrapper)JSON.deserialize(req.requestBody.toString(), mbProspectWrapper.class);

        MB_Prospect__c newMbProspectObj = new MB_Prospect__c();
		newMbProspectObj.AddressLine1__c				= reqBody.AddressLine1;
		newMbProspectObj.AddressLine2__c				= reqBody.AddressLine2;
		newMbProspectObj.AddressLine3__c				= reqBody.AddressLine3;
		newMbProspectObj.AddressLine4__c				= reqBody.AddressLine4;
		newMbProspectObj.Current_Vehicle_Number__c		= reqBody.CurrentVehicleNumber;
		newMbProspectObj.Customer_Full_Name__c			= reqBody.CustomerName;
		newMbProspectObj.Date_of_Birth__c				= reqBody.DateOfBirth;
		newMbProspectObj.DateTime_of_Submission__c		= reqBody.DateTimeOfSubmission;
		newMbProspectObj.Email_Address__c				= reqBody.EmailAddress;
		newMbProspectObj.Mobile_Number__c				= reqBody.MobileNumber;
		newMbProspectObj.Postalcode__c					= reqBody.PostalCode;
		newMbProspectObj.Preferred_SC__c				= reqBody.PreferredSC;
		newMbProspectObj.Promotion_name__c				= reqBody.PromotionName;
		newMbProspectObj.Testdrive_DateTime__c			= reqBody.TestDriveDateTime;
		newMbProspectObj.Testdrive_Model__c				= reqBody.TestDriveModel;
		newMbProspectObj.Trade_In__c					= reqBody.TradeIn;
		newMbProspectObj.Type__c						= reqBody.EventType;
		newMbProspectObj.Spare_Date_Field_1__c			= reqBody.SpareDateField1;
		newMbProspectObj.Spare_Date_Field_2__c			= reqBody.SpareDateField2;
		newMbProspectObj.Spare_Number_Field_1__c		= reqBody.SpareNumberField1;
		newMbProspectObj.Spare_Number_Field_2__c		= reqBody.SpareNumberField2;
		newMbProspectObj.Spare_Text_Field_1__c			= reqBody.SpareTextField1;
		newMbProspectObj.Spare_Text_Field_2__c			= reqBody.SpareTextField2;
		newMbProspectObj.Spare_Text_Field_3__c			= reqBody.SpareTextField3;
		newMbProspectObj.Spare_Text_Field_4__c			= reqBody.SpareTextField4;
		newMbProspectObj.Spare_Text_Field_5__c			= reqBody.SpareTextField5;
		newMbProspectObj.Spare_Text_Field_6__c			= reqBody.SpareTextField6;
        
        insert newMbProspectObj;

        responseMap.put('status', 'Success');

        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

   

    public class mbProspectWrapper 
	{		
		public String PromotionName;
		public String EventType;
		public String CustomerName;
		public String MobileNumber;
		public String EmailAddress;
		public String PreferredSC;
		public String TradeIn;
		public Date DateOfBirth;
		public String TestDriveModel;
		public DateTime TestDriveDateTime;
		public String AddressLine1;
		public String AddressLine2;
		public String AddressLine3;
		public String AddressLine4;
		public String PostalCode;
		public String CurrentVehicleNumber;
		public DateTime DateTimeOfSubmission;		  

		public String SpareTextField1;
		public String SpareTextField2;
		public String SpareTextField3;
		public String SpareTextField4;
		public String SpareTextField5;
		public String SpareTextField6;
		public Decimal SpareNumberField1;
		public Decimal SpareNumberField2;
		public Date SpareDateField1;
		public Date SpareDateField2;

    }
    

}
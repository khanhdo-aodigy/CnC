//Apex class to Update Alerts Status 
@RestResource(urlMapping='/UpsertServiceAppointment/v1/*')
global with sharing class UpsertServiceAppointment 
{
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;  
    private static Map<String, Object> mapJSONBody = new map<String, Object>();
    
    @HttpPost
    global static void updateAlerts()    
    {   		
        string errorMsg = '';
        List<SObject>  returnObject = new List<SObject>();
        List<Contact> contactList = new List<Contact>();
        List<Registered_Vehicle__c> regVehicleList = new List<Registered_Vehicle__c>();
        RestContext.response = res;
        Service_Appointment__c serviceAppointment; 
        Service_Appointment__c [] serviceAppointmentList; 
        Map<String, String> responseMap = new Map<String, String>();
        
        try
        {
            mapJSONBody = (map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            String registrationNumber = mapJSONBody.containsKey('registrationNumber') ? (String)mapJSONBody.get('registrationNumber') : '';
            String action    = mapJSONBody.containsKey('action') ? (String)mapJSONBody.get('action') : '';
            String bookingId = mapJSONBody.containsKey('bookingId') ? (String)mapJSONBody.get('bookingId') : '';
            String nric      = mapJSONBody.containsKey('nric') ? (String)mapJSONBody.get('nric') : '';
            String remarks   = mapJSONBody.containsKey('remarks') && String.isNotBlank((String)mapJSONBody.get('remarks')) ? (String)mapJSONBody.get('remarks') : '-';

			string orderID   = mapJSONBody.containsKey('orderID') ? (String)mapJSONBody.get('orderID') : '';
			string brand     = mapJSONBody.containsKey('Brand') ? (String)mapJSONBody.get('Brand') : '';

			Datetime appointmentDateTime;
            if( mapJSONBody.containsKey('appointmentDateTime') )
			{
                appointmentDateTime = (DateTime)JSON.deserialize('"'+ mapJSONBody.get('appointmentDateTime') +'"', DateTime.class) ;
            }

            String location          = mapJSONBody.containsKey('location') ? (String)mapJSONBody.get('location') : '';
            String serviceType       = mapJSONBody.containsKey('serviceType') ? (String)mapJSONBody.get('serviceType') : '';
            String mileage           = mapJSONBody.containsKey('mileage') && String.isNotBlank((String)mapJSONBody.get('mileage')) ? (String)mapJSONBody.get('mileage') : '-';
            String serviceCentreName = mapJSONBody.containsKey('serviceCentreName') ? (String)mapJSONBody.get('serviceCentreName') : '';
            String NonOwnerName      = mapJSONBody.containsKey('NonOwnerName') ? (String)mapJSONBody.get('NonOwnerName') : '';
            String NonOwnerEmail     = mapJSONBody.containsKey('NonOwnerEmail') ? (String)mapJSONBody.get('NonOwnerEmail') : '';
            String NonOwnerPhoneNumber = mapJSONBody.containsKey('NonOwnerPhoneNumber') ?  (String)mapJSONBody.get('NonOwnerPhoneNumber') : '';
           
			String bookingSource = mapJSONBody.containsKey('bookingSource') ? (String)mapJSONBody.get('bookingSource') : '';
			String serviceName = mapJSONBody.containsKey('serviceName') ? (String)mapJSONBody.get('serviceName') : '';

            //Enhanced Booking Flow Project
            //additional fields
            List<AddOn> addOns = mapJSONBody.get('addOns') == null ? null : (List<AddOn>)JSON.deserialize(JSON.serialize(mapJSONBody.get('addOns')), List<AddOn>.class);

            Datetime pickupTime;
            if ( mapJSONBody.containsKey('pickupTime') && String.isNotBlank((String)mapJSONBody.get('pickupTime')) ) 
            {
                pickupTime = (Datetime)JSON.deserialize('"'+ mapJSONBody.get('pickupTime') +'"', DateTime.class) ;
            }

            String tempPickUpFrom = mapJSONBody.containsKey('pickupFrom') && String.isNotBlank((String)mapJSONBody.get('pickupFrom')) ? (String)mapJSONBody.get('pickupFrom') : '';
            String pickupFrom     = String.isNotBlank(tempPickUpFrom) ? (tempPickUpFrom.substring(0, tempPickUpFrom.indexOf(tempPickUpFrom.right(6))) + ' SINGAPORE ' + tempPickUpFrom.right(6)) : '-';

            String tempReturnTo = mapJSONBody.containsKey('returnTo') && String.isNotBlank((String)mapJSONBody.get('returnTo')) ? (String)mapJSONBody.get('returnTo') : '';
            String returnTo     = String.isNotBlank(tempReturnTo) ? (tempReturnTo.substring(0, tempReturnTo.indexOf(tempReturnTo.right(6))) + ' SINGAPORE ' + tempReturnTo.right(6)) : '-';
            
            String pkdIndicator = mapJSONBody.containsKey('pkdIndicator') ? (String)mapJSONBody.get('pkdIndicator') : '';
            //

			Boolean eShopFlag = false;
            if( mapJSONBody.containsKey('eShopFlag') )
			{
                eShopFlag = Boolean.valueOf(mapJSONBody.get('eShopFlag'));
            } 

			Boolean doNotSendNotification  = false;
            if( mapJSONBody.containsKey('doNotSendNotification') )
			{
                doNotSendNotification = Boolean.valueOf(mapJSONBody.get('doNotSendNotification'));
            } 		   
		   		   
		    Boolean IsNonOwner = false;
            if( mapJSONBody.containsKey('IsNonOwner') )
			{
                IsNonOwner = Boolean.valueOf(mapJSONBody.get('IsNonOwner'));
            } 
            String Branch = mapJSONBody.containsKey('Branch') ? (String) mapJSONBody.get('Branch') : ''; 
            
            System.debug(String.isBlank(action)+ '||'+ String.isBlank(bookingId)+ '||'+ String.isBlank(registrationNumber));
            System.debug(action+ '||'+bookingId+ '||'+ registrationNumber);

            if( String.isBlank(action) || String.isBlank(bookingId) || String.isBlank(registrationNumber)) 
            {     
                responseMap.put('Message', 'Mandatory field(s) are missing. Please refer API doc');
                responseMap.put('ErrorCode', 'Err02-SF');
                res.statusCode = 400;
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));   
                return;
            }

            Contact tempcontact = new Contact();
            List<Contact> tempCN = new List<Contact >();

            List<Registered_Vehicle__c > tempRV = new List<Registered_Vehicle__c >();
            tempRV = [SELECT Contact__c, Contact__r.Name, Account__c, Account__r.Name 
                      FROM Registered_Vehicle__c
                      WHERE Registration_Number__c = :registrationNumber LIMIT 1];            
            
            //select alert record based on alert id.  
            serviceAppointment =  new Service_Appointment__c();
            serviceAppointment.Name = bookingId;
            serviceAppointment.Booking_ID__c = bookingId;
            serviceAppointment.Action__c = action;
            serviceAppointment.Car_Registration_No__c = registrationNumber;
            serviceAppointment.Customer_Remarks__c = remarks;
            serviceAppointment.Service_Appointment_Date_Time__c = appointmentDateTime;
            serviceAppointment.Service_Centre_Location__c = location;
            serviceAppointment.Service_Code__c = serviceType; 
			serviceAppointment.OrderID__c = orderID;
			serviceAppointment.Brand__c = brand;
			serviceAppointment.Booking_Source__c = bookingSource;
			serviceAppointment.Service_Name__c = serviceName;
			serviceAppointment.eShop_Flag__c = eShopFlag;
			serviceAppointment.Do_not_send_notification_to_Customer__c = doNotSendNotification;

            //Enhanced Booking Flow Project
            //additional fields
            serviceAppointment.Pick_up_Time__c = pickupTime;
            serviceAppointment.Pick_up_From__c = pickupFrom;
            serviceAppointment.Return_To__c    = returnTo;
            serviceAppointment.PKD_Indicator__c= pkdIndicator;
            //End

			//default assign serviceAppointment.RecordType  
			serviceAppointment.RecordTypeId = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Service Appointment - Customer').getRecordTypeId();  
            if(IsNonOwner != null && IsNonOwner) 
			{
                if(String.isBlank(NonOwnerName))
				{
					if(tempRV[0].Account__c != null)
					{
						serviceAppointment.Non_Owner_Name__c = tempRV.get(0).Account__r.Name ;
					}
					else
					{
						serviceAppointment.Non_Owner_Name__c = tempRV.get(0).Contact__r.Name ;
					}
                }
				else
				{
                    serviceAppointment.Non_Owner_Name__c = NonOwnerName;
                }
                
                serviceAppointment.Non_Owner_Email__c = NonOwnerEmail;
                serviceAppointment.Non_Owner_Phone_Number__c = NonOwnerPhoneNumber;
                serviceAppointment.Is_Non_Owner__c = IsNonOwner;
                serviceAppointment.Branch__c = Branch;
				serviceAppointment.RecordTypeId = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Service Appointment - Guest').getRecordTypeId();  
            }  
            
            if(String.isNotBlank(nric))
            {       
                if(IsNonOwner != null && IsNonOwner == true) 
                { 

                    tempCN = [SELECT Id, AccountId FROM Contact WHERE id =: nric];
                    if(tempCN.size()>0)
                    {
                        serviceAppointment.Contact__c = tempCN.get(0).Id;
                        serviceAppointment.Account__c = tempCN.get(0).AccountId;
                    }
                }
                else
                {   
                    tempCN = [SELECT Id, AccountId FROM Contact WHERE id =: nric];
                    if(tempCN.size()>0)
                    {
                        serviceAppointment.Contact__c = tempCN.get(0).Id;
                        serviceAppointment.Account__c = tempCN.get(0).AccountId;
                    }
                }      
            }
            else
            {                
                if(tempRV.size()>0)
                {
                    tempcontact.Id = tempRV[0].Contact__c;
                    serviceAppointment.Contact__c = tempcontact.Id;

                    if(tempRV[0].Account__c != null)
                    {
                        serviceAppointment.Account__c = tempRV[0].Account__c;
                    }

                }  
            }                
            
            if(IsNonOwner != null && IsNonOwner == true) 
            {  
                if(tempRV.size()>0)
                {
                    Registered_Vehicle__c regVehicle = new Registered_Vehicle__c();                            
                    regVehicle.Registration_Number__c = registrationNumber; 
                    serviceAppointment.Registered_Vehicle__r = regVehicle;
                }  
            }  
            else
            {
                Registered_Vehicle__c regVehicle = new Registered_Vehicle__c();                            
                regVehicle.Registration_Number__c = registrationNumber; 
                serviceAppointment.Registered_Vehicle__r = regVehicle;
            }
            
            serviceAppointment.Mileage__c = mileage;
            serviceAppointment.Service_Centre_Name__c = serviceCentreName;
            serviceAppointment.Flag__c = False ;

            if(String.isNotBlank(action))
			{

            	List<Service_Appointment__c> serv = new list<Service_Appointment__c>();
										serv = [SELECT Id 
            									FROM Service_Appointment__c 
            									WHERE Booking_ID__c =: bookingId 
            									AND Car_Registration_No__c=: registrationNumber 
            									LIMIT 1];


            	if(action == 'Create')
				{
					if(serv.size()> 0)
					{
            			serviceAppointment.Id = serv[0].Id;
						serviceAppointment.eShop_Flag__c = eShopFlag; 
						serviceAppointment.System_don_t_fire_MC__c = true;
						serviceAppointment.Alternate_Email_Address__c = null; //have to set it as null to prevent double fire entry event in Journey builder 
            			update serviceAppointment;						
					}
					else
					{
            			insert serviceAppointment;

                        //Enhanced Booking Flow Project
                        if (addOns <> null && addOns.size() > 0)
                        {
                            createAddOns(addOns, serviceAppointment.Id, bookingId);
                        }
                        //End
					}

            	}
				else if((action == 'Edit' /*|| action == 'Cancel'*/) 
                         && String.isNotBlank(bookingId) 
                         && String.isNotBlank(registrationNumber))
                {            		
            		if( serv.size()> 0 )
					{
            			serviceAppointment.Id = serv[0].Id;
						serviceAppointment.System_don_t_fire_MC__c = false;
						serviceAppointment.Alternate_Email_Address__c = null; //have to set it as null to prevent double fire entry event in Journey builder 
            			update serviceAppointment;
            		}
                    //Enhanced Booking Flow Project
                    if (addOns <> null && addOns.size() > 0 && bookingId <> null)
                    {
                        createAddOns(addOns, serviceAppointment.Id, bookingId);
                        removeAddOns(addOns, bookingId);
                    }
                    //End
            	}
                else if (action == 'Cancel')
                {
                    if (serv.size() > 0)
                    {
                        Service_Appointment__c serviceAppt = new Service_Appointment__c(Id = serv[0].Id, Action__c = action);

                        update serviceAppt;
                    }
                }
            }                       
            res.statusCode = 200;
            responseMap.put('Status', 'Success');   
        }
        catch (Exception e)
        {     
            responseMap.put('Message', 'A system exception has occurred, Please contact your administrator.'+e.getMessage());
            responseMap.put('ErrorCode', 'Err04-SF');
            res.statusCode = 400;
            loggerDataPool.buildLogDataPool('UpsertServiceAppointment v1', e);
        }    
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        serviceDataPool.buildServiceDataPool('/UpsertServiceAppointment/v1/','UpsertServiceAppointment', '', req, res);
    }

    //Enhanced Booking Flow Project
    private static void createAddOns (List<AddOn> records, Id serviceAppointmentId, String bookingId)
    {
        List<Service_Appointment_Add_On__c> addOnList = new List<Service_Appointment_Add_On__c>();
        
        for (AddOn rec : records)
        {   
            Service_Appointment_Add_On__c addOn = new Service_Appointment_Add_On__c();
            addOn.Add_On_Name__c                = rec.itemName;
            addOn.Service_Appointment__c        = serviceAppointmentId;
            addOn.Add_On_ID__c                  = rec.itemID;
            addOn.BookingAndAddonID__c          = bookingId + '_' + rec.itemID;
            addOnList.add(addOn);
        }
        
        upsert addOnList BookingAndAddonID__c;
             
    }
    
    private static void removeAddOns (List<Addon> records, String bookingId)
    {
        List<Service_Appointment_Add_On__c> addonsToRemove = new List<Service_Appointment_Add_On__c> ();
                        
        List<String> addonIDs = new List<String> ();
                        
        for (Addon a : records)
        {
            addonIDs.add(a.itemID);
        }

        addonsToRemove = [SELECT Id, Name, Add_On_ID__c
                            FROM Service_Appointment_Add_On__c 
                            WHERE Service_Appointment__r.Booking_ID__c =:bookingId
                            AND Add_On_ID__c NOT IN :addonIDs];
        
        delete(addonsToRemove);
    }

    public class AddOn
    {
        public String itemName;
        public String itemID;
    }
    //End
}
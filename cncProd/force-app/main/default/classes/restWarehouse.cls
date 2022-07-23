/** ******
 * Description : restWarehouse
 *  
 * Change History:
 * Date(YYYYMMDD)       Name                              Description
 * YYYYMMDD             C&C                               Created Initial Version.
 * 20211008             khanh.do@aodigy.com               Remove Test_Drive__c creation
***** **/
@RestResource (urlMapping = '/Warehouse/*')
global class restWarehouse 
{
    
    private static RestResponse res = RestContext.response;
    private static RestRequest req = RestContext.request;
    private static Utility.httpErrorResponse errorResponse;
    private static Utility.httpSuccessResponse successResponse;
    private static Map<String, Object> mapJSONBody = new Map<String, Object>();
    private static Map<String, Object> mapParams = new Map<String, Object>();
    private static Map<String, Object> mapCustomerDetails = new Map<String, Object>();
    private static List<Vehicle_Master2__c> lstVehicleMaster = new List<Vehicle_Master2__c>();
    private static List<Variant__c> lstVariantFromModelMaster = new List<Variant__c>();
    private static Map<String, String> mapGenerateDE = new Map<String, String>();
    private static Map<String, Branch_Configuration__mdt> mapBatchConfiguration = Utility.getBatchConfiguration(); 
    
    @HttpGet 
    global static void wareHouseDetails()
    { 
        res.addHeader('Content-Type', 'application/json');
        
        try
        {
            processGetRequest();
        }
        catch(Exception exce)
        {
            loggerDataPool.buildLogDataPool('restWarehouse', exce);        
            errorResponse = new Utility.httpErrorResponse('Failed', exce.getMessage());
        }           
        if(successResponse != null)
        {
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(successResponse));
        }
        if(errorResponse != null)
        {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('wareHouseDetails', 'restWarehouse', '', req, res);
    }
    
    @HttpPost
    global static void reserveWarehouseStock()
    {
        res.addHeader('Content-Type', 'application/json');
        try
        {
            processPostRequest();
        }
        catch(Exception exce)
        {
            loggerDataPool.buildLogDataPool('restWarehouse', exce);
            errorResponse = new Utility.httpErrorResponse('Failed', exce.getMessage());
        }
        if(successResponse != null && successResponse.status == 'Success')
        {    
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.Serialize(successResponse));
        }
        if(errorResponse != null && errorResponse.status == 'Failed')
        {    
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        serviceDataPool.buildServiceDataPool('reserveWarehouseStock', 'restWarehouse', '', req, res);
    }
    
    public static void processGetRequest()
    {
        
        List<Stock_Promotion__c> lstStockPromotion = new List<Stock_Promotion__c>();
        Set<String> setVehicleType = new Set<String>();
        String stockPromotionId = ''; 
        mapParams = req.params;
        
        if(mapParams.get('source') == 'democars')
        {
            setVehicleType.add('Demo Cars');
        }
        else if(mapParams.get('source') == 'promocars')
        {
            setVehicleType.add('Promotional Cars');
        }
        else if(mapParams.get('source') == 'demoandpromo')
        {
            setVehicleType.add('Demo Cars');
            setVehicleType.add('Promotional Cars');
        }
        /* Promotion Code Dealer Web */
        else if(mapParams.get('source') == 'Exclusive') 
        {
            setVehicleType.add('Exclusive car');
        }
        /* End */
        else if(mapParams.get('source') == 'selectedcar')
        {
            stockPromotionId = (String)mapParams.get('stockId');
        }
        
        if(setVehicleType != null && setVehicleType.size() > 0)
        {
            lstStockPromotion = getStockPromotionList( setVehicleType );
            if(lstStockPromotion != null && lstStockPromotion.size() > 0)
            {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.Serialize(lstStockPromotion));
            }
            else
            {
                res.statusCode = 400;
                errorResponse = new Utility.httpErrorResponse('Failed', 'Stock Not Available.'); 
            }
        }
        else if(stockPromotionId != '')
        {
            lstStockPromotion = [SELECT id, Actual_Price__c, Discounted_Price__c, Mileage__c, Stock_Vehicle_Master__c, Vehicle_Type__c, Vehicle_Sub_Type__c, 
                                 Year_of_Manufacture__c, Stock_Vehicle_Master__r.Model_Description__c, Stock_Vehicle_Master__r.Model_Code__r.name, 
                                 Stock_Vehicle_Master__r.Color_Code__r.Name, Stock_Vehicle_Master__r.Color_Code__r.Color_Description__c 
                                 FROM Stock_Promotion__c 
                                 WHERE Stock_Promotion_Status__c = 'ADD' 
                                 AND Stock_Vehicle_Master__r.Vehicle_Status__c = 'RESRV' 
                                 AND Id = :stockPromotionId];
            
            if(lstStockPromotion != null && lstStockPromotion.size() > 0)
            {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.Serialize(lstStockPromotion));
            }
            else
            {
                res.statusCode = 400;
                errorResponse = new Utility.httpErrorResponse('Failed', 'Stock Not Available.');
            }
        }
        else
        {
            res.statusCode = 400;
            errorResponse = new Utility.httpErrorResponse('Failed', 'Parameter source value is incorrect.');
            System.debug('mapParams = ' + mapParams);
        }
    }
    
    public static void processPostRequest()
    { 
        List<Account> lstPAcustomer = new List<Account>();
        List<Account> lstPAprospect = new List<Account>();
        List<Contact> lstContact = new List<Contact>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<GiftItem> giftItems = new List<GiftItem>();
        Boolean isRequired = false;
		
        mapParams = req.params;
        mapJSONBody = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        mapCustomerDetails = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapJSONBody.get('customerInfo')));
        /* Promo Code Dealer Web */
        giftItems = mapJSONBody.get('GiftItems') == null ? giftItems : (List<GiftItem>)JSON.deserialize(JSON.serialize(mapJSONBody.get('GiftItems')), List<GiftItem>.class);
        
        if (!giftItems.isEmpty()) {
            for (GiftItem giftItem : giftItems) {
                if ((giftItem.Type == null || String.isEmpty(giftItem.Type)) || (giftItem.Value == null || String.isEmpty(giftItem.Value))) {
                    isRequired = true;
                }                  
            }
        }
        /** END */
        lstVehicleMaster = Database.query('SELECT ' +Utility.getFields('Vehicle_Master2__c')+ ', Model_Code__r.Name, Model_Code__r.Branch_Code__c, Model_Code__r.Franchise_Code__c'
                                          + ' FROM Vehicle_Master2__c WHERE Id = \'' +mapJSONBody.get('StockVehicleMasterId') + '\'');
    
        lstVariantFromModelMaster = Utility.getVariantFromStockVehicleMaster(lstVehicleMaster[0]);
      
        lstPAcustomer = AccountUtil.getCustomerListByEmails( new Set<String>{ (String)mapCustomerDetails.get('Email') } );
        lstPAprospect = AccountUtil.getProspectListByEmails( new Set<String>{ (String)mapCustomerDetails.get('Email') } );

        
        if(mapParams.get('source') != null && mapParams.get('source') == 'duplicate')
        {   
            lstOpportunity = Utility.checkForExistingOpportunity( (String)mapCustomerDetails.get('Email'), lstVariantFromModelMaster );
            
            if(lstOpportunity != null && lstOpportunity.size() > 0)
            { 
                //Duplicate flag checker
                Boolean flagDupe = false;
                
                //Opportunity Size is always 1
                //Check Stock Reservation if Cancelled 
                List<Stock_Reservation__c> srList = new List<Stock_Reservation__c>();
                
                // do not allow to reserve if Stock reservation is not yet cancelled
                // 21-May-2019: For now, we do not check the model tagged to the Stock Reservation
                // but in future may need to so if customers need to buy another car from warehouse.
                srList = [SELECT Id FROM Stock_Reservation__c 
                          WHERE Opportunity__c =: lstOpportunity.get(0).Id 
                          AND Reservation_Status__c !='Cancel' LIMIT 1];
                
                if(srList!=null && !srList.isEmpty()) {
                    flagDupe = true; 
                }
                
                if(flagDupe) {
                    //there is an Existing stock reservation
                    errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. There is already a stock reserved for you.');
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
                }
                else {
                    successResponse = new Utility.httpSuccessResponse('Success', 'Duplicate check passed.');
                }
            }
            else
            {
                successResponse = new Utility.httpSuccessResponse('Success', 'Duplicate check passed.');
            }
        }
        else
        {   
            
            
            /** Promo Code Dealer Web */   
            if (mapJSONBody.get('IsPromo') != null) 
            {
               
                if ((Boolean)mapJSONBody.get('IsPromo')) 
                {
                    if (mapJSONBody.get('CampaignId') == null || String.isEmpty((String)mapJSONBody.get('CampaignId'))) 
                    {
                        errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. Campaign ID is required.');
                    } 
                    else if (mapJSONBody.get('PriceAfterDiscount') == null || (Decimal)mapJSONBody.get('PriceAfterDiscount') == 0) 
                    {
                        errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. Price After Discount is required.');
                    } 
                    else if (giftItems.isEmpty() || isRequired) 
                    {
                        errorResponse = new Utility.httpErrorResponse('Failed', 'Sorry. Gift Items are required.');
                    /** END */
                    } 
                    else 
                    {
                        if(lstPAcustomer != null && lstPAcustomer.size() > 0) 
                        {
                            reserveWarehouseStock((Object)lstPAcustomer[0]);
                        }
                        else if(lstPAprospect != null && lstPAprospect.size() > 0) 
                        {
                             reserveWarehouseStock((Object)lstPAprospect[0]);
                        }
                        else 
                        {
                            reserveWarehouseStock((Object)null);
                        }
                    }
                } 
                else 
                {
                  
                    if(lstPAcustomer != null && lstPAcustomer.size() > 0) 
                    {
                        reserveWarehouseStock((Object)lstPAcustomer[0]);
                    }
                    else if(lstPAprospect != null && lstPAprospect.size() > 0) 
                    {
                        reserveWarehouseStock((Object)lstPAprospect[0]);
                    }
                    else {
                        reserveWarehouseStock((Object)null);
                    }
                }
            } 
            else 
            {
              
                if(lstPAcustomer != null && lstPAcustomer.size() > 0) 
                {
                    reserveWarehouseStock((Object)lstPAcustomer[0]);
                }
                else if(lstPAprospect != null && lstPAprospect.size() > 0) 
                {
                    reserveWarehouseStock((Object)lstPAprospect[0]);
                }
                else {
                    reserveWarehouseStock((Object)null);
                }
            }     
        }
    }
    
    public static List<Stock_Promotion__c> getStockPromotionList(Set<String> setVehicleType)
    {
        List<Stock_Promotion__c> lstStockPromotion = new List<Stock_Promotion__c>();
        Set<String> setVehicleMaster = new Set<String>();
        Map<Id, Vehicle_Master2__c> mapVehicleMaster = new Map<Id, Vehicle_Master2__c>();
        Set<String> setToRemoveFromStockPromotion = new Set<String>(); 
        
        lstStockPromotion = [SELECT id, Actual_Price__c, Discounted_Price__c, Mileage__c, Stock_Vehicle_Master__c, Vehicle_Type__c, Vehicle_Sub_Type__c, 
                             Year_of_Manufacture__c, Stock_Vehicle_Master__r.Model_Description__c, Stock_Vehicle_Master__r.Model_Code__r.name, 
                             Stock_Vehicle_Master__r.Color_Code__r.Name, Stock_Vehicle_Master__r.Chassis__c, Stock_Vehicle_Master__r.Model_Year_Code__r.name, 
                             Address__c, Showroom__c, Stock_Vehicle_Master__r.Color_Code__r.Color_Description__c 
                             FROM Stock_Promotion__c where Stock_Promotion_Status__c = 'ADD' 
                             AND Stock_Vehicle_Master__r.Vehicle_Status__c = 'RESRV' 
                             AND Stock_Vehicle_Master__r.Branch_Code__c = :(String)mapParams.get('branch') 
                             AND Vehicle_Type__c IN :setVehicleType 
                             AND Promotion_Type__c = :mapBatchConfiguration.get((String)mapParams.get('branch')).Warehouse_Name__c]; 
        
        for(Stock_Promotion__c stkPromo : lstStockPromotion)
        {
            setVehicleMaster.add( stkPromo.Stock_Vehicle_Master__c );
        }
        
        mapVehicleMaster = new Map<Id, Vehicle_Master2__c>([SELECT Id, (SELECT Id 
                                                                        FROM Stock_Reservations__r 
                                                                        WHERE Reservation_Status__c not in ('Cancel', 'Indent')) 
                                                            FROM Vehicle_Master2__c 
                                                            WHERE Id IN :setVehicleMaster]);
        
        for(Stock_Promotion__c stkPromo : lstStockPromotion)
        {
            if(mapVehicleMaster.get( stkPromo.Stock_Vehicle_Master__c ).Stock_Reservations__r != null 
               && mapVehicleMaster.get( stkPromo.Stock_Vehicle_Master__c ).Stock_Reservations__r.size() > 0)
            {
                setToRemoveFromStockPromotion.add( stkPromo.Stock_Vehicle_Master__c );
            }
        }
        
        if(setToRemoveFromStockPromotion != null && setToRemoveFromStockPromotion.size() > 0)
        {
            lstStockPromotion = [SELECT id, Actual_Price__c, Discounted_Price__c, Mileage__c, Stock_Vehicle_Master__c, Vehicle_Type__c, Vehicle_Sub_Type__c, 
                                 Year_of_Manufacture__c, Stock_Vehicle_Master__r.Model_Description__c, Stock_Vehicle_Master__r.Model_Code__r.name, 
                                 Stock_Vehicle_Master__r.Color_Code__r.Name, Stock_Vehicle_Master__r.Chassis__c, Stock_Vehicle_Master__r.Model_Year_Code__r.name, 
                                 Address__c, Showroom__c, Stock_Vehicle_Master__r.Color_Code__r.Color_Description__c 
                                 FROM Stock_Promotion__c where Stock_Promotion_Status__c = 'ADD' 
                                 AND Stock_Vehicle_Master__r.Vehicle_Status__c = 'RESRV' 
                                 AND Stock_Vehicle_Master__r.Branch_Code__c = :(String)mapParams.get('branch') 
                                 AND Vehicle_Type__c IN :setVehicleType 
                                 AND Promotion_Type__c = :mapBatchConfiguration.get((String)mapParams.get('branch')).Warehouse_Name__c 
                                 AND Stock_Vehicle_Master__c NOT IN :setToRemoveFromStockPromotion];
        }
        return lstStockPromotion;
    }
    
    public static void reserveWarehouseStock(Object customerInfo)
    {         
        Map<String, Object> mapGenerateJSON = new Map<String, Object>();
        Opportunity opp = createOpportunity(customerInfo);
        Task toDoTask = createTask(opp);
        createModelInterest(opp);

        Stock_Reservation__c stockReserve = createStockReservation(opp);
        //Test_Drive__c testDrive = createTestDrive(opp); //Removed By Khanh: MF Test Drive Modification
        
        List<Stock_Reservation__c> stockReserveNumber = [select id, ownerid, Model_Description__c, name, 
                                                        Promo_Gifts_Descriptions__c, Campaign__r.Promo_Code__c,
														Vehicle_Master__r.id
                                                         from Stock_Reservation__c 
                                                         where id = :stockReserve.Id];
        
        tagStockReservationToPaymentReceipt(stockReserveNumber);
        reserveStockInVSMS(stockReserve);

		// Update Vehicle_Master2__c with stockReserveNumber
        if(stockReserveNumber != null && stockReserveNumber.size() > 0)
        {	
			if(stockReserveNumber[0].Vehicle_Master__r.id != null)
			{	
				Vehicle_Master2__c updateVehStockMaster = new Vehicle_Master2__c();
				updateVehStockMaster.id = stockReserveNumber[0].Vehicle_Master__r.id;
				updateVehStockMaster.Reservation_No__c = stockReserveNumber[0].name;
				update updateVehStockMaster;
			}

		}
		// End of Update Vehicle_Master2__c with stockReserveNumber

        Utility.createToDoTask(stockReserve, 'Confirmation');
        
        if(stockReserveNumber != null && stockReserveNumber.size() > 0)
        {
            
            system.debug('JMT ---- stockReserveNumber');
            system.debug(stockReserveNumber);
            mapGenerateJSON.put('StockReservationNo', stockReserveNumber[0].name);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(mapGenerateJSON));
            mapGenerateDE.put('brand', (String)mapParams.get('branch'));
            mapGenerateDE.put('stockReserveId', stockReserveNumber[0].id);
            mapGenerateDE.put('PromoDesc', stockReserveNumber[0].Promo_Gifts_Descriptions__c);
            mapGenerateDE.put('PromoCode', stockReserveNumber[0].Campaign__r.Promo_Code__c);
            mapGenerateDE.put('emailFor', 'Cust');
            mapGenerateDE.put('emailType', 'Confirmation');
            mapGenerateDE.put('stockPromoId', (String)mapJSONBody.get('StockPromotionId'));
            if(mapParams.get('branch') == 'CCK')
            {
                mapGenerateDE.put('fromAddress', 'sales.kia.sg@e.cyclecarriage.com');
                mapGenerateDE.put('fromName', 'C&C Kia Showroom');
            }
            else if(mapParams.get('branch') == 'CCA')
            {
                mapGenerateDE.put('fromAddress', 'sales.mitsubishi.sg@e.cyclecarriage.com');
                mapGenerateDE.put('fromName', 'C&C Mitsubishi Sales');
            }
            else if(mapParams.get('branch') == 'CCF')
            {
                mapGenerateDE.put('fromAddress', 'sales.citroen.sg@e.cyclecarriage.com');
                mapGenerateDE.put('fromName', 'C&C Citroen Showroom');
                
                if(stockReserveNumber[0].Model_Description__c.contains('DS'))
                {
                    mapGenerateDE.put('fromAddress', 'sales.DS.sg@e.cyclecarriage.com');
                    mapGenerateDE.put('fromName', 'C&C DS Showroom');
                }
                
            }
            BusinessRuleHandlerSFMC.sendEmail(mapGenerateDE);
            mapGenerateDE.put('emailFor', 'SC');
            BusinessRuleHandlerSFMC.sendEmail(mapGenerateDE);
        }
        else
        {
            errorResponse = new Utility.httpErrorResponse('Failed', '');
        }
    } 
    
    public static Opportunity createOpportunity(Object customerInfo)
    {
		//Code was modified for Oppty standardisation --> NSJ

		String OppName;
		String ContactId;
		String AccountId;

        if(customerInfo instanceOf Account)
        {
            Account personAcctDetails = (Account)customerInfo;
            OppName = personAcctDetails.Name + ' - ' +mapBatchConfiguration.get((String)mapParams.get('branch')).Branch_Name__c;
            AccountId = personAcctDetails.Id;
            ContactId = personAcctDetails.PersonContactId;
        }
        else 
		{
            String strUniqueKey = AccountUtil.createUniqueString();
            Account newPA = [SELECT Id, PersonContactId, Name FROM Account WHERE Id =: createPersonAccount().Id LIMIT 1];
            OppName = newPA.Name + ' - ' +mapBatchConfiguration.get((String)mapParams.get('branch')).Branch_Name__c;
            AccountId = newPA.Id;
            ContactId = newPA.PersonContactId; 
        }		

        Opportunity newOpp = new Opportunity();
        List<Opportunity> lstOpportunityExists = new List<Opportunity>();
        List<sharingHelper.generateShare> lstToCreateShare = new List<sharingHelper.generateShare>();

		newOpp = OpportunityService.newOpportunityObject(ContactId, AccountId, null,
														lstVehicleMaster[0].Branch_Code__c, lstVehicleMaster[0].Franchise_Code__c, 'Warehouse');
		newOpp.Name = OppName;
        newOpp.TotalOpportunityQuantity = 1;
        newOpp.RecordTypeId             = mapBatchConfiguration.get((String)mapParams.get('branch')).Opp_RT__c;
		newOpp.StageName = 'Stock Reserved';
        
        if((String)mapJSONBody.get('SalesConsultantId') != '' && (String)mapJSONBody.get('SalesConsultantId') != null)
        {
            lstOpportunityExists = Utility.checkOppExistsForThisConsultant((String)mapJSONBody.get('SalesConsultantId'), (String)mapCustomerDetails.get('Email'));
            if(lstOpportunityExists != null && lstOpportunityExists.size() > 0)
            {
                return lstOpportunityExists[0];
            }
            else
            {
                //Preferred Sales Consultant                
                newOpp.OwnerId = (String)mapJSONBody.get('SalesConsultantId');
                TriggerExclusion.excludeTrigger('Opportunity', true);
                insert newOpp;
                TriggerExclusion.excludeTrigger('Opportunity', false);
            }       
        }
        else
        {
            if(newOpp.Contact_Person__c != null)
            {
                lstOpportunityExists = Utility.checkOpenOppExistsForThisContact((String)mapParams.get('branch'), newOpp.Contact_Person__c);
                if(lstOpportunityExists != null && lstOpportunityExists.size() > 0)
                {
                    //Open Opportunity Exists
                    return lstOpportunityExists[0];
                }
                else
                {
                    lstOpportunityExists = Utility.checkOpenOppExistsForThisContact((String)mapParams.get('branch'), newOpp.Contact_Person__c);
                    if(lstOpportunityExists !=  null && lstOpportunityExists.size() > 0)
                    {
                        newOpp.OwnerId = lstOpportunityExists[0].OwnerId;
                        TriggerExclusion.excludeTrigger('Opportunity', true);
                        //Last Consultant
                        insert newOpp;
                        TriggerExclusion.excludeTrigger('Opportunity', false);
                    }
                    else
                    {
                        //Round Robbin
                        insert newOpp;
                    }
                }
            }
        }
        
        Opportunity oppToShare = [SELECT Id, Name, Contact_Person__c, /*Lead__c,*/ Account__c, StageName, Branch_Code__c, Franchise_Code__c, 
                                  Model_c__c, TotalOpportunityQuantity, CloseDate, OwnerId, Owner.Name, Owner.MobilePhone, 
                                  (SELECT Id, Model__c, Touch_Points__c FROM Models_Interested__r) 
                                  FROM Opportunity WHERE Id = :newOpp.Id];

        if(oppToShare.Account__c != null) {
            Contact personAccountContact = [SELECT Id FROM Contact WHERE AccountId =: oppToShare.Account__c];
            lstToCreateShare.add(new sharingHelper.generateShare('Read', 'Contact', personAccountContact.Id, oppToShare.OwnerId));
        }
        sharingHelper.creatShare( lstToCreateShare ); 
        
        return oppToShare;
    }
    
    private static Task createTask(Opportunity opp){
        Task task          = new Task();
        task.Subject       = String.isNotBlank(System.Label.OppAssignment) ? System.Label.OppAssignment : 'Schedule Digital Consultation';
        task.WhatId        = opp.Id;
        task.Status        = 'Open';
        task.Priority      = 'Normal';
        task.OwnerId       = opp.OwnerId;
        task.ActivityDate  = Date.valueOf((String)mapJSONBody.get('TestDriveDate'));
        task.IsReminderSet = false;
        insert task;
        return task;
    }

    public static void createModelInterest(Opportunity opp)
    {
        Models_Interested__c modInt = new Models_Interested__c();
        system.debug('opp.Id');
        system.debug(opp.Id);
        system.debug('lstVariantFromModelMaster[0].Model_ID__c');
        system.debug(lstVariantFromModelMaster);
		modInt = ModelsInterestedService.newModelInterestedObject(opp.Id,lstVariantFromModelMaster[0].Model_ID__c, 'Online', 'Warehouse');
        insert modInt;
    }
    
    public static Stock_Reservation__c createStockReservation(Opportunity opp)
    { 
        Stock_Reservation__c newStockReserve  = new Stock_Reservation__c();
        newStockReserve.Reservation_Status__c = 'Reserve';
        newStockReserve.Model_Code__c         = lstVehicleMaster[0].Model_code__c;
        newStockReserve.Model_Year_Code__c    = lstVehicleMaster[0].Model_Year_Code__c;
        newStockReserve.Trim_Code__c          = lstVehicleMaster[0].Trim_Code__c;
        newStockReserve.Vehicle_Master__c     = lstVehicleMaster[0].Id;
        newStockReserve.Color_Code__c         = lstVehicleMaster[0].Color_Code__c;  
        newStockReserve.Opportunity__c        = opp.Id;
        newStockReserve.Customer_Name__c      = (String)mapCustomerDetails.get('FirstName') + ' ' +(String)mapCustomerDetails.get('LastName');
        newStockReserve.Customer_Email__c     = (String)mapCustomerDetails.get('Email');
        newStockReserve.Customer_Mobile_Number__c = '65' +(String)mapCustomerDetails.get('Mobile');
        newStockReserve.Branch_Code__c        = lstVehicleMaster[0].Branch_Code__c; 
        newStockReserve.Franchise_Code__c     = lstVehicleMaster[0].Franchise_Code__c;  
        newStockReserve.Stock_Source__c       = mapBatchConfiguration.get((String)mapParams.get('branch')).Warehouse_Name__c;
        newStockReserve.OwnerId               = opp.OwnerId;
        /** Promo Code Dealer Web */
        if (mapJSONBody.get('IsPromo') != null) {
            if ((Boolean)mapJSONBody.get('IsPromo')) {
                Campaign campaign = [SELECT Promo_Code__c FROM Campaign WHERE Id =: (String)mapJSONBody.get('CampaignId')];
                
                newStockReserve.Campaign__c           = (String)mapJSONBody.get('CampaignId');

                string InvitedMemberId = '';
                InvitedMemberId = (String)mapJSONBody.get('InvitedMemberId');
                if( String.isNotBlank( InvitedMemberId ) ) {
                    newStockReserve.Campaign_Invited_members__c = (String)mapJSONBody.get('InvitedMemberId');
                }
                newStockReserve.Price_after_discount__c = (Decimal)mapJSONBody.get('PriceAfterDiscount');
                newStockReserve.Promo_Gifts_Descriptions__c = (String)mapJSONBody.get('Description');
                newStockReserve.Comment__c = String.isEmpty((String)mapJSONBody.get('Description')) ? 
                                                'Promo code: ' + campaign.Promo_Code__c : 
                                                    'Promo code: ' + campaign.Promo_Code__c + ', ' + (String)mapJSONBody.get('Description');
                
                /* Update status of related Campaign Invited Member from Open to Redeemed */
                if( String.isNotBlank( InvitedMemberId ) )
                {                
                    Campaign_Invited_members__c updatedInvitedMember = [SELECT Redeem__c FROM Campaign_Invited_members__c WHERE Id =: (String)mapJSONBody.get('InvitedMemberId')];
                    updatedInvitedMember.Redeem__c = 'Redeemed';
                    update updatedInvitedMember;
                }
            }
        }
        /** END */
        insert newStockReserve;
        
        return newStockReserve; 
    }  
    

    /** Removed By Khanh: MF Test Drive Modification */
    // public static Test_Drive__c createTestDrive(Opportunity opp)
    // {
    //     List<Vehicle_Master__c> lstTDModel = new List<Vehicle_Master__c>();
    //     Test_Drive__c newTestDrive      = new Test_Drive__c();
    //     newTestDrive.Opportunity__c     = opp.id;
    //     newTestDrive.Branch_Code__c     = opp.Branch_Code__c;
    //     newTestDrive.Franchise_Code__c  = opp.Franchise_Code__c;
    //     newTestDrive.Date__c            = Date.valueOf((String)mapJSONBody.get('TestDriveDate')); 
    //     newTestDrive.Prospect__c        = opp.Contact_Person__c;
    //     newTestDrive.Account__c         = opp.Account__c;   //PA MIGRATION
    //     newTestDrive.OwnerId            = opp.OwnerId;
    //     newTestDrive.Status__c          = 'Pending'; 
    //     newTestDrive.Test_Drive_Source__c = 'Warehouse';
    //     lstTDModel = Utility.getModelForTestDrive( lstVariantFromModelMaster[0] );
        
    //     if(lstTDModel != null && lstTDModel.size() > 0) {
    //         newTestDrive.Model__c = lstTDModel[0].Id; 
    //     }
    //     TriggerExclusion.excludeTrigger('TestDrive', true);
    //     insert newTestDrive;
    //     TriggerExclusion.excludeTrigger('TestDrive', false);
    //     return newTestDrive;
    // }
    

    public static void tagStockReservationToPaymentReceipt(List<Stock_Reservation__c> lstStockReservation)
    {
        List<Invoice__c> lstInvoice = [SELECT Id, Invoice_Number__c, StockReservation__c 
                                       FROM Invoice__c 
                                       WHERE Invoice_Number__c = :(String)mapJSONBody.get('InvoiceNo')];
        lstInvoice[0].StockReservation__c = lstStockReservation[0].Id;
        update lstInvoice[0];
    }
    

    public static void reserveStockInVSMS(Stock_Reservation__c stockReservation)
    {
        String oppOwnerUsername = [SELECT Id, Owner.Username2__c 
                                   FROM Opportunity 
                                   WHERE Id = :stockReservation.Opportunity__c].Owner.Username2__c;
        
        BusinessRuleHandlerVSMS.createStocKVSMS(stockReservation.Id, oppOwnerUsername, true); 
    }
    
    public static account createPersonAccount()
    {
        Id idPA_prospect = AccountUtil.getProspectRecordTypeId();
        Account thisAccount = new Account();
        thisAccount.FirstName   = (String)mapCustomerDetails.get('FirstName');
        thisAccount.LastName    = (String)mapCustomerDetails.get('LastName');
        thisAccount.Phone       = (String)mapCustomerDetails.get('Mobile');
        thisAccount.PersonEmail = (String)mapCustomerDetails.get('Email');
        thisAccount.RecordTypeId = idPA_prospect;

        thisAccount = AccountUtil.createProspect( thisAccount );
        return thisAccount;
    }
    
    
    public static Boolean isValidateParamPassed()
    {
        String errorMessage = '';
        
        if(mapParams != null && mapParams.size() > 0) {
            if(mapParams.get('branch') == null || mapParams.get('branch') == '') {
                errorMessage = 'branch';
            }
            
            if(mapParams.get('source') == null || mapParams.get('source') == '') {
                errorMessage = (errorMessage == '') ? 'source' : errorMessage + ', ' +'source';
            }
            else if(mapParams.get('source') == 'selectedcar' && mapParams.get('stockId') == null) {
                errorMessage = (errorMessage == '') ? 'stockId' : errorMessage + ', ' +'stockId';
            }
        }
        else {
            errorMessage = 'All';
        }
        
        if(errorMessage == '') {
            return true;
        }
        else {
            errorResponse = new Utility.httpErrorResponse('Failed', 'Missing parameter: ' +errorMessage);
        }
        return false;
    }

    /** Promotion Code Dealer Web */
    public class GiftItem {
        public String Value;
        public String Type;
    }
    /** End */
    
}
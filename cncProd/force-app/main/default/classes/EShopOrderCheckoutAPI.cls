/** *****
 * Description : E-SHOP Order API class. used by EShop to create/update Order 
 * 
 * Change History:
 * Date(YYYYMMDD)       Name                Description
 * 20200210             nguyen.tho          Created Initial Version. 
 * 20200428             HS                  Added extra checking to verify the non user customer by Email value to avoid duplication  
 * 20200726             SJ                  eShop Phase 2. 
 * 20200925             TP                  PA Phase 2 : Removed Contact creation
 * 20210623             KD                  Removed Person Account RecordType "E-shop customer"
** *****/
@RestResource(urlMapping='/EShopOrderCheckout/*')
global with sharing class EShopOrderCheckoutAPI 
{
    @HttpPost
    global static void checkoutOrder()
	{
        Map<String, String> responseMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestContext.response = res;
        
        try 
        {
            EShopOrderWrapper orderWrap = (EShopOrderWrapper)JSON.deserialize(req.requestBody.toString(), EShopOrderWrapper.class);                               
            EShopOrderWrapper.Order order = orderWrap.order;
            List<EShopOrderWrapper.ItemWrapper> items = order.LineItems;
            
            OrderSelector selector = new OrderSelector();
            String cntId;
            String actId;
            Contact con = new Contact();
            Account act = new Account();
            Order__c newOrder = new Order__c();
            List<Order_Line_Item__c> orderItems = new List<Order_Line_Item__c>();
            
            Id customerTypeId = AccountUtil.getCustomerRecordTypeId();
            if(String.isBlank(orderWrap.UserId))
            {
                

                List<Account> lstAccount = [SELECT Id, Name, PersonContactId,
                                                (SELECT Id FROM Contacts1__r)
                                            FROM Account 
                                            WHERE IsPersonAccount = true 
                                            AND PersonEmail = :orderWrap.Email 
                                            ];
                
                List<Contact> lstContact = [SELECT Id, AccountId, IsPersonAccount 
                                            FROM Contact 
                                            WHERE Email = :orderWrap.Email
                                            AND IsPersonAccount = true
                                            ];

                if( !lstContact.isEmpty() ){

                    act = new Account( Id = lstContact.get(0).AccountId );
                    order.PersonAccount = lstContact.get(0).AccountId;

                    if( !lstAccount.get(0).Contacts1__r.isEmpty() ){
                        cntId = lstContact.get(0).Id;
                        con = lstContact.get(0);
                    }

                }
                else
                {
                    //CREATE NEW CONTACT & PA(ESHOP)
                    
                    //Person Account(E-SHOP)
                    act.LastName          = orderWrap.Name;
                    act.PersonEmail       = orderWrap.Email;
                    act.PersonMobilePhone = orderWrap.mobile;
                    act.RecordTypeId      = customerTypeId;
                    if(orderWrap.Promotions == true) {
                        UpdatePDPA.updateConsentPDPA(act, true);
                    }          
                    act.Type__pc = 'E-Shop'; 
                }
            }
            else
            {
                //FIND EXISTING CUSTOMER CONTACT USER
                List<User> users = [SELECT /*ContactId__c,*/ ContactId, Contact.AccountId FROM User WHERE Id = :orderWrap.UserId];
                if(!users.isEmpty())
				{
                    // cntId = users[0].ContactId__c;
                    cntId = users[0].ContactId;
                    con = new Contact(Id=(ID)cntId);                  
                    actId = users[0].Contact.AccountId;
                    act = String.isNotBlank( actId ) ? new Account(Id=(ID)actId ) : act;

                    order.PersonAccount = order.PersonAccount != null ? order.PersonAccount : actId;
                }
                else
				{
                    res.addHeader('Content-Type', 'application/json');
                    res.statusCode = 400;
                    responseMap.put('Status', 'Failed');
                    responseMap.put('Message', 'Invalid UserId');
                    res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
                    return;
                }
            }
            

            String recordTypeId;
            Map<String,Schema.RecordTypeInfo> mapOrderRT = selector.getOrderRtByDeveloperName();
            if( mapOrderRT.containsKey('C_C_E_Shop') )
			{
                recordTypeId = mapOrderRT.get('C_C_E_Shop').getRecordTypeId();
            }
            
            Order__c existingOrder = selector.selectByEshopOrderID( order.orderId, cntId );
            System.debug('@@@@DEBUG EShopOrderCheckoutAPI :: order.orderId = ' + order.orderId );
            System.debug('@@@@DEBUG EShopOrderCheckoutAPI :: cntId = ' + cntId );
            System.debug('@@@@DEBUG EShopOrderCheckoutAPI :: existingOrder = ' + existingOrder );
            
            //EXISTING ORDER
            if( existingOrder <> null && String.isNotBlank( existingOrder.Id ) )
            {
                    Order__c orderToUpdate = EShopOrderWrapper.createOrder(order, recordTypeId, cntId);
                    orderToUpdate.Id = existingOrder.Id;
                    EShopOrderCheckoutService.cancelOrder( orderToUpdate );
                    
            }
            //NEW ORDER
            else
            {
                newOrder = EShopOrderWrapper.createOrder(order, recordTypeId, cntId);
                
                if( !items.isEmpty() ) 
				{
                    orderItems = new List<Order_Line_Item__c>();
                    for(EShopOrderWrapper.ItemWrapper item : items)
					{
                        orderItems.add( EShopOrderWrapper.createOrderLineItem( item, newOrder.Id ) );
                    }
                }
                                     
                if(orderWrap.Promotions == true) {
                    UpdatePDPA.updateConsentPDPA(act, true);
                } //else: if the PDPA is false then we do not do any update on the PDPA

                EShopOrderCheckoutService.processOrder( act, newOrder, orderItems );
				//EShopOrderCheckoutService.insert_pctymentSF_clearAcc(newOrder);
            }           
            
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
            responseMap.put('Status', 'Success');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
            
        } 
        catch (Exception ex) 
		{
            System.debug('@@@@DEBUG EShopOrderCheckoutAPI :: ERR CAUSE = ' + ex.getCause() + ' --- ERR MSG = ' + ex.getMessage() + ' --- ERR LINE NUMER = ' + ex.getLineNumber());
            res.addHeader('Content-Type', 'application/json');
            res.statusCode   = 400;
            responseMap.put('Status', 'Failed');
            responseMap.put('Message', ex.getMessage());
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap)); 
            loggerDataPool.buildLogDataPool('EShopOrderCheckoutAPI', ex);
        }
        
        serviceDataPool.buildServiceDataPool('CheckoutOrder', 'EShopOrderCheckoutAPI', '', req, res);
    }
    
}


/* Sample

	/services/apexrest/EShopOrderCheckout 

    {
        "UserId": "005O0000006UtGu",
        "Name": "Peter",
        "Email": "Peter@Peter123.com",
        "Mobile": "6510203040",
        "Promotions": true,
        "Order": {
            "OrderID": "Entity-12345ABCDEF1",
            "OrderNumber": "Order-12345ABCDEF1",
            "EInvoice": "PJ12345ABCDEF1",
            "EInvoiceDate": "2020-12-30",
            "EInvoiceURL": "www.e-shop.com/image12345 (http://www.e-shop.com/image12345)",
            "TransactionDate": "2020-12-31",
            "OrderAmount": 88.0,
            "OrderAmountBeforeGST": 80.0,
            "GST": 7.00,
            "Branch": "CCF",
            "SiteName": "CIT",
            "CreatedDate": "2020-03-23T02:00:00.000Z",
            "UpdatedDate": "2020-04-25T02:00:00.000Z",
            "Status": "ordered",
            "Shop": "e-shop Kia",
            "Subtotal": 7100,
            "Adjustment": 500,
            "GrandTotal": 7999.1,
            "LineItems": [
                {
                    "ItemName": "water bottle2",
                    "ItemSellingPrice": 3000,
                    "ItemSubtotal": 3000,
                    "ItemAdjustment": 100,
                    "ItemTotal": 3000,
                    "ItemQuantity": 1,
                    "ItemSKU": "Bottle1234D",
                    "ItemVariants": "KIA bottle",
                    "ItemCategory": "Lifestyle",
                    "ItemSubCategory": "Bottle",
                    "ItemVehicleGroup": "Lancer",
                    "ItemVehicleVariant": "Lancer 1.6 ex5",
                    "ItemVehicleNumber": "SK1234S"
                },
                {
                    "ItemName": "cap2",
                    "ItemSellingPrice": 2000,
                    "ItemSubtotal": 2000,
                    "ItemAdjustment": 200,
                    "ItemTotal": 2000,
                    "ItemQuantity": 2,
                    "ItemSKU": "CAP1234D",
                    "ItemVariants": "KIA CAP",
                    "ItemCategory": "Lifestyle",
                    "ItemSubCategory": "CAP",
                    "ItemVehicleGroup": "",
                    "ItemVehicleVariant": "",
                    "ItemVehicleNumber": ""
                }
            ]
        }
    }

*/
/** *****
 * Description : E-SHOP Order Service Class
 * 
 * Change History:
 * Date(YYYYMMDD)      Name        Description
 * 20200211            HS          Created Initial Version. 
 * 20200726            SJ          eShop Phase 2. 
 * 20200925            TP          PA Phase 2 : Removed logic for Contact Obj
 * 20210617            KD          Added Person Account Profiling creation
** *****/
public with sharing class EShopOrderCheckoutService 
{
    private final static String CONST_PA_PROFILING_ESHOP = 'E_Shop_Person_Account_Profiling_RT';

    public static void processOrder( Account actRef, Order__c ordRef, List<Order_Line_Item__c> oliRefs )
	{

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Account.SObjectType,                                                                
                                                                                              Order__c.SObjectType, 
																							  Order_Line_Item__c.SObjectType,
                                                                                              Invoice__c.SObjectType});
		Invoice__c paymentRef = new Invoice__c();
				                                                                                        
        try {

            Contact cntRef = new Contact();

            if( actRef <> null && actRef.Id == null )
            {
                insert actRef;
                AccountUtil.createProfiling(CONST_PA_PROFILING_ESHOP, actRef);
            }
            
            if( actRef <> null && actRef.Id <> null ){
                update actRef;
                cntRef = [SELECT Id, AccountId FROM Contact WHERE AccountID =: actRef.Id AND IsPersonAccount = true ];
            }

            //REGISTER ORDER RECORD, AND ESTABLISH PARENT RELATIONSHIP TO CONTACT
            uow.registerNew( ordRef, Order__c.Account__c, actRef);
            uow.registerRelationship( ordRef, Order__c.Contact__c, cntRef );
            uow.registerRelationship( ordRef, Order__c.Account__c, actRef ); 
            
            //REGISTER ORDER LINE ITEM RECORD(S), AND ESTABLISH PARENT RELATIONSHIP TO ORDER
            for( Order_Line_Item__c oli : oliRefs ) {
                uow.registerNew( oli, Order_Line_Item__c.Order__c, ordRef );
			}
						
			//REGISTER PAYMENT RECORD, AND ESTABLISH PARENT RELATIONSHIP TO ORDER					
			paymentRef = insert_paymentSF_clearAcc(ordRef);
			uow.registerNew(paymentRef, Invoice__c.E_shop_Order__c, ordRef);
            uow.registerRelationship(paymentRef, Invoice__c.E_shop_Order__c, ordRef);
            uow.registerRelationship(paymentRef, Invoice__c.Account__c, actRef);
            uow.registerRelationship(paymentRef, Invoice__c.Contact__c, cntRef);

            //COMMIT DATA
            uow.commitWork();


            /*
            //REGISTER PERSON ACCOUNT(E-SHOP)
            if( actRef <> null && actRef.Id == null )
            {
                uow.registerNew( actRef );
            }
            
            //REGISTER CONTACT RECORD
            // if( cntRef <> null && cntRef.Id == null )
            // {
            //     // uow.registerNew( cntRef );
            //     uow.registerNew( cntRef, Contact.Account__c, actRef);
            // }
            
            //REGISTER ORDER RECORD, AND ESTABLISH PARENT RELATIONSHIP TO CONTACT
            uow.registerNew( ordRef, Order__c.Account__c, actRef);
            //uow.registerRelationship( ordRef, Order__c.Contact__c, cntRef );
            uow.registerRelationship( ordRef, Order__c.Account__c, actRef ); //PA MIGRATION
            
            //REGISTER ORDER LINE ITEM RECORD(S), AND ESTABLISH PARENT RELATIONSHIP TO ORDER
            for( Order_Line_Item__c oli : oliRefs ) {
                uow.registerNew( oli, Order_Line_Item__c.Order__c, ordRef );
			}
						
			//REGISTER PAYMENT RECORD, AND ESTABLISH PARENT RELATIONSHIP TO ORDER					
			paymentRef = insert_paymentSF_clearAcc(ordRef);
			uow.registerNew(paymentRef, Invoice__c.E_shop_Order__c, ordRef);
            uow.registerRelationship(paymentRef, Invoice__c.E_shop_Order__c, ordRef);
            uow.registerRelationship(paymentRef, Invoice__c.Account__c, actRef);
            //COMMIT DATA

            uow.commitWork();

            Map<Id, Id> contactIdMap = getPersonContactId(new Set<Id> {actRef.Id});
            if (contactIdMap.containsKey(actRef.Id))
            {
                ordRef.Contact__c     = contactIdMap.get(actRef.Id); 
                paymentRef.Contact__c = contactIdMap.get(actRef.Id); 
            }

            update ordRef;
            update paymentRef;
            */
        }
        catch (Exception ex) 
        {
            loggerDataPool.buildLogDataPool('EShopOrderCheckoutService', ex);
        }
    }

    public static void cancelOrder( Order__c ordRef ) {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Order__c.SObjectType,
                                                                                              /*Comment out by NSJ Reward_Usage__c.SObjectType,*/
                                                                                              Invoice__c.SObjectType });
        uow.registerDirty( ordRef );
		//Comment out by NSJ   
        //List<Reward_Usage__c> relatedRewardUsages = updateRelatedRewardUsages(ordRef);
        //if(relatedRewardUsages <> null) {
        //    uow.registerDirty(relatedRewardUsages);
        //}
        
        //List<Invoice__c> relatedPayments = updateRelatedPayments(ordRef);
        //if(relatedPayments <> null) {
        //    uow.registerDirty(relatedPayments);
        //}
		//Comment out by NSJ   
        uow.commitWork();
    }

		public static /*void*/ Invoice__c insert_paymentSF_clearAcc(Order__c ordRef)
		{

			Invoice__c objPayment = new Invoice__c();

			objPayment.RecordTypeId        = OrderService.getRecordTypeId('E_Shop_Payment_RT');
			objPayment.Transaction_Type__c = 'Purchase';
			objPayment.Event__c = 'eShop';
			objPayment.Payment_Type__c = 'Salesforce clearing Account';
			objPayment.Amount_With_GST__c = ordRef.Order_Amount__c;
			//objPayment.Contact__c = ordRef.Contact__c;
			objPayment.Account__c = ordRef.Account__c;
			objPayment.eInvoice__c = ordRef.eInvoice__c;
			objPayment.eInvoice_Date__c = ordRef.eInvoice_Date__c;
			objPayment.eInvoice_Url__c = ordRef.eInvoice_URL__c;
			//objPayment.Department__c = ordRef.Branch__c;
			objPayment.Department__c = strBranch(ordRef.Site_Name__c);
			objPayment.Brand__c = ordRef.Site_Name__c;
			objPayment.E_shop_OrderId__c = ordRef.OrderID__c;
			objPayment.E_shop_order_number__c = ordRef.E_shop_Order_Number__c;
			//objPayment.E_shop_Order__c = ordRef.Id;
			objPayment.E_shop_transaction_date__c = ordRef.Transaction_Date__c;

			//insert objPayment;
			return objPayment;
		}

		private static string strBranch(string brand)
		{
			Map<String,string> mapBrandtoBranch = new Map<String,string>();

			mapBrandtoBranch.put('DS', 'CCF');
			mapBrandtoBranch.put('CIT', 'CCF');
			mapBrandtoBranch.put('MIT', 'CCA');
			mapBrandtoBranch.put('KIA', 'CCF');
			mapBrandtoBranch.put('MB', 'CCI');

			string strBranch = mapBrandtoBranch.get(brand);

			return strBranch;
        }

    /* Comment out by NSJ   
    // Credit Management Related methods
    public static List<Reward_Usage__c> updateRelatedRewardUsages(Order__c order) {
        List<Reward_Usage__c> relatedRewardUsages = RewardUsageService.getRewardUsagesByOrderId(order.Id);
            if(relatedRewardUsages <> null) {
                for (Reward_Usage__c rewardUsage : relatedRewardUsages) {
                    //rewardUsage.Status__c = 'Utilised';
                    rewardUsage.e_Invoice__c = order.eInvoice__c;
                    rewardUsage.e_Invoice_Date__c = order.eInvoice_Date__c;
                    rewardUsage.e_Invoice_URL__c  = order.eInvoice_URL__c;
                }
        }
        System.debug('relatedRewardUsages == ' + relatedRewardUsages);            
        return (relatedRewardUsages <> null ? relatedRewardUsages : null); 
    }
    
    public static List<Invoice__c> updateRelatedPayments(Order__c order) {
        List<Invoice__c> relatedPayments = PaymentService.getPaymentsByOrderId(order.Id);
        if(relatedPayments <> null) {
            for (Invoice__c payment : relatedPayments)
            {
                payment.eInvoice__c = order.eInvoice__c;
            }
        }
        System.debug('relatedPayments == ' + relatedPayments);  
        return (relatedPayments <> null ? relatedPayments : null); 
    }
	Comment out by NSJ   */

	/* Not in use -------------------------------------------------
	public static void cancelled_paymentSF_clearAcc(Order__c ordRef)
	{
		List<Invoice__c> list_CancelPayment = new List<Invoice__c>();

		if(ordRef.Status__c == 'Cancelled')
		{
			list_CancelPayment = [select id from Invoice__c 
								 where E_shop_Order__c =: ordref.id 
								 and E_shop_Order__c != NULL 
								 and Payment_Type__c = 'Salesforce clearing Account'
								 LIMIT 1];

			if(list_CancelPayment.size() > 0)
			{
				list_CancelPayment[0].Transaction_Type__c = 'Cancel';
				update list_CancelPayment[0];
			}

		}

	}
	*/

}
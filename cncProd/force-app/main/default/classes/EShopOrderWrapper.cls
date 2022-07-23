public class EShopOrderWrapper 
{
    public Order order {get; set;}
    public String UserId {get; set;}
    public String Name {get; set;}
    public String Email {get; set;}
    public string Mobile {get;set;}
    public Boolean Promotions {get;set;}
    
    public class Order
	{
        public String OrderID {get; set;}
		public String OrderNumber {get; set;}
		public String EInvoice {get; set;}
		public String EInvoiceDate {get; set;}
		public String EInvoiceURL {get; set;}
		public String TransactionDate {get; set;}
		public Decimal OrderAmount {get; set;}
		public Decimal OrderAmountBeforeGST {get; set;}
		public Decimal GST {get; set;}
		public String Branch {get; set;}
		public String SiteName {get; set;}
        public String CreatedDate {get; set;}
        public String UpdatedDate {get; set;}
        public String Status {get; set;}
        public String Shop {get; set;}
        public Decimal Subtotal {get; set;}
        public Decimal Adjustment {get; set;}
        public Decimal GrandTotal {get; set;}
        public String PersonAccount {get; set;}  
        public List<ItemWrapper> LineItems = new List<ItemWrapper>();
        
        public Order(){}
    }
    
    public class ItemWrapper
	{
        public String ItemName {get; set;}
        public Decimal ItemSellingPrice {get; set;}
        public Decimal ItemSubtotal {get; set;}
        public Decimal ItemAdjustment {get; set;}
        public Decimal ItemTotal {get; set;}
        public Decimal ItemQuantity {get; set;}
        public String ItemSKU {get; set;}
        public String ItemVariants {get; set;}
        public String ItemCategory {get; set;}
        public String ItemSubCategory {get; set;}
        public String ItemVehicleGroup {get;set;}
        public String ItemVehicleVariant {get;set;}
        public String ItemVehicleNumber {get;set;}
        
        public ItemWrapper(){}
    }
    
    public static Order__c createOrder (EShopOrderWrapper.Order order, String recordTypeId, String contactId)
	{
        Order__c newOrder = new Order__c();
        newOrder.Adjustment__c      = order.Adjustment;

		datetime cd = null;
		datetime ud = null;
		if(order.CreatedDate != null)
		{
			cd = DateTime.valueOf((order.CreatedDate).replaceAll('T',' '));
        }

		if(order.UpdatedDate != null)
		{
			ud = DateTime.valueOf((order.UpdatedDate).replaceAll('T',' '));
        }

		newOrder.Created_Date__c    = cd; //String.isBlank(order.CreatedDate) ? null : Date.valueOf(order.CreatedDate); //cd;	//
        newOrder.Grand_Total__c     = order.GrandTotal;
        newOrder.OrderID__c         = order.OrderID;
        newOrder.RecordTypeId       = recordTypeId;
        newOrder.Contact__c         = contactId;
        newOrder.Shop__c            = order.Shop;
        newOrder.Status__c          = order.Status;
        newOrder.Subtotal__c        = order.Subtotal;
        newOrder.Updated_Date__c    = ud; //String.isBlank(order.UpdatedDate) ? null : Date.valueOf(order.UpdatedDate); //ud;	//
        newOrder.Account__c         = order.PersonAccount;       		
		newOrder.Branch__c	        = order.Branch;
		newOrder.eInvoice__c	    = order.EInvoice;
		newOrder.eInvoice_Date__c	= String.isBlank(order.EInvoiceDate) ? null : Date.valueOf(order.EInvoiceDate);
		newOrder.eInvoice_URL__c	= order.EInvoiceURL;
		newOrder.E_shop_Order_Number__c	    = order.OrderNumber;
		newOrder.GST_Amount__c	            = order.GST;
		newOrder.Order_Amount__c	        = order.OrderAmount;
		newOrder.Order_Amount_Before_GST__c	= order.OrderAmountBeforeGST;
		newOrder.Site_Name__c	            = order.SiteName;
		newOrder.Transaction_Date__c	    = String.isBlank(order.TransactionDate) ? null : Date.valueOf(order.TransactionDate);

        return newOrder;
    }
    
    public static Order_Line_Item__c createOrderLineItem (EShopOrderWrapper.ItemWrapper item, String orderId)
	{  
        return new Order_Line_Item__c(  Item_Adjustment__c = item.itemAdjustment,
                                        Item_Name__c = item.itemName,
                                        Item_Quantity__c = item.itemQuantity,
                                        Item_Selling_Price__c = item.itemSellingPrice,
                                        Item_SKU__c = item.ItemSKU,
                                        Item_Subtotal__c = item.itemSubtotal,
                                        Item_Total__c = item.itemTotal,
                                        Item_Variants__c = item.itemVariants,
                                        Item_Sub_Category__c = item.itemSubCategory,
                                        Item_Category__c = item.itemCategory,
                                        Order__c = orderId,
                                        Item_Vehicle_Group__c = item.ItemVehicleGroup,
                                        Item_Vehicle_Number__c = item.ItemVehicleNumber,
                                        Item_Vehicle_Variant__c = item.ItemVehicleVariant );
    }
    
}
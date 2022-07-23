@isTest
private class EShopOrderCheckoutAPI_Test {
    @testSetup
    static void createData()
    {
        Account customer = Test_DataFactory.createPA(true, 'Bob', 'bob@gmail.com', 'Customer');

        List<RecordType> recTypeOrder = [SELECT id FROM recordtype WHERE SobjectType = 'Order__c' 
                                                AND DeveloperName ='C_C_E_Shop'];

        Order__c order = Test_DataFactory.createOrder(recTypeOrder[0].Id);
        insert order;
        
        customer = [Select PersonContactId From Account LIMIT 1];
        User user = Test_DataFactory.createUser(false, UserInfo.getLastName(), 'asdas');
        insert user;
    }
    
    static testMethod void testInvalidUserId(){
        Test.startTest();
        String reqURI = '/services/apexrest/EShopOrderCheckout/'; 
        String reqBody = '{"UserId":"123456","Name":"Jason","Email":"bob@gmail.com","Mobile":"6596552945","Vehicle Number":"SK1234S","Order":{"OrderID":"12345ABCDEFG","OrderNumber": "Order-12345ABCDEF1","EInvoice": "PJ12345ABCDEF1","EInvoiceDate" : "2020-12-30","EInvoiceURL" : "www.e-shop.com/image12345","TransactionDate" : "2020-12-31","OrderAmount":88.0,"OrderAmountBeforeGST":80.0,"GST" : 7.00,"Branch":"CCF","SiteName":"CIT","CreatedDate":"2020-03-23T02:00:00.000Z","UpdatedDate":"2020-04-25T02:00:00.000Z","Status":"ordered","Shop":"MIT e-shop","Subtotal":7000,"Adjustment":500,"GrandTotal":7999.1,"LineItems":[{"itemName":"water bottle","itemSellingPrice":3000,"itemSubtotal":3000,"itemAdjustment":100,"itemTotal":3000,"itemQuantity":1,"ItemSKU":"Bottle1234D","itemVariants":"KIA bottle","itemCategory":"Lifestyle","itemSubCategory":"CAP"},{"itemName":"cap","itemSellingPrice":2000,"itemSubtotal":2000,"itemAdjustment":200,"itemTotal":2000,"itemQuantity":2,"ItemSKU":"CAP1234D","itemVariants":"KIA CAP","itemCategory":"Lifestyle","itemSubCategory":"CAP"}]}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        EShopOrderCheckoutAPI.checkoutOrder();
        Test.stopTest();
        

        System.debug('@@@ contacts: '+[SELECT Id, Name From Account]);
        System.assertEquals(1, [SELECT Count() FROM Account]);
    }
    
    static testMethod void testNegative(){
        Test.startTest();
        String reqURI = '/services/apexrest/EShopOrderCheckout/'; 
        String reqBody = '{"Name":"Jason","Email":"bob@gmail.com","Mobile":"6596552945","Vehicle Number":"SK1234S","Order":{"OrderID":"12345ABCDEFG","OrderNumber": "Order-12345ABCDEF1","EInvoice": "PJ12345ABCDEF1","EInvoiceDate" : "2020-12-30","EInvoiceURL" : "www.e-shop.com/image12345","TransactionDate" : "2020-12-31","OrderAmount":88.0,"OrderAmountBeforeGST":80.0,"GST" : 7.00,"Branch":"CCF","SiteName":"CIT","CreatedDate":"2020-03-23T02:00:00.000Z","UpdatedDate":"2020-04-25T02:00:00.000Z","Status":"ordered","Shop":"MIT e-shop","Subtotal":7000,"Adjustment":500,"GrandTotal":7999.1,"LineItems":[{"itemName":"water bottle","itemSellingPrice":3000,"itemSubtotal":3000,"itemAdjustment":100,"itemTotal":3000,"itemQuantity":1,"ItemSKU":"Bottle1234D","itemVariants":"KIA bottle","itemCategory":"Test","itemSubCategory":"CAP"},{"itemName":"cap","itemSellingPrice":2000,"itemSubtotal":2000,"itemAdjustment":200,"itemTotal":2000,"itemQuantity":2,"ItemSKU":"CAP1234D","itemVariants":"KIA CAP","itemCategory":"Lifestyle","itemSubCategory":"CAP"}]}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        EShopOrderCheckoutAPI.checkoutOrder();
        Test.stopTest();
        // System.assertEquals(1, [SELECT Count() FROM Contact]);
    }
    
     static testMethod void testNegative2(){
        Test.startTest();
        String reqURI = '/services/apexrest/EShopOrderCheckout/'; 
        String reqBody = '{"Name":"Jason","Email":"JJ22@gmail.com","Mobile":"6596552945","Vehicle Number":"SK1234S","Promotions": true, "Order":{"OrderID":"12345ABCDEFG","OrderNumber": "Order-12345ABCDEF1","EInvoice": "PJ12345ABCDEF1","EInvoiceDate" : "2020-12-30","EInvoiceURL" : "www.e-shop.com/image12345","TransactionDate" : "2020-12-31","OrderAmount":88.0,"OrderAmountBeforeGST":80.0,"GST" : 7.00,"Branch":"CCF","SiteName":"CIT","CreatedDate":"2020-03-23T02:00:00.000Z","UpdatedDate":"2020-04-25T02:00:00.000Z","Status":"ordered","Shop":"MIT e-shop","Subtotal":7000,"Adjustment":500,"GrandTotal":7999.1,"LineItems":[{"itemName":"water bottle","itemSellingPrice":3000,"itemSubtotal":3000,"itemAdjustment":100,"itemTotal":3000,"itemQuantity":1,"ItemSKU":"Bottle1234D","itemVariants":"KIA bottle","itemCategory":"Test","itemSubCategory":"CAP"},{"itemName":"cap","itemSellingPrice":2000,"itemSubtotal":2000,"itemAdjustment":200,"itemTotal":2000,"itemQuantity":2,"ItemSKU":"CAP1234D","itemVariants":"KIA CAP","itemCategory":"Lifestyle","itemSubCategory":"CAP"}]}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        EShopOrderCheckoutAPI.checkoutOrder();
        Test.stopTest();
        // System.assertEquals(1, [SELECT Count() FROM Contact]);
    }
    
    static testMethod void testPositive(){
        Order__c order = [SELECT OrderID__c FROM Order__c LIMIT 1];
        List<User> user = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        String reqURI = '/services/apexrest/EShopOrderCheckout/'; 
        String reqBody = '{"UserId":"'+user[0].Id +'","Name":"Jason","Email":"JJ11@gmail.com","Mobile":"6596552945","Vehicle Number":"SK1234S","Order":{"OrderID":"'+order.OrderID__C+'","OrderNumber": "Order-12345ABCDEF1","EInvoice": "PJ12345ABCDEF1","EInvoiceDate" : "2020-12-30","EInvoiceURL" : "www.e-shop.com/image12345","TransactionDate" : "2020-12-31","OrderAmount":88.0,"OrderAmountBeforeGST":80.0,"GST" : 7.00,"Branch":"CCF","SiteName":"CIT","CreatedDate":"2020-03-23T02:00:00.000Z","UpdatedDate":"2020-04-25T02:00:00.000Z","Status":"ordered","Shop":"MIT e-shop","Subtotal":7000,"Adjustment":500,"GrandTotal":7999.1,"LineItems":[{"itemName":"water bottle","itemSellingPrice":3000,"itemSubtotal":3000,"itemAdjustment":100,"itemTotal":3000,"itemQuantity":1,"ItemSKU":"Bottle1234D","itemVariants":"KIA bottle","itemCategory":"Lifestyle","itemSubCategory":"CAP"},{"itemName":"cap","itemSellingPrice":2000,"itemSubtotal":2000,"itemAdjustment":200,"itemTotal":2000,"itemQuantity":2,"ItemSKU":"CAP1234D","itemVariants":"KIA CAP","itemCategory":"Lifestyle","itemSubCategory":"CAP"}]}}';
        Test_DataFactory.createReqSF( reqURI, 'POST', reqBody, null, 200);
        EShopOrderCheckoutAPI.checkoutOrder();
        Test.stopTest();
        List<Account> lst = [SELECT Id, Name FROM Account];
        system.debug('@@@lst con: '+lst);
        System.assertEquals(1, [SELECT Count() FROM Account]); 
    }
}
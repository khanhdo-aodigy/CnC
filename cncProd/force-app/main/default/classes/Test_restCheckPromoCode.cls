/*******
 * Description : Test class for restCheckPromoCode.cls
 * 
 * Change History : 
 * Date(YYYYMMDD)      Name       Description
 * 20200520             TP     Created Initial Version 
*******/
@isTest
private class Test_restCheckPromoCode {
    
   @isTest
    static void test_restCheckPromoCode_Success() {
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo',
                                         Promo_Code__c = 'ILYMA20000',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(-1),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;
        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Open',
                                                                             Campaign__c = campaign.Id);
        insert member;
        Promo_gift_line_item__c item1 = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                    Gift_type__c = 'Price Discount',
                                                                    Name = '2000');
        insert item1;
        Promo_gift_line_item__c item2 = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                    Gift_type__c = 'Accessories Credit',
                                                                    Name = '4000');
        insert item2;
        Promo_gift_line_item__c item3 = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                    Gift_type__c = 'Gift',
                                                                    Name = 'Blackvue Camera');
        insert item3;

        String reqBody = '{"Email" : "phan.thu@aodigy.com","PromoCode" : "ILYMA20000","PromoCategory" : "Exclusive","Branch" : "CCK","Brand" : "KIA" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restCheckPromoCode';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        restCheckPromoCode.doPost();
        Test.stopTest();
    }

    @isTest
    static void test_restCheckPromoCode_NoCampaignFound() {
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo',
                                         Promo_Code__c = 'ILYMA20000',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(-1),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;
        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Open',
                                                                             Campaign__c = campaign.Id);
        insert member;
        Promo_gift_line_item__c item = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                   Gift_type__c = 'Price Discount',
                                                                   Name = '2000');
        insert item;

        String reqBody = '{"Email" : "phan.thu@aodigy.com","PromoCode" : "ILYMA200004","PromoCategory" : "Exclusive","Branch" : "CCK","Brand" : "KIA" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restCheckPromoCode';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        restCheckPromoCode.doPost();
        Test.stopTest();
    }

    @isTest
    static void test_restCheckPromoCode_NoValidCode() {
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo 2',
                                         Promo_Code__c = 'ILYMA2005',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(3),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;
        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Open',
                                                                             Campaign__c = campaign.Id);
        insert member;
        Promo_gift_line_item__c item = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                   Gift_type__c = 'Price Discount',
                                                                   Name = '2000');
        insert item;

        String reqBody = '{"Email" : "phan.thu@aodigy.com","PromoCode" : "ILYMA2005","PromoCategory" : "Exclusive","Branch" : "CCK","Brand" : "KIA" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restCheckPromoCode';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        restCheckPromoCode.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void test_restCheckPromoCode_EmailError() {
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo 3',
                                         Promo_Code__c = 'ILYMA2007',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(-3),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;
        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Open',
                                                                             Campaign__c = campaign.Id);
        insert member;
        Promo_gift_line_item__c item = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                   Gift_type__c = 'Price Discount',
                                                                   Name = '2000');
        insert item;
        
        String reqBody = '{"Email" : "tphan@aodigy.com","PromoCode" : "ILYMA2007","PromoCategory" : "Exclusive","Branch" : "CCK","Brand" : "KIA" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restCheckPromoCode';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        restCheckPromoCode.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void test_restCheckPromoCode_CodeError() {
        Campaign campaign = new Campaign(Name = 'Kia Special Discount Exclusive Promo 4',
                                         Promo_Code__c = 'ILYMA2008',
                                         Promo_Category__c = 'Exclusive',
                                         Branch_Code__c = 'CCK',
                                         Brand__c = 'KIA',
                                         //RecordTypeId = '012O0000000brQ0IAI',
                                         StartDate = Date.today().addDays(-3),
                                         EndDate = Date.today().addDays(5), 
                                         Promo_Code_Type__c = 'Fixture');
        insert campaign;
        Campaign_Invited_members__c member = new Campaign_Invited_members__c(First_Name__c = 'Tori',
                                                                             Last_Name__c = 'Phan',
                                                                             Email__c = 'phan.thu@aodigy.com',
                                                                             Redeem__c = 'Redeemed',
                                                                             Campaign__c = campaign.Id);
        insert member;
        Promo_gift_line_item__c item = new Promo_gift_line_item__c(Campaign__c = campaign.Id,
                                                                   Gift_type__c = 'Price Discount',
                                                                   Name = '2000');
        insert item;
        
        String reqBody = '{"Email" : "phan.thu@aodigy.com","PromoCode" : "ILYMA2008","PromoCategory" : "Exclusive","Branch" : "CCK","Brand" : "KIA" }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/restCheckPromoCode';
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpGenerator(200,reqBody));
        restCheckPromoCode.doPost();
        Test.stopTest();
    }
}
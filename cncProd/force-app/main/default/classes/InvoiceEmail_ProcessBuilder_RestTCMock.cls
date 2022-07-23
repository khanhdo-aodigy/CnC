@isTest
public class InvoiceEmail_ProcessBuilder_RestTCMock implements HttpCalloutMock 
{
    public HTTPResponse respond(HTTPRequest request) 
    {
        HttpResponse response = new HttpResponse();
        String resBody = '{"Version":"1.0","StatusCode":200,"Timestamp":"2021-04-27T15:27:54.203","Result":{"Promo":[{"PromoID":"701O0000001O9LYIA0","PromoName":"mit-puricaredisinfectingpackage_app","PromoUrl":"/sg/mitsubishi/promos/servicing/mit-puricaredisinfectingpackage_app?sc_device=mobile","PromoTag":"Mitsubishi","PromoTitle":"Test","PromoEndDateLabel":"Ends on","PromoEndingSoonLabel":"ending soon","PromoTermsAndConditions":{"ShortDescription":"abc","Content":"abc"},"PromoShortTitle":"Puri.Care Disinfecting Package Promotion","PromoShortDescription":"test","PromoOverlayImage":"","PromoOverlayText":"Buy Now","PromoCTA":"buy now","PromoExclusiveTag":true}],"Error":null}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(resBody);
        response.setStatusCode(200);

        return response;
    }
}
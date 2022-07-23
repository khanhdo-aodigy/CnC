/** *****
 * Description : API class for Reserve Car Model
 * 
 * Change History : 
 * Date(YYYYMMDD)       Name                            Description
 * 20201230             khanh.do@aodigy.com             Created Initial Version
 * 20210407             HS@aodigy                       Removed compulsory customer mobile check
 * 20210727             khanh.do@aodigy.com             Person Account Merging
 * 
** *****/

@RestResource (urlMapping = '/PriceDetail/insert/*')
global with sharing class RASendPriceDetailAPI {
    private static RestRequest request   = RestContext.request;
    private static RestResponse response = RestContext.response;
    private static RequestBody reqBody   = new RequestBody();
    private static ResponseBody resBody  = new ResponseBody();
    private static Utility.httpErrorResponse errorResponse;
    
    private static String processedRecId;

    @HttpPost
    global static void doPost() {
        try {
            processRequest();
        } catch(Exception ex) {
            response.statusCode = 400;            
            response.responseBody = Blob.valueOf(JSON.Serialize(ex.getMessage()));
            loggerDataPool.buildLogDataPool('RASendPriceDetailAPI',ex);
            System.debug ('Exception: ' + ex.getMessage() + ' || .Error at line: ' + ex.getLineNumber());
        }

        if(errorResponse != null) {    
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.Serialize(errorResponse));
        }
        
        serviceDataPool.buildServiceDataPool('RASendPriceDetailAPI', 'RASendPriceDetailAPI', processedRecId, request, response);
    }

    public static void processRequest() {
        reqBody = (RequestBody)JSON.deserialize(request.requestBody.toString(), RequestBody.class);
        String firstName = reqBody.FirstName;
        String lastName  = reqBody.LastName;
        String mobile    = reqBody.Mobile;
        String email     = reqBody.Email;        
        Boolean consentForMarketing = reqBody.ConsentForMarketingRA;
        String docNo     = reqBody.DocNo;
        String scName    = reqBody.SCName;
        String scEmail   = reqBody.SCEmail;
        String scMobile  = reqBody.SCMobile;
        Boolean isPromo  = reqBody.IsPromo;
        Double financingDiscount = reqBody.VehiclePriceFinancingDiscount;
        Double insuranceDiscount = reqBody.VehiclePriceInsuranceDiscount;
        Double tradeInDiscount   = reqBody.VehiclePriceTradeInDiscount;
        Double promoDiscount     = reqBody.VehiclePricePromoDiscount;
        Double totalVehiclePrice = reqBody.VehiclePriceTotal;
        Double downpayment    = reqBody.CarFinancingDownpayment;
        Double loanAmount     = reqBody.CarFinancingLoadAmount;
        Double interestRate   = reqBody.CarFinancingInterestRate;
        Double loanTerm       = reqBody.CarFinancingLoanTerm;
        Double monthlyInstallment      = reqBody.CarFinancingMonthlyInstallment;
        Double upfrontDownpayment      = reqBody.UpfrontDownpayment;
        Double firstMonthlyInstallment = reqBody.UpfrontFirstMonthlyInstallment;
        Double transferFee         = reqBody.UpfrontTransferFee;
        Double upfrontRoadTax      = reqBody.UpfrontRoadTax;
        Double totalUpfrontPayment = reqBody.UpfrontPaymentTotal;
        List<AddOn> addOns         = reqBody.AddOn;


        if( String.isBlank(firstName) || String.isBlank(lastName)
            //|| String.isBlank(mobile) 
                || String.isBlank(email) || String.isBlank(docNo) || String.isBlank(scName)
                    || String.isBlank(scEmail) || String.isBlank(scMobile)
                        || totalVehiclePrice == null || consentForMarketing == null
        ) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Mandatory field is missing. Please refer API doc');
            return;
        }
            
        if( (String.isNotBlank(mobile) && !mobile.startsWith('65')) || (String.isNotBlank(scMobile) && !scMobile.startsWith('65')) ) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Mobile Phone. Mobile must start with 65');
            return;
        }

        if( (String.isNotBlank(mobile) && !mobile.isNumeric()) || (String.isNotBlank(scMobile) && !scMobile.isNumeric()) ) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Mobile Phone. Mobile must contain number only');
            return;
        }

        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[]{ Purchase_Option__c.SObjectType,
                                                                                              Vehicle_Pricing_Option__c.SObjectType,
                                                                                              Pricing_Option_Add_on__c.SObjectType
                                                                                            } );
        
        Used_Car_Vehicle_Stock__c vehStock = UsedCarVehicleStockService.getVehicleStockByStockNumber(docNo);
        System.debug('vehStock = ' + vehStock);
        if(vehStock == null) {
            errorResponse = new Utility.HttpErrorResponse('Request failed', 'Invalid Used Car Vehicle Stock Number');
            return;
        }

        AccountUtil.RACustomerWrapper customerWrapper = new AccountUtil.RACustomerWrapper(firstName, lastName, email, mobile, consentForMarketing);
        Account personAcc = AccountUtil.upsertRACustomer(customerWrapper, 'Prospect');
        System.debug('@@@@DEBUG processRequest :: personAcc = ' + personAcc );

        Sales_Opportunity__c salesOpp = SalesOpportunityService.upsertSalesOppByAccIdAndSCEmail(personAcc, scEmail, scName, scMobile);

        Purchase_Option__c purchaseOption = new Purchase_Option__c();
        uow.registerNew(purchaseOption);
        uow.registerRelationship(purchaseOption, Purchase_Option__c.Used_Car_Vehicle_Stock__c, vehStock);        
        uow.registerRelationship(purchaseOption, Purchase_Option__c.Sales_Opportunity__c, salesOpp);        
        uow.registerRelationship(purchaseOption, Purchase_Option__c.Account__c, personAcc);      
        uow.registerRelationship(purchaseOption, Purchase_Option__c.Contact__c, new Contact(Id = personAcc.PersonContactId));
        System.debug('purchaseOption = ' + purchaseOption);

        Vehicle_Pricing_Option__c vehPrice = new Vehicle_Pricing_Option__c();
        vehPrice.RecordTypeId = Schema.SObjectType.Vehicle_Pricing_Option__c.getRecordTypeInfosByDeveloperName().get('RA_Vehicle_Pricing_Option_RT').getRecordTypeId();
        vehPrice.Financing_Discount__c         = financingDiscount;
        vehPrice.Insurance_Discount__c         = insuranceDiscount;        
        vehPrice.Trade_in_Discount__c          = tradeInDiscount;
        vehPrice.Promotion_Discount__c         = promoDiscount;
        vehPrice.Total_Vehicle_Price__c        = totalVehiclePrice;
        vehPrice.Car_Financing_Downpayment__c  = downpayment;
        vehPrice.Loan_Amount__c                = loanAmount;
        vehPrice.Interest_Rate__c              = interestRate;
        vehPrice.Loan_Term__c                  = loanTerm;
        vehPrice.Monthly_Installment__c        = monthlyInstallment;
        vehPrice.Upfront_Downpayment__c        = upfrontDownpayment;
        vehPrice.First_Monthly_Installment__c  = firstMonthlyInstallment;
        vehPrice.Transfer_Fee__c               = transferFee;
        vehPrice.Road_Tax_12_Months__c         = upfrontRoadTax;        
        vehPrice.Total_Upfront_Payment__c      = totalUpfrontPayment;
        uow.registerNew( vehPrice, Vehicle_Pricing_Option__c.Purchase_Option__c, purchaseOption );
        
        System.debug('vehPrice = ' + vehPrice);
        if( addOns <> null ){
            for(AddOn item: addOns){
                Pricing_Option_Add_on__c addOn = new Pricing_Option_Add_on__c();
                addOn.RecordTypeId = Schema.SObjectType.Pricing_Option_Add_on__c.getRecordTypeInfosByDeveloperName().get('RA_Pricing_Option_Add_on_RT').getRecordTypeId();
                addOn.Add_on_Name__c = item.AddOnName;
                addOn.Add_on_Price__c = item.AddOnPrice;
                uow.registerNew(addOn, Pricing_Option_Add_on__c.Purchase_Option__c, purchaseOption);
            }
        }

        uow.commitWork();
        processedRecId = purchaseOption.Id;
        response.addHeader('Content-Type', 'application/json');
        response.statusCode = 200;
        resBody.status = 'Success';
        resBody.message = 'Purchase Option ID: ' + purchaseOption.Id;
        response.responseBody = Blob.valueOf(JSON.serialize(resBody));   

    }

    public class ResponseBody {
        public String status;
        public String message;
    }

    public class RequestBody {
        public String FirstName; 
        public String LastName;
        public String Mobile;
        public String Email;        
        public Boolean ConsentForMarketingRA;
        public String DocNo; //Vehicle Stock No
        public String SCName;
        public String SCEmail;
        public String SCMobile;
        public Boolean IsPromo; //new
        public Double VehiclePriceFinancingDiscount;
        public Double VehiclePriceInsuranceDiscount;
        public Double VehiclePriceTradeInDiscount;
        public Double VehiclePricePromoDiscount; //new
        public Double VehiclePriceTotal;
        public Double CarFinancingDownpayment;
        public Double CarFinancingLoadAmount;
        public Double CarFinancingInterestRate;
        public Double CarFinancingLoanTerm;
        public Double CarFinancingMonthlyInstallment;
        public Double UpfrontDownpayment;
        public Double UpfrontFirstMonthlyInstallment;
        public Double UpfrontTransferFee;
        public Double UpfrontRoadTax;
        public Double UpfrontPaymentTotal;
        public List<AddOn> AddOn;
    }

    public class AddOn {
        public String AddOnName;
        public Double AddOnPrice;
    }

}
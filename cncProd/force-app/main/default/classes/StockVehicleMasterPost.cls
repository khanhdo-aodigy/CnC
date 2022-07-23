@RestResource(urlMapping='/StockVehicleMaster/*')
global without sharing class StockVehicleMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');       
        String AgreementDate = req.params.get('AgreementDate');
        String AgreementNo = req.params.get('AgreementNo');
        String AllocationDate = req.params.get('AllocationDate');
        String ARF = req.params.get('ARF');
        String ARFBeforeRebate = req.params.get('ARFBeforeRebate');
        String BranchCode = req.params.get('BranchCode');
        String BranchLocationCode = req.params.get('BranchLocationCode');
        String BranchUniqueCode = req.params.get('BranchUniqueCode');
        String Chassis = req.params.get('Chassis');
        String COEDocumentNo = req.params.get('COEDocumentNo');
        String COEReabteUsedCar = req.params.get('COEReabteUsedCar');
        String COERebateCNC = req.params.get('COERebateCNC');
        String ColorCode = req.params.get('ColorCode');
        String ConfirmationDate = req.params.get('ConfirmationDate');
        String ConfirmationNo = req.params.get('ConfirmationNo');
        String ConversionRate = req.params.get('ConversionRate');
        String CurrencyCode = req.params.get('CurrencyCode');
        String Customercode = req.params.get('Customercode');
        String DeallocationReason = req.params.get('DeallocationReason');
        String DeliveryCertificate = req.params.get('DeliveryCertificate');
        String DeliveryDate = req.params.get('DeliveryDate');
        String DeliveryRequestBy = req.params.get('DeliveryRequestBy');
        String DeliveryRequestDate = req.params.get('DeliveryRequestDate');
        String DeliveryRequestNo = req.params.get('DeliveryRequestNo');
        String DeliverySMSSentDate = req.params.get('DeliverySMSSentDate');
        String DemoCar = req.params.get('DemoCar');
        String DutyAmount = req.params.get('DutyAmount');
        String DutyExempted = req.params.get('DutyExempted');
        String DutyGainLoss = req.params.get('DutyGainLoss');
        String DutyPaymentDocumentNo = req.params.get('DutyPaymentDocumentNo');
        String DutyRequestBy = req.params.get('DutyRequestBy');
        String DutyRequestDate = req.params.get('DutyRequestDate');
        String DutySaleDate = req.params.get('DutySaleDate');
        String DutyStatus = req.params.get('DutyStatus');
        String EngineNo = req.params.get('EngineNo');
        String ETADate = req.params.get('ETADate');
        String FOBAmount = req.params.get('FOBAmount');
        String FOBdate = req.params.get('FOBdate');
        String FOBGainLoss = req.params.get('FOBGainLoss');
        String FOBSaleDate = req.params.get('FOBSaleDate');
        String FranchiseCode = req.params.get('FranchiseCode');
        String FreightCharges = req.params.get('FreightCharges');
        String FulcoStock = req.params.get('FulcoStock');
        String GoodReceiveDate = req.params.get('GoodReceiveDate');
        String GoodReceiveNote = req.params.get('GoodReceiveNote');
        String HandlingCharges = req.params.get('HandlingCharges');
        String InsuranceCharges = req.params.get('InsuranceCharges');
        String InvoiceDate = req.params.get('InvoiceDate');
        String InvoiceNo = req.params.get('InvoiceNo');
        String InwardCostType = req.params.get('InwardCostType');
        String IUDocumentNo = req.params.get('IUDocumentNo');
        String KeyNo = req.params.get('KeyNo');
        String ManufacturePrice = req.params.get('ManufacturePrice');
        String ModelCode = req.params.get('ModelCode');
        String ModelYearCode = req.params.get('ModelYearCode');
        String OMV = req.params.get('OMV');
        String OriginalCommcase = req.params.get('OriginalCommcase');
        String PARFBenefitCNC = req.params.get('PARFBenefitCNC');
        String PARFBenefitUsedCar = req.params.get('PARFBenefitUsedCar');
        String PDI = req.params.get('PDI');
        String PDICompletionDate = req.params.get('PDICompletionDate');
        String ProductionMonth = req.params.get('ProductionMonth');
        String PurchaseOrderNo = req.params.get('PurchaseOrderNo');
        String RegistrationCharges = req.params.get('RegistrationCharges');
        String RegistrationDate = req.params.get('RegistrationDate');
        String RegistrationNo = req.params.get('RegistrationNo');
        String Remarks = req.params.get('Remarks');
        String RequestRegistrationBy = req.params.get('RequestRegistrationBy');
        String RequestRegistrationDate = req.params.get('RequestRegistrationDate');
        String RequestRegistrationNo = req.params.get('RequestRegistrationNo');
        String ReservationNo = req.params.get('ReservationNo');
        String SalePrice = req.params.get('SalePrice');
        String StandardAccural = req.params.get('StandardAccural');
        String StockExclude = req.params.get('StockExclude');
        String SupplementaryInvoiceDate = req.params.get('SupplementaryInvoiceDate');
        String SupplementaryInvoiceNo = req.params.get('SupplementaryInvoiceNo');
        String SystemCommcase = req.params.get('SystemCommcase');
        String TMSFinalSaleDate = req.params.get('TMSFinalSaleDate');
        String TrimCode = req.params.get('TrimCode');
        String UpLiftCharges = req.params.get('UpLiftCharges');
        String UpLiftPer = req.params.get('UpLiftPer');
        String VehcileBayNo = req.params.get('VehcileBayNo');
        String VehicleBayLocationCode = req.params.get('VehicleBayLocationCode');
        String VehicleCost = req.params.get('VehicleCost');
        String VehicleStatus = req.params.get('VehicleStatus');
        String VehicleType = req.params.get('VehicleType');
        String YearOfManufacture = req.params.get('YearOfManufacture');

        
        Vehicle_Master2__c VM=new Vehicle_Master2__c();
        Color_Master__c CM=new Color_Master__c();
        Model_Master__c MM=new Model_Master__c();
        Trim_Master__c TM=new Trim_Master__c();
        Model_Year_Master__c MYM=new Model_Year_Master__c();
        
        String[] dts;
        
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        
        try{
            CM=[select id from Color_Master__c where name=:ColorCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            MM=[select id from Model_Master__c where name=:ModelCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            TM=[select id from Trim_Master__c where name=:TrimCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            String tempName=ModelCode+' '+ModelYearCode;
            MYM=[select id from Model_Year_Master__c where name=:tempName limit 1];
            
            List<Vehicle_Master2__c> VMlist = [SELECT Id, Name, Agreement_Date__c, Agreement_No__c, Allocation_Date__c, ARF__c, ARF_Before_Rebate__c,
                           Branch_Code__c, Branch_Location_Code__c, Branch_Unique_Code__c, Chassis__c, COE_Document_no__c, 
                           COE_Reabte_Used_Car__c, COE_Rebate_CNC__c, Color_Code__c, Confirmation_Date__c, Confirmation_No__c, 
                           Conversion_Rate__c, Currency_Code__c, Customer_code__c, Deallocation_Reason__c, Delivery_Certificate__c, 
                           Delivery_Date__c, Delivery_Request_By__c, Delivery_Request_Date__c, Delivery_Request_No__c, 
                           Delivery_SMS_Sent_Date__c, Demo_Car__c, Duty_Amount__c, Duty_Exempted__c, Duty_Gain_Loss__c, 
                           Duty_Payment_Document_No__c, Duty_Request_By__c, Duty_Request_Date__c, Duty_Sale_Date__c, Duty_Status__c, 
                           Engine_No__c, ETA_Date__c, FOB_Amount__c, FOB_date__c, FOB_Gain_Loss__c, FOB_Sale_Date__c, Franchise_Code__c, 
                           Freight_Charges__c, Fulco_Stock__c, Good_Receive_Date__c, Good_Receive_Note__c, Handling_Charges__c, 
                           Insurance_Charges__c, Invoice_Date__c, Invoice_No__c, Inward_Cost_Type__c, IU_Document_No__c, Key_No__c, 
                           Manufacture_Price__c, Model_Code__c, Model_Year_Code__c, OMV__c, Original_Commcase__c, PARF_Benefit_CNC__c, 
                           PARF_Benefit_Used_Car__c, PDI__c, PDI_Completion_Date__c, ProductionMonth__c, Purchase_Order_No__c, 
                           Registration_Charges__c, Registration_Date__c, Registration_no__c, Remarks__c, Request_Registration_By__c, 
                           Request_Registration_Date__c, Request_Registration_No__c, Reservation_No__c, Sale_Price__c, 
                           Standard_Accural__c, Stock_Exclude__c, Supplementary_Invoice_Date__c, Supplementary_Invoice_No__c, 
                           System_Commcase__c, TMS_Final_Sale_Date__c, Trim_Code__c, Up_Lift_Charges__c, Up_Lift_Per__c, 
                           Vehcile_Bay_No__c, Vehicle_Bay_Location_Code__c, Vehicle_Cost__c, Vehicle_Status__c, Vehicle_Type__c, 
                           Year_Of_Manufacture__c
                    FROM Vehicle_Master2__c
                    WHERE System_Commcase__c=:SystemCommcase and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                    
            if(VMlist != null && VMlist.size() > 0){
            	VM = VMlist[0];
            }
            VM.Trim_Code__c = TM.Id;
            VM.Color_Code__c = CM.Id;
            VM.Model_Code__c = MM.Id;
            VM.Model_Year_Code__c = MYM.Id;
            VM.Original_Commcase__c = OriginalCommcase;
            VM.System_Commcase__c = SystemCommcase;
            if (AgreementDate!=null && AgreementDate!=''){
                dts=AgreementDate.split(':');
                VM.Agreement_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Agreement_No__c = AgreementNo;
            if (AllocationDate!=null && AllocationDate!=''){
                dts=AllocationDate.split(':');
                VM.Allocation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.ARF__c = decimal.valueOf(ARF);
            VM.ARF_Before_Rebate__c = decimal.valueOf(ARFBeforeRebate);
            VM.Branch_Code__c = BranchCode;
            VM.Branch_Location_Code__c = BranchLocationCode;
            VM.Branch_Unique_Code__c = BranchUniqueCode;
            VM.Chassis__c = Chassis;
            VM.COE_Document_no__c = COEDocumentNo;
            VM.COE_Reabte_Used_Car__c = decimal.valueOf(COEReabteUsedCar);
            VM.COE_Rebate_CNC__c = decimal.valueOf(COERebateCNC);
            if (ConfirmationDate!=null && ConfirmationDate!=''){
                dts=ConfirmationDate.split(':');
                VM.Confirmation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Confirmation_No__c = ConfirmationNo;
            VM.Conversion_Rate__c = decimal.valueOf(ConversionRate);
            VM.Currency_Code__c = CurrencyCode;
            VM.Customer_code__c = Customercode;
            VM.Deallocation_Reason__c = DeallocationReason;
            VM.Delivery_Certificate__c = DeliveryCertificate;
            if (DeliveryDate!=null && DeliveryDate!=''){
                dts=DeliveryDate.split(':');
                VM.Delivery_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Delivery_Request_By__c = DeliveryRequestBy;
            if (DeliveryRequestDate!=null && DeliveryRequestDate!=''){
                dts=DeliveryRequestDate.split(':');
                VM.Delivery_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Delivery_Request_No__c = DeliveryRequestNo;
            if (DeliverySMSSentDate!=null && DeliverySMSSentDate!=''){
                dts=DeliverySMSSentDate.split(':');
                VM.Delivery_SMS_Sent_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Demo_Car__c = DemoCar;
            VM.Duty_Amount__c = decimal.valueOf(DutyAmount);
            VM.Duty_Exempted__c = DutyExempted;
            VM.Duty_Gain_Loss__c = decimal.valueOf(DutyGainLoss);
            VM.Duty_Payment_Document_No__c = DutyPaymentDocumentNo;
            VM.Duty_Request_By__c = DutyRequestBy;
            if (DutyRequestDate!=null && DutyRequestDate!=''){
                dts=DutyRequestDate.split(':');
                VM.Duty_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            if (DutySaleDate!=null && DutySaleDate!=''){
                dts=DutySaleDate.split(':');
                VM.Duty_Sale_Date__c  = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Duty_Status__c = DutyStatus;
            VM.Engine_No__c = EngineNo;
            if (ETADate!=null && ETADate!=''){
                dts=ETADate.split(':');
                VM.ETA_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.FOB_Amount__c = decimal.valueOf(FOBAmount);
            if (FOBdate!=null && FOBdate!=''){
                dts=FOBdate.split(':');
                VM.FOB_date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.FOB_Gain_Loss__c = decimal.valueOf(FOBGainLoss);
            if (FOBSaleDate!=null && FOBSaleDate!=''){
                dts=FOBSaleDate.split(':');
                VM.FOB_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Franchise_Code__c = FranchiseCode;
            VM.Freight_Charges__c = decimal.valueOf(FreightCharges);
            VM.Fulco_Stock__c = FulcoStock;
            if (GoodReceiveDate!=null && GoodReceiveDate!=''){
                dts=GoodReceiveDate.split(':');
                VM.Good_Receive_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Good_Receive_Note__c = GoodReceiveNote;
            VM.Handling_Charges__c = decimal.valueOf(HandlingCharges);
            VM.Insurance_Charges__c = decimal.valueOf(InsuranceCharges);
            if (InvoiceDate!=null && InvoiceDate!=''){
                dts=InvoiceDate.split(':');
                VM.Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Invoice_No__c = InvoiceNo;
            if(InwardCostType.contains('AMP')){
            	InwardCostType = InwardCostType.replaceAll('AMP', '&');
            }
            VM.Inward_Cost_Type__c = InwardCostType;
            VM.IU_Document_No__c = IUDocumentNo;
            VM.Key_No__c = KeyNo;
            VM.Manufacture_Price__c = decimal.valueOf(ManufacturePrice);
            VM.OMV__c = decimal.valueOf(OMV);
            VM.PARF_Benefit_CNC__c = decimal.valueOf(PARFBenefitCNC);
            VM.PARF_Benefit_Used_Car__c = decimal.valueOf(PARFBenefitUsedCar);
            VM.PDI__c = PDI;
            if (PDICompletionDate!=null && PDICompletionDate!=''){
                dts=PDICompletionDate.split(':');
                VM.PDI_Completion_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            dts=ProductionMonth.split(':');
            VM.ProductionMonth__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            VM.Purchase_Order_No__c = PurchaseOrderNo;
            VM.Registration_Charges__c = decimal.valueOf(RegistrationCharges);
            if (RegistrationDate!=null && RegistrationDate!=''){
                dts=RegistrationDate.split(':');
                VM.Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Registration_no__c = RegistrationNo;
            VM.Remarks__c = Remarks;
            VM.Request_Registration_By__c = RequestRegistrationBy;
            if (RequestRegistrationDate!=null && RequestRegistrationDate!=''){
                dts=RequestRegistrationDate.split(':');
                VM.Request_Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Request_Registration_No__c = RequestRegistrationNo;
            //VM.Reservation_No__c = ReservationNo;
            VM.Sale_Price__c = decimal.valueOf(SalePrice);
            VM.Standard_Accural__c = decimal.valueOf(StandardAccural);
            VM.Stock_Exclude__c = StockExclude;
            if (SupplementaryInvoiceDate!=null && SupplementaryInvoiceDate!=''){
                dts=SupplementaryInvoiceDate.split(':');
                VM.Supplementary_Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Supplementary_Invoice_No__c = SupplementaryInvoiceNo;
            if (TMSFinalSaleDate!=null && TMSFinalSaleDate!=''){
                dts=TMSFinalSaleDate.split(':');
                VM.TMS_Final_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            VM.Up_Lift_Charges__c = decimal.valueOf(UpLiftCharges);
            VM.Up_Lift_Per__c = decimal.valueOf(UpLiftPer);
            VM.Vehcile_Bay_No__c = VehcileBayNo;
            VM.Vehicle_Bay_Location_Code__c = VehicleBayLocationCode;
            VM.Vehicle_Cost__c = decimal.valueOf(VehicleCost);
            VM.Vehicle_Status__c = VehicleStatus;
            VM.Vehicle_Type__c = VehicleType;
            VM.Year_Of_Manufacture__c = decimal.valueOf(YearOfManufacture);
            
            upsert VM;
            res.responseBody = Blob.valueOf('OK');
             
            
            /*if (Action=='Insert') {
                List<Vehicle_Master2__c> VMlist=[SELECT Id FROM Vehicle_Master2__c
                    WHERE System_Commcase__c=:SystemCommcase and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                if(VMlist.size()<=0){
                VM.Trim_Code__c = TM.Id;
                VM.Color_Code__c = CM.Id;
                VM.Model_Code__c = MM.Id;
                VM.Model_Year_Code__c = MYM.Id;
                VM.Original_Commcase__c = OriginalCommcase;
                VM.System_Commcase__c = SystemCommcase;
                if (AgreementDate!=null && AgreementDate!=''){
                    dts=AgreementDate.split(':');
                    VM.Agreement_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Agreement_No__c = AgreementNo;
                if (AllocationDate!=null && AllocationDate!=''){
                    dts=AllocationDate.split(':');
                    VM.Allocation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.ARF__c = decimal.valueOf(ARF);
                VM.ARF_Before_Rebate__c = decimal.valueOf(ARFBeforeRebate);
                VM.Branch_Code__c = BranchCode;
                VM.Branch_Location_Code__c = BranchLocationCode;
                VM.Branch_Unique_Code__c = BranchUniqueCode;
                VM.Chassis__c = Chassis;
                VM.COE_Document_no__c = COEDocumentNo;
                VM.COE_Reabte_Used_Car__c = decimal.valueOf(COEReabteUsedCar);
                VM.COE_Rebate_CNC__c = decimal.valueOf(COERebateCNC);
                if (ConfirmationDate!=null && ConfirmationDate!=''){
                    dts=ConfirmationDate.split(':');
                    VM.Confirmation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Confirmation_No__c = ConfirmationNo;
                VM.Conversion_Rate__c = decimal.valueOf(ConversionRate);
                VM.Currency_Code__c = CurrencyCode;
                VM.Customer_code__c = Customercode;
                VM.Deallocation_Reason__c = DeallocationReason;
                VM.Delivery_Certificate__c = DeliveryCertificate;
                if (DeliveryDate!=null && DeliveryDate!=''){
                    dts=DeliveryDate.split(':');
                    VM.Delivery_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Delivery_Request_By__c = DeliveryRequestBy;
                if (DeliveryRequestDate!=null && DeliveryRequestDate!=''){
                    dts=DeliveryRequestDate.split(':');
                    VM.Delivery_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Delivery_Request_No__c = DeliveryRequestNo;
                if (DeliverySMSSentDate!=null && DeliverySMSSentDate!=''){
                    dts=DeliverySMSSentDate.split(':');
                    VM.Delivery_SMS_Sent_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Demo_Car__c = DemoCar;
                VM.Duty_Amount__c = decimal.valueOf(DutyAmount);
                VM.Duty_Exempted__c = DutyExempted;
                VM.Duty_Gain_Loss__c = decimal.valueOf(DutyGainLoss);
                VM.Duty_Payment_Document_No__c = DutyPaymentDocumentNo;
                VM.Duty_Request_By__c = DutyRequestBy;
                if (DutyRequestDate!=null && DutyRequestDate!=''){
                    dts=DutyRequestDate.split(':');
                    VM.Duty_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                if (DutySaleDate!=null && DutySaleDate!=''){
                    dts=DutySaleDate.split(':');
                    VM.Duty_Sale_Date__c  = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Duty_Status__c = DutyStatus;
                VM.Engine_No__c = EngineNo;
                if (ETADate!=null && ETADate!=''){
                    dts=ETADate.split(':');
                    VM.ETA_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.FOB_Amount__c = decimal.valueOf(FOBAmount);
                if (FOBdate!=null && FOBdate!=''){
                    dts=FOBdate.split(':');
                    VM.FOB_date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.FOB_Gain_Loss__c = decimal.valueOf(FOBGainLoss);
                if (FOBSaleDate!=null && FOBSaleDate!=''){
                    dts=FOBSaleDate.split(':');
                    VM.FOB_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Franchise_Code__c = FranchiseCode;
                VM.Freight_Charges__c = decimal.valueOf(FreightCharges);
                VM.Fulco_Stock__c = FulcoStock;
                if (GoodReceiveDate!=null && GoodReceiveDate!=''){
                    dts=GoodReceiveDate.split(':');
                    VM.Good_Receive_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Good_Receive_Note__c = GoodReceiveNote;
                VM.Handling_Charges__c = decimal.valueOf(HandlingCharges);
                VM.Insurance_Charges__c = decimal.valueOf(InsuranceCharges);
                if (InvoiceDate!=null && InvoiceDate!=''){
                    dts=InvoiceDate.split(':');
                    VM.Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Invoice_No__c = InvoiceNo;
                VM.Inward_Cost_Type__c = InwardCostType;
                VM.IU_Document_No__c = IUDocumentNo;
                VM.Key_No__c = KeyNo;
                VM.Manufacture_Price__c = decimal.valueOf(ManufacturePrice);
                VM.OMV__c = decimal.valueOf(OMV);
                VM.PARF_Benefit_CNC__c = decimal.valueOf(PARFBenefitCNC);
                VM.PARF_Benefit_Used_Car__c = decimal.valueOf(PARFBenefitUsedCar);
                VM.PDI__c = PDI;
                if (PDICompletionDate!=null && PDICompletionDate!=''){
                    dts=PDICompletionDate.split(':');
                    VM.PDI_Completion_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                dts=ProductionMonth.split(':');
                VM.ProductionMonth__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                VM.Purchase_Order_No__c = PurchaseOrderNo;
                VM.Registration_Charges__c = decimal.valueOf(RegistrationCharges);
                if (RegistrationDate!=null && RegistrationDate!=''){
                    dts=RegistrationDate.split(':');
                    VM.Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Registration_no__c = RegistrationNo;
                VM.Remarks__c = Remarks;
                VM.Request_Registration_By__c = RequestRegistrationBy;
                if (RequestRegistrationDate!=null && RequestRegistrationDate!=''){
                    dts=RequestRegistrationDate.split(':');
                    VM.Request_Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Request_Registration_No__c = RequestRegistrationNo;
                //VM.Reservation_No__c = ReservationNo;
                VM.Sale_Price__c = decimal.valueOf(SalePrice);
                VM.Standard_Accural__c = decimal.valueOf(StandardAccural);
                VM.Stock_Exclude__c = StockExclude;
                if (SupplementaryInvoiceDate!=null && SupplementaryInvoiceDate!=''){
                    dts=SupplementaryInvoiceDate.split(':');
                    VM.Supplementary_Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Supplementary_Invoice_No__c = SupplementaryInvoiceNo;
                if (TMSFinalSaleDate!=null && TMSFinalSaleDate!=''){
                    dts=TMSFinalSaleDate.split(':');
                    VM.TMS_Final_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Up_Lift_Charges__c = decimal.valueOf(UpLiftCharges);
                VM.Up_Lift_Per__c = decimal.valueOf(UpLiftPer);
                VM.Vehcile_Bay_No__c = VehcileBayNo;
                VM.Vehicle_Bay_Location_Code__c = VehicleBayLocationCode;
                VM.Vehicle_Cost__c = decimal.valueOf(VehicleCost);
                VM.Vehicle_Status__c = VehicleStatus;
                VM.Vehicle_Type__c = VehicleType;
                VM.Year_Of_Manufacture__c = decimal.valueOf(YearOfManufacture);
                
                insert VM;
                res.responseBody = Blob.valueOf('OK');
                }else{
                //send email eror
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> idList = new List<String>();
                List<String> mailToAddresses = new List<String>();
                Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'VSMS Admin'];
                for (GroupMember gm : g.groupMembers) {
                    idList.add(gm.userOrGroupId);
                }
                User[] usr = [SELECT email FROM user WHERE id IN :idList];
                for(User u : usr) {
                    mailToAddresses.add(u.email);
                }
                mail.setToAddresses(mailToAddresses);
                mail.setSubject('Stock Vehicle Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            
            if (Action=='Update') {
                VM=[SELECT Id, Name, Agreement_Date__c, Agreement_No__c, Allocation_Date__c, ARF__c, ARF_Before_Rebate__c,
                           Branch_Code__c, Branch_Location_Code__c, Branch_Unique_Code__c, Chassis__c, COE_Document_no__c, 
                           COE_Reabte_Used_Car__c, COE_Rebate_CNC__c, Color_Code__c, Confirmation_Date__c, Confirmation_No__c, 
                           Conversion_Rate__c, Currency_Code__c, Customer_code__c, Deallocation_Reason__c, Delivery_Certificate__c, 
                           Delivery_Date__c, Delivery_Request_By__c, Delivery_Request_Date__c, Delivery_Request_No__c, 
                           Delivery_SMS_Sent_Date__c, Demo_Car__c, Duty_Amount__c, Duty_Exempted__c, Duty_Gain_Loss__c, 
                           Duty_Payment_Document_No__c, Duty_Request_By__c, Duty_Request_Date__c, Duty_Sale_Date__c, Duty_Status__c, 
                           Engine_No__c, ETA_Date__c, FOB_Amount__c, FOB_date__c, FOB_Gain_Loss__c, FOB_Sale_Date__c, Franchise_Code__c, 
                           Freight_Charges__c, Fulco_Stock__c, Good_Receive_Date__c, Good_Receive_Note__c, Handling_Charges__c, 
                           Insurance_Charges__c, Invoice_Date__c, Invoice_No__c, Inward_Cost_Type__c, IU_Document_No__c, Key_No__c, 
                           Manufacture_Price__c, Model_Code__c, Model_Year_Code__c, OMV__c, Original_Commcase__c, PARF_Benefit_CNC__c, 
                           PARF_Benefit_Used_Car__c, PDI__c, PDI_Completion_Date__c, ProductionMonth__c, Purchase_Order_No__c, 
                           Registration_Charges__c, Registration_Date__c, Registration_no__c, Remarks__c, Request_Registration_By__c, 
                           Request_Registration_Date__c, Request_Registration_No__c, Reservation_No__c, Sale_Price__c, 
                           Standard_Accural__c, Stock_Exclude__c, Supplementary_Invoice_Date__c, Supplementary_Invoice_No__c, 
                           System_Commcase__c, TMS_Final_Sale_Date__c, Trim_Code__c, Up_Lift_Charges__c, Up_Lift_Per__c, 
                           Vehcile_Bay_No__c, Vehicle_Bay_Location_Code__c, Vehicle_Cost__c, Vehicle_Status__c, Vehicle_Type__c, 
                           Year_Of_Manufacture__c
                    FROM Vehicle_Master2__c
                    WHERE System_Commcase__c=:SystemCommcase and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                
                VM.Trim_Code__c = TM.Id;
                VM.Color_Code__c = CM.Id;
                VM.Model_Code__c = MM.Id;
                VM.Model_Year_Code__c = MYM.Id;
                VM.Original_Commcase__c = OriginalCommcase;
                VM.System_Commcase__c = SystemCommcase;
                if (AgreementDate!=null && AgreementDate!=''){
                    dts=AgreementDate.split(':');
                    VM.Agreement_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Agreement_No__c = AgreementNo;
                if (AllocationDate!=null && AllocationDate!=''){
                    dts=AllocationDate.split(':');
                    VM.Allocation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.ARF__c = decimal.valueOf(ARF);
                VM.ARF_Before_Rebate__c = decimal.valueOf(ARFBeforeRebate);
                VM.Branch_Code__c = BranchCode;
                VM.Branch_Location_Code__c = BranchLocationCode;
                VM.Branch_Unique_Code__c = BranchUniqueCode;
                VM.Chassis__c = Chassis;
                VM.COE_Document_no__c = COEDocumentNo;
                VM.COE_Reabte_Used_Car__c = decimal.valueOf(COEReabteUsedCar);
                VM.COE_Rebate_CNC__c = decimal.valueOf(COERebateCNC);
                if (ConfirmationDate!=null && ConfirmationDate!=''){
                    dts=ConfirmationDate.split(':');
                    VM.Confirmation_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Confirmation_No__c = ConfirmationNo;
                VM.Conversion_Rate__c = decimal.valueOf(ConversionRate);
                VM.Currency_Code__c = CurrencyCode;
                VM.Customer_code__c = Customercode;
                VM.Deallocation_Reason__c = DeallocationReason;
                VM.Delivery_Certificate__c = DeliveryCertificate;
                if (DeliveryDate!=null && DeliveryDate!=''){
                    dts=DeliveryDate.split(':');
                    VM.Delivery_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Delivery_Request_By__c = DeliveryRequestBy;
                if (DeliveryRequestDate!=null && DeliveryRequestDate!=''){
                    dts=DeliveryRequestDate.split(':');
                    VM.Delivery_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Delivery_Request_No__c = DeliveryRequestNo;
                if (DeliverySMSSentDate!=null && DeliverySMSSentDate!=''){
                    dts=DeliverySMSSentDate.split(':');
                    VM.Delivery_SMS_Sent_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Demo_Car__c = DemoCar;
                VM.Duty_Amount__c = decimal.valueOf(DutyAmount);
                VM.Duty_Exempted__c = DutyExempted;
                VM.Duty_Gain_Loss__c = decimal.valueOf(DutyGainLoss);
                VM.Duty_Payment_Document_No__c = DutyPaymentDocumentNo;
                VM.Duty_Request_By__c = DutyRequestBy;
                if (DutyRequestDate!=null && DutyRequestDate!=''){
                    dts=DutyRequestDate.split(':');
                    VM.Duty_Request_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                if (DutySaleDate!=null && DutySaleDate!=''){
                    dts=DutySaleDate.split(':');
                    VM.Duty_Sale_Date__c  = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Duty_Status__c = DutyStatus;
                VM.Engine_No__c = EngineNo;
                if (ETADate!=null && ETADate!=''){
                    dts=ETADate.split(':');
                    VM.ETA_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.FOB_Amount__c = decimal.valueOf(FOBAmount);
                if (FOBdate!=null && FOBdate!=''){
                    dts=FOBdate.split(':');
                    VM.FOB_date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.FOB_Gain_Loss__c = decimal.valueOf(FOBGainLoss);
                if (FOBSaleDate!=null && FOBSaleDate!=''){
                    dts=FOBSaleDate.split(':');
                    VM.FOB_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Franchise_Code__c = FranchiseCode;
                VM.Freight_Charges__c = decimal.valueOf(FreightCharges);
                VM.Fulco_Stock__c = FulcoStock;
                if (GoodReceiveDate!=null && GoodReceiveDate!=''){
                    dts=GoodReceiveDate.split(':');
                    VM.Good_Receive_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Good_Receive_Note__c = GoodReceiveNote;
                VM.Handling_Charges__c = decimal.valueOf(HandlingCharges);
                VM.Insurance_Charges__c = decimal.valueOf(InsuranceCharges);
                if (InvoiceDate!=null && InvoiceDate!=''){
                    dts=InvoiceDate.split(':');
                    VM.Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Invoice_No__c = InvoiceNo;
                VM.Inward_Cost_Type__c = InwardCostType;
                VM.IU_Document_No__c = IUDocumentNo;
                VM.Key_No__c = KeyNo;
                VM.Manufacture_Price__c = decimal.valueOf(ManufacturePrice);
                VM.OMV__c = decimal.valueOf(OMV);
                VM.PARF_Benefit_CNC__c = decimal.valueOf(PARFBenefitCNC);
                VM.PARF_Benefit_Used_Car__c = decimal.valueOf(PARFBenefitUsedCar);
                VM.PDI__c = PDI;
                if (PDICompletionDate!=null && PDICompletionDate!=''){
                    dts=PDICompletionDate.split(':');
                    VM.PDI_Completion_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                dts=ProductionMonth.split(':');
                VM.ProductionMonth__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                VM.Purchase_Order_No__c = PurchaseOrderNo;
                VM.Registration_Charges__c = decimal.valueOf(RegistrationCharges);
                if (RegistrationDate!=null && RegistrationDate!=''){
                    dts=RegistrationDate.split(':');    
                    VM.Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Registration_no__c = RegistrationNo;
                VM.Remarks__c = Remarks;
                VM.Request_Registration_By__c = RequestRegistrationBy;
                if (RequestRegistrationDate!=null && RequestRegistrationDate!=''){
                    dts=RequestRegistrationDate.split(':');
                    VM.Request_Registration_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Request_Registration_No__c = RequestRegistrationNo;
                //VM.Reservation_No__c = ReservationNo;
                VM.Sale_Price__c = decimal.valueOf(SalePrice);
                VM.Standard_Accural__c = decimal.valueOf(StandardAccural);
                VM.Stock_Exclude__c = StockExclude;
                if (SupplementaryInvoiceDate!=null && SupplementaryInvoiceDate!=''){
                    dts=SupplementaryInvoiceDate.split(':');
                    VM.Supplementary_Invoice_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Supplementary_Invoice_No__c = SupplementaryInvoiceNo;
                if (TMSFinalSaleDate!=null && TMSFinalSaleDate!=''){
                    dts=TMSFinalSaleDate.split(':');
                    VM.TMS_Final_Sale_Date__c = date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                VM.Up_Lift_Charges__c = decimal.valueOf(UpLiftCharges);
                VM.Up_Lift_Per__c = decimal.valueOf(UpLiftPer);
                VM.Vehcile_Bay_No__c = VehcileBayNo;
                VM.Vehicle_Bay_Location_Code__c = VehicleBayLocationCode;
                VM.Vehicle_Cost__c = decimal.valueOf(VehicleCost);
                VM.Vehicle_Status__c = VehicleStatus;
                VM.Vehicle_Type__c = VehicleType;
                VM.Year_Of_Manufacture__c = decimal.valueOf(YearOfManufacture);
                
                update VM;
                res.responseBody = Blob.valueOf('OK');
            }*/
         
        }catch(Exception e) {
            res.responseBody = Blob.valueOf('The following exception has occurred: ' + e.getMessage());
            System.debug('The following exception has occurred: ' + e.getMessage());
            //send email eror
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> idList = new List<String>();
            List<String> mailToAddresses = new List<String>();
            Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'VSMS Admin'];
            for (GroupMember gm : g.groupMembers) {
                idList.add(gm.userOrGroupId);
            }
            User[] usr = [SELECT email FROM user WHERE id IN :idList];
            for(User u : usr) {
                mailToAddresses.add(u.email);
            }
            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Stock Vehicle Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
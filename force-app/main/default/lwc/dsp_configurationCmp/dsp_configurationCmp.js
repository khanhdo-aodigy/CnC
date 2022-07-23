/* eslint-disable no-unused-expressions */

/*
const FIELDS_TO_BE_DISABLED = {     COE :{  pickListAsButton : [{ apiName:'COE_Package__c' },{ apiName: 'Number_of_COE_Bids__c'}],
                                            inputField : [{ apiName: 'COE_Charged_Rebate__c'}],
                                            heckbox :[{    apiName: 'Open_Category_COE_Option__c'}]}
                                }

const CONFIGURATION_PICKLIST =  [   {   listItem : 'LTA Assigned Number (for new car)',
                                        collapsible : false,
                                    },
                                    {  listItem : 'Number Retention (for new car) & Acceptance of Random Number (for used car)',
                                        collapsible : true,
                                        inputFields : [{apiName : 'Used_Car_Registration_Number__c', label:"Used Car Registration Number", existingValue: ""}],
                                    },
                                    {  listItem : 'Number Retention (for new car) & Use of Purchase-Bid Number (for used car)',
                                        collapsible : true,
                                        inputFields : [{apiName : 'Used_Car_Registration_Number__c', label:"Used Car Registration Number", existingValue: ""}],
                                    },
                                    {  listItem : 'Purchasing-Bid Number (for new car)',
                                        collapsible : true,
                                        inputFields : [{apiName : 'Bid_Number__c', label:"Bid Number", existingValue: ""}],
                                    },
                                    {  listItem : 'To be decided',
                                        collapsible : true,
                                        messageToDisplay : [{msg:'Registration Number Method has to be decided before Registration.'}]
                                    },
                                ]

const VEH_FIELDS = ['Sales_Agreement__c.Id','Sales_Agreement__c.Model__c', 'Sales_Agreement__c.Trim__c', 'Sales_Agreement__c.COECategory__c',
                'Sales_Agreement__c.Color__c', 'Sales_Agreement__c.PurchasewithCOE__c','Sales_Agreement__c.COE_Package__c',
                'Sales_Agreement__c.Number_of_COE_Bids__c', 'Sales_Agreement__c.COE_Charged_Rebate__c', 'Sales_Agreement__c.Registration_Number_Type__c',
                'Sales_Agreement__c.isPromotionVehicle__c', 'Sales_Agreement__c.Package_Header__r.PKH_PKGPRICE__c','Sales_Agreement__c.Service_Credit__c',
                'Sales_Agreement__c.COE_Refund__c','Sales_Agreement__c.Promo_Discount__c', 'Sales_Agreement__c.Accessories_Discount__c',
                'Sales_Agreement__c.Branch_Code__c','Sales_Agreement__c.VehicleListPrice__c', 'Sales_Agreement__c.Vehicle_Purchase_Price__c',
                'Sales_Agreement__c.Registration_Number_Method__c', 'Sales_Agreement__c.Bid_Number__c', 'Sales_Agreement__c.Used_Car_Registration_Number__c',
                'Sales_Agreement__c.Open_Category_COE_Option__c', 'Sales_Agreement__c.Customer_Purchased_COE__c','Sales_Agreement__c.Total_VES_Roadtax_and_fees__c',
                'Sales_Agreement__c.Road_Tax_Top_Up__c', 'Sales_Agreement__c.service_credit_effective_years__c','Sales_Agreement__c.Total_Discount_Price__c'];
*/

const TRADEIN_FIELDS = [ 'Sales_Agreement__c.DeliveryFrom__c' ,'Sales_Agreement__c.DeliveryTo__c', 'Sales_Agreement__c.MobileSA__c',
                'Sales_Agreement__c.FirstName__c', 'Sales_Agreement__c.COE_Package__c','Sales_Agreement__c.Registration_Number_Method__c', 'Sales_Agreement__c.Terms_Years__c', 'Sales_Agreement__c.Premium_Payable__c'
                ,'Sales_Agreement__c.AcknowledgementAgreement__c','Sales_Agreement__c.AcknowledgementCOE__c','Sales_Agreement__c.AcknowledgementDeposits__c','Sales_Agreement__c.AcknowledgementInsurance__c'
                ,'Sales_Agreement__c.AcknowledgementPersonalData__c','Sales_Agreement__c.AcknowledgementTradeIn__c','Sales_Agreement__c.AcknowledgementVehiclePrices__c','Sales_Agreement__c.Amount_to_Finance__c'
                ,'Sales_Agreement__c.Building_NameRA__c','Sales_Agreement__c.Building_NameMA__c','Sales_Agreement__c.COECategory__c','Sales_Agreement__c.COE_Charged_Rebate__c'
                ,'Sales_Agreement__c.COE_Deposit__c','Sales_Agreement__c.Color__c','Sales_Agreement__c.Customer_Full_Name__c'
                ,'Sales_Agreement__c.Date_Of_Birth__c','Sales_Agreement__c.Expected_Delivery_From__c','Sales_Agreement__c.Expected_Delivery_To__c','Sales_Agreement__c.Finance_Company__c'
                ,'Sales_Agreement__c.Floor_UnitRA__c','Sales_Agreement__c.Floor_UnitMA__c','Sales_Agreement__c.Full_Settlement_Amount__c','Sales_Agreement__c.Gender__c'
                ,'Sales_Agreement__c.GMS_Package__c','Sales_Agreement__c.Insurance_Package__c','Sales_Agreement__c.Last_save_on_form__c','Sales_Agreement__c.Marital_Status__c'
                ,'Sales_Agreement__c.Mobile__c','Sales_Agreement__c.Model__c','Sales_Agreement__c.Model_Color_Trim__c','Sales_Agreement__c.MonthlyInstalment__c'
                ,'Sales_Agreement__c.NCD__c','Sales_Agreement__c.New_Insurance_Company__c','Sales_Agreement__c.NRIC_Number__c','Sales_Agreement__c.Number_of_COE_Bids__c'
                ,'Sales_Agreement__c.Old_Insurance_Company__c','Sales_Agreement__c.Open_Category_CatE__c','Sales_Agreement__c.Open_Category_COE_Option__c','Sales_Agreement__c.Open_COE_Quota_Premium__c'
                ,'Sales_Agreement__c.Postal_CodeRA__c','Sales_Agreement__c.Postal_CodeMA__c','Sales_Agreement__c.PurchasewithCOE__c','Sales_Agreement__c.Rate_p_a__c'
                ,'Sales_Agreement__c.RegistrationInstruction__c','Sales_Agreement__c.Registration_Number_Type__c','Sales_Agreement__c.Salutation__c','Sales_Agreement__c.Secondary_Contact_No__c'
                ,'Sales_Agreement__c.Street_NameRA__c','Sales_Agreement__c.Street_NameMA__c','Sales_Agreement__c.Surname__c','Sales_Agreement__c.Trade_in_Value__c'
                ,'Sales_Agreement__c.Trim__c','Sales_Agreement__c.Used_Car_Make__c','Sales_Agreement__c.Used_Car_Registration_Number__c','Sales_Agreement__c.Used_Car_Vehicle_Finance_Company__c'
                ,'Sales_Agreement__c.User_Car_Model__c','Sales_Agreement__c.Vehicle_Deposit__c','Sales_Agreement__c.VehicleListPrice__c','Sales_Agreement__c.emailaddress__c'
                ,'Sales_Agreement__c.Trade_In_Used_Car_Registration_Number__c', 'Sales_Agreement__c.isSellerNotBuyer__c', 'Sales_Agreement__c.isUsedCarUnderCompany__c'
                ,'Sales_Agreement__c.Seller_First_Name__c', 'Sales_Agreement__c.Seller_Last_Name__c', 'Sales_Agreement__c.Seller_Email_Address__c','Sales_Agreement__c.Seller_Mobile_Number__c'
                ,'Sales_Agreement__c.Seller_Company_Name__c', 'Sales_Agreement__c.DSA_Registration_Number__c', 'Sales_Agreement__c.Package_List_Price__c'
                ,'Sales_Agreement__c.Seller_Company_UEN__c', 'Sales_Agreement__c.Seller_GST_Registration_No__c'
                ,'Sales_Agreement__c.Seller_NRIC__c', 'Sales_Agreement__c.Seller_Date_Of_Birth__c', 'Sales_Agreement__c.Seller_Full_Name__c'
                ,'Sales_Agreement__c.Seller_Street_Name__c', 'Sales_Agreement__c.Seller_Floor_Unit__c', 'Sales_Agreement__c.Seller_Building_Name__c', 'Sales_Agreement__c.Seller_Postal_Code__c'
                ,'Sales_Agreement__c.Trade_in_Date__c', 'Sales_Agreement__c.Customer_Type__c', 'Sales_Agreement__c.Seller_Type__c'
                ];
/*

const SERVICE_CREDIT_WEF_DURATION = {   getWEFYears(serviceCredit){
                                        let isFound = false, WEFYear = 1;
                                        this.ServiceWEFRange.forEach(element => {
                                            isFound = serviceCredit >= element.Min && serviceCredit <= element.Max;
                                            WEFYear = isFound === true ? element.Year : WEFYear;
                                        }); return WEFYear;
                                    },
                                    ServiceWEFRange: [{ Year : 1, Min : 0 , Max: 1999 },
                                                    { Year : 2, Min : 2000 , Max: 2999},
                                                    { Year : 3, Min : 3000 , Max: 3999},
                                                    { Year : 4, Min : 4000 , Max: 4999},
                                                    { Year : 5, Min : 5000 , Max: 5999},
                                                    { Year : 6, Min : 6000 , Max: 6999},
                                                    { Year : 7, Min : 7000 , Max: 7999},
                                                    { Year : 8, Min : 8000 , Max: 8999},
                                                    { Year : 9, Min : 9000 , Max: 9999},
                                                    { Year : 10, Min : 10000 , Max: 10999}]};


                                                    
const GET_ROADTAX_LABEL = {Label : [{'RoadTaxType': 'R004', 'RoadTaxDisplayLabel': '12 Months'},{'RoadTaxType': 'R002', 'RoadTaxDisplayLabel': '6 Months'}],
                          getRoadTaxLabel (roadTaxType){

                            return  this.Label.find((row)=>{
                                  return row.RoadTaxType === roadTaxType;
                              }).RoadTaxDisplayLabel;
                          }};
                          const VEHICLE_REQUIRED_FIELDS =  {checkedFields : [{apiname : 'Registration_Number_Method__c', component: 'c-picklist-as-accordion-cmp', isFilled: false, 
                          errorMsg: 'Please select a Registration Number Method'}],
              processRequiredFieldsFirstTimeLoad(salesRec){
                  this.checkedFields.forEach(elem=>{
                      salesRec[elem.apiname].value && (elem.isFilled = true); 
                  })
              },
              validationCheck(document){    
                  let isError = false;
                  const failedCheckList = this.checkedFields.filter((row) => {
                      return row.isFilled === false;
                  });
                  failedCheckList.forEach(row=>{
                      document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
                          elem.setErrorMsg({ errorMsg: row.errorMsg});
                          document.errorMsg = row.errorMsg;
                          isError = true;
                      })
                  });
                  return isError;
              },
              setIsFilled(apiName){
                  const rowFound = this.checkedFields.find( row => row.apiname === apiName );
                  rowFound && (rowFound.isFilled = true);
              }
          };
*/
const STOCK_RESERVATION_FIELDS = ['Stock_Reservation__c.Id', 'Stock_Reservation__c.Registration_Type__c', 'Stock_Reservation__c.Model_Code__r.Id', 'Stock_Reservation__c.Package_Header_From_PickList__c'];
const DEPOSIT_FIELDS = ['Sales_Agreement__c.Vehicle_Deposit__c', 'Sales_Agreement__c.COE_Deposit__c'
                ,'Sales_Agreement__c.Expected_Delivery_From__c', 'Sales_Agreement__c.Expected_Delivery_To__c'
                ,'Sales_Agreement__c.RegistrationInstruction__c'];
const REVIEW_FIELDS = [ 'Sales_Agreement__c.Id' ,'Sales_Agreement__c.DeliveryFrom__c' ,'Sales_Agreement__c.DeliveryTo__c', 'Sales_Agreement__c.MobileSA__c',
                'Sales_Agreement__c.FirstName__c', 'Sales_Agreement__c.COE_Package__c','Sales_Agreement__c.Registration_Number_Method__c', 'Sales_Agreement__c.Terms_Years__c', 'Sales_Agreement__c.Premium_Payable__c'
                ,'Sales_Agreement__c.AcknowledgementAgreement__c','Sales_Agreement__c.AcknowledgementCOE__c','Sales_Agreement__c.AcknowledgementDeposits__c','Sales_Agreement__c.AcknowledgementInsurance__c'
                ,'Sales_Agreement__c.AcknowledgementPersonalData__c','Sales_Agreement__c.AcknowledgementTradeIn__c','Sales_Agreement__c.AcknowledgementVehiclePrices__c','Sales_Agreement__c.Amount_to_Finance__c'
                ,'Sales_Agreement__c.Building_NameRA__c','Sales_Agreement__c.Building_NameMA__c','Sales_Agreement__c.COECategory__c','Sales_Agreement__c.COE_Charged_Rebate__c'
                ,'Sales_Agreement__c.COE_Deposit__c','Sales_Agreement__c.Color__c','Sales_Agreement__c.Customer_Full_Name__c'
                ,'Sales_Agreement__c.Date_Of_Birth__c','Sales_Agreement__c.Expected_Delivery_From__c','Sales_Agreement__c.Expected_Delivery_To__c','Sales_Agreement__c.Finance_Company__c'
                ,'Sales_Agreement__c.Floor_UnitRA__c','Sales_Agreement__c.Floor_UnitMA__c','Sales_Agreement__c.Full_Settlement_Amount__c','Sales_Agreement__c.Gender__c'
                ,'Sales_Agreement__c.GMS_Package__c','Sales_Agreement__c.Insurance_Package__c','Sales_Agreement__c.Last_save_on_form__c','Sales_Agreement__c.Marital_Status__c'
                ,'Sales_Agreement__c.Mobile__c','Sales_Agreement__c.Model__c','Sales_Agreement__c.Model_Color_Trim__c','Sales_Agreement__c.MonthlyInstalment__c'
                ,'Sales_Agreement__c.NCD__c','Sales_Agreement__c.New_Insurance_Company__c','Sales_Agreement__c.NRIC_Number__c','Sales_Agreement__c.Number_of_COE_Bids__c'
                ,'Sales_Agreement__c.Old_Insurance_Company__c','Sales_Agreement__c.Open_Category_CatE__c','Sales_Agreement__c.Open_Category_COE_Option__c','Sales_Agreement__c.Open_COE_Quota_Premium__c'
                ,'Sales_Agreement__c.Postal_CodeRA__c','Sales_Agreement__c.Postal_CodeMA__c','Sales_Agreement__c.PurchasewithCOE__c','Sales_Agreement__c.Rate_p_a__c'
                ,'Sales_Agreement__c.RegistrationInstruction__c','Sales_Agreement__c.Registration_Number_Type__c','Sales_Agreement__c.Salutation__c','Sales_Agreement__c.Secondary_Contact_No__c'
                ,'Sales_Agreement__c.Street_NameRA__c','Sales_Agreement__c.Street_NameMA__c','Sales_Agreement__c.Surname__c','Sales_Agreement__c.Trade_in_Value__c'
                ,'Sales_Agreement__c.Trim__c','Sales_Agreement__c.Used_Car_Make__c','Sales_Agreement__c.Used_Car_Registration_Number__c','Sales_Agreement__c.Used_Car_Vehicle_Finance_Company__c'
                ,'Sales_Agreement__c.User_Car_Model__c','Sales_Agreement__c.Vehicle_Deposit__c','Sales_Agreement__c.VehicleListPrice__c','Sales_Agreement__c.emailaddress__c'
                ,'Sales_Agreement__c.PrivateHire__c', 'Sales_Agreement__c.isPromotionVehicle__c','Sales_Agreement__c.Package_Header__r.PKH_PKGPRICE__c', 'Sales_Agreement__c.Trade_In_Used_Car_Registration_Number__c'
                ,'Sales_Agreement__c.Vehicle_Purchase_Price__c', 'Sales_Agreement__c.Total_Addon_Price__c', 'Sales_Agreement__c.Total_Discount_Price__c'
                ,'Sales_Agreement__c.COE_Refund__c','Sales_Agreement__c.Accessories_Discount__c','Sales_Agreement__c.Promo_Discount__c','Sales_Agreement__c.Total_VES_Roadtax_and_fees__c'
                ,'Sales_Agreement__c.Insurance_Company_Lookup__r.Name','Sales_Agreement__c.Finance_Company_Lookup__r.Name','Sales_Agreement__c.Road_Tax_Top_Up__c'
                ,'Sales_Agreement__c.Branch_Code__c','Sales_Agreement__c.Company_Name__c','Sales_Agreement__c.ARCA_Number__c','Sales_Agreement__c.Registration_Type__c'
                ,'Sales_Agreement__c.AcknowledgementOffPeak__c', 'Sales_Agreement__c.DSA_Registration_Number__c', 'Sales_Agreement__c.Stage__c', 'Sales_Agreement__c.Package_List_Price__c'
                ,'Sales_Agreement__c.Seller_Email_Address__c', 'Sales_Agreement__c.isSellerNotBuyer__c', 'Sales_Agreement__c.DS_Model__c', 'Sales_Agreement__c.Customer_Type__c', 'Sales_Agreement__c.Seller_Type__c'];
 
const DEPOSIT_REQUIRED_FIELDS =  { checkedFields : 
                                    [{apiname : 'Expected_Delivery_From__c', component: 'c-date-selection-duration-cmp', isFilled: false, 
                                        errorMsg: 'Please select a delivery period'}],

        processRequiredFieldsFirstTimeLoad(salesRec){
            this.checkedFields.forEach(elem=>{
                salesRec[elem.apiname].value && (elem.isFilled = true); 
            })
        },
        validationCheck(document){    
            let isError = false;
            const failedCheckList = this.checkedFields.filter((row) => {
                return row.isFilled === false;
            });
            failedCheckList.forEach(row=>{
                document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
                    row.apiname === elem.fieldAPIName &&
                        ( elem.setErrorMsg({ errorMsg: row.errorMsg}),
                            document.errorMsg = row.errorMsg,
                            isError = true);
                })
            });
            return isError;
        },
        isFormComplete(){
            return this.checkedFields.every(rowItem => {return rowItem.isFilled}) ? false : true;
        },

        setIsFilled(apiName){
            const rowFound = this.checkedFields.find( row => row.apiname === apiName );
            rowFound && (rowFound.isFilled = true);
        }
    };

const REGISTRATION_TYPE_REQUIRED_FIELDS =  { checkedFields :  [{apiname : 'Package_Header_From_PickList__c', component: 'c-pick-list-as-record-list-cmp', isFilled: false, errorMsg: 'Please select a package'}],

                                            processRequiredFieldsFirstTimeLoad(stockReservationRec){
                                                    this.checkedFields.forEach(elem=>{
                                                        stockReservationRec[elem.apiname].value && (elem.isFilled = true);                   
                                                })
                                            },
                                            validationCheck(document){    
                                                    let isError = false;
                                                    const failedCheckList = this.checkedFields.filter((row) => {
                                                    return row.isFilled === false;
                                                });
                                                failedCheckList.forEach(row=>{
                                                    document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
                                                        row.apiname === elem.objName &&
                                                        ( elem.setErrorMsg({ errorMsg: row.errorMsg}),
                                                        document.errorMsg = row.errorMsg,
                                                        isError = true);
                                                    })
                                                });
                                                return isError;
                                            },
                                            isFormComplete(){
                                                return this.checkedFields.every(rowItem => {return rowItem.isFilled}) ? false : true;
                                            },

                                            setIsFilled(apiName){
                                                const rowFound = this.checkedFields.find( row => row.apiname === apiName );
                                                rowFound && (rowFound.isFilled = true);
                                            }
};    

// const TRADE_IN_REQUIRED_FIELDS =  { isUnderCompany : false,
//                                     checkedFieldCompany : [
//                                         {apiname : 'Seller_Full_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Company_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Company_UEN__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Mobile_Number__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Mailing_Address__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Street_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'}
//                                     ],
//                                     checkedFieldIndividual : [
//                                         {apiname : 'Seller_Full_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_NRIC__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Date_Of_Birth__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Mobile_Number__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Mailing_Address__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'},
//                                         {apiname : 'Seller_Street_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data'}
//                                     ],

//                                     processRequiredFieldsFirstTimeLoad(salesRec){
//                                         this.isUnderCompany = salesRec.isUsedCarUnderCompany__c.value === true ? true : false;
//                                         const checkedFieldList =  this.isUnderCompany ? this.checkedFieldCompany : this.checkedFieldIndividual;
//                                         checkedFieldList.forEach(elem=>{
//                                             salesRec[elem.apiname].value && (elem.isFilled = true);                   
//                                         });
//                                     },
//                                     validationCheck(document){    
//                                             let isError = false;
//                                             const failedCheckList = this.checkedFields.filter((row) => {
//                                             return row.isFilled === false;
//                                         });
//                                         failedCheckList.forEach(row=>{
//                                             document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
//                                                 row.apiname === elem.objName &&
//                                                 ( elem.setErrorMsg({ errorMsg: row.errorMsg}),
//                                                 document.errorMsg = row.errorMsg,
//                                                 isError = true);
//                                             })
//                                         });
//                                         return isError;
//                                     },
//                                     isFormComplete(){
//                                         return this.checkedFields.every(rowItem => {return rowItem.isFilled}) ? false : true;
//                                     },

//                                     setIsFilled(apiName){
//                                         const rowFound = this.checkedFields.find( row => row.apiname === apiName );
//                                         rowFound && (rowFound.isFilled = true);
//                                     }
// };    

const REVIEW_REQUIRED_FIELDS = {'AcknowledgementAgreement__c':false, 'AcknowledgementCOE__c':false,
                                'AcknowledgementDeposits__c':false, 'AcknowledgementInsurance__c':false,
                                'AcknowledgementTradeIn__c':false, 'AcknowledgementVehiclePrices__c':false,
                                'AcknowledgementOffPeak__c':false, 'AcknowledgementPersonalData__c':true};
const BRANCHCODE_NAME_MAPPING = {'CCK' : 'Cycle & Carriage Kia Pte Ltd (“CCK”)',
                                 'CCA' : 'Cycle & Carriage Automotive Pte Ltd (“CCA”)',
                                 'CCF' : 'Cycle & Carriage Citroen Pte Ltd (CCF)'}

// add by Phap on 09 Sep 2020
const CREDIT_TC = {
    'CCK'   : 'https://kia.sg/T&C_credits',
    'CCA'   : 'https://mitsubishi.sg/T&C_credits',
    'CCF'   : 'https://citroencars.sg/T&C_credits',
    'CCFDS' : 'https://dscars.sg/T&C_credits',
}
const MARKETING_CONTACTUS = {'CCK' : 'Kia Marketing at kiamarketing@cyclecarriage.com.sg',
                            'CCA' : 'Mitsubishi Marketing at mitsubishimarketing@cyclecarriage.com.sg',
                            'CCF' : 'Citroen Marketing at citroenmarketing@cyclecarriage.com.sg'}

const MONTHLY_INSTALLMENT_FIELDS = { Amount_to_Finance__c : 0, Rate_p_a__c : 0 , Terms_Years__c: 0 };
const getMonthlyInstalment = (loanAmt,rate,term )=>{
    const calculation = Math.ceil((((loanAmt * (rate / 100) * term) + loanAmt) / (term * 12)));
    return calculation.toLocaleString('en');
}

const capitalizedText = (text)=>{ return text.toUpperCase();}

const CONVERT_DATE = (dateField)=>{
        const month = dateField.getMonth();
        const date = dateField.getDate();
        const year = dateField.getYear();
        return `${month}-${date}-${year}`;
    };


export { MONTHLY_INSTALLMENT_FIELDS, CREDIT_TC,
        TRADEIN_FIELDS, DEPOSIT_FIELDS, REVIEW_FIELDS, 
        REVIEW_REQUIRED_FIELDS, DEPOSIT_REQUIRED_FIELDS,  BRANCHCODE_NAME_MAPPING, MARKETING_CONTACTUS, CONVERT_DATE,
        getMonthlyInstalment, capitalizedText, STOCK_RESERVATION_FIELDS, REGISTRATION_TYPE_REQUIRED_FIELDS};
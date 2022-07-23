const VEH_FIELDS = ['Sales_Agreement__c.Id','Sales_Agreement__c.Model__c', 'Sales_Agreement__c.Trim__c', 'Sales_Agreement__c.COECategory__c',
                'Sales_Agreement__c.Color__c', 'Sales_Agreement__c.PurchasewithCOE__c','Sales_Agreement__c.COE_Package__c',
                'Sales_Agreement__c.Number_of_COE_Bids__c', 'Sales_Agreement__c.COE_Charged_Rebate__c', 'Sales_Agreement__c.Registration_Number_Type__c',
                'Sales_Agreement__c.isPromotionVehicle__c', 'Sales_Agreement__c.Package_Header__r.PKH_PKGPRICE__c','Sales_Agreement__c.Service_Credit__c',
                'Sales_Agreement__c.COE_Refund__c','Sales_Agreement__c.Promo_Discount__c', 'Sales_Agreement__c.Accessories_Discount__c',
                'Sales_Agreement__c.Branch_Code__c','Sales_Agreement__c.VehicleListPrice__c', 'Sales_Agreement__c.Vehicle_Purchase_Price__c',
                'Sales_Agreement__c.Registration_Number_Method__c', 'Sales_Agreement__c.Bid_Number__c', 'Sales_Agreement__c.Used_Car_Registration_Number__c',
                'Sales_Agreement__c.Open_Category_COE_Option__c', 'Sales_Agreement__c.Customer_Purchased_COE__c','Sales_Agreement__c.Total_VES_Roadtax_and_fees__c',
                'Sales_Agreement__c.Road_Tax_Top_Up__c', 'Sales_Agreement__c.service_credit_effective_years__c','Sales_Agreement__c.Total_Discount_Price__c',
                'Sales_Agreement__c.Package_List_Price__c', 'Sales_Agreement__c.Accessories_Credit__c', 'Sales_Agreement__c.Package_Accessories_Credit__c', 
                'Sales_Agreement__c.Package_Service_Credit__c', 'Sales_Agreement__c.Vehicle_Condition__c', 'Sales_Agreement__c.Vehicle_Mileage__c', 'Sales_Agreement__c.Vehicle_Location__c'];

const CONFIGURATION_PICKLIST =  [   {  listItem : 'LTA Assigned Number (for new car)',collapsible : false,},
                                    {  listItem : 'Number Retention (for new car) & Acceptance of Random Number (for used car)',collapsible : true, 
                                                   inputFields : [{apiName : 'Used_Car_Registration_Number__c', label:"Used Car Registration Number", existingValue: ""}],},
                                    {  listItem : 'Number Retention (for new car) & Use of Purchase-Bid Number (for used car)',collapsible : true, inputFields : [{apiName : 'Used_Car_Registration_Number__c', label:"Used Car Registration Number", existingValue: ""}],},
                                    {  listItem : 'Purchasing-Bid Number (for new car)',collapsible : true,inputFields : [{apiName : 'Bid_Number__c', label:"Bid Number", existingValue: ""}],},
                                    //Start of RN2020Q1007. We would need to add the picklist value in the picklist.
                                    {  listItem : 'Number Retention by Customer & Wavier of Retention Fee',collapsible : true,inputFields : [{apiName : 'Used_Car_Registration_Number__c', label:"Used Car Registration Number", existingValue: ""}],},
                                    //End of RN2020Q1007
                                    {  listItem : 'To be decided',collapsible : true, messageToDisplay : [{msg:'Registration Number Method has to be decided before Registration.'}]},]
const FIELDS_TO_BE_DISABLED = { COE :{  pickListAsButton : [{ apiName:'COE_Package__c' },{ apiName: 'Number_of_COE_Bids__c'}],
                                        inputField : [{ apiName: 'COE_Charged_Rebate__c'}],
                                        checkbox :[{    apiName: 'Open_Category_COE_Option__c'}]}
                                
                                        }
const VEHICLE_REQUIRED_FIELDS =  {checkedFields : [{apiname : 'Registration_Number_Method__c', component: 'c-picklist-as-accordion-cmp', isFilled: false, errorMsg: 'Please select a Registration Number Method'}],
                                    processRequiredFieldsFirstTimeLoad(salesRec){this.checkedFields.forEach(elem=>{salesRec[elem.apiname].value && (elem.isFilled = true); })},
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

const GET_ROADTAX_LABEL = {Label : [{'RoadTaxType': 'R004', 'RoadTaxDisplayLabel': '12 Months'},
                                    {'RoadTaxType': 'R002', 'RoadTaxDisplayLabel': '6 Months'}],

                          getRoadTaxLabel (roadTaxType){return  this.Label.find((row)=>{return row.RoadTaxType === roadTaxType;}).RoadTaxDisplayLabel;}};

const SERVICE_CREDIT_WEF_DURATION = {  ServiceWEFRange: [   { Year : 1, Min : 0 , Max: 1999 },
                                                            { Year : 2, Min : 2000 , Max: 2999},
                                                            { Year : 3, Min : 3000 , Max: 10999}],
                                                            /*
                                                            { Year : 3, Min : 4000 , Max: 4999},
                                                            { Year : 3, Min : 5000 , Max: 5999},
                                                            { Year : 3, Min : 6000 , Max: 6999},
                                                            { Year : 3, Min : 7000 , Max: 7999},
                                                            { Year : 3, Min : 8000 , Max: 8999},
                                                            { Year : 3, Min : 9000 , Max: 9999},
                                                            { Year : 3, Min : 10000 , Max: 10999}],
                                                            */
                                        getWEFYears(serviceCredit){
                                            let isFound = false, WEFYear = 1;
                                            this.ServiceWEFRange.forEach(element => {
                                                isFound = serviceCredit >= element.Min && serviceCredit <= element.Max;
                                                WEFYear = isFound === true ? element.Year : WEFYear;
                                            }); return WEFYear;
                                        }};

export{VEH_FIELDS, CONFIGURATION_PICKLIST, FIELDS_TO_BE_DISABLED, VEHICLE_REQUIRED_FIELDS, GET_ROADTAX_LABEL,SERVICE_CREDIT_WEF_DURATION };
/* eslint-disable no-unused-expressions */
const FINANCE_FIELDS = ['Sales_Agreement__c.Payment__c', 'Sales_Agreement__c.Finance_Company_In_House__c',
                'Sales_Agreement__c.Other_Finance__c','Sales_Agreement__c.Finance_Company__c',
                'Sales_Agreement__c.Amount_to_Finance__c', 'Sales_Agreement__c.Rate_p_a__c',
                'Sales_Agreement__c.PrivateHire__c', 'Sales_Agreement__c.New_Insurance_Company__c',
                'Sales_Agreement__c.Old_Insurance_Company__c', 'Sales_Agreement__c.Insurance_Package__c',
                'Sales_Agreement__c.Premium_Payable__c', 'Sales_Agreement__c.NCD__c', 'Sales_Agreement__c.Term_Period__c',
                'Sales_Agreement__c.Terms_Years__c', 'Sales_Agreement__c.Insurance_Company_In_House__c', 'Sales_Agreement__c.Insurance_Register_Vehicle__c',
                'Sales_Agreement__c.Insurance_Company_Lookup__c','Sales_Agreement__c.Finance_Company_Lookup__c'];

const FINANCE_REQUIRED_FIELDS =  { checkedFields : [{apiname : 'Insurance_Company_Lookup__c', component: 'c-lookup-field-as-pick-list-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                    {apiname : 'Insurance_Register_Vehicle__c', component: 'c-lookup-field-as-pick-list-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                    {apiname : 'Finance_Company_Lookup__c', component: 'c-lookup-field-as-pick-list-cmp', isFilled: false, errorMsg: 'Please enter the required data.'}],

                                    processRequiredFieldsFirstTimeLoad(salesRec){
                                        this.checkedFields.forEach(elem=>{
                                            salesRec[elem.apiname].value && (elem.isFilled = true);
                                            elem.apiname === 'Finance_Company_Lookup__c' && (salesRec.Payment__c.value === 'Full Payment' && (elem.isFilled = true));
                                        })
                                    },
                                    validationCheck(document){    
                                        let isError = false;
                                        const failedCheckList = this.checkedFields.filter((row) => {
                                            return row.isFilled === false;
                                        });
                                        failedCheckList.forEach(row=>{
                                            document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
                                                elem.apiFieldName === row.apiname && (
                                                    elem.setErrorMsg({ errorMsg: row.errorMsg}),
                                                    document.errorMsg = row.errorMsg,
                                                    isError = true );                                         
                                                 })
                                        });
                                        return isError;
                                    },
                                    setIsFilled(apiName, isFilled){
                                        const rowFound = this.checkedFields.find( row => row.apiname === apiName );
                                        rowFound && (rowFound.isFilled = isFilled);
                                    }
                                };
                                

const FIELDS_TO_BE_DISABLED = {  Finance : {   pickListAsList : [  {apiName:'Finance_Company_Lookup__c' , enableForNotInhouse: true}],
                                                inputField : [     {apiName: 'Amount_to_Finance__c', enableForNotInhouse: true},
                                                                   {apiName: 'Rate_p_a__c', enableForNotInhouse: false}],
                                                checkbox :[        {apiName: 'Finance_Company_In_House__c', enableForNotInhouse: true}],
                                                pickListAsButton : [{apiName:'Term_Period__c', enableForNotInhouse: false}],
                                            }
                                }

const MONTHLY_INSTALLMENT_FIELDS = { Amount_to_Finance__c : 0, Rate_p_a__c : 0 , Terms_Years__c: 0 };

const getMonthlyInstalment = (loanAmt,rate,term )=>{
    const calculation = Math.ceil((((loanAmt * (rate / 100) * term) + loanAmt) / (term * 12)));
    return calculation.toLocaleString('en');
}

const isEmptyValue = (value) => {
    if (value === '' || value === null || value === undefined) {
        return true;
    } 
    return false;
};


export { FIELDS_TO_BE_DISABLED, MONTHLY_INSTALLMENT_FIELDS, getMonthlyInstalment, FINANCE_FIELDS, FINANCE_REQUIRED_FIELDS, isEmptyValue} ;
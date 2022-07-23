const CUSTOMER_FIELDS = ['Sales_Agreement__c.Customer_Full_Name__c', 'Sales_Agreement__c.emailaddress__c','Sales_Agreement__c.Salutation__c', 'Sales_Agreement__c.FirstName__c'
                        ,'Sales_Agreement__c.Surname__c','Sales_Agreement__c.NRIC_Number__c','Sales_Agreement__c.MobileSA__c','Sales_Agreement__c.Secondary_Contact_No__c'
                        ,'Sales_Agreement__c.Date_Of_Birth__c','Sales_Agreement__c.Gender__c','Sales_Agreement__c.Marital_Status__c','Sales_Agreement__c.Name','Sales_Agreement__c.Id',
                        'Sales_Agreement__c.Mobile__c','Sales_Agreement__c.NRIC__c', 'Sales_Agreement__c.Postal_CodeMA__c','Sales_Agreement__c.Postal_CodeRA__c',
                        'Sales_Agreement__c.Street_NameRA__c','Sales_Agreement__c.Building_NameRA__c','Sales_Agreement__c.Floor_UnitRA__c','Sales_Agreement__c.Street_NameMA__c'
                        ,'Sales_Agreement__c.Building_NameMA__c','Sales_Agreement__c.Floor_UnitMA__c' ,'Sales_Agreement__c.Company_Name__c','Sales_Agreement__c.ARCA_Number__c','Sales_Agreement__c.Registration_Type__c'
                        ,'Sales_Agreement__c.Customer_Type__c', 'Sales_Agreement__c.Stage__c', 'Sales_Agreement__c.Stock_Reservation__c'];


const CUSTOMER_REQUIRED_FIELDS =  { isCompany : false,
                                    checkedFieldCompany : [{}],
                                    checkedFieldsCustomer : [{apiname : 'Postal_CodeRA__c', component: 'c-address-callout-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            //{apiname : 'Street_NameRA__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'Surname__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'MobileSA__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'NRIC_Number__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'FirstName__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'Customer_Full_Name__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'emailaddress__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'},
                                                            {apiname : 'Date_Of_Birth__c', component: 'c-input-field-as-cmp', isFilled: false, errorMsg: 'Please enter the required data.'}],
                                        processRequireFieldsInitial (salesRec) {
                                                        this.isCompany = salesRec.Registration_Type__c.value === 'C' ? true : false;
                                                        const checkedFieldList =  this.isCompany ? this.checkedFieldCompany : this.checkedFieldsCustomer;
                                                        if (checkedFieldList.length > 1) {
                                                            checkedFieldList.forEach(elem=>{salesRec[elem.apiname].value && (elem.isFilled = true);});
                                                        }
                                                        //checkedFieldList.forEach(elem=>{salesRec[elem.apiname].value && (elem.isFilled = true);});
                                                    },
                                        validationCheck (document){
                                                    let isError = false;
                                                    const checkedFieldList =  this.isCompany ? this.checkedFieldCompany : this.checkedFieldsCustomer;
                                                    const failedCheckList = checkedFieldList.filter((row) => {return row.isFilled === false;});
                                                    failedCheckList.forEach(row=>{ 
                                                        document.template.querySelectorAll(`${row.component}`).forEach(elem=>{
                                                            row.apiname === elem.fieldAPIName && ( elem.setErrorMsg({ errorMsg: row.errorMsg}),document.errorMsg = row.errorMsg,isError = true);
                                                        })
                                                    }); return isError;
                                                },
                                        isFormComplete() {
                                            const checkedFieldList =  this.isCompany ? this.checkedFieldCompany : this.checkedFieldsCustomer;
                                            return checkedFieldList.every(rowItem => {return rowItem.isFilled}) ? false : true;
                                        },                                                                                     
                                        setIsFilled(apiName, isFilled){
                                                const checkedFieldList =  this.isCompany ? this.checkedFieldCompany : this.checkedFieldsCustomer;
                                                const rowFound = checkedFieldList.find( row => row.apiname === apiName );
                                                rowFound && (rowFound.isFilled = isFilled);
                                            }
                                    };

const isEmptyValue = (value) => {
    if (value === '' || value === null || value === undefined) {
        return true;
    } 
    return false;
};

export { CUSTOMER_REQUIRED_FIELDS , CUSTOMER_FIELDS, isEmptyValue};
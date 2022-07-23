public with sharing class DocusignTextCustomField {
    public string configurationType;
    public string fieldId;
    public string name;
    public string required;
    public string show;
    public string value;

    public DocusignTextCustomField(string value) {
        //this.configurationType = 'salesforce';
        this.fieldId = '1';
        this.name = 'recordnumber';
        this.required = 'true'; // for safe
        this.show = 'true';
        this.value = value;
    }
}
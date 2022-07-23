public with sharing class DocusignAccountCustomFields {
    public DocusignTextCustomField[] textCustomFields;

    public DocusignAccountCustomFields() {
        this.textCustomFields = new list<DocusignTextCustomField>();
    }

    public void addRecordAutoNumber(string value) {
        this.textCustomFields.add(new DocusignTextCustomField(value));
    }
}
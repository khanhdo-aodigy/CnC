public class DocusignEnvelope {
    /**
     * This class represent the DocuSign envelope
     * Parse to JSON to generate the body of the request
     **/
    public string status;
    public string emailSubject;
    public string emailBlurb;
    public string envelopeId;
    public string brandId;
    public DocuSignNotificationSettings notification;
    public DocusignSigners recipients;
    public List<DocusignDocument> documents;
    public DocusignAccountCustomFields customFields;
    //public DocusignSenderDetail sender;
    //public DocusignEnvelopeEmailSettings emailSettings;

    /**
    * This constructor is for creating request which required documents 
	**/
    public DocusignEnvelope(string status, string emailSubject, DocusignSigners recipients, List<DocusignDocument> documents) {
        this.status = status;
        this.emailSubject = emailSubject;
        this.recipients = recipients;
        this.documents = documents;
        this.customFields = new DocusignAccountCustomFields();
    }
    
    /** 
    * this constructor is for other request such as modify recipients, delete recipient,... which do not required documents 
	**/
    public DocusignEnvelope(string status, string emailSubject, DocusignSigners recipients) {
        this.status = status;
        this.emailSubject = emailSubject;
        this.recipients = recipients;
    }
}
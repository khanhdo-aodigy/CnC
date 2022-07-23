public class DocusignDocument {
    /**
     * This class represent a DocuSign document
     **/
    public string name;
    public string fileExtension;
    public string documentId;
    //public string documentBase64;

    /**
    * This constructor is for multiform request which do not required base64 encode of documents
    **/
    public DocusignDocument(string name, string extension, string documentId) {
        
        this.name = name;
        this.fileExtension = extension;
        this.documentId = documentId;
    }
}
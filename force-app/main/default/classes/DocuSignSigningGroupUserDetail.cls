public without sharing class DocuSignSigningGroupUserDetail {
    /**
    This class represent the signing group member's detail 
    **/
    public string userName;
    public string email;
    public DocuSignSigningGroupUserDetail(string userName, string email) {
        this.userName = userName;
        this.email = email;
    }
}
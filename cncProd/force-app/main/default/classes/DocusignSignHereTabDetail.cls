public with sharing class DocusignSignHereTabDetail {

    public string anchorIgnoreIfNotPresent;
    public string anchorString;
    public string recipientId;
    public string status;
    public string tabId;
    public string tabType;
    public string anchorXOffset;
    public string anchorYOffset;
    // public string documentId;

    public DocusignSignHereTabDetail(string anchorString, string recipientId, string tabId, string anchorXOffset, string anchorYOffset) {
        this.anchorIgnoreIfNotPresent = 'true';
        this.anchorString = anchorString;
        this.recipientId = recipientId;
        this.status = 'active';
        this.tabId = tabId;
        this.tabType = 'signHere';
        this.anchorXOffset = anchorXOffset;
        this.anchorYOffset = anchorYOffset;
        // this.documentId = '1';
    }
}
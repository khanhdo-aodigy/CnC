public with sharing class DocusignTabs {
    public List<DocusignSignHereTabDetail> signHereTabs = new List<DocusignSignHereTabDetail>();
    public List<DocusignDateSignedTabDetail> dateSignedTabs = new List<DocusignDateSignedTabDetail>();

    /**
     * This constructor for MF
     */
    public DocusignTabs(List<DocusignSignHereTabDetail> signHereTabs) {
        this.signHereTabs = signHereTabs;
    }

    /**
     * This constructor for MB
     */
    public DocusignTabs(List<DocusignSignHereTabDetail> signHereTabs, List<DocusignDateSignedTabDetail> dateSignedTabs) {
        this.signHereTabs = signHereTabs;
        this.dateSignedTabs = dateSignedTabs;
    }

    public DocusignTabs() {}
}
public class DocusignSigners {
    /**
     * This class represent list of signers in envelope
     **/
    
	public List<DocusignSignerDetail> signers = new List<DocusignSignerDetail> {};
    public List<DocusignSignerDetail> carbonCopies = new List<DocusignSignerDetail> {};
    public List<DocusignSignerDetail> agents = new List<DocusignSignerDetail> {};                   // reserved for future use
    public List<DocusignSignerDetail> certifiedDeliveries = new List<DocusignSignerDetail> {};      // reserved for future use
    public List<DocusignSignerDetail> inPersonSigners = new List<DocusignSignerDetail> {};          // reserved for future use
    public List<DocusignSignerDetail> intermediaries = new List<DocusignSignerDetail> {};           // reserved for future use
    public List<DocusignSignerDetail> editors = new List<DocusignSignerDetail> {};                  // reserved for future use

    
    public DocusignSigners(List<DocusignSignerDetail> recipients) {
        for (DocusignSignerDetail recipient : recipients) {
            switch on recipient.recipientType {
                when 'Signer' {
                    this.signers.add(recipient);
                }
                when 'Carbon copy' {
                    this.carbonCopies.add(recipient);
                }
            }
        }
        this.signers = signers;
    }
}
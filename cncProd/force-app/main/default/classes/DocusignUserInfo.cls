public class DocusignUserInfo {
	public string sub;
    public string name;
    public string given_name;
    public string family_name;
    public string created;
    public string email;
    public DocusignAccount[] accounts;
    
    public class DocusignAccount {
        public string account_id;
        public string is_default;
        public string account_name;
        public string base_uri;
    }
}
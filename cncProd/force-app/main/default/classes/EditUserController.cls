public without sharing class EditUserController {
    
    ApexPages.StandardController controller;
    public User u {get;set;}
    public List<String> fieldNames {get;set;}
    
    public EditUserController(ApexPages.StandardController controller) {
        this.controller = controller;
        
        fieldNames = new List<String>();
        
        List<FieldPermissions> fpList = [SELECT Field, PermissionsEdit, Parent.ProfileId
                                          FROM FieldPermissions
                                          WHERE SobjectType = 'User'
                                          AND PermissionsEdit = true
                                          AND Parent.ProfileId=:Userinfo.getProfileId()
                                         ];
        
        
        for(FieldPermissions fp: fpList){
            fieldNames.add(fp.Field.substringAfter('.'));
        }
        System.debug('fieldNames = ' + fieldNames);
        
        String userId = controller.getId();
        String soql = 'SELECT Id ';
        for(String fieldName : fieldNames){
          soql += ', ' + fieldName;
        }
        soql = soql + ' FROM User WHERE ID = :userId' ;
        u = (User)Database.Query(soql);
    }
    
    public PageReference checkPermission() {
        Boolean hasPermission = FeatureManagement.checkPermission('Edit_User');
        if(!hasPermission){
            return new PageReference('javascript:window.close()');
        }
        return null;
    }
    
    public PageReference save() {
        update u;
        return new PageReference('javascript:window.close()');
    }
    
    public PageReference cancel() {
        controller.cancel();
        return new PageReference('javascript:window.close()');
    }

}
@RestResource(urlMapping='/ColorMaster/*')
global without sharing class ColorMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');       
        String Name = req.params.get('Code');
        String Active = req.params.get('Status');
        String ColorDescription = req.params.get('Description');
        String FranchiseCode = req.params.get('FranchiseCode');
        String BranchCode = req.params.get('BranchCode');
        
        Color_Master__c CM=new Color_Master__c();
        
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        try{
        	List<Color_Master__c> CMList =[select Id,Name,Color_Description__c,Franchise_Code__c,Branch_Code__c,Active__c from Color_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
        	if(CMList != null && CMList.size() > 0){
        		CM = CMList[0];
        	}
        	CM.Name=Name;
            CM.Color_Description__c=ColorDescription;
            CM.Franchise_Code__c=FranchiseCode;
            CM.Branch_Code__c=BranchCode;
            //The below three are added to match the DWH sync up.
            CM.ColorCode__c = Name;
            CM.Source__c = 'DWH';
            CM.DWH_Color_ID__c = CM.Branch_Code__c +',' +CM.Franchise_Code__c + ',' +CM.ColorCode__c;
            if (Active=='A'){
                CM.Active__c=True;
            }else{
                CM.Active__c=false;
            }
            upsert CM;
            res.responseBody = Blob.valueOf('OK');
        	
        	
            /*if (Action=='Insert'){
               List<Color_Master__c> CMList =[select Id from Color_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
                if(CMList.size()<= 0){
                CM.Name=Name;
                CM.Color_Description__c=ColorDescription;
                CM.Franchise_Code__c=FranchiseCode;
                CM.Branch_Code__c=BranchCode;
                if (Active=='A'){
                    CM.Active__c=True;
                }else{
                    CM.Active__c=false;
                }
                insert CM;
                res.responseBody = Blob.valueOf('OK');
                }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> idList = new List<String>();
                List<String> mailToAddresses = new List<String>();
                Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'VSMS Admin'];
                for (GroupMember gm : g.groupMembers) {
                    idList.add(gm.userOrGroupId);
                }
                User[] usr = [SELECT email FROM user WHERE id IN :idList];
                for(User u : usr) {
                    mailToAddresses.add(u.email);
                }
                mail.setToAddresses(mailToAddresses);
                mail.setSubject('Color Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            if (Action=='Update'){
                CM=[select Id,Name,Color_Description__c,Franchise_Code__c,Branch_Code__c,Active__c from Color_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
                CM.Color_Description__c=ColorDescription;
                CM.Franchise_Code__c=FranchiseCode;
                CM.Branch_Code__c=BranchCode;
                if (Active=='A'){
                    CM.Active__c=true;
                }else{
                    CM.Active__c=false;
                }
                update CM;
                res.responseBody = Blob.valueOf('OK');
            }*/   
        }catch(Exception e) {
            res.responseBody = Blob.valueOf('The following exception has occurred: ' + e.getMessage());
            System.debug('The following exception has occurred: ' + e.getMessage());
            //send email eror
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> idList = new List<String>();
            List<String> mailToAddresses = new List<String>();
            Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'VSMS Admin'];
            for (GroupMember gm : g.groupMembers) {
                idList.add(gm.userOrGroupId);
            }
            User[] usr = [SELECT email FROM user WHERE id IN :idList];
            for(User u : usr) {
                mailToAddresses.add(u.email);
            }
            mail.setToAddresses(mailToAddresses);
            mail.setSubject('Color Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
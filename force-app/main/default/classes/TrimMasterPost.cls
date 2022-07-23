@RestResource(urlMapping='/TrimMaster/*')
global without sharing class TrimMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');
        String Name = req.params.get('Code');
        String Active = req.params.get('Status');
        String TrimDescription = req.params.get('Description');
        String FranchiseCode = req.params.get('FranchiseCode');
        String BranchCode = req.params.get('BranchCode');
        
        Trim_Master__c TM=new Trim_Master__c();
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        
        try{
        	List<Trim_Master__c> TMlist=[select Id,Name,Trim_Description__c,Franchise_Code__c,Branch_Code__c,Active__c from Trim_Master__c 
                    where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
            if(TMlist != null && TMlist.size() > 0){
            	TM = TMlist[0];
            }
            TM.Name=Name;
            TM.Trim_Description__c=TrimDescription;
            TM.Franchise_Code__c=FranchiseCode;
            TM.Branch_Code__c=BranchCode;
            if (Active=='A'){
                TM.Active__c=True;
            }else{
                TM.Active__c=false;
            }
            upsert TM;
            res.responseBody = Blob.valueOf('OK');
        	
        	
            /*if (Action=='Insert'){
                List<Trim_Master__c> TMlist=[select Id from Trim_Master__c where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                if(TMlist.size()<=0){
                TM.Name=Name;
                TM.Trim_Description__c=TrimDescription;
                TM.Franchise_Code__c=FranchiseCode;
                TM.Branch_Code__c=BranchCode;
                if (Active=='A'){
                    TM.Active__c=True;
                }else{
                    TM.Active__c=false;
                }
                insert TM;
                res.responseBody = Blob.valueOf('OK');
                }else{
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
                mail.setSubject('Trim Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            if (Action=='Update'){
                TM=[select Id,Name,Trim_Description__c,Franchise_Code__c,Branch_Code__c,Active__c from Trim_Master__c 
                    where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                TM.Trim_Description__c=TrimDescription;
                TM.Franchise_Code__c=FranchiseCode;
                TM.Branch_Code__c=BranchCode;
                if (Active=='A'){
                    TM.Active__c=true;
                }else{
                    TM.Active__c=false;
                }
                update TM;
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
            mail.setSubject('Trim Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
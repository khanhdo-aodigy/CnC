@RestResource(urlMapping='/MTCMaster/*')
global without sharing class MTCMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');
        String Active = req.params.get('Status');
        String FranchiseCode = req.params.get('FranchiseCode');
        String BranchCode = req.params.get('BranchCode');
        String ColorCode = req.params.get('ColorCode');
        String ModelCode = req.params.get('ModelCode');
        String TrimCode = req.params.get('TrimCode');
        String Name=ModelCode+' '+TrimCode+' '+ColorCode;
        
        Model_Color_Trim_Master__c MTCM=new Model_Color_Trim_Master__c();
        Color_Master__c CM=new Color_Master__c();
        Model_Master__c MM=new Model_Master__c();
        Trim_Master__c TM=new Trim_Master__c();
        
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        
        try{
            CM=[select id from Color_Master__c where name=:ColorCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            MM=[select id from Model_Master__c where name=:ModelCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            TM=[select id from Trim_Master__c where name=:TrimCode and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode limit 1];
            
            List<Model_Color_Trim_Master__c> MTCMlist=[select Id,Name,Franchise_Code__c,Branch_Code__c,Active__c,Color_Code__c,Model_Code__c,Trim_Code__c
                      from Model_Color_Trim_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
            if(MTCMlist != null && MTCMlist.size() > 0){
            	MTCM = MTCMlist[0];
            }
            MTCM.Name=Name;
            MTCM.Franchise_Code__c=FranchiseCode;
            MTCM.Branch_Code__c=BranchCode;
            MTCM.Color_Code__c=CM.id;
            MTCM.Model_Code__c=MM.id;
            MTCM.Trim_Code__c=TM.id;
            if (Active=='A'){
                MTCM.Active__c=true;
            }else{
                MTCM.Active__c=false;
            }         
            insert MTCM;
            res.responseBody = Blob.valueOf('OK');
            
            /*if (Action=='Insert'){
                List<Model_Color_Trim_Master__c> MTCMlist=[select Id from Model_Color_Trim_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
                if(MTCMlist.size()<=0){
                MTCM.Name=Name;
                MTCM.Franchise_Code__c=FranchiseCode;
                MTCM.Branch_Code__c=BranchCode;
                MTCM.Color_Code__c=CM.id;
                MTCM.Model_Code__c=MM.id;
                MTCM.Trim_Code__c=TM.id;
                if (Active=='A'){
                    MTCM.Active__c=true;
                }else{
                    MTCM.Active__c=false;
                }         
                insert MTCM;
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
                mail.setSubject('MTC Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            if (Action=='Update'){
                MTCM=[select Id,Name,Franchise_Code__c,Branch_Code__c,Active__c,Color_Code__c,Model_Code__c,Trim_Code__c
                      from Model_Color_Trim_Master__c where Name=:Name and Franchise_Code__c=:FranchiseCode and  Branch_Code__c =:BranchCode];
                MTCM.Franchise_Code__c=FranchiseCode;
                MTCM.Branch_Code__c=BranchCode;
                MTCM.Color_Code__c=CM.id;
                MTCM.Model_Code__c=MM.id;
                MTCM.Trim_Code__c=TM.id;
                if (Active=='A'){
                    MTCM.Active__c=true;
                }else{
                    MTCM.Active__c=false;
                }
                update MTCM;
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
            mail.setSubject('MTC Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
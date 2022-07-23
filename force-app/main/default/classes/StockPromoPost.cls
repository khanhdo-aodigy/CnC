@RestResource(urlMapping='/StockPromo/*')
global without sharing class StockPromoPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');
        String Name = req.params.get('SystemCommcase');
        String Comment = req.params.get('Comment');
        String Status = req.params.get('Status');
        
        Stock_Promotion__c SP=new Stock_Promotion__c();
        
        try{
            if (Action=='Insert'){
                List<Stock_Promotion__c> SPlist=[select id,name,Comment__c,Stock_Promotion_Status__c from Stock_Promotion__c where Name=:Name];
                if(SPlist.size()<=0){
                Vehicle_Master2__c VM = [select id from Vehicle_Master2__c where System_Commcase__c=:Name ];
                SP.Name=Name;
                SP.Comment__c=Comment;
                SP.Stock_Promotion_Status__c=Status;
                SP.Stock_Vehicle_Master__c=VM.id;
                insert SP;
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
                mail.setSubject('Stock Promo Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            if (Action=='Update'){
                SP=[select id,name,Comment__c,Stock_Promotion_Status__c from Stock_Promotion__c where Name=:Name];
                SP.Comment__c=Comment;
                SP.Stock_Promotion_Status__c=Status;
                update SP;
                res.responseBody = Blob.valueOf('OK');
            }       
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
            mail.setSubject('Stock Promo Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
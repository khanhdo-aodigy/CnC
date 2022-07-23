@RestResource(urlMapping='/StockReservation/*')
global without sharing class StockReservationPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');
        String ID = req.params.get('ID');
        String Status = req.params.get('Status');
        String AgreementNo = req.params.get('AgreementNo');
        String CommCase = req.params.get('CommCase');
        String CancelReason = req.params.get('CancelReason');
        
        Stock_Reservation__c SR=new Stock_Reservation__c();
        List<Stock_Reservation__c> CMList =[select Id from Stock_Reservation__c where id=:ID];
        if (Action=='Update' || Action=='Change'){
            if(CMList.size()<= 0){
                res.responseBody = Blob.valueOf('NOT OK,No Record To Update');
            }
        }
        try{
            if (Action=='Update'){
                //just update
                SR=[select id,Reservation_Status__c,Agreement_No__c from Stock_Reservation__c where id=:ID];
                SR.Reservation_Status__c=Status;
                SR.Agreement_No__c=AgreementNo;
                if (Status=='Cancel'){
                    SR.Cancellation_Reason__c=CancelReason;
                }
                update SR;
                res.responseBody = Blob.valueOf('OK');
            }
            if (Action=='Change'){
                //update and change the vehicle
                SR=[select id,Reservation_Status__c,Agreement_No__c,Vehicle_Master__c,Name,Model_Code__c,Model_Year_Code__c,Trim_Code__c,Color_Code__c,Cancellation_Reason__c from Stock_Reservation__c where id=:ID];
                SR.Reservation_Status__c=Status;
                SR.Agreement_No__c=AgreementNo;
                //List <Vehicle_Master2__c> lsvm=[select id,Reservation_No__c from Vehicle_Master2__c where System_Commcase__c=:CommCase and Reservation_No__c!=''];
                List <Vehicle_Master2__c> lsvm=[select id,Reservation_No__c from Vehicle_Master2__c where System_Commcase__c=:CommCase];
                if (lsvm.size()>0){
                    if (lsvm[0].Reservation_No__c!=null){
                        res.responseBody = Blob.valueOf('COMCASE '+CommCase+' alredy in use.');
                    }else{
                        List <Vehicle_Master2__c> listToUpdate=new List <Vehicle_Master2__c>();
                        
                        if (SR.Vehicle_Master__c!=null){
                            Vehicle_Master2__c ovm=[select id,Reservation_No__c,Model_Code__c,Model_Year_Code__c,Trim_Code__c,Color_Code__c from Vehicle_Master2__c where id=:SR.Vehicle_Master__c];
                            ovm.Reservation_No__c='';
                            listToUpdate.add(ovm);
                        }
                        
                        Vehicle_Master2__c nvm=[select id,Reservation_No__c,Model_Code__c,Model_Year_Code__c,Trim_Code__c,Color_Code__c from Vehicle_Master2__c where System_Commcase__c=:CommCase limit 1];
                        nvm.Reservation_No__c=SR.Name;
                        listToUpdate.add(nvm);
                        
                        SR.Model_Code__c=nvm.Model_Code__c;
                        SR.Model_Year_Code__c=nvm.Model_Year_Code__c;
                        SR.Trim_Code__c=nvm.Trim_Code__c;
                        SR.Color_Code__c=nvm.Color_Code__c;
                        SR.Vehicle_Master__c=nvm.id;
                        if (Status=='Cancel'){
                            SR.Cancellation_Reason__c=CancelReason;
                        }
                        update listToUpdate; 
                        update SR;
                        res.responseBody = Blob.valueOf('OK');
                    }
                }else{
                    //res.responseBody = Blob.valueOf('COMCASE '+CommCase+' alredy in use.');
                    res.responseBody = Blob.valueOf('No Vehicle with this commcase '+CommCase);
                }
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
            mail.setSubject('Stock Reservation Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
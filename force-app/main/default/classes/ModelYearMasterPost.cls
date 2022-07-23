@RestResource(urlMapping='/ModelYearMaster/*')
global without sharing class ModelYearMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');       
        String Name = req.params.get('ModelCode');
        String BranchCode = req.params.get('BranchCode');
        String FranchiseCode = req.params.get('FranchiseCode');
        String DutyAmount = req.params.get('DutyAmount');
        String FOBAmount = req.params.get('FOBAmount');
        String LaunchDate = req.params.get('LaunchDate');
        String ModelYear = req.params.get('ModelYear');
        String Status = req.params.get('Status');
        String OutOfProductionDate = req.params.get('OutOfProductionDate');
        
        Model_Year_Master__c MYM=new Model_Year_Master__c();
        List<Model_Master__c> MM=[select id from Model_Master__c where name=:name];
        String[] dts;
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        
        try{
        	String tempName = Name+' '+ModelYear;
        	List<Model_Year_Master__c> MYMlist = [select Id,Name,Franchise_Code__c,Branch_Code__c,Duty_Amount__c,FOB_Amount__c,//Model_Year__c,
                         Active__c,Out_Of_Production_Date__c
                         from Model_Year_Master__c where Name=:tempName and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
        	if(MYMlist != null && MYMlist.size() > 0){
        		MYM = MYMlist[0];
        	}
        	MYM.Name=Name+' '+ModelYear;
            MYM.Model_Master__c=MM[0].id;
            MYM.Franchise_Code__c=FranchiseCode;
            MYM.Branch_Code__c=BranchCode;
            MYM.Duty_Amount__c=decimal.valueOf(DutyAmount);
            MYM.FOB_Amount__c=decimal.valueOf(FOBAmount);
            if (LaunchDate!=null && LaunchDate!=''){
                dts=LaunchDate.split(':');
                MYM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }                
            dts=ModelYear.split(':');
            MYM.ModelYear__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            //MYM.Model_Year__c=decimal.valueOf(dts[2]);
            //MYM.Model_Year_Status__c=Status;
            MYM.Active__c=(Status=='A')? true : false;
            if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                dts=OutOfProductionDate.split(':');
                MYM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            upsert MYM;
            res.responseBody = Blob.valueOf('OK');
        	
            /*if (MM.size()>0){
                res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
                if (Action=='Insert'){
                    List<Model_Year_Master__c> MYMlist=[select Id from Model_Year_Master__c where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode ];
                    if(MYMlist.size() <= 0){
                    MYM.Name=Name+' '+ModelYear;
                    MYM.Model_Master__c=MM[0].id;
                    MYM.Franchise_Code__c=FranchiseCode;
                    MYM.Branch_Code__c=BranchCode;
                    MYM.Duty_Amount__c=decimal.valueOf(DutyAmount);
                    MYM.FOB_Amount__c=decimal.valueOf(FOBAmount);
                    if (LaunchDate!=null && LaunchDate!=''){
                        dts=LaunchDate.split(':');
                        MYM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    }                
                    dts=ModelYear.split(':');
                    MYM.ModelYear__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    //MYM.Model_Year__c=decimal.valueOf(dts[2]);
                    //MYM.Model_Year_Status__c=Status;
                    MYM.Active__c=(Status=='A')? true : false;
                    if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                        dts=OutOfProductionDate.split(':');
                        MYM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    }
                    insert MYM;
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
                    mail.setSubject('Model Year Master Eror');
                    mail.setPlainTextBody('Duplicate Record');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                    }
                }
                if (Action=='Update'){
                    String tempName=Name+' '+ModelYear;
                    MYM=[select Id,Name,Franchise_Code__c,Branch_Code__c,Duty_Amount__c,FOB_Amount__c,//Model_Year__c,
                         Active__c,Out_Of_Production_Date__c
                         from Model_Year_Master__c where Name=:tempName and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode ];
                    //CM.Name=Name;
                    MYM.Franchise_Code__c=FranchiseCode;
                    MYM.Branch_Code__c=BranchCode;
                    MYM.Duty_Amount__c=decimal.valueOf(DutyAmount);
                    MYM.FOB_Amount__c=decimal.valueOf(FOBAmount);
                    if (LaunchDate!=null && LaunchDate!=''){
                        dts=LaunchDate.split(':');
                        MYM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    }
                    dts=ModelYear.split(':');
                    MYM.ModelYear__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    //MYM.Model_Year__c=decimal.valueOf(dts[2]);
                    //MYM.Model_Year_Status__c=Status;
                    MYM.Active__c=(Status=='A')? true : false;
                    if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                        dts=OutOfProductionDate.split(':');
                        MYM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                    }
                    update MYM;
                    res.responseBody = Blob.valueOf('OK');
                }           
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
            mail.setSubject('Model Year Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
public without sharing class DailyCheckListClass {

    public List<Showroom_Questions_List__c> showQuestions {get;set;}
    public List<Showroom_Questions_List__c> generalQuestions {get;set;}
    public List<Test_Drive_Vehicle_Checklist__c> testVehicles {get;set;}
    public List<Showroom_Vehicle_Checklist__c> showVehicles {get;set;}
    public List<Trade_Plate_Checklist__c> tpLists {get;set;}
    public Daily_Checklist__c daily {get;set;}
    public Boolean isNew {get;set;}
    public Boolean noEdit {get;set;}
    public String profileUser {get;set;}
    public String branchCode {get;set;}
    public String franchiseCode {get;set;}
    
    public pageReference goBack {get;set;}
    
    public DailyCheckListClass(ApexPages.StandardController controller){
        showQuestions=new List<Showroom_Questions_List__c>();
        generalQuestions=new List<Showroom_Questions_List__c>();
        testVehicles=new List<Test_Drive_Vehicle_Checklist__c>();
        showVehicles=new List<Showroom_Vehicle_Checklist__c>();
        tpLists=new List<Trade_Plate_Checklist__c>();
        noEdit=false;
        goBack=controller.cancel();
        Id profileId=userinfo.getProfileId();
       
        profileUser=[select Name from Profile where id=:profileId].Name;
        
        Id userId=UserInfo.getUserId();
        User a=[select Branch_Code__c,Franchise_Code__c from User where id=: userId];
        branchCode=a.Branch_Code__c;
        franchiseCode=a.Franchise_Code__c;
    }
    
    public void getDailycheck(){
        Date today=date.today();
        List<Daily_Checklist__c> tempdaily;
        string id=apexpages.currentpage().getparameters().get('id');
        if (id!=null){
            tempdaily=[select Id,Date__c,Status__c, Branch_Code__c, Franchise_Code__c from Daily_Checklist__c where id=:id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode  Limit 1];
            isNew=false;
            fillDaily();
        }else{
            tempdaily=[select Id,Date__c,Status__c, Branch_Code__c, Franchise_Code__c from Daily_Checklist__c where Date__c=:today 
                       and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode Limit 1];
            isNew=true;    
            if (tempdaily.size()>0){
                noEdit=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot create more than one checklist per day.'));
            }else{
                fillBlankDaily();
            }
        }
    }
    
    private void fillDaily(){
        Date today=date.today();
        if (isNew==false){
            string id=apexpages.currentpage().getparameters().get('id');
            List<Daily_Checklist__c> dailyList=[select Id,Date__c,Status__c, Branch_Code__c, Franchise_Code__c from Daily_Checklist__c 
                   where id=:id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode Limit 1];
            if(dailyList.Size()>0){
            daily = dailyList[0];}      
        }else{
            daily=[select Id,Date__c,Status__c, Branch_Code__c, Franchise_Code__c from Daily_Checklist__c 
                   where Date__c=:today and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode Limit 1];
        }
        //get checklist from database
        if(daily!=null){
        showQuestions = [select id, Name, Answer__c, Number__c, Showroom_Questions_Master__c,Type__c,Remarks__c, Branch_Code__c, Franchise_Code__c 
                        from Showroom_Questions_List__c
                        where Daily_Checklist__c=:daily.id and Type__c='Showroom' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        generalQuestions = [select id, Name, Answer__c, Number__c, Showroom_Questions_Master__c,Type__c,Remarks__c, Branch_Code__c, Franchise_Code__c 
                            from Showroom_Questions_List__c
                            where Daily_Checklist__c=:daily.id and Type__c='General Cleanliness' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        testVehicles = [select id, Name, Additional_Remarks__c, Cleanliness__c, Key_is_Present_Evening__c,Comm_Reg_No__c,
                        Key_is_Present_Morning__c, Mileage_at_End__c, Mileage_at_Start__c, Model__c, Petrol_Level_Evening__c, Petrol_Level_Morning__c,
                        Branch_Code__c, Franchise_Code__c
                        from Test_Drive_Vehicle_Checklist__c
                        where Daily_Checklist__c=:daily.id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        showVehicles = [select id, Name, Additional_Remarks__c, Key_is_Present_Evening__c,Comm_Reg_No__c,Interior__c,Exterior__c,
                        Key_is_Present_Morning__c, Model__c, Petrol_Level_Evening__c, Petrol_Level_Morning__c, Branch_Code__c, Franchise_Code__c
                        from Showroom_Vehicle_Checklist__c
                        where Daily_Checklist__c=:daily.id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        tpLists = [select id, name, Additional_Remarks__c, Is_Present_AM__c, Is_Present_PM__c, Trade_Plate__c, Branch_Code__c, Franchise_Code__c
                    from Trade_Plate_Checklist__c
                    where Daily_Checklist__c=:daily.id and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        }
        if (daily!=null && (daily.status__c=='Open' || daily.status__c=='Rejected' || daily.status__c=='Committed')){
            noEdit=false;
        }else{
            noEdit=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You can not edit the record after submission/Approval'));
        }
        if (profileUser=='Sales Manager' || profileUser=='System Administrator'){
            noEdit=false;
        }
    }
    
    private void fillBlankDaily(){
        Date today=date.today();
        daily=new Daily_Checklist__c();
        daily.date__c=today;
        daily.Branch_Code__c=branchCode;
        daily.Franchise_Code__c=franchiseCode;
        Map<Id,Decimal> oldTdMileage = new Map<Id,Decimal>();
        Map<Id,Id> oldTdMileagehelper = new Map<Id,Id>();
        Set<Id> modelIdSet = new Set<Id>();
        //fill the blank checklist from master
        List<Trade_Plate__c> tpmaster=new List<Trade_Plate__c>();
        List<Vehicle_Master__c> showvehimaster=new List<Vehicle_Master__c>();
        List<Vehicle_Master__c> testvehimaster=new List<Vehicle_Master__c>();
        List<Showroom_Questions_Master__c> showquesmaster=new List<Showroom_Questions_Master__c>();
        List<Showroom_Questions_Master__c> generalquesmaster=new List<Showroom_Questions_Master__c>();
        
        tpmaster=[select id,Name, Branch_Code__c, Franchise_Code__c from Trade_Plate__c where Active__c=true and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        showvehimaster=[select id,Name, Branch_Code__c, Franchise_Code__c from Vehicle_Master__c where Status__c='Available' and Type__c='Showroom' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        testvehimaster=[select id,Name, Branch_Code__c, Franchise_Code__c from Vehicle_Master__c where Status__c='Available' and Type__c='Test Drive' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode];
        Map<id,Vehicle_Master__c> vehicleMap = new Map<id,Vehicle_Master__c>(testvehimaster);
        showquesmaster=[select id,name,Number__c, Branch_Code__c, Franchise_Code__c from Showroom_Questions_Master__c where Active__c=true and Type__c='Showroom' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode order by Number__c];
        generalquesmaster=[select id,name,Number__c, Branch_Code__c, Franchise_Code__c from Showroom_Questions_Master__c where Active__c=true and Type__c='General Cleanliness' and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode order by Number__c];
        
        for (Trade_Plate__c tptemp:tpmaster){
            Trade_Plate_Checklist__c t1=new Trade_Plate_Checklist__c();
            t1.Trade_Plate__c=tptemp.id;
            tpLists.add(t1);
        }
        
        for (Vehicle_Master__c svm:showvehimaster){
            Showroom_Vehicle_Checklist__c sv1=new Showroom_Vehicle_Checklist__c();
            sv1.Model__c=svm.id;
            showVehicles.add(sv1);
        }
        if(!testvehimaster.isEmpty() && branchCode!=null && franchiseCode!=null)
        {
            /*for(AggregateResult aggr : [SELECT model__c,MAX(Mileage_at_End__c ) MaxMileage FROM Test_Drive_Vehicle_Checklist__c where model__c IN : testvehimaster and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode and Mileage_at_End__c !=null GROUP BY model__c ])
            {
                oldTdMileage.put((id)aggr.get('model__c'),Integer.valueOf(aggr.get('MaxMileage')));
            }*/ 
            for(AggregateResult aggr : [SELECT model__c,MAX(Id) MaxMileage FROM Test_Drive_Vehicle_Checklist__c where model__c IN : testvehimaster and Branch_Code__c=:branchCode and Franchise_Code__c=:franchiseCode GROUP BY model__c ])
            {
                oldTdMileagehelper.put((id)aggr.get('model__c'),(id)aggr.get('MaxMileage'));
            } 
            if(!oldTdMileagehelper.IsEmpty()){
            for(Test_Drive_Vehicle_Checklist__c  tdvc : [select id,Mileage_at_End__c,model__c from Test_Drive_Vehicle_Checklist__c where Id IN : oldTdMileagehelper.values() ])
            {    
                if(oldTdMileagehelper.ContainsKey(tdvc.model__c) && oldTdMileagehelper.get(tdvc.model__c)==tdvc.id){       
                oldTdMileage.put(tdvc.model__c,tdvc.Mileage_at_End__c);
                }
            }}           
        }
        for (Vehicle_Master__c td:testvehimaster){
            Test_Drive_Vehicle_Checklist__c td1=new Test_Drive_Vehicle_Checklist__c();
            td1.Model__c=td.id;
            if(oldTdMileage.ContainsKey(td1.Model__c)){
            td1.Mileage_at_Start__c = oldTdMileage.get(td1.Model__c);}
            testVehicles.add(td1);
        }
       
        for (Showroom_Questions_Master__c sqm:showquesmaster){
            Showroom_Questions_List__c sql1=new Showroom_Questions_List__c();
            sql1.Number__c=sqm.Number__c;
            sql1.Showroom_Questions_Master__c=sqm.id;
            sql1.name=sqm.name;
            showQuestions.add(sql1);
        }
        for (Showroom_Questions_Master__c gqm:generalquesmaster){
            Showroom_Questions_List__c gql1=new Showroom_Questions_List__c();
            gql1.Number__c=gqm.Number__c;
            gql1.Showroom_Questions_Master__c=gqm.id;
            gql1.name=gqm.name;
            generalQuestions.add(gql1);
        }
        
        insert daily;
        
        List<Test_Drive_Vehicle_Checklist__c> insertTest=new List<Test_Drive_Vehicle_Checklist__c>();
        for (Test_Drive_Vehicle_Checklist__c tv:testVehicles){
            tv.Daily_Checklist__c=daily.id;
            tv.Branch_Code__c=branchCode;
            tv.Franchise_Code__c=franchiseCode;
            insertTest.add(tv);
        }
        insert insertTest;
        
        List<Showroom_Vehicle_Checklist__c> insertShow=new List<Showroom_Vehicle_Checklist__c>();
        for (Showroom_Vehicle_Checklist__c sv:showVehicles){
            sv.Daily_Checklist__c=daily.id;
            sv.Branch_Code__c=branchCode;
            sv.Franchise_Code__c=franchiseCode;
            insertShow.add(sv);
        }
        insert insertShow;
        
        List<Trade_Plate_Checklist__c> insertTP=new List<Trade_Plate_Checklist__c>();
        for (Trade_Plate_Checklist__c tl:tpLists){
            tl.Daily_Checklist__c=daily.id;
            tl.Branch_Code__c =branchCode;
            tl.Franchise_Code__c =franchiseCode;
            insertTP.add(tl);
        }
        insert insertTP;
                
        List<Showroom_Questions_List__c> insertQuestion=new List<Showroom_Questions_List__c>();
        for (Showroom_Questions_List__c sq:showQuestions){
            sq.Daily_Checklist__c=daily.id;
            sq.Branch_Code__c=branchCode;
            sq.Franchise_Code__c=franchiseCode;
            insertQuestion.add(sq);
        }
        insert insertQuestion;
        
        List<Showroom_Questions_List__c> insertQuestion2=new List<Showroom_Questions_List__c>();
        for (Showroom_Questions_List__c sq2:generalQuestions){
            sq2.Daily_Checklist__c=daily.id;
            sq2.Branch_Code__c=branchCode;
            sq2.Franchise_Code__c=franchiseCode;
            insertQuestion2.add(sq2);
        }
        insert insertQuestion2;
        
        fillDaily();
    }
    
    public pageReference doSubmit(){
        try{
            update daily;
            List<Test_Drive_Vehicle_Checklist__c> insertTest=new List<Test_Drive_Vehicle_Checklist__c>();
            for (Test_Drive_Vehicle_Checklist__c tv:testVehicles){
                if (tv.Mileage_at_End__c < tv.Mileage_at_Start__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Mileage PM cant be less than Mileage AM'));
                    return null;
                }
                insertTest.add(tv);
            }
            update insertTest;
            update showVehicles;
            update tpLists;
            update showQuestions;
            update generalQuestions;
        }catch(DmlException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dailychecklist cant be insert.Please contact IT'));
            return null;
        }
        return new Pagereference('/'+daily.Id);
    }
    
    public pageReference doSubmit2(){
        try{
            if (daily.status__c=='Open'){
                daily.status__c='Committed';
            }
            update daily;
            List<Test_Drive_Vehicle_Checklist__c> insertTest=new List<Test_Drive_Vehicle_Checklist__c>();
            for (Test_Drive_Vehicle_Checklist__c tv:testVehicles){
                if (tv.Mileage_at_End__c < tv.Mileage_at_Start__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Mileage PM cant be less than Mileage AM'));
                    return null;
                }
                insertTest.add(tv);
            }
            update insertTest;
            update showVehicles;
            update tpLists;
            update showQuestions;
            update generalQuestions;
        }catch(DmlException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dailychecklist cant be insert.Please contact IT'));
            return null;
        }
        return new Pagereference('/'+daily.Id);
    }
    
    public pageReference doCancel(){
        return goBack;
    }
}
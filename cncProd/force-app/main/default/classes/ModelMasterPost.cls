@RestResource(urlMapping='/ModelMaster/*')
global without sharing class ModelMasterPost {
    @HttpPost
    global static void getPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('NOT OK, Action not recognize');
        
        HttpResponse rese=new HttpResponse();
        
        String Action = req.params.get('Action');
        String Name = req.params.get('Code');
        String BHP = req.params.get('BHP');
        String BodyStyle = req.params.get('BodyStyle');
        String BranchCode = req.params.get('BranchCode');
        String COECategory = req.params.get('COECategory');
        String Commission = req.params.get('Commission');
        String Decomission = req.params.get('Decomission');
        String EngineCapacity = req.params.get('EngineCapacity');
        String FranchiseCode = req.params.get('FranchiseCode');
        String FuelCapacity = req.params.get('FuelCapacity');
        String FuelType = req.params.get('FuelType');
        String GMDiscountLimit = req.params.get('GMDiscountLimit');
        String GSTCode = req.params.get('GSTCode');
        String LaunchDate = req.params.get('LaunchDate');
        String MajorGroupCode = req.params.get('MajorGroupCode');
        String ManufactureCode = req.params.get('ManufactureCode');
        String MinimunDepositAmount = req.params.get('MinimunDepositAmount');
        String MinorGroupCode = req.params.get('MinorGroupCode');
        String ModelDescription = req.params.get('ModelDescription');
        String ModelShortDescription = req.params.get('ModelShortDescription');
        String ModelStatus = req.params.get('ModelStatus');
        String ModelType = req.params.get('ModelType');
        String NEACNGCorNo = req.params.get('NEACNGCorNo');
        String NEACorNo = req.params.get('NEACorNo');
        String NEAFuelConsumption = req.params.get('NEAFuelConsumption');
        String NEAModelCode = req.params.get('NEAModelCode');
        String NEAModelDescription = req.params.get('NEAModelDescription');
        String NoOfDoors = req.params.get('NoOfDoors');
        String NoOfGears = req.params.get('NoOfGears');
        String NoOfWeeksDelivery = req.params.get('NoOfWeeksDelivery');
        String OutOfProductionDate = req.params.get('OutOfProductionDate');
        String SalesManagerDiscountLimit = req.params.get('SalesManagerDiscountLimit');
        String SalesRepDiscountLimit = req.params.get('SalesRepDiscountLimit');
        String Transmission = req.params.get('Transmission');
        String VITASCode = req.params.get('VITASCode');
        String WarrantyMileage = req.params.get('WarrantyMileage');
        String WarrantyMonths = req.params.get('WarrantyMonths');
        
        Model_Master__c MM=new Model_Master__c();
        
        String[] dts;
        
        if(FranchiseCode == 'MITPC'){
        	BranchCode = 'CCA';
        }
        
        try{
        	List<Model_Master__c> MMlist = [select id,Name,BHP__c,Body_Style__c,Branch_Code__c,COE_Category__c,Commission__c,Decomission__c,Engine_Capacity__c,
                      Franchise_Code__c,Fuel_Capacity__c,Fuel_Type__c,GM_Discount_Limit__c,GST_Code__c,Launch_Date__c,Major_Group_Code__c,
                      Manufacture_Code__c,Minimun_Deposit_Amount__c,Minor_Group_Code__c,Model_Description__c,Model_Short_Description__c,
                      Active__c,Model_Type__c,NEA_CNG_Cor_No__c,NEA_Cor_No__c,NEA_Fuel_Consumption__c,NEA_Model_Code__c,
                      NEA_Model_Description__c,No_Of_Doors__c,No_Of_Gears__c,No_Of_Weeks_Delivery__c,Out_Of_Production_Date__c,Sales_Manager_Discount_Limit__c,
                      Sales_Rep_Discount_Limit__c,Transmission__c,VITAS_Code__c,Warranty_Mileage__c,Warranty_Months__c
                      from Model_Master__c where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
        	if(MMlist != null && MMlist.size() > 0){
        		MM = MMlist[0];
        	}
        	MM.Name=Name;
            MM.BHP__c=decimal.valueOf(BHP);
            MM.Body_Style__c=BodyStyle;
            MM.Branch_Code__c=BranchCode;
            MM.COE_Category__c=COECategory;
            MM.Commission__c=decimal.valueOf(Commission);
            MM.Decomission__c=decimal.valueOf(Decomission);
            MM.Engine_Capacity__c=decimal.valueOf(EngineCapacity);
            MM.Franchise_Code__c=FranchiseCode;
            MM.Fuel_Capacity__c=FuelCapacity;
            MM.Fuel_Type__c=FuelType;
            MM.GM_Discount_Limit__c=decimal.valueOf(GMDiscountLimit);
            MM.GST_Code__c=GSTCode;
            if (LaunchDate!=null && LaunchDate!=''){
                dts=LaunchDate.split(':');
                MM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            MM.Major_Group_Code__c=MajorGroupCode;
            MM.Manufacture_Code__c=ManufactureCode;
            MM.Minimun_Deposit_Amount__c=decimal.valueOf(MinimunDepositAmount);
            MM.Minor_Group_Code__c=MinorGroupCode;
            MM.Model_Description__c=ModelDescription;
            MM.Model_Short_Description__c=ModelShortDescription;
            //MM.Model_Status__c=ModelStatus;
            MM.Active__c=(ModelStatus=='A')? true : false;
            MM.Model_Type__c=ModelType;
            MM.NEA_CNG_Cor_No__c=NEACNGCorNo;
            MM.NEA_Cor_No__c=NEACorNo;
            MM.NEA_Fuel_Consumption__c=decimal.valueOf(NEAFuelConsumption);
            MM.NEA_Model_Code__c=NEAModelCode;
            MM.NEA_Model_Description__c=NEAModelDescription;
            MM.No_Of_Doors__c=decimal.valueOf(NoOfDoors);
            MM.No_Of_Gears__c=NoOfGears;
            MM.No_Of_Weeks_Delivery__c=decimal.valueOf(NoOfWeeksDelivery);
            if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                dts=OutOfProductionDate.split(':');
                MM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
            }
            MM.Sales_Manager_Discount_Limit__c=decimal.valueOf(SalesManagerDiscountLimit);
            MM.Sales_Rep_Discount_Limit__c=decimal.valueOf(SalesRepDiscountLimit);
            MM.Transmission__c=Transmission;
            MM.VITAS_Code__c=VITASCode;
            MM.Warranty_Mileage__c=decimal.valueOf(WarrantyMileage);
            MM.Warranty_Months__c=decimal.valueOf(WarrantyMonths);
            system.debug('Sebelum insert 2');
            upsert MM;
            system.debug('Sesudah Insert');
            res.responseBody = Blob.valueOf('OK');
        	
        	
            /*if (Action=='Insert'){
                system.debug('Sebelum insert');
                List<Model_Master__c> MMlist = [select id from Model_Master__c where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                if(MMlist.size()<=0){
                MM.Name=Name;
                MM.BHP__c=decimal.valueOf(BHP);
                MM.Body_Style__c=BodyStyle;
                MM.Branch_Code__c=BranchCode;
                MM.COE_Category__c=COECategory;
                MM.Commission__c=decimal.valueOf(Commission);
                MM.Decomission__c=decimal.valueOf(Decomission);
                MM.Engine_Capacity__c=decimal.valueOf(EngineCapacity);
                MM.Franchise_Code__c=FranchiseCode;
                MM.Fuel_Capacity__c=FuelCapacity;
                MM.Fuel_Type__c=FuelType;
                MM.GM_Discount_Limit__c=decimal.valueOf(GMDiscountLimit);
                MM.GST_Code__c=GSTCode;
                if (LaunchDate!=null && LaunchDate!=''){
                    dts=LaunchDate.split(':');
                    MM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                MM.Major_Group_Code__c=MajorGroupCode;
                MM.Manufacture_Code__c=ManufactureCode;
                MM.Minimun_Deposit_Amount__c=decimal.valueOf(MinimunDepositAmount);
                MM.Minor_Group_Code__c=MinorGroupCode;
                MM.Model_Description__c=ModelDescription;
                MM.Model_Short_Description__c=ModelShortDescription;
                //MM.Model_Status__c=ModelStatus;
                MM.Active__c=(ModelStatus=='A')? true : false;
                MM.Model_Type__c=ModelType;
                MM.NEA_CNG_Cor_No__c=NEACNGCorNo;
                MM.NEA_Cor_No__c=NEACorNo;
                MM.NEA_Fuel_Consumption__c=decimal.valueOf(NEAFuelConsumption);
                MM.NEA_Model_Code__c=NEAModelCode;
                MM.NEA_Model_Description__c=NEAModelDescription;
                MM.No_Of_Doors__c=decimal.valueOf(NoOfDoors);
                MM.No_Of_Gears__c=NoOfGears;
                MM.No_Of_Weeks_Delivery__c=decimal.valueOf(NoOfWeeksDelivery);
                if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                    dts=OutOfProductionDate.split(':');
                    MM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                MM.Sales_Manager_Discount_Limit__c=decimal.valueOf(SalesManagerDiscountLimit);
                MM.Sales_Rep_Discount_Limit__c=decimal.valueOf(SalesRepDiscountLimit);
                MM.Transmission__c=Transmission;
                MM.VITAS_Code__c=VITASCode;
                MM.Warranty_Mileage__c=decimal.valueOf(WarrantyMileage);
                MM.Warranty_Months__c=decimal.valueOf(WarrantyMonths);
                system.debug('Sebelum insert 2');
                insert MM;
                system.debug('Sesudah Insert');
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
                mail.setSubject('Model Master Eror');
                mail.setPlainTextBody('Duplicate Record');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                res.responseBody = Blob.valueOf('NOT OK, Duplicate Record');
                }
            }
            if (Action=='Update'){
                MM = [select id,Name,BHP__c,Body_Style__c,Branch_Code__c,COE_Category__c,Commission__c,Decomission__c,Engine_Capacity__c,
                      Franchise_Code__c,Fuel_Capacity__c,Fuel_Type__c,GM_Discount_Limit__c,GST_Code__c,Launch_Date__c,Major_Group_Code__c,
                      Manufacture_Code__c,Minimun_Deposit_Amount__c,Minor_Group_Code__c,Model_Description__c,Model_Short_Description__c,
                      Active__c,Model_Type__c,NEA_CNG_Cor_No__c,NEA_Cor_No__c,NEA_Fuel_Consumption__c,NEA_Model_Code__c,
                      NEA_Model_Description__c,No_Of_Doors__c,No_Of_Gears__c,No_Of_Weeks_Delivery__c,Out_Of_Production_Date__c,Sales_Manager_Discount_Limit__c,
                      Sales_Rep_Discount_Limit__c,Transmission__c,VITAS_Code__c,Warranty_Mileage__c,Warranty_Months__c
                      from Model_Master__c where Name=:Name and Franchise_Code__c=: FranchiseCode and  Branch_Code__c =:BranchCode];
                MM.BHP__c=decimal.valueOf(BHP);
                MM.Body_Style__c=BodyStyle;
                MM.Branch_Code__c=BranchCode;
                MM.COE_Category__c=COECategory;
                MM.Commission__c=decimal.valueOf(Commission);
                MM.Decomission__c=decimal.valueOf(Decomission);
                MM.Engine_Capacity__c=decimal.valueOf(EngineCapacity);
                MM.Franchise_Code__c=FranchiseCode;
                MM.Fuel_Capacity__c=FuelCapacity;
                MM.Fuel_Type__c=FuelType;
                MM.GM_Discount_Limit__c=decimal.valueOf(GMDiscountLimit);
                MM.GST_Code__c=GSTCode;
                if (LaunchDate!=null && LaunchDate!=''){
                    dts=LaunchDate.split(':');
                    MM.Launch_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                MM.Major_Group_Code__c=MajorGroupCode;
                MM.Manufacture_Code__c=ManufactureCode;
                MM.Minimun_Deposit_Amount__c=decimal.valueOf(MinimunDepositAmount);
                MM.Minor_Group_Code__c=MinorGroupCode;
                MM.Model_Description__c=ModelDescription;
                MM.Model_Short_Description__c=ModelShortDescription;
                //MM.Model_Status__c=ModelStatus;
                MM.Active__c=(ModelStatus=='A')? true : false;
                MM.Model_Type__c=ModelType;
                MM.NEA_CNG_Cor_No__c=NEACNGCorNo;
                MM.NEA_Cor_No__c=NEACorNo;
                MM.NEA_Fuel_Consumption__c=decimal.valueOf(NEAFuelConsumption);
                MM.NEA_Model_Code__c=NEAModelCode;
                MM.NEA_Model_Description__c=NEAModelDescription;
                MM.No_Of_Doors__c=decimal.valueOf(NoOfDoors);
                MM.No_Of_Gears__c=NoOfGears;
                MM.No_Of_Weeks_Delivery__c=decimal.valueOf(NoOfWeeksDelivery);
                if (OutOfProductionDate!=null && OutOfProductionDate!=''){
                    dts=OutOfProductionDate.split(':');
                    MM.Out_Of_Production_Date__c=date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[1]), Integer.valueOf(dts[0]));
                }
                MM.Sales_Manager_Discount_Limit__c=decimal.valueOf(SalesManagerDiscountLimit);
                MM.Sales_Rep_Discount_Limit__c=decimal.valueOf(SalesRepDiscountLimit);
                MM.Transmission__c=Transmission;
                MM.VITAS_Code__c=VITASCode;
                MM.Warranty_Mileage__c=decimal.valueOf(WarrantyMileage);
                MM.Warranty_Months__c=decimal.valueOf(WarrantyMonths);
                update MM;
                res.responseBody = Blob.valueOf('OK');
            }  */ 
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
            mail.setSubject('Model Master Eror');
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
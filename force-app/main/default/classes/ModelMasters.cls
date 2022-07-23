public class ModelMasters extends ADGLIB_SObjectDomain {
    public ModelMasters(List<Model_Master__c> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) {
			return new ModelMasters(sObjectList);
		}
	}

    public override void onApplyDefaults() {
        for(Model_Master__c modelMaster : (List<Model_Master__c>) Records) {
            String cleanFranchiseCode = modelMaster.Franchise_Code__c == null ? '' : modelMaster.Franchise_Code__c;
			modelMaster.VSMS_Compound_Primary_Key__c = cleanFranchiseCode + modelMaster.Name;
        }
    }

    public override void onAfterInsert()
    {
        updateModelGlobalValueSet(null);
    }

    public void updateModelGlobalValueSet(Map<Id, SObject> existingRecords)
    {
        List<String> modelNames = new List<String>();

        for (Model_Master__c model : (List<Model_Master__c>) Records)
        {
            modelNames.add(model.Model_Description__c);
        }

        ToolingAPIUtility.updateModelGlobalValueSet(modelNames);
    }
}
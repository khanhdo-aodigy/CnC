/** *****
 * Description : Service Class for Used Car Vehicle Sizing object
 * 
 * Change History
 * Date(YYYYMMDD)       Name                    Description
 * 20211013            TPhan@aodigy         Created Initial Version. 
** *****/

public class UsedCarVehicleSizingService 
{
    private static UsedCarVehicleSizingSelector sel = new UsedCarVehicleSizingSelector();

    public static List<Used_Car_Vehicle_Sizing__c> getUsedCarSizingsByNames (Set<String> names)
    {
        return sel.selectUsedCarSizingsByNames(names);
    }

    public static List<Used_Car_Vehicle_Sizing__c> createNewUsedCarSizing (List<ModelGroup> groups)
    {
        List<Used_Car_Vehicle_Sizing__c> newUsedCarSizingList = new List<Used_Car_Vehicle_Sizing__c>();
        Used_Car_Vehicle_Sizing__c newUsedCarSizing; 
        
        for (ModelGroup modelGroup : groups)
        {
            newUsedCarSizing           = new Used_Car_Vehicle_Sizing__c();
            newUsedCarSizing.Make__c   = modelGroup.make;
            newUsedCarSizing.Model__c  = modelGroup.model;
            newUsedCarSizing.Name      = modelGroup.make + ' ' + modelGroup.model;
            newUsedCarSizingList.add(newUsedCarSizing);
        }      
            
        insert newUsedCarSizingList;

        return newUsedCarSizingList;
    }

    public static Map<String, Used_Car_Vehicle_Sizing__c> checkAndCreateNewUCSizing (Map<String, ModelGroup> groupMap)
    {
        Map<String, Used_Car_Vehicle_Sizing__c> UCSizingMap   = new Map<String, Used_Car_Vehicle_Sizing__c>();
        List<Used_Car_Vehicle_Sizing__c> existingUCSizingList = new List<Used_Car_Vehicle_Sizing__c>();        
        List<Used_Car_Vehicle_Sizing__c> newUCSizingList      = new List<Used_Car_Vehicle_Sizing__c>();
        List<ModelGroup> nonExistingGroups                    = new List<ModelGroup>();

        Set<String> names    = groupMap.keySet();
        existingUCSizingList = getUsedCarSizingsByNames(names);

        if (!existingUCSizingList.isEmpty())
        {
            for (Used_Car_Vehicle_Sizing__c rcd : existingUCSizingList)
            {
                if (names.contains(rcd.Name))
                {
                    UCSizingMap.put(rcd.Name, rcd);
                    names.remove(rcd.Name);
                }
            }
        }

        if (names.size() > 0)
        {
           for (String name : names)
           {
               nonExistingGroups.add(groupMap.get(name));
           }

           newUCSizingList = createNewUsedCarSizing(nonExistingGroups);

           for (Used_Car_Vehicle_Sizing__c rcd : newUCSizingList)
           {
               UCSizingMap.put(rcd.Name, rcd);
           }
        }

        return UCSizingMap;
    }

    public class ModelGroup
    {
        public String make;
        public String model;

        public ModelGroup (String make, String model)
        {
            this.make = make;
            this.model= model;
        }
    }
}
public with sharing class VehicleDeliveryCertificate_pdfCtrl {
    public Sales_Agreement__c agreement {get; set;}
    public list<VehicleChecklistWrap> handoverItems {get; set;}
    public list<VehicleChecklistWrap> checklist {get; set;}
    public list<SA_Accessory__c> a_accessories {get; set;}
    public list<SA_Accessory__c> m_accessories {get; set;}
    

    public boolean displayHandoverItems {get; set;}
    public boolean displayChecklist {get; set;}
    public boolean displayAdditionalAccessories {get; set;}
    public boolean displayMainAccessories {get; set;}
    public class VDC_Exception extends Exception{}

    /**
     -- constructor
     */
    public VehicleDeliveryCertificate_pdfCtrl() {
        system.debug(' -- Begin Constructor');
        string recordId = ApexPages.currentPage().getParameters().get('id');

        // get sales agreement
        agreement = get_SalesAgreement(recordId);
        
        // get handover items
        try {
            handoverItems = get_HandoverItems();
        } catch (Exception e) {throw new VDC_Exception('Error when getting handover items: ' + e.getMessage());}
        
        
        // get vehicle checklist
        try {
            checklist = get_VehicleChecklist(agreement.FranchiseCode__c);
        } catch (Exception e) {throw new VDC_Exception('Error when getting vehicle checklist: ' + e.getMessage());}
        

        // get additional accessories
        try {
            this.displayAdditionalAccessories = false;
            set<string> a_selectedCart = agreement.VDC_Additional_Accessories_Cart__c == null? new set<string>() : new set<string> (agreement.VDC_Additional_Accessories_Cart__c.split(','));
            a_accessories = get_SelectedAccessories(recordId, agreement, 'ADDITIONAL ACCESSORIES', a_selectedCart);
            if (a_accessories.size() > 0) this.displayAdditionalAccessories = true;
        } catch (Exception e) {throw new VDC_Exception('Error when getting additional accessories: ' + e.getMessage());}

        // get main accessories
        try {
            this.displayMainAccessories = false;
            set<string> m_selectedCart = agreement.VDC_Main_Accessories_Cart__c == null? new set<string>() : new set<string> (agreement.VDC_Main_Accessories_Cart__c.split(','));
            m_accessories = get_SelectedAccessories(recordId, agreement, 'MAIN ACCESSORIES', m_selectedCart);
            if (m_accessories.size() > 0) this.displayMainAccessories = true;
        } catch (Exception e) {throw new VDC_Exception('Error when getting main accessories: ' + e.getMessage());}

        system.debug(' -- End Constructor');
    }

    /**
     -- get sales agreement record with specific ID
     */
    private Sales_Agreement__c get_SalesAgreement(string recordId) {
        list<Sales_Agreement__c> records = (list<Sales_Agreement__c>) SDP_VehicleDeliveryCertificateController.getRecords('Sales_Agreement__c', 'id', recordId, '');
        if (records.size() == 1) {
            return records[0];
        } else {throw new VDC_Exception('Found no Sales Agreement record with this record ID');}
    }

    /**
     -- get handover items and wrap to useable format
     */
    private list<VehicleChecklistWrap> get_HandoverItems() {
        this.displayHandoverItems = false;
        list<VehicleChecklistWrap> result = new list<VehicleChecklistWrap>();
        list<SA_Vehicle_Checklist__c> raw_HandoverItems = (list<SA_Vehicle_Checklist__c>) SDP_VehicleDeliveryCertificateController.getRecords('SA_Vehicle_Checklist__c', 'Checklist_Type__c', 'Handover Items', 'ORDER BY Position__c');
        if (raw_HandoverItems.size() > 0) {
            result = wrap_VehicleItems(raw_HandoverItems, false);
            this.displayHandoverItems = true;
        }
        return result;
    }

    /**
     -- get vehicle checklist and wrap to useable format
     */
    private list<VehicleChecklistWrap> get_VehicleChecklist(string frCode) {
        this.displayChecklist = false;
        list<VehicleChecklistWrap> result = new list<VehicleChecklistWrap>();
        list<SA_Vehicle_Checklist__c> raw_Checklist = (list<SA_Vehicle_Checklist__c>) SDP_VehicleDeliveryCertificateController.getRecords('SA_Vehicle_Checklist__c', 'Checklist_Type__c', 'Vehicle Checklist', 'AND Franchise_Code__c = \'' + frCode + '\' ORDER BY Position__c');
        if (raw_Checklist.size() > 0) {
            result = wrap_VehicleItems(raw_Checklist, true);
            this.displayChecklist = true;
        }
        return result;
    }

    /**
     -- get selected accessories of a specific type
     */
    private list<SA_Accessory__c> get_SelectedAccessories(string recordID, Sales_Agreement__c SA, string accsType, set<string> selectedCart) {
        system.debug('hahaha');
        system.debug(selectedCart);
        list<SA_Accessory__c> result = new list<SA_Accessory__c>();
        result = (list<SA_Accessory__c>) SDP_VehicleDeliveryCertificateController.getRecords('SA_Accessory__c', 'Sales_Agreement__c', recordId, 'AND Accessories_Master__r.AccessoriesGroup__c = \'' + accsType + '\'');
        result = removeUnselectedAccessories(result, selectedCart);
        return result;
    }

    /**
     -- remove un-selected accessories from list of all accessories
     */
    private list<SA_Accessory__c> removeUnselectedAccessories(list<SA_Accessory__c> accessories, set<string> selectedCart) {
        system.debug('--- removeUnselectedAccessories input:');
        system.debug(accessories);
        system.debug(selectedCart);

        list<SA_Accessory__c> result = new list<SA_Accessory__c>();

        for (integer index = 0; index < accessories.size(); index++) {
            if (selectedCart.contains(accessories[index].Id)) result.add(accessories[index]);
        }

        return result;
    }
    /**
     -- wrap SA_Vehicle_Checklist__c to VehicleChecklistWrap
     */
    private list<VehicleChecklistWrap> wrap_VehicleItems(list<SA_Vehicle_Checklist__c> tempHandoverItems, boolean isNumbering) {
        boolean isLeftItem = true;
        list<VehicleChecklistWrap> result = new list<VehicleChecklistWrap>{};
        for (integer index = 0; index < tempHandoverItems.size(); index++) {
            
            if (isLeftItem) {
                result.add(new VehicleChecklistWrap());
                result.get(result.size() -1).setLeftItem(tempHandoverItems[index]);
                string numbering = string.valueOf(index + 1).length() < 2? '0' + string.valueOf(index + 1) : string.valueOf(index + 1);
                if(isNumbering) result.get(result.size() -1).setLeftNumbering(numbering);
                // handle for last item in list
                if (index == tempHandoverItems.size() - 1)
                result.get(result.size() -1).setDisplay(false);
            }
            
            if (!isLeftItem) {
                result.get(result.size() -1).setRightItem(tempHandoverItems[index]);
                string numbering = string.valueOf(index + 1).length() < 2? '0' + string.valueOf(index + 1) : string.valueOf(index + 1);
                if(isNumbering) result.get(result.size() -1).setRightNumbering(numbering);
            }
            isLeftItem = !isLeftItem;
        }
        return result;
    }

    /**
     -- wrapper class for Vehicle Items
     */
    public class VehicleChecklistWrap {
        public SA_Vehicle_Checklist__c left {get; set;}
        public SA_Vehicle_Checklist__c right {get; set;}
        public boolean display {get; set;}
        public string leftNumbering {get; set;}
        public string rightNumbering {get; set;}

        public VehicleChecklistWrap() {
            this.display = true;
        }

        public void setLeftItem(SA_Vehicle_Checklist__c item) {
            this.left = item;
        }

        public void setRightItem(SA_Vehicle_Checklist__c item) {
            this.right = item;
        }

        public void setDisplay(boolean display) {
            this.display = display;
        }

        public void setLeftNumbering(string numbering) {
            this.leftNumbering = numbering;
        }

        public void setRightNumbering(string numbering) {
            this.rightNumbering = numbering;
        }
    }
}
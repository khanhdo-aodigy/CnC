/*==========================================================================================================================================================================
 * Domain class for Shipment Line Item Entity
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *          DATE::                              BY::                                TICKET::                                            CHANGELOG
 *      23 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000025                                           init
 * ========================================================================================================================================================================== 
 */

public inherited sharing class VehicleShipmentLineItems extends ADGLIB_SObjectDomain
{
    public VehicleShipmentLineItems(List<Shipment_Line_Item__c> sObjectList) 
    {
        super(sObjectList);
    }

    public class Constructor implements ADGLIB_SObjectDomain.IConstructable 
    {
		public ADGLIB_SObjectDomain construct(List<SObject> sObjectList) 
        {
			return new VehicleShipmentLineItems(sObjectList);
		}
	}

    public override void onAfterInsert()
    {
        defaultLineItemSeqNo(null);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        defaultLineItemSeqNo(existingRecords);
    }

    /**
     * ===================================================================================
     * Number the invoice line items under 1 Manufacturer Invoice in sequence for Getsasia API integration
     * Created By: phan.thu@aodigy.com
     * Created Date: Aug 2022
     * ===================================================================================
    */
    @TestVisible
    private void defaultLineItemSeqNo(Map<Id, SObject> existingRecords)
    {
        ADGLIB_SObjectUnitOfWork uow               = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Shipment_Line_Item__c.SObjectType});
        Set<Id> invoiceIds                         = new Set<Id>();
        Set<Id> oldInvoiceIds                      = new Set<Id>();
        Map<String, Integer> invoiceAndSequenceNos = new Map<String, Integer>();

        if (existingRecords <> null)
        {
            for (Shipment_Line_Item__c item : (List<Shipment_Line_Item__c>) Records)
            {
                Shipment_Line_Item__c oldItem = (Shipment_Line_Item__c) existingRecords.get(item.Id);

                if (oldItem.Invoice_No__c == null && oldItem.Invoice_No__c <> item.Invoice_No__c)
                {
                    invoiceIds.add(item.Invoice_No__c);
                }
                else if (oldItem.Invoice_No__c <> null && oldItem.Invoice_No__c <> item.Invoice_No__c && item.Invoice_No__c <> null)
                {
                    invoiceIds.add(item.Invoice_No__c);
                    oldInvoiceIds.add(oldItem.Invoice_No__c);
                }
                else if (oldItem.Invoice_No__c <> null && item.Invoice_No__c == null)
                {
                    oldInvoiceIds.add(oldItem.Invoice_No__c);
                    uow.registerDirty(new Shipment_Line_Item__c(Id = item.Id, Shipment_Line_Item_Sequence_No__c = ''));
                }
            }
        }
        else 
        {
            for (Shipment_Line_Item__c item : (List<Shipment_Line_Item__c>) Records) 
            {
                if (item.Invoice_No__c <> null)
                {
                    invoiceIds.add(item.Invoice_No__c);
                }
            }  
        }

        if (invoiceIds.size() > 0)
        {
            Map<Id, List<Shipment_Line_Item__c>> lineItemMap = new Map<Id, List<Shipment_Line_Item__c>>();

            List<Manufacturer_Invoice__c> invoices = ManufacturerInvoiceService.getManufacturerInvoiceWithSLIByIds(invoiceIds);

            for (Manufacturer_Invoice__c inv : invoices)
            {
                lineItemMap.put(inv.Id, inv.Shipment_Line_Items__r);
            }

            for (Shipment_Line_Item__c item : (List<Shipment_Line_Item__c>) Records)
            {
                if (lineItemMap.containsKey(item.Invoice_No__c))
                {
                    if (lineItemMap.get(item.Invoice_No__c) <> null && !lineItemMap.get(item.Invoice_No__c).isEmpty())
                    {
                        Integer currentSeqNo = 1;
                        for (Shipment_Line_Item__c updatedItem : lineItemMap.get(item.Invoice_No__c))
                        {
                            uow.registerDirty(new Shipment_Line_Item__c(Id = updatedItem.Id, Shipment_Line_Item_Sequence_No__c = String.valueOf(currentSeqNo)));
                            currentSeqNo++;
                        }
                    }
                    else 
                    {
                        uow.registerDirty(new Shipment_Line_Item__c(Id = item.Id, Shipment_Line_Item_Sequence_No__c = '1'));
                    }
                }
            }
        }

        if (oldInvoiceIds.size() > 0)
        {
            List<Manufacturer_Invoice__c> oldInvoices = ManufacturerInvoiceService.getManufacturerInvoiceWithSLIByIds(oldInvoiceIds);
            if (oldInvoices <> null && oldInvoices.size() > 0)
            {
                for (Manufacturer_Invoice__c inv : oldInvoices)
                {
                    if (inv.Shipment_Line_Items__r <> null && inv.Shipment_Line_Items__r.size() > 0)
                    {
                        Integer currentSeqNo = 1;

                        for (Shipment_Line_Item__c item : inv.Shipment_Line_Items__r)
                        {
                            item.Shipment_Line_Item_Sequence_No__c = String.valueOf(currentSeqNo);
                            uow.registerDirty(item);
                            currentSeqNo++;
                        }
                    }
                }
            }
        }
        
        TriggerExclusion.excludeTrigger('Shipment_Line_Item__c', true);
        uow.commitWork();
        TriggerExclusion.excludeTrigger('Shipment_Line_Item__c', false);
    }
}
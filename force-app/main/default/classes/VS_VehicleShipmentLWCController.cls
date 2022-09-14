/*==========================================================================================================================================================================
 * Controller class for LWC in Vehicle Shipment module
 * Created By: Aodigy Team
 * Create Date: August 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *           18 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000023                                     Init
 *           20 Aug 2022                       nam@aodigy.com                    	  US-Ship-000024                                     
 *			 25 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000028                                     Added submitToGetsAsia method
 *           27 Aug 2022                       phan.thu@aodigy.com                    US-Ship-000027                                     Added getVehicleShipmentWithInvoicesAndLineItems
 *           05 Sep 2022                       phan.thu@aodigy.com                    US-Ship-000035                                     Added getStockVehicleMastersForDutyRequest, getGrouppedStockVehicleMasters, createInvoiceAndInwardDeclaration methods
 *           08 Sep 2022                       phan.thu@aodigy.com                    US-Ship-000036                                     Added retrievePermitNo method
 * ========================================================================================================================================================================== 
 */

public without sharing class VS_VehicleShipmentLWCController 
{
    @AuraEnabled(cacheable = true)
    public static List<Shipment_Line_Item__c> getUnmatchedLineItems(String vehicleShipmentId)
    {
        try 
        {
            return VehicleShipmentLineItemService.getLineItemsNotTaggedToInvoicesByShipmentId(vehicleShipmentId);
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Manufacturer_Invoice__c> getManufacturerInvoices(String vehicleShipmentId)
    {
        try 
        {
            return [SELECT Id, Invoice_No__c FROM Manufacturer_Invoice__c WHERE Vehicle_Shipment__c =: vehicleShipmentId];
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Master2__c> getStockVehicleMasters(String vehicleShipmentId)
    {
        try 
        {
		    return [SELECT Id, Name, Shipment_Line_Item__r.name, Manufacturer_Ref_No__c, 
                       Vehicle_Status__c, Invoice_No__c, Chassis__c, TN_HS_Code__c, Engine_No__c 
                    FROM Vehicle_Master2__c 
                    WHERE Vehicle_Shipment__c =: vehicleShipmentId];
            
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean matchManufacturerInvoiceAndLineItem(String invoiceId, List<String> lineItemIds)
    {
        ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Shipment_Line_Item__c.SObjectType});
        
        try 
        {
            for (String itemId : lineItemIds)
            {
                uow.registerDirty(new Shipment_Line_Item__c (Id = itemId, Invoice_No__c = invoiceId));
            }

            uow.commitWork();
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    // @AuraEnabled
    // public static Boolean submitToGetsAsia(String vehicleShipmentId, String serviceType, Map<String, List<String>> grouppedItems)
    // {
    //     Boolean result;

    //     try 
    //     {
    //         if (serviceType == 'IPT')
    //         {
    //            result = !Test.isRunningTest() ? VS_InwardPaymentSVC.submitIPT(vehicleShipmentId, grouppedItems, true) : true;
    //         }

    //         if (serviceType == 'INP')
    //         {
    //             result = !Test.isRunningTest() ? VS_InwardNonPaymentSVC.submitINP(vehicleShipmentId, grouppedItems) : true;
    //         }
    //     } 
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage());
    //     }

    //     return result;
    // }

    // @AuraEnabled(cacheable = true)
    // public static VehicleShipmentWrapper getVehicleShipmentWithInvoicesAndLineItems(String vehicleShipmentId, String transactionType)
    // {
    //     Map<String, List<Shipment_Line_Item__c>> lineItemMap   = new Map<String, List<Shipment_Line_Item__c>>();
    //     Map<String, List<Vehicle_Master2__c>> vehicleMasterMap = new Map<String, List<Vehicle_Master2__c>>();
    //     VehicleShipmentWrapper shipmentWrapper                 = new VehicleShipmentWrapper();

    //     try 
    //     {
    //         if (transactionType == 'INP')
    //         {
    //             Vehicle_Shipment__c vehicleShipment = VehicleShipmentServices.getByIdWithInvoicesAndLineItemsAndSVMs(vehicleShipmentId, true, true, false);
    
    //             if (vehicleShipment.Shipment_Line_Items__r <> null && vehicleShipment.Shipment_Line_Items__r.size() > 0)
    //             {
    //                 for (Shipment_Line_Item__c item : vehicleShipment.Shipment_Line_Items__r)
    //                 {
    //                     List<Shipment_Line_Item__c> tempItemList;
    
    //                     if (lineItemMap.containsKey(item.Item_Group_Code__c))
    //                     {
    //                         tempItemList = lineItemMap.get(item.Item_Group_Code__c);
    //                         tempItemList.add(item);
    //                         lineItemMap.put(item.Item_Group_Code__c, tempItemList);
    //                     }
    //                     else 
    //                     {
    //                         lineItemMap.put(item.Item_Group_Code__c, new List<Shipment_Line_Item__c> {item});    
    //                     }
    //                 }
    
    //                 shipmentWrapper.lineItems = lineItemMap;
    //             }
    //         }

    //         if (transactionType == 'IPT')
    //         {
    //             Vehicle_Shipment__c vehicleShipment = VehicleShipmentServices.getByIdWithInvoicesAndLineItemsAndSVMs(vehicleShipmentId, true, false, true);

    //             if (vehicleShipment.Stock_Vehicle_Masters__r <> null && vehicleShipment.Stock_Vehicle_Masters__r.size() > 0)
    //             {
    //                 for (Vehicle_Master2__c vh : vehicleShipment.Stock_Vehicle_Masters__r)
    //                 {
    //                     List<Vehicle_Master2__c> tempVehicleList;
    
    //                     if (vehicleMasterMap.containsKey(vh.Item_Group_Code__c))
    //                     {
    //                         tempVehicleList = vehicleMasterMap.get(vh.Item_Group_Code__c);
    //                         tempVehicleList.add(vh);
    //                         vehicleMasterMap.put(vh.Item_Group_Code__c, tempVehicleList);
    //                     }
    //                     else 
    //                     {
    //                         vehicleMasterMap.put(vh.Item_Group_Code__c, new List<Vehicle_Master2__c> {vh});    
    //                     }
    //                 }
    
    //                 shipmentWrapper.vehicleMasters = vehicleMasterMap;
    //             }
    //         }
    //     } 
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage() + ' -- ' + e.getLineNumber());
    //     }

    //     return shipmentWrapper;
    // }

    // @AuraEnabled(cacheable = true)
    // public static List<Vehicle_Master2__c> getStockVehicleMastersForDutyRequest()
    // {
    //     try 
    //     {
    //         return (List<Vehicle_Master2__c>) StockVehicleMasterService.selectStockVehicleMastersForDutyRequest();
    //     } 
    //     catch (Exception e) 
    //     {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled(cacheable = true)
    // public static StockVehicleMasterWrapper getGrouppedStockVehicleMasters(List<Id> stockVehicleMasterIds)
    // {
    //     StockVehicleMasterWrapper vehicleMasterWrapper                     = new StockVehicleMasterWrapper();
    //     Map<String, Map<String, List<Vehicle_Master2__c>>> groupedVehicles = new Map<String, Map<String, List<Vehicle_Master2__c>>>();  
    //     Map<String, List<Vehicle_Master2__c>> vehiclesByVesselCode         = new Map<String, List<Vehicle_Master2__c>>();
    //     Map<String, List<Vehicle_Master2__c>> vehiclesByHSAndProdCodes;
    //     List<Vehicle_Master2__c> tempVehicleList;
        
    //     try 
    //     {
    //         for (Vehicle_Master2__c vh: StockVehicleMasterService.selectByIds(stockVehicleMasterIds))
    //         {
    //             if (vehiclesByVesselCode.containsKey(vh.Vessel_Name__c))
    //             {
    //                 tempVehicleList = vehiclesByVesselCode.get(vh.Vessel_Name__c);
    //                 tempVehicleList.add(vh);
    //                 vehiclesByVesselCode.put(vh.Vessel_Name__c, tempVehicleList);
    //             }
    //             else 
    //             {
    //                 vehiclesByVesselCode.put(vh.Vessel_Name__c, new List<Vehicle_Master2__c> {vh});    
    //             }
    //         }

    //         for (String vesselCode : vehiclesByVesselCode.keySet())
    //         {
    //             vehiclesByHSAndProdCodes = new Map<String, List<Vehicle_Master2__c>>();

    //             for (Vehicle_Master2__c vehicle : vehiclesByVesselCode.get(vesselCode))
    //             {
    //                 if (vehiclesByHSAndProdCodes.containsKey(vehicle.Item_Group_Code__c))
    //                 {
    //                     tempVehicleList = vehiclesByHSAndProdCodes.get(vehicle.Item_Group_Code__c);
    //                     tempVehicleList.add(vehicle);
    //                     vehiclesByHSAndProdCodes.put(vehicle.Item_Group_Code__c, tempVehicleList);
    //                 }
    //                 else 
    //                 {
    //                     vehiclesByHSAndProdCodes.put(vehicle.Item_Group_Code__c, new List<Vehicle_Master2__c> {vehicle});    
    //                 }
    //             }

    //             groupedVehicles.put(vesselCode, vehiclesByHSAndProdCodes);
    //         }

    //         vehicleMasterWrapper.grouppedVehicles = groupedVehicles;
    //     } 
    //     catch (Exception e) 
    //     {
    //         throw new AuraHandledException(e.getMessage());
    //     }

    //     return vehicleMasterWrapper;
    // }

    // @AuraEnabled
    // public static Id createInvoiceAndInwardDeclaration(Map<String, List<Vehicle_Master2__c>> vehicleMastersByVessel)
    // {
    //     ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Inward_Declaration__c.SObjectType,
    //                                                                                          Manufacturer_Invoice__c.SObjectType, 
    //                                                                                          Vehicle_Master2__c.SObjectType});
    //     Id returnedId;
    //     try 
    //     {
    //         Id recordTypeId                    = Schema.SObjectType.Inward_Declaration__c.getRecordTypeInfosByDeveloperName()?.get('Inward_Payment')?.getRecordTypeId();
    //         Inward_Declaration__c newInwardDec = new Inward_Declaration__c(recordTypeId = recordTypeId);
    //         uow.registerNew(newInwardDec);

    //         String vesselName              = new List<String>(vehicleMastersByVessel?.keySet())?.get(0);
    //         String invoiceNo               = vehicleMastersByVessel?.values()?.get(0)?.get(0)?.Invoice_No__c;
    //         Manufacturer_Invoice__c newInv = new Manufacturer_Invoice__c(Name = vesselName, Invoice_Date__c = Date.today(), Invoice_No__c = invoiceNo);
    //         uow.registerNew(newInv, Manufacturer_Invoice__c.Inward_Declaration__c, newInwardDec);

    //         for (List<Vehicle_Master2__c> vehicleLst : vehicleMastersByVessel.values())
    //         {
    //             for (Vehicle_Master2__c vh : vehicleLst)
    //             {
    //                 uow.registerDirty(vh, Vehicle_Master2__c.Inward_Declaration_Invoice__c, newInv);
    //             }
    //         }

    //         uow.commitWork();

    //         returnedId = newInv.Id;
    //     }
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage() + ' -- ' + e.getLineNumber());
    //     }

    //     return returnedId;
    // }

    // @AuraEnabled(cacheable = true)
    // public static VehicleShipmentWrapper getGrouppedStockVehicleMastersByInwardDecId(String inwardDeclarationId)
    // {
    //     VehicleShipmentWrapper vehicleMasterWrapper                = new VehicleShipmentWrapper();
    //     Set<Id> invoiceIds                                         = new Set<Id>();
    //     Map<String, List<Vehicle_Master2__c>> vehiclesByGroupCodes = new Map<String, List<Vehicle_Master2__c>>();
    //     List<Vehicle_Master2__c> tempVehicleList;

    //     try 
    //     {
    //         Inward_Declaration__c inwardDec = InwardDeclarationService.getByIdsWithInvoices(new Set<Id> {inwardDeclarationId}, true)?.get(0);

    //         if (inwardDec.Inward_Declaration_Invoices__r <> null && inwardDec.Inward_Declaration_Invoices__r.size() > 0)
    //         {
    //             for (Manufacturer_Invoice__c inv : inwardDec.Inward_Declaration_Invoices__r)
    //             {
    //                 invoiceIds.add(inv.Id);
    //             }

    //             List<Vehicle_Master2__c> vehicleMasters = StockVehicleMasterService.selectStockVehicleMastersByInvoiceIds(invoiceIds);

    //             if (vehicleMasters <> null && vehicleMasters.size() > 0)
    //             {
    //                 for (Vehicle_Master2__c vh : vehicleMasters)
    //                 {
    //                     if (vehiclesByGroupCodes.containsKey(vh.Item_Group_Code__c))
    //                     {
    //                         tempVehicleList = vehiclesByGroupCodes.get(vh.Item_Group_Code__c);
    //                         tempVehicleList.add(vh);
    //                         vehiclesByGroupCodes.put(vh.Item_Group_Code__c, tempVehicleList);
    //                     }
    //                     else 
    //                     {
    //                         vehiclesByGroupCodes.put(vh.Item_Group_Code__c, new List<Vehicle_Master2__c> {vh});    
    //                     }
    //                 }

    //                 vehicleMasterWrapper.vehicleMasters = vehiclesByGroupCodes;
    //             }
    //         }
    //     } 
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage() + ' -- ' + e.getLineNumber());
    //     }

    //     return vehicleMasterWrapper;
    // }

    // @AuraEnabled
    // public static Boolean submitToGetsAsiaIPT(String inwardDeclarationId, Map<String, List<String>> grouppedItems)
    // {
    //     Boolean result;

    //     try 
    //     {
    //         result = !Test.isRunningTest() ? VS_InwardPaymentSVC.submitIPT(inwardDeclarationId, grouppedItems, false) : true;
    //     } 
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage());
    //     }

    //     return result;
    // }

    // @AuraEnabled(cacheable = true)
    // public static List<Manufacturer_Invoice__c> getManufacturerInvoicesByIds(List<Id> invoiceIds)
    // {
    //     try 
    //     {
    //         return ManufacturerInvoiceService.getManufacturerInvoiceWithSLIByIds(new Set<Id> (invoiceIds));
    //     } 
    //     catch (Exception e) 
    //     {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static Boolean retrievePermitNo(Id inwardDeclarationId)
    // {
    //     Boolean result = false;
        
    //     try 
    //     {
    //         Inward_Declaration__c inwardDec = InwardDeclarationService.getByIdsWithInvoices(new Set<Id> {inwardDeclarationId}, false)?.get(0);

    //         if (String.isNotBlank(inwardDec?.Transaction_ID__c))
    //         {
    //             List<serviceDataPool.ServiceDataPoolWrapper> serviceWrapper = new List<serviceDataPool.ServiceDataPoolWrapper>();

    //             VS_HttpCalloutUtil.ResponseWrapper wrapper = VS_HttpCalloutUtil.invokeApiCallToGetResponse(VS_HttpCalloutUtil.generateHttpRequestPayloadForResponseAPI(inwardDec?.Transaction_ID__c), inwardDec?.Transaction_ID__c);
    //             HttpResponse httpRes                       = wrapper.res;
    //             Map<String, Object> response               = (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
    
    //             serviceWrapper.add(wrapper.serviceDataPoolWrapper);
    
    //             serviceDataPool.buildListServiceDataPoolHttp(serviceWrapper);
    
    //             if (response.get('status') == 'S001')
    //             {
    //                 List<Object> data = (List<Object>) response.get('data');

    //                 if (data <> null && data.size() > 0)
    //                 {
    //                     Map<String, Object> dataMap  = (Map<String, Object>) (data[0]);
    //                     Map<String, Object> resMap   = (Map<String, Object>) dataMap.get('Response');
    //                     String status                = resMap.get('StatusDesc')?.toString();
                        
    //                     if (status == 'Declaration Approved')
    //                     {
    //                         List<Object> remarks = (List<Object>) resMap.get('Remarks');

    //                         if (remarks <> null && remarks.size() > 0)
    //                         {
    //                             Map<String, Object> remarksMap  = (Map<String, Object>) (remarks[0]);
    //                             Map<String, Object> permitMap   = (Map<String, Object>) remarksMap.get('permit');
    //                             String permitNo                 = permitMap.get('pmt_no')?.toString();

    //                             if (String.isNotBlank(permitNo))
    //                             {
    //                                 result = updatePermitNo(inwardDec.Id, inwardDec.Vehicle_Shipment__c, permitNo);
    //                             }
    //                             else 
    //                             {
    //                                 throwError('Permit has not been approved yet!');
    //                             }
    //                         }
    //                     }
    //                     else 
    //                     {
    //                         throwError('Permit has not been approved yet!');
    //                     }
    //                 }
    //             }
    //         }
    //     } 
    //     catch (Exception e) 
    //     {
    //         loggerDataPool.buildLogDataPool('retrievePermitNo', e);
    //         throwError(e.getMessage() + ' -- ' + e.getLineNumber());
    //     }

    //     return result;
    // }

    // private static Boolean updatePermitNo(Id inwardDecId, Id vehicleShipmentId, String permitNo)
    // {
    //     try 
    //     {
    //         ADGLIB_SObjectUnitOfWork uow = new ADGLIB_SObjectUnitOfWork(new Schema.SObjectType[] {Inward_Declaration__c.SObjectType, Vehicle_Shipment__c.SObjectType});

    //         uow.registerDirty(new Inward_Declaration__c(Id = inwardDecId, TN_Permit_No__c = permitNo));
            
    //         if (String.isNotBlank(vehicleShipmentId))
    //         {
    //             uow.registerDirty(new Vehicle_Shipment__c(Id = vehicleShipmentId, TN_Permit_No__c = permitNo));
    //         } 
                 
    //         uow.commitWork();
    //     } 
    //     catch (Exception e) 
    //     {
    //         throwError(e.getMessage() + ' -- ' + e.getLineNumber());
    //     }

    //     return true;
    // }

    // public class VehicleShipmentWrapper
    // {
    //     @AuraEnabled
    //     public Map<String, List<Shipment_Line_Item__c>> lineItems {get; set;}

    //     @AuraEnabled
    //     public Map<String, List<Vehicle_Master2__c>> vehicleMasters {get; set;}
    // }

    // public class StockVehicleMasterWrapper
    // {
    //     @AuraEnabled
    //     public Map<String, Map<String, List<Vehicle_Master2__c>>> grouppedVehicles {get; set;}
    // }

    private static void throwError(String errorMsg)
    {
        AuraHandledException e = new AuraHandledException(errorMsg);
        e.setMessage(errorMsg);

        throw e;
    }
}
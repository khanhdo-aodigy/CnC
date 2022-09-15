/*==========================================================================================================================================================================
 * InwardDeclarationSelectorTest for InwardDeclarationSelector
 * Created By: Aodigy Team
 * Create Date: September 2022
 * History
 *              DATE::                              BY::                                TICKET::                                            CHANGELOG
 *            8 Sep 2022                        dong.nguyen@aodigy.com                 US-VPO-000027                                              init
 * ========================================================================================================================================================================== 
 */

 @isTest
public with sharing class InwardDeclarationSelectorTest {
    @TestSetup
    static void makeData(){
         // create supplier account
         Account supplier = Test_DataFactory.createAccount(true, 'Supplier Account');

         //create Vehicle shipment
         Vehicle_Shipment__c vehicleShipment = Test_DataFactory.createVehicleShipment(true, supplier.Id);

         //create Inward Declaration
         Inward_Declaration__c inwardDeclaration = new Inward_Declaration__c(
         RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Inward_Non_Payment' LIMIT 1].Id,
         Name = 'Inward Non-Payment-Vehicles',
         Vehicle_Shipment__c = vehicleShipment.Id
        
         );
         insert inwardDeclaration;
         
        
    }
    @istest
    public static void selectByRecordTypeAndVehicleShipmentId_success(){

        // String RecordTypeID = Schema.SObjectType.Inward_Declaration__c.getRecordTypeInfosByName().get('Inward_Non_Payment').getRecordTypeId();
        Inward_Declaration__c de = [SELECT Id ,RecordTypeId, Vehicle_Shipment__c FROM Inward_Declaration__c];
        InwardDeclarationSelector selector = new InwardDeclarationSelector();
        Inward_Declaration__c inward_1 =  selector.selectByRecordTypeAndVehicleShipmentId('Inward_Non_Payment', de.Vehicle_Shipment__c);
        System.assertNotEquals(null, inward_1.Id);
    }

    @isTest
    public static void selectByIdsWithInvoices_success() {

        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c];
        Inward_Declaration__c inward = [SELECT Id FROM Inward_Declaration__c];
        InwardDeclarationSelector selector = new InwardDeclarationSelector();
        List<Inward_Declaration__c> inward_1 =  selector.selectByIdsWithInvoices(new set<Id> {inward.Id}, true);
        System.assertNotEquals(null, inward_1.get(0).Id);
    }

    @istest
    public static void selectTodayExistingInwardDeclarations_success(){

        Vehicle_Shipment__c shipment = [SELECT Id FROM Vehicle_Shipment__c];
        Inward_Declaration__c inward = [SELECT Id FROM Inward_Declaration__c];
        InwardDeclarationSelector selector = new InwardDeclarationSelector();
        List<Inward_Declaration__c> inward_1 =  selector.selectTodayExistingInwardDeclarations();
        System.assertNotEquals(null, inward_1.get(0).Id);
    }
}
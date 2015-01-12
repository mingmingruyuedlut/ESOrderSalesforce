/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (seeAllData=true)
private class LOAControllerTest {

    static testMethod void myUnitTest() {
        // Setup
        User owner = [Select Id, Name From User limit 1];
        Account account = [Select Id, Name From Account limit 1];
        
        Product2 myProduct = new Product2(
        	Name = 'product',
        	SKU__c = 'E21191AE067422712339',
        	Model__c = 'model',
        	Manufacturer__c = 'manufacturer',
        	Description = 'description',
        	IsActive = true,
        	Ticket_Price__c = 10,
        	Supplier__c = 'supplier',
        	Short_Description__c = 'short description',
        	Season_Code__c = 'Q',
        	SOH__c = 20,
        	Promotion_Price__c = 10,
        	Product_Group__c = 'group1',
        	Online__c = false,
        	Online_Title__c = 'online tilte',
        	Long_Description__c = 'Long_Description',
        	Floor_Price__c = 10,
        	Department__c = 'Department',
        	Cost_Inc_GST__c = 10.1,
        	Cost_Ex_GST__c  = 10 	
        );
        insert myProduct;
        
        Order__c myOrder = new Order__c();
		myOrder.Total_Price_Inc__c = 195;
		myOrder.Name = 'my order';
		myOrder.OwnerId = owner.Id;
		myOrder.Billing_Account__c = account.Id;
		myOrder.Sending_Account__c = account.Id;
		myOrder.Order_Notes__c = 'notes';
		myOrder.Status__c = 'Open';
		myOrder.ByPass_VR__c = true;
		myOrder.Create_Date__c = Date.today();		
		insert myOrder;
		
		// store
		Store__c myStore = new Store__c(
			Suburb__c = 'suburb',
			Store_Company__c = 'fabric',
			StoreCode__c = 'storecode',
			State__c = 'VIC',
			Postcode__c = '1234',
			Name = 'STORE1',
			Address2__c = 'address2',
			Address1__c = 'address1',
			Phone__c = '11 2222 3333'
		);
		insert myStore;
		
		//Select o.SKU__c, o.Quantity__c, o.Model__c, o.Freight_Method__c, o.Product__r.Name, o.Product__r.Short_Description__c
		OrderLineItem__c myOrderLineItem = new OrderLineItem__c();
        myOrderLineItem.Name = 'LOA Test';
		myOrderLineItem.Product__c = myProduct.Id;
		myOrderLineItem.Order__c = myOrder.Id;
		myOrderLineItem.Sales_Price_Inc__c = 22.5;
		myOrderLineItem.Quantity__c = 10;
		myOrderLineItem.DispatchPoint__c = myStore.Id;
		insert myOrderLineItem;
		
		PageReference pageRef = Page.LOA;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('id', myOrder.Id);
        pageRef.getParameters().put('store', myStore.Id);
        
        LOAController controller = new LOAController();
        controller.Init();
        
        Order__c ord = [Select Order_Number__c From Order__c Where Id = :myOrder.Id];
        
        // Assert
        system.assert(controller.LOA.OrderNumber == ord.Order_Number__c);
        
    }
}
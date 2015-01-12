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
private class FinaliseOrderControllerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        Account account001 = new Account(
			Name = 'Test Account 001',
			AccountNumber = '00001',
			ABN__c = '11',
			Auto_Email_Invoice__c = true,
			Credit_Type__c = 'Cash'
		);
		insert account001;
        system.assert(account001.id != null);
        
        Account account002 = new Account(
			Name = 'Test Account 002',
			AccountNumber = '00002',
			ABN__c = '11',
			Auto_Email_Invoice__c = true,
			Credit_Type__c = 'Accout'
		);
		insert account002;
        system.assert(account002.id != null);
        
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
        system.assert(myProduct.id != null);
        
        Order__c order001 = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			OwnerId = u.Id,
			Billing_Account__c = account001.Id,
			Sending_Account__c = account001.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			Create_Date__c = Date.today()
        );		
		insert order001;
		system.assert(order001.id != null);
		
		Order__c order002 = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			OwnerId = u.Id,
			Billing_Account__c = account002.Id,
			Sending_Account__c = account002.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			Create_Date__c = Date.today()
        );		
		insert order002;
		system.assert(order002.id != null);
		
		Order__c order003 = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			OwnerId = u.Id,
			Billing_Account__c = account002.Id,
			Sending_Account__c = account002.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			Create_Date__c = Date.today()
        );		
		insert order003;
		system.assert(order003.id != null);
		
		Order__c order004 = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			OwnerId = u.Id,
			Billing_Account__c = account002.Id,
			Sending_Account__c = account002.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			Create_Date__c = Date.today()
        );		
		insert order004;
		system.assert(order004.id != null);
		
		order004.ByPass_VR__c = true;
		order004.Status__c = 'Finalised';
		update order004;
		system.assert(order004.id != null);
		
		Store__c myStore = new Store__c(
			Name = 'my store',
			StoreCode__c = 'StoreCode'
		);
		insert myStore;
		system.assert(myStore.id != null);
		
		OrderLineItem__c oli001 = new OrderLineItem__c(
			Product__c = myProduct.Id,
			Order__c = order001.Id,
			Sales_Price_Inc__c = 20.2,
			Quantity__c = 2,
			Status__c = 'Open',
			//Freight_Method__c = 'Pickup',
			DispatchPoint__c = myStore.Id
		);		
		insert oli001;
		system.assert(oli001.id != null);
		
		OrderLineItem__c oli002 = new OrderLineItem__c(
			Product__c = myProduct.Id,
			Order__c = order002.Id,
			Sales_Price_Inc__c = 20.2,
			Quantity__c = 2,
			Status__c = 'Open',
			Freight_Method__c = 'Pickup',
			DispatchPoint__c = myStore.Id
		);		
		insert oli002;
		system.assert(oli002.id != null);
		
		OrderLineItem__c oli003 = new OrderLineItem__c(
			Product__c = myProduct.Id,
			Order__c = order003.Id,
			Sales_Price_Inc__c = 20.2,
			Quantity__c = 2,
			Status__c = 'Open',
			//Freight_Method__c = 'Pickup',
			DispatchPoint__c = myStore.Id
		);		
		insert oli003;
		system.assert(oli003.id != null);
		
		// run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            Test.setCurrentPage(Page.FinaliseOrder);
	        FinaliseOrderController controller = new FinaliseOrderController();     
	        ApexPages.currentPage().getParameters().put('id',order001.id);
	        controller.Finalise();
	        
	        ApexPages.currentPage().getParameters().put('id',order002.id);
	        controller.Finalise();
	        
	        ApexPages.currentPage().getParameters().put('id',order003.id);
	        controller.Finalise();
	        
	        ApexPages.currentPage().getParameters().put('id',order004.id);
	        controller.Finalise();
	        
            // end test
            Test.stopTest();
        }
    }
}
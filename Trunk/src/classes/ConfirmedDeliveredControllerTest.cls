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
private class ConfirmedDeliveredControllerTest {

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
        
        Order__c myOrder = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			OwnerId = owner.Id,
			Billing_Account__c = account.Id,
			Sending_Account__c = account.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			ByPass_VR__c = true,
			Create_Date__c = Date.today()
        );		
		insert myOrder;
		
		OrderLineItem__c myOrderLineItem = new OrderLineItem__c(
			Product__c = myProduct.Id,
			Order__c = myOrder.Id,
			Sales_Price_Inc__c = 20.2,
			Quantity__c = 2,
			Status__c = 'Open'
		);		
		insert myOrderLineItem;
		
		// execute
		PageReference pageRef = Page.ConfirmedDelivered;
        pageRef.getParameters().put('id', myOrder.Id);
        Test.setCurrentPage(pageRef);
        ConfirmedDeliveredController controller = new ConfirmedDeliveredController();        
        controller.ConfirmedDelivered();        
			
		Order__c orderC = [Select o.Order_Number__c, o.Order_ID__c, o.Name, o.Id, o.Status__c From Order__c o Where Id = : myOrder.Id];
		
		// assert
		system.assert(controller.ShowOpenMessage == true);
		system.assert(controller.ShowClosedMessage == false);
						
		
		// setup
		Order__c myOrder2 = [Select Status__c, ByPass_VR__c From Order__c Where Id = :myOrder.Id];
		myOrder2.Status__c = 'Finalised';
		myOrder2.ByPass_VR__c = true;
		update myOrder2;
		
		controller.ConfirmedDelivered(); 	
		
		Order__c myOrder3 = [Select Status__c, ByPass_VR__c From Order__c Where Id = :myOrder.Id];		
		// assert
		system.assert(myOrder3.Status__c == 'Closed');
		
		// setup
		controller.ConfirmedDelivered(); 			
		// assert
		system.assert(controller.ShowOpenMessage == false);
		system.assert(controller.ShowClosedMessage == true);
    }
}
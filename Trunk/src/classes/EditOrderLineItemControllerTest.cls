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
private class EditOrderLineItemControllerTest {

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
		myOrder.Create_Date__c = Date.today();		
		insert myOrder;
        
        OrderLineItem__c myOrderLineItem = new OrderLineItem__c();
        myOrderLineItem.Name = 'Edit Test';
		myOrderLineItem.Product__c = myProduct.Id;
		myOrderLineItem.Order__c = myOrder.Id;
		myOrderLineItem.Sales_Price_Inc__c = 22.5;
		myOrderLineItem.Quantity__c = 10;
		myOrderLineItem.Status__c = 'Open';
		insert myOrderLineItem;
        

		ApexPages.StandardController stdController = new ApexPages.StandardController(myOrderLineItem);
        EditOrderLineItemController controller = new EditOrderLineItemController(stdController);
        
        PageReference pageRef = Page.EditOrderLineItem;
        //--------------------- url ---------------------//
        pageRef.getParameters().put('retURL', '/' + myOrder.Id);
        Test.setCurrentPage(pageRef);
    	        
        EditOrderLineItemController.OrderLineItemData itemData = controller.OrderLineItem;
        itemData.Id = myOrderLineItem.Id;
        
        itemData.LineItemName = 'Edit Test';
        itemData.SalesPriceInc = string.valueOf(myOrderLineItem.Sales_Price_Inc__c);
        itemData.Quantity = string.valueOf(myOrderLineItem.Quantity__c);
        itemData.DispatchPoint = myOrderLineItem.DispatchPoint__c;
        itemData.FreightMethod = myOrderLineItem.Freight_Method__c;

		PageReference p1 = controller.Save();
		PageReference p2 = controller.Cancel();        
        
        OrderLineItem__c newItem = [Select Name From OrderLineItem__c Where Id = :myOrderLineItem.Id limit 1];
        
                
        List<string> freightMethodList = Common.GetPicklistValues('OrderLineItem__c', 'Freight_Method__c');
        Store__c[] stores = [Select s.StoreCode__c, s.Name, s.Id From Store__c s Order By Name];
        
        // Assert
        system.assert(freightMethodList.size() + 1 == controller.FreightMethodList.size());
        system.assert(stores.size() + 1 == controller.DispatchPointList.size());
        system.assert(newItem.Name == 'Edit Test'); 
        
        system.assert(itemData.InValidLineItemName == false);
        system.assert(itemData.InValidSalesPrice == 0);
        system.assert(itemData.InValidQuantity == 0);
        system.assert(p1.getUrl() == '/' + myOrder.Id);
        system.assert(p2.getUrl() == '/' + myOrder.Id);
    }
}
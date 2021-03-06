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
private class AddOrderLineItemControllerTest {

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
        
        PageReference pageRef = Page.AddOrderLineItem;
        Test.setCurrentPage(pageRef);
        
        //--------------------- url ---------------------//
        pageRef.getParameters().put('addTo', myOrder.Id);
        pageRef.getParameters().put('ids', myProduct.Id);
        
        AddOrderLineItemController controller = new AddOrderLineItemController();
        for(AddOrderLineItemController.OrderLineItem item : controller.OrderLineItems){
        	item.SalesPrice = '19.5';
        	item.Quantity = '10';
        }
        // Save
        PageReference p1 = controller.Save();
        // Cancel
        PageReference p2 = controller.Cancel();
        // Save & More
        PageReference p3 = controller.SaveAndMore();
        
        OrderLineItem__c newItem = [Select o.Ticket_Price__c, o.Status__c, o.Sales_Price_Inc__c, o.SKU__c, o.Quantity__c, o.Product__c, o.Product_Group__c
    		, o.Order__c, o.Name, o.Model__c, o.Id, o.GP_percent__c, o.GP_dollar__c, o.Freight_Method__c, o.DispatchPoint__c, o.Cost_Inc__c, o.Cost_Ex__c 
    		From OrderLineItem__c o Where o.Order__c = :myOrder.Id And Product__c = :myProduct.Id Order By CreatedDate desc limit 1];
    	
    	List<string> freightMethodList = Common.GetPicklistValues('OrderLineItem__c', 'Freight_Method__c');
        Store__c[] stores = [Select s.StoreCode__c, s.Name, s.Id From Store__c s Order By Name];
        
    	// Assert
    	system.assert(freightMethodList.size() + 1 == controller.FreightMethodList.size());
        system.assert(stores.size() + 1 == controller.DispatchPointList.size());
    	system.assert(p1.getUrl() == '/' + myOrder.Id);	
		system.assert(newItem.Name == myProduct.Name);
		system.assert(newItem.Sales_Price_Inc__c == 19.5);
		system.assert(newItem.Quantity__c == 10);	
		system.assert(p2.getUrl() == '/' + myOrder.Id);
		system.assert(p3.getUrl() == '/apex/SelectSearchProduct?addTo=' + myOrder.Id);        
    }
}
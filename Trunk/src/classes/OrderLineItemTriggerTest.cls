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
private class OrderLineItemTriggerTest {

    static testMethod void myUnitTest() {
        // Setup
        Store__c store = [Select s.StoreCode__c, s.Name, s.Id From Store__c s limit 1];
        
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
        	Cost_Ex_GST__c  = 10,
        	Cost_Inc_GST__c = 10.1
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
        
        decimal salesPrice = myProduct.Cost_Inc_GST__c + 1;
        
        decimal totalPrice1 = 0;    		
    	for(OrderLineItem__c item : [Select Sales_Price_Inc__c, Quantity__c, Id From OrderLineItem__c Where Order__c = :myOrder.Id]){
    		totalPrice1 += item.Sales_Price_Inc__c * item.Quantity__c;
    	}
        
        OrderLineItem__c lineItem = new OrderLineItem__c();
		lineItem.Product__c = myProduct.Id;
		lineItem.Order__c = myOrder.Id;
		lineItem.Sales_Price_Inc__c = salesPrice;
		lineItem.Quantity__c = 2;
		lineItem.DispatchPoint__c = store.Id;
		lineItem.Freight_Method__c = 'Pickup';
		lineItem.Status__c = 'Open';
		
		insert lineItem;
		
		decimal gpDollor = ((lineItem.Sales_Price_Inc__c - myProduct.Cost_Inc_GST__c) * lineItem.Quantity__c).setScale(2, RoundingMode.HALF_UP);
		decimal gpPercent = ((lineItem.Sales_Price_Inc__c - myProduct.Cost_Inc_GST__c) / myProduct.Cost_Inc_GST__c).setScale(4, RoundingMode.HALF_UP) * 100;
			
		OrderLineItem__c newLineItem = [Select Sales_Price_Inc__c, Quantity__c, Name, GP_percent__c, GP_dollar__c, Cost_Ex__c, Cost_Inc__c From OrderLineItem__c
										Where Order__c = :myOrder.Id and Product__c = :myProduct.Id Order By CreatedDate desc limit 1];
		
		decimal totalPrice2 = 0;    		
    	for(OrderLineItem__c item : [Select Sales_Price_Inc__c, Quantity__c, Id From OrderLineItem__c Where Order__c = :myOrder.Id]){
    		totalPrice2 += item.Sales_Price_Inc__c * item.Quantity__c;
    	}
		
		system.assert(newLineItem.GP_dollar__c == gpDollor);
        system.assert(newLineItem.GP_percent__c == gpPercent);
        system.assert(totalPrice2 == totalPrice1 + (lineItem.Sales_Price_Inc__c * lineItem.Quantity__c));
    }
}
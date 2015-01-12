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
private class MultiLineItemControllerTest {

    static testMethod void myUnitTest() {
        // Setup
        User owner = [Select Id, Name From User limit 1];
        Account account = [Select Id, Name From Account limit 1];
         
        Pricebook2 myPricebook = new Pricebook2(
        	Name = 'pricebook',
        	IsActive = true
        );
        insert myPricebook;        
        
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
                
        PricebookEntry myPricebookEntry = new PricebookEntry(
        	Pricebook2Id = myPricebook.Id,
        	Product2Id = myProduct.Id,
        	UnitPrice = 15,
        	IsActive = true
        );
        insert myPricebookEntry;
        
        Opportunity myOpp = new Opportunity(
        	Pricebook2Id = myPricebook.Id, 
        	OwnerId = owner.Id, 
        	Name = 'my opp',
        	AccountId = account.Id,
			StageName = 'Prospecting',
			CloseDate = Date.today().addDays(10)
        );
        insert myOpp;
        
        OpportunityLineItem myOppLineItem = new OpportunityLineItem(
        	OpportunityId = myOpp.Id,
        	UnitPrice = 19.5,
        	Quantity = 10
        );
        
        Quote myQuote = new Quote(
        	Name = 'quote',
        	OpportunityId = myOpp.Id,
        	Pricebook2Id = myPricebook.Id
        	//,AccountManager__c = myAccountManager.Id
        );
        insert myQuote;  

		QuoteLineItem myQuoteLineItem = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 2,
        	PricebookEntryId = myPricebookEntry.Id
        );
        insert myQuoteLineItem;
        
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
        
        PageReference pageRef = Page.MultiLineItem;
        Test.setCurrentPage(pageRef);
                
        //--------------------- addOrderLine ---------------------//  
        pageRef.getParameters().put('action', 'addOrderLine');
        pageRef.getParameters().put('id', myOrder.Id);
        pageRef.getParameters().put('ids', myProduct.Id);
        
        MultiLineItemController controller1 = new MultiLineItemController();
        
        controller1.PageInit();
        // Assert
        system.assert(controller1.IsOrder == true);
        system.assert(controller1.IsProduct == false);        
        
        controller1.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem1 = new MultiLineItemController.LineItem();
        newLineItem1.LineItemName = myProduct.Name;
        newLineItem1.ProductId = myProduct.Id;
        newLineItem1.SKU = myProduct.SKU__c;
        newLineItem1.Title = myProduct.Name;
        newLineItem1.SalesPriceInc = '19.5';
        newLineItem1.Quantity = '10';
        controller1.LineItems.add(newLineItem1);        
        
        // Save
        PageReference p1 = controller1.Save();
        // Cancel
        PageReference p2 = controller1.Cancel();
        
        OrderLineItem__c orderLineItem1 = [Select o.Ticket_Price__c, o.Status__c, o.Sales_Price_Inc__c
        	, o.SKU__c, o.Quantity__c, o.Product__c, o.Product_Group__c
    		, o.Order__c, o.Name, o.Model__c, o.Id, o.GP_percent__c, o.GP_dollar__c, o.Freight_Method__c, o.DispatchPoint__c
    		, o.Cost_Inc__c, o.Cost_Ex__c 
    		From OrderLineItem__c o 
    		Where o.Order__c = :myOrder.Id And Product__c = :myProduct.Id
    		Order by o.CreatedDate desc limit 1];
        
        
    	List<string> freightMethodList = Common.GetPicklistValues('OrderLineItem__c', 'Freight_Method__c');
        Store__c[] stores = [Select s.StoreCode__c, s.Name, s.Id From Store__c s Order By Name];
        
        // Assert
        system.assert(controller1.CurrentDate == Datetime.now().format('dd/MM/yyyy'));
        system.assert(controller1.OrderId == pageRef.getParameters().get('id'));
        system.assert(controller1.ShowFinalisedMessage == false);
    	system.assert(freightMethodList.size() + 1 == controller1.FreightMethodList.size());
        system.assert(stores.size() + 1 == controller1.DispatchPointList.size());
        system.assert(p1.getUrl() == '/' + myOrder.Id);	
        system.assert(p2.getUrl() == '/' + myOrder.Id);
        system.assert(orderLineItem1.Sales_Price_Inc__c == 19.5);
		system.assert(orderLineItem1.Quantity__c == 10);
        
        
        //--------------------- editOrderLine ---------------------//        
        pageRef.getParameters().put('action', 'editOrderLine');
        pageRef.getParameters().put('id', myOrder.Id);
        pageRef.getParameters().put('ids', myProduct.Id);
        
        MultiLineItemController controller2 = new MultiLineItemController();
        controller2.PageInit();
        // Assert
        system.assert(controller2.IsOrder == true);
        system.assert(controller2.IsProduct == false); 
        
        controller2.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem2 = new MultiLineItemController.LineItem();
        newLineItem2.Id = orderLineItem1.Id;
        newLineItem2.LineItemName = myProduct.Name;
        newLineItem2.ProductId = myProduct.Id;
        newLineItem2.SKU = myProduct.SKU__c;
        newLineItem2.Title = myProduct.Name;
        newLineItem2.SalesPriceInc = '19.5';
        newLineItem2.Quantity = '10';
        controller2.LineItems.add(newLineItem2);
        // Save
        controller2.Save();
        
        OrderLineItem__c orderLineItem2 = [Select o.Ticket_Price__c, o.Status__c, o.Sales_Price_Inc__c
        	, o.SKU__c, o.Quantity__c, o.Product__c, o.Product_Group__c
    		, o.Order__c, o.Name, o.Model__c, o.Id, o.GP_percent__c, o.GP_dollar__c, o.Freight_Method__c, o.DispatchPoint__c
    		, o.Cost_Inc__c, o.Cost_Ex__c 
    		From OrderLineItem__c o 
    		Where o.Order__c = :myOrder.Id And Product__c = :myProduct.Id
    		Order by o.CreatedDate desc limit 1];    	
        
    	// Assert    	
		system.assert(orderLineItem2.Sales_Price_Inc__c == 19.5);
		system.assert(orderLineItem2.Quantity__c == 10);			  
		
		
		//--------------------- addProduct ---------------------//
	  	pageRef.getParameters().put('action', 'addProduct');
        pageRef.getParameters().put('id', myOpp.Id);
        pageRef.getParameters().put('ids', myProduct.Id);
        
        MultiLineItemController controller3 = new MultiLineItemController();
        controller3.PageInit();
        // Assert
        system.assert(controller3.IsOrder == false);
        system.assert(controller3.IsProduct == true); 
        
        controller3.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem3 = new MultiLineItemController.LineItem();
        newLineItem3.LineItemName = myProduct.Name;
        newLineItem3.ProductId = myProduct.Id;
        newLineItem3.SKU = myProduct.SKU__c;
        newLineItem3.Title = myProduct.Name;
        newLineItem3.SalesPriceInc = '19.5';
        newLineItem3.Quantity = '10';
        newLineItem3.ServiceDate = '18/11/2013';
        newLineItem3.Description = 'Description 1';
        controller3.LineItems.add(newLineItem3);
        // Save
        controller3.Save();
        
        OpportunityLineItem oppLineItem = [Select o.UnitPrice, o.TotalPrice, o.Quantity, o.PricebookEntryId, o.ListPrice, o.Id 
        									From OpportunityLineItem o 
        									Where o.OpportunityId = :myOpp.Id And o.PricebookEntryId = :myPricebookEntry.Id];
        // Assert									
		system.assert(oppLineItem.Quantity == 10);
		system.assert(oppLineItem.UnitPrice == 19.5);
		
		//--------------------- editProduct ---------------------//
	  	pageRef.getParameters().put('action', 'editProduct');
        pageRef.getParameters().put('id', myOpp.Id);
        
        MultiLineItemController controller4 = new MultiLineItemController();
        controller4.PageInit();
        // Assert
        system.assert(controller4.IsOrder == false);
        system.assert(controller4.IsProduct == true); 
        
        controller4.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem4 = new MultiLineItemController.LineItem();
        newLineItem4.Id = oppLineItem.Id;
        newLineItem4.LineItemName = myProduct.Name;
        newLineItem4.ProductId = myProduct.Id;
        newLineItem4.SKU = myProduct.SKU__c;
        newLineItem4.Title = myProduct.Name;
        newLineItem4.SalesPriceInc = '20.5';
        newLineItem4.Quantity = '11';        
        newLineItem4.ServiceDate = '18/11/2013';
        newLineItem4.Description = 'Description 2';
        controller4.LineItems.add(newLineItem4);
        // Save
        controller4.Save();
        
        OpportunityLineItem oppLineItem2 = [Select o.UnitPrice, o.TotalPrice, o.Quantity, o.PricebookEntryId, o.ListPrice, o.Id 
        									From OpportunityLineItem o 
        									Where o.Id = :oppLineItem.Id];
        
        // Assert
        system.assert(oppLineItem2.Quantity == 11);
		system.assert(oppLineItem2.UnitPrice == 20.5);
		
		//--------------------- addQuoteLine ---------------------//
	  	pageRef.getParameters().put('action', 'addQuoteLine');
        pageRef.getParameters().put('id', myQuote.Id);
        pageRef.getParameters().put('ids', myProduct.Id);
        
        MultiLineItemController controller5 = new MultiLineItemController();
        controller5.PageInit();
        // Assert
        system.assert(controller5.IsOrder == false);
        system.assert(controller5.IsProduct == false); 
        
        controller5.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem5 = new MultiLineItemController.LineItem();
        newLineItem5.LineItemName = myProduct.Name;
        newLineItem5.ProductId = myProduct.Id;
        newLineItem4.SKU = myProduct.SKU__c;
        newLineItem5.Title = myProduct.Name;
        newLineItem5.SalesPriceInc = '19.5';
        newLineItem5.Quantity = '10';
        controller5.LineItems.add(newLineItem5);
 
        // Save
        controller5.Save();
        
        QuoteLineItem quoteLineItem = [Select UnitPrice, Quantity, PricebookEntryId, ListPrice, Id 
        									From QuoteLineItem 
        									Where QuoteId = :myQuote.Id And PricebookEntryId = :myPricebookEntry.Id
        									Order By LineItemNumber__c desc limit 1];
        	
    	// Assert								
		system.assert(quoteLineItem.Quantity == 10);
		system.assert(quoteLineItem.UnitPrice == 19.5);
		
		//--------------------- editQuoteLine ---------------------//
	  	pageRef.getParameters().put('action', 'editQuoteLine');
        pageRef.getParameters().put('id', myQuote.Id);
        
        MultiLineItemController controller6 = new MultiLineItemController();
        controller6.PageInit();
        // Assert
        system.assert(controller6.IsOrder == false);
        system.assert(controller6.IsProduct == false); 
        
        controller6.LineItems = new List<MultiLineItemController.LineItem>();
        MultiLineItemController.LineItem newLineItem6 = new MultiLineItemController.LineItem();
        newLineItem6.Id = quoteLineItem.Id;
        newLineItem6.LineItemName = myProduct.Name;
        newLineItem6.ProductId = myProduct.Id;
        newLineItem6.SKU = myProduct.SKU__c;
        newLineItem6.Title = myProduct.Name;
        newLineItem6.SalesPriceInc = '20.5';
        newLineItem6.Quantity = '11';
        controller6.LineItems.add(newLineItem6);
        
        controller6.Save();
        
        QuoteLineItem quoteLineItem2 = [Select UnitPrice, Quantity, PricebookEntryId, ListPrice, Id 
        									From QuoteLineItem 
        									Where Id = :quoteLineItem.Id];
        // Assert
        system.assert(quoteLineItem2.Quantity == 11);
		system.assert(quoteLineItem2.UnitPrice == 20.5);
		
		
    }
}
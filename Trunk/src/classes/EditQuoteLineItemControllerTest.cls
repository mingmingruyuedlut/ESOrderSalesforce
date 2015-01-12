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
private class EditQuoteLineItemControllerTest {

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
        );
        insert myQuote;  

		QuoteLineItem myQuoteLineItem = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 2,
        	PricebookEntryId = myPricebookEntry.Id
        );
        insert myQuoteLineItem;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(myQuoteLineItem);
        EditQuoteLineItemController controller = new EditQuoteLineItemController(stdController);
        
        PageReference pageRef = Page.EditQuoteLineItem;
        Test.setCurrentPage(pageRef);
                  
        pageRef.getParameters().put('id', myQuoteLineItem.Id);
        
        EditQuoteLineItemController.QuoteLineItemData itemData = controller.QuoteLine;
        itemData.Id = myQuoteLineItem.Id;
        itemData.SalesPriceInc = '100';
        itemData.Quantity = '10';
        
        PageReference p1 = controller.Save();
		PageReference p2 = controller.Cancel(); 
		
		QuoteLineItem newQuoteLineItem = [Select UnitPrice, Quantity From QuoteLineItem Where Id = :myQuoteLineItem.Id];
		
		// Assert
		system.assert(newQuoteLineItem.UnitPrice == 100);
		system.assert(newQuoteLineItem.Quantity == 10);
		system.assert(p2.getUrl() == '/' + myQuote.Id);
    }
}
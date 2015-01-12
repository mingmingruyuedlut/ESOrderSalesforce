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
private class QuoteLineItemTriggerTest {

    static testMethod void myUnitTest() {
        // setup
        Pricebook2 standardPricebook = [Select Id, IsActive From Pricebook2 where IsStandard = true limit 1];
        if (!standardPricebook.isActive) {
            standardPricebook.isActive = true;
            update standardPricebook;
        }	
                
        Product2 myProduct = new Product2(
        	Name = 'product',
        	SKU__c = 'E21191AE067422712339',
        	Model__c = 'model',
        	Manufacturer__c = 'manufacturer',
        	Description = 'description',
        	Cost_Ex_GST__c = 10,
        	Cost_Inc_GST__c = 11,
        	Ticket_Price__c = 15,
        	IsActive = true
        );
        insert myProduct;
        
        PricebookEntry standardPricebookEntry = [Select Id From PricebookEntry where Pricebook2Id = :standardPricebook.Id and Product2Id = :myProduct.Id limit 1];
        
        Opportunity myOpp = new Opportunity(
        	Pricebook2Id = standardPricebook.Id, 
        	Name = 'my opp',
			StageName = 'Prospecting',
			CloseDate = Date.today().addDays(10)
        );
        insert myOpp;
        
        Quote myQuote = new Quote(
        	Name = 'quote',
        	OpportunityId = myOpp.Id,
        	Pricebook2Id = standardPricebook.Id
        );
        insert myQuote;
        
        QuoteLineItem myQuoteLineItem1 = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 1,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        insert myQuoteLineItem1;
		
		QuoteLineItem myQuoteLineItem2 = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 2,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        insert myQuoteLineItem2;
        
		QuoteLineItem myQuoteLineItem3 = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 3,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        insert myQuoteLineItem3;
		
		// insert assert
		QuoteLineItem[] insertItems = [Select LineItemNumber__c, QuoteId,
											Sales_Price_Ex__c, Sales_Price_Inc__c, Total_Price_Ex__c, Total_Price_Inc__c,
											Description, SKU__c, Manufacturer__c, Model__c
										From QuoteLineItem q Where QuoteId = :myQuote.Id Order By LineItemNumber__c DESC limit 3];
			
		system.assert(insertItems[0].LineItemNumber__c == insertItems[1].LineItemNumber__c + 1);
		system.assert(insertItems[0].LineItemNumber__c == insertItems[2].LineItemNumber__c + 2);
		
		system.assert(insertItems[0].Sales_Price_Ex__c == (myQuoteLineItem3.UnitPrice / 1.1).setScale(2, RoundingMode.HALF_UP));
		system.assert(insertItems[0].Sales_Price_Inc__c == myQuoteLineItem3.UnitPrice);
		system.assert(insertItems[0].Total_Price_Ex__c == (myQuoteLineItem3.UnitPrice * myQuoteLineItem3.Quantity / 1.1).setScale(2, RoundingMode.HALF_UP));
		system.assert(insertItems[0].Total_Price_Inc__c == myQuoteLineItem3.UnitPrice * myQuoteLineItem3.Quantity);
		
		system.assert(insertItems[0].Description == 'description');
		system.assert(insertItems[0].SKU__c == 'E21191AE067422712339');
		system.assert(insertItems[0].Manufacturer__c == 'manufacturer');
		system.assert(insertItems[0].Model__c == 'model');
		
		// delete sutup
		decimal quoteLineItem0Number = insertItems[2].LineItemNumber__c;
		delete insertItems[2];
		
		// delete assert
		QuoteLineItem[] deleteItems = [Select LineItemNumber__c, QuoteId From QuoteLineItem q Where QuoteId = :myQuote.Id Order By LineItemNumber__c DESC limit 2];
		system.assert(deleteItems[0].LineItemNumber__c == quoteLineItem0Number + 1);
		system.assert(deleteItems[1].LineItemNumber__c == quoteLineItem0Number);
    }
}
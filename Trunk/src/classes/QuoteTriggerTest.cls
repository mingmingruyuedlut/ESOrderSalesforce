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
private class QuoteTriggerTest {

	// test QuoteTrigger and QuoteLineItemTrigger
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
                
        //User myAccountManager = [Select u.Id, u.Username, u.Phone, u.LastName, u.FirstName, u.Email, u.Alias, u.AccountId From User u where IsActive = true limit 1];  
        User owner = [Select Id, Name From User limit 1];
        Account account = [Select Id, Name From Account limit 1];
        
        Opportunity myOpp = new Opportunity(
        	Pricebook2Id = standardPricebook.Id, 
        	OwnerId = owner.Id, 
        	Name = 'my opp',
        	AccountId = account.Id,
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

		QuoteLineItem myQuoteLineItem = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 2,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        insert myQuoteLineItem;
        
        // execute
        // QuoteTrigger runs on insert
        
        // assert
        Quote quote = [select ExpirationDate, Tax, Total_Price_Ex__c, Total_Price_Inc__c, q.AccountManager__c, q.AccountManagerPhone__c, q.AccountManagerEmail__c from Quote q where Id = :myQuote.Id limit 1];
        system.assert(quote.ExpirationDate == datetime.now().addDays(30).date());
        system.assert(quote.Tax == 3.63);
        system.assert(quote.Total_Price_Ex__c == 36.27);
        system.assert(quote.Total_Price_Inc__c == 39.9);
        system.assert(quote.AccountManager__c == UserInfo.getUserId());
        
        QuoteLineItem quoteLineItem = [select Sales_Price_Ex__c, Sales_Price_Inc__c, Total_Price_Ex__c, Total_Price_Inc__c,
        	Description, SKU__c, Manufacturer__c, Model__c from QuoteLineItem where Id = :myQuoteLineItem.Id limit 1];
        system.assert(quoteLineItem.Sales_Price_Ex__c == 18.14);
        system.assert(quoteLineItem.Sales_Price_Inc__c == 19.95);
        system.assert(quoteLineItem.Total_Price_Ex__c == 36.27);
        system.assert(quoteLineItem.Total_Price_Inc__c == 39.9);
        system.assert(quoteLineItem.Description == 'description');
        system.assert(quoteLineItem.SKU__c == 'E21191AE067422712339');
        system.assert(quoteLineItem.Manufacturer__c == 'manufacturer');
        system.assert(quoteLineItem.Model__c == 'model');
    }
}
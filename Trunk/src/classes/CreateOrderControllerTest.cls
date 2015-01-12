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
private class CreateOrderControllerTest {

    static testMethod void myUnitTest() {
    	// setup                
        User myAccountManager = [Select u.Id, u.Username, u.Phone, u.LastName, u.FirstName, u.Email, u.Alias, u.AccountId From User u where IsActive = true limit 1]; 
        User owner = [Select Id, Name From User limit 1];
        Account account = [Select Id, Name From Account limit 1];
        
        Pricebook2 standardPricebook = [Select Id, IsActive From Pricebook2 where IsStandard = true limit 1];
        if (!standardPricebook.isActive) {
            standardPricebook.isActive = true;
            update standardPricebook;
        }
        
        Product2 myProduct = new Product2(
        	Name = 'product',
        	SKU__c = 'E21191AE067422712339',
        	Model__c = 'model',
        	Product_Group__c = 'Group1',
        	Cost_Ex_GST__c = 20,
        	Cost_Inc_GST__c = 22,
        	Ticket_Price__c = 25,
        	Manufacturer__c = 'manufacturer',
        	Description = 'description',
        	IsActive = true
        );
        insert myProduct;
        
        PricebookEntry standardPricebookEntry = [Select Id From PricebookEntry where Pricebook2Id = :standardPricebook.Id and Product2Id = :myProduct.Id limit 1];
        
        Opportunity myOpp = new Opportunity(
        	Pricebook2Id = standardPricebook.Id, 
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
        	Quantity = 10,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        
        Quote myQuote = new Quote(
        	Name = 'quote',
        	OpportunityId = myOpp.Id,
        	Pricebook2Id = standardPricebook.Id,
        	AccountManager__c = myAccountManager.Id
        );
        insert myQuote;

		QuoteLineItem myQuoteLineItem = new QuoteLineItem(
        	QuoteId = myQuote.Id,
        	UnitPrice = 19.95,
        	Quantity = 2,
        	PricebookEntryId = standardPricebookEntry.Id
        );
        insert myQuoteLineItem;
        
        
        CreateOrderController controller = new CreateOrderController();
        
        PageReference pageRef = Page.CreateOrder;
        Test.setCurrentPage(pageRef);
        
        //--------------------- Opportunity ---------------------//
        pageRef.getParameters().put('from', 'opp');
        pageRef.getParameters().put('id', myOpp.Id); 
        PageReference p1 = controller.Create();
 
        Order__c order1 = [Select o.Sending_Account__c, o.OwnerId, o.Name, o.Id, o.Billing_Account__c From Order__c o 
        						Where o.Opportunity__c = :myOpp.Id And o.OwnerId = :myOpp.OwnerId  And o.Billing_Account__c = :myOpp.AccountId
        						Order By CreatedDate desc Limit 1];
        						
		// Assert
		system.assert(order1.Name == myOpp.Name);
		system.assert(p1.getUrl() == '/' + order1.Id + '/e?retURL=' + order1.Id);
		
	
        //--------------------- Quote ---------------------//
        pageRef.getParameters().put('from', 'quote');
        pageRef.getParameters().put('id', myQuote.Id);      
        PageReference p2 = controller.Create();

        Order__c order2 = [Select o.Sending_Account__c, o.OwnerId, o.Name, o.Id, o.Billing_Account__c From Order__c o 
        						Where o.Quote__c = :myQuote.Id And o.OwnerId = :myOpp.OwnerId  And o.Billing_Account__c = :myOpp.AccountId
        						Order By CreatedDate desc Limit 1];
        						
		// Assert
		system.assert(order2.Name == myQuote.Name);
		system.assert(p2.getUrl() == '/' + order2.Id + '/e?retURL=' + order2.Id);       
      
    }
}
public with sharing class CreateOrderController {
	
	static final string Status_Open = 'Open';

    public PageReference Create(){
        
        string source = ApexPages.currentPage().getParameters().get('from');         
        string defaultURL = ApexPages.currentPage().getParameters().get('defaultURL'); 
        string id = ApexPages.currentPage().getParameters().get('id');
      
        string retUrl = CreateOrder(source, id, defaultURL);
        
        PageReference page = new PageReference(retUrl);
        page.setRedirect(true);
        
        return page;
    }
    
    private string CreateOrder(string source, string id, string defaultURL){
    	string retUrl = defaultURL;
    	
    	string orderId = '';
        
        if(source == 'opp'){
        	Opportunity[] opportunities = [Select o.Pricebook2Id, o.OwnerId, o.Name, o.Id, o.AccountId From Opportunity o Where o.Id = :id limit 1];
        	
        	if(opportunities != null && opportunities.size() > 0){
        		orderId = CopyOpportunityToOrder(opportunities[0]);
        	} 
        }
        else if(source == 'quote'){
        	Quote[] quotes = [Select Opportunity.OwnerId, Opportunity.AccountId, OpportunityId, Notes__c, Name, Id, CreatedById, Total_Price_Inc__c From Quote Where Id = :id limit 1];
        	
        	if(quotes != null && quotes.size() > 0){
        		orderId = CopyQuoteToOrder(quotes[0]);
        	} 
        }
        
        if(orderId != ''){
        	retUrl = '/' + orderId + '/e?retURL=' + orderId;
        }
        
        return retUrl;
    }
    
    private string CopyOpportunityToOrder(Opportunity opportunity){
    	string orderId = '';
    	if(opportunity != null){
    		// Order
    		Order__c newOrder = new Order__c();
    		newOrder.Opportunity__c = opportunity.Id;
    		newOrder.Name = opportunity.Name;
    		newOrder.OwnerId = opportunity.OwnerId;
    		newOrder.Billing_Account__c = opportunity.AccountId;
    		newOrder.Sending_Account__c = opportunity.AccountId;
    		newOrder.Status__c = Status_Open;
    		newOrder.Create_Date__c = Date.today();
    		
    		insert newOrder;
    		
    		orderId = newOrder.Id;
    		    		    		
			//  OpportunityLineItem
			OpportunityLineItem[]  opportunityLineItems = [Select o.UnitPrice, o.TotalPrice, o.Quantity, o.PricebookEntry.ProductCode, o.PricebookEntry.Product2Id, o.PricebookEntryId, o.Id 
															From OpportunityLineItem o
															Where o.OpportunityId = :opportunity.Id];	
																							
    		for(OpportunityLineItem item : opportunityLineItems){
				PricebookEntry priceBookEntry = [Select p.Product2.Manufacturer__c, p.Product2.Model__c, p.Product2.SKU__c, p.Product2.Name, p.Product2.Product_Group__c 
												,p.Product2.Ticket_Price__c, p.Product2.Cost_Inc_GST__c, p.Product2.Cost_Ex_GST__c
												From PricebookEntry p 
												Where id = :item.PricebookEntryId limit 1];
												
				OrderLineItem__c orderLineItem = new OrderLineItem__c();
				
				orderLineItem.Order__c = newOrder.Id;				
				orderLineItem.Product__c = item.PricebookEntry.Product2Id;
				orderLineItem.Name = priceBookEntry.Product2.Name;
				orderLineItem.Quantity__c = item.Quantity;
				orderLineItem.Sales_Price_Inc__c = item.UnitPrice;
				orderLineItem.Status__c = Status_Open;
				
				insert orderLineItem;
				
			} 		
    	}
    	return orderId;
    } 
    
    private string CopyQuoteToOrder(Quote quote){
    	string orderId = '';
    	if(quote != null){
    		// Order
    		Order__c newOrder = new Order__c();
    		newOrder.Opportunity__c = quote.OpportunityId;
    		newOrder.Quote__c = quote.Id;
    		newOrder.Total_Price_Inc__c = quote.Total_Price_Inc__c;
    		newOrder.Name = quote.Name;
    		newOrder.OwnerId = quote.Opportunity.OwnerId;
    		newOrder.Billing_Account__c = quote.Opportunity.AccountId;
    		newOrder.Sending_Account__c = quote.Opportunity.AccountId;
    		newOrder.Order_Notes__c = quote.Notes__c;
    		newOrder.Status__c = Status_Open;
    		newOrder.Create_Date__c = Date.today();
    		
    		insert newOrder;
    		
    		orderId = newOrder.Id;
    		    		
    		// Order Line Items
    		QuoteLineItem[] quoteLineItems = [Select UnitPrice, Quantity, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name
												From QuoteLineItem
    											Where QuoteId = :quote.Id];   			
											
			for(QuoteLineItem item : quoteLineItems){
				OrderLineItem__c orderLineItem = new OrderLineItem__c();
				
				orderLineItem.Order__c = newOrder.Id;				
				orderLineItem.Product__c = item.PricebookEntry.Product2.Id;
				orderLineItem.Name = item.PricebookEntry.Product2.Name;
				orderLineItem.Quantity__c = item.Quantity;
				orderLineItem.Sales_Price_Inc__c = item.UnitPrice;				
				orderLineItem.Status__c = Status_Open;
				
				insert orderLineItem;
			}   		
	}
    	return orderId;
    }
}
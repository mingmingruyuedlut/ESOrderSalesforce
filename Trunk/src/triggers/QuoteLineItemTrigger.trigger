trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update, after delete, after insert) {
	if (Trigger.isBefore) {	
		if(trigger.isInsert || trigger.isUpdate){
			for(QuoteLineItem lineItem : Trigger.new){
				// update GST price
				lineItem.Sales_Price_Ex__c = (lineItem.UnitPrice / 1.1).setScale(2, RoundingMode.HALF_UP);
				lineItem.Sales_Price_Inc__c = lineItem.UnitPrice;
				lineItem.Total_Price_Ex__c = (lineItem.TotalPrice / 1.1).setScale(2, RoundingMode.HALF_UP);
				lineItem.Total_Price_Inc__c = lineItem.TotalPrice;
				
				// copy product data
				PricebookEntry pbEntry = [select Product2.Cost_Ex_GST__c, Product2.Cost_Inc_GST__c, Product2.Ticket_Price__c,
						Product2.Manufacturer__c, Product2.Model__c, Product2.SKU__c, Product2.Description
					from PricebookEntry where Id = :lineItem.PricebookEntryId limit 1];
				lineItem.Cost_Ex__c = pbEntry.Product2.Cost_Ex_GST__c;
				lineItem.Cost_Inc__c = pbEntry.Product2.Cost_Inc_GST__c;
				lineItem.Ticket_Price__c = pbEntry.Product2.Ticket_Price__c;
				if(lineItem.Description == null){
					lineItem.Description = pbEntry.Product2.Description;
				}
				lineItem.SKU__c = pbEntry.Product2.SKU__c;
				lineItem.Manufacturer__c = pbEntry.Product2.Manufacturer__c;
				lineItem.Model__c = pbEntry.Product2.Model__c;
				
				// Calculate GP
				if(lineItem.Cost_Inc__c != null) {
					lineItem.GP_dollar__c = ((lineItem.Sales_Price_Inc__c - lineItem.Cost_Inc__c) * lineItem.Quantity).setScale(2, RoundingMode.HALF_UP);
					if(lineItem.Cost_Inc__c != 0) {
	                	lineItem.GP_percent__c = ((lineItem.Sales_Price_Inc__c - lineItem.Cost_Inc__c) / lineItem.Cost_Inc__c).setScale(4, RoundingMode.HALF_UP) * 100;
					}
				}
			}
		}
	}
	else // isAfter
	{
		// update LineItemNumber
		if(trigger.isInsert){
			for(QuoteLineItem lineItem : Trigger.new) {
				integer maxLineNum = Integer.valueOf([select max(LineItemNumber__c) maxLineNum from QuoteLineItem where QuoteId = :lineItem.QuoteId][0].get('maxLineNum'));
				
				if(maxLineNum == null) maxLineNum = 1;
				else maxLineNum++;
				
				QuoteLineItem updLineItem = [select Id, LineItemNumber__c From QuoteLineItem where id = :lineItem.Id limit 1];
				updLineItem.LineItemNumber__c = maxLineNum;
				update updLineItem;
			}
		}
		if(trigger.isDelete){
			for(QuoteLineItem lineItem : Trigger.old){
				QuoteLineItem[] quoteLineItems = [Select LineItemNumber__c, QuoteId From QuoteLineItem q Where QuoteId = :lineItem.QuoteId And q.LineItemNumber__c > :lineItem.LineItemNumber__c];
				
				for(QuoteLineItem item : quoteLineItems){
					item.LineItemNumber__c = item.LineItemNumber__c - 1;
					update item;
				}				
			}
		}
	}
}
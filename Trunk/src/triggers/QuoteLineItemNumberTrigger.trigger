trigger QuoteLineItemNumberTrigger on QuoteLineItem (after delete, before insert) {
	if (Trigger.isBefore) {	
		if(trigger.isInsert){
			for(QuoteLineItem lineItem : Trigger.new){
				QuoteLineItem[] quoteLineItems = [Select LineItemNumber__c, QuoteId From QuoteLineItem q Where QuoteId = :lineItem.QuoteId And q.LineItemNumber__c > 0 Order By LineItemNumber__c DESC limit 1];
				
				decimal maxLineItemNumber = 1;
				if (quoteLineItems != null && quoteLineItems.size() > 0){
					maxLineItemNumber = quoteLineItems[0].LineItemNumber__c + 1;
				}
				
				lineItem.LineItemNumber__c = maxLineItemNumber;
			}
		}
	}
	else
	{	
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
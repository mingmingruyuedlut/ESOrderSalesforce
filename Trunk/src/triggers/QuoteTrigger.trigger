trigger QuoteTrigger on Quote (before insert, before update) {
	
	if(Trigger.isInsert){
		
		// Set ExpirationDate to 30 days after today.
		for(Quote quote : Trigger.new){
			if(quote.ExpirationDate == null){
				quote.ExpirationDate = datetime.now().addDays(30).date();
			}
			
			if(quote.AccountManager__c == null){
				quote.AccountManager__c = UserInfo.getUserId();
			}
		}
	}
	
	if(trigger.isInsert || trigger.isUpdate){
		
		// update GST price
		for(Quote quote : Trigger.new){
			quote.Total_Cost_Inc__c = 0;
			quote.Total_Ticket_Price__c = 0;
			quote.Total_Price_Inc__c = 0;
			
			QuoteLineItem[] lineItems = [select Cost_Inc__c, Ticket_Price__c, Quantity, Total_Price_Inc__c from QuoteLineItem where QuoteId = :quote.Id];
			
			for (QuoteLineItem lineItem : lineItems){
				quote.Total_Cost_Inc__c += lineItem.Cost_Inc__c * lineItem.Quantity;
				quote.Total_Ticket_Price__c += lineItem.Ticket_Price__c * lineItem.Quantity;
				quote.Total_Price_Inc__c += lineItem.Total_Price_Inc__c;
			}
			quote.Total_Cost_Ex__c = (quote.Total_Cost_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
			quote.Total_Price_Ex__c = (quote.Total_Price_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
			quote.Tax = quote.Total_Price_Inc__c - quote.Total_Price_Ex__c;
			if(quote.Total_Cost_Inc__c != null) {
				quote.Total_GP_dollar__c = (quote.Total_Price_Inc__c - quote.Total_Cost_Inc__c).setScale(2, RoundingMode.HALF_UP);
				if(quote.Total_Cost_Inc__c != 0) {
                	quote.Total_GP_percent__c = ((quote.Total_Price_Inc__c - quote.Total_Cost_Inc__c) / quote.Total_Cost_Inc__c).setScale(4, RoundingMode.HALF_UP) * 100;
				}
			}
			
			if(quote.AccountManager__c != null){
				User accountManager = [Select Phone, Email From User Where Id = :quote.AccountManager__c];
				if(accountManager != null && accountManager.Phone != null) quote.AccountManagerPhone__c = accountManager.Phone;
				if(accountManager != null && accountManager.Email != null) quote.AccountManagerEmail__c = accountManager.Email;
			}
		}
	}
}
trigger ProductTrigger on Product2 (after insert, after update) {
	
	if(Trigger.isInsert){
		if(Common.StandardPricebookId == null){
			Pricebook2 standardPricebook = [Select Id, Name From Pricebook2 Where IsStandard=true];
			Common.StandardPricebookId = standardPricebook.Id;
		}
		// Insert and Update PricebookEntry base on current product
		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		for(Product2 product : Trigger.new){
			//insert the pricebookentry
			PricebookEntry pricebookEntry = new PricebookEntry();
			pricebookEntry.Product2Id = product.Id;
			pricebookEntry.Pricebook2Id = Common.StandardPricebookId;
			pricebookEntry.UnitPrice = product.Ticket_Price__c;
			pricebookEntry.UseStandardPrice = false;
			pricebookEntry.IsActive = true;
			pricebookEntries.add(pricebookEntry);
		}
		insert pricebookEntries;
	}
}
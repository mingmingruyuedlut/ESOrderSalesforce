public with sharing class EditQuoteLineItemController {
	
	public QuoteLineItemData QuoteLine {get; set;}	
	
	private final QuoteLineItem quoteLineItem;
	public EditQuoteLineItemController(ApexPages.StandardController stdController) {
		this.quoteLineItem = (QuoteLineItem)stdController.getRecord();
		
		QuoteLineItem quoteLineItem = [Select q.Id, q.UnitPrice, q.Total_Price_Inc__c, q.Total_Price_Ex__c, q.TotalPrice, q.Ticket_Price__c, q.Subtotal, q.ServiceDate
					, q.Sales_Price_Inc__c, q.Sales_Price_Ex__c, q.SKU__c, q.QuoteId, q.Quantity, q.PricebookEntryId, q.Model__c, q.Manufacturer__c, q.ListPrice
					, q.LineNumber, q.LineItemNumber__c, q.GP_percent__c, q.GP_dollar__c, q.Discount, q.Description, q.Cost_Inc__c, q.Cost_Ex__c 
					, q.Quote.Name
					, PricebookEntry.Product2.Name, PricebookEntry.Product2.Id
					From QuoteLineItem q
					Where q.Id = :this.quoteLineItem.Id
		];
		
		QuoteLine = ConvertQuoteLineItem(quoteLineItem);
	}
	
	public PageReference Save(){
		if(!CheckData(QuoteLine)){
			return ApexPages.currentPage();
		}else{
			UpdateQuoteLineItem(QuoteLine);
			
			PageReference page = new PageReference('/' + QuoteLine.QuoteId);
	        page.setRedirect(true);
	        
	        return page;
		}
	}
	
	private boolean CheckData(QuoteLineItemData item){
		boolean isValid = true;
		
		string salesPrice = item.SalesPriceInc.trim();
		string quantity = item.Quantity.trim();
		
		if(salesPrice == ''){
			item.InValidSalesPrice = 1;
		}
		else if(!Common.IsDecimal(salesPrice)){
			item.InValidSalesPrice = 2;
		}
		else{
			item.InValidSalesPrice = 0;
		}
		
		if(quantity == ''){
			item.InValidQuantity = 1;
		}
		else if(!Common.IsDecimal(quantity)){
			item.InValidQuantity = 2;
		}
		else{
			item.InValidQuantity = 0;
		}
		
		if(item.InValidSalesPrice > 0 || item.InValidQuantity > 0){
			isValid = false;
		}
		
		return isValid;
	}
	
	private void UpdateQuoteLineItem(QuoteLineItemData item){
		QuoteLineItem quoteLine = [Select Total_Price_Inc__c, Quantity From QuoteLineItem Where Id = :item.Id];
		quoteLine.UnitPrice = decimal.valueOf(item.SalesPriceInc);
		quoteLine.Quantity = decimal.valueOf(item.Quantity);
		quoteLine.Description = item.Description;
		
		update quoteLine;
	}
	
	public PageReference Cancel(){
		PageReference page = new PageReference('/' + QuoteLine.QuoteId);
        page.setRedirect(true);
        
        return page;
	}
	
	private QuoteLineItemData ConvertQuoteLineItem(QuoteLineItem item){
		QuoteLineItemData itemData = new QuoteLineItemData();
		
		itemData.QuoteId = item.QuoteId;
		itemData.QuoteName = item.Quote.Name;
		itemData.Id = item.Id;
		itemData.LineNumber = item.LineNumber;
		itemData.LineItemNumber = string.valueOf(item.LineItemNumber__c);
		itemData.ProductId = item.PricebookEntry.Product2.Id;
		itemData.ProductName = item.PricebookEntry.Product2.Name;
		itemData.SKU = item.SKU__c;
		itemData.Model = item.Model__c;
		itemData.Manufacturer = item.Manufacturer__c;
		itemData.Description = item.Description;
		itemData.CostEx = string.valueOf(item.Cost_Ex__c);
		itemData.CostInc = string.valueOf(item.Cost_Inc__c);
		itemData.TicketPrice = string.valueOf(item.Ticket_Price__c);
		itemData.Quantity = string.valueOf(item.Quantity);
		itemData.SalesPriceEx = string.valueOf(item.Sales_Price_Ex__c);
		itemData.SalesPriceInc = string.valueOf(item.Sales_Price_Inc__c);
		itemData.GPDollor = string.valueOf(item.GP_dollar__c);
		itemData.GPPercent = string.valueOf(item.GP_percent__c);
		itemData.TotalPriceEx = string.valueOf(item.Total_Price_Ex__c);	
		itemData.TotalPriceInc = string.valueOf(item.Total_Price_Inc__c);	
		
		return itemData;
	}
	
	
	public class QuoteLineItemData{
		public string QuoteId {get;set;}
		public string QuoteName {get;set;}
    	public string Id {get;set;}
    	public string LineNumber {get;set;}
    	public string LineItemNumber {get;set;}
    	public string ProductId {get;set;}
    	public string ProductName {get;set;}
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Manufacturer {get;set;}
		public string Description {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string TicketPrice {get;set;}
		
		public string Quantity {get;set;}
		public string SalesPriceEx {get;set;}
		public string SalesPriceInc {get;set;}		
		public string GPDollor {get;set;}
		public string GPPercent {get;set;}
		
		public string TotalPriceEx {get;set;}
		public string TotalPriceInc {get;set;}
		
		public integer InValidQuantity {get;set;} // 1: empty 2: invalid
		public integer InValidSalesPrice {get;set;}
	}
}
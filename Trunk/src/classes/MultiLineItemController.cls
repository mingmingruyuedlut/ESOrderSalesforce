public with sharing class MultiLineItemController {
	static final string Status_Open = 'Open';
	
	public string PageType {get; set;}
	public string PageDescription {get; set;}
	public string SubDescription {get; set;}
	public boolean IsOrder {get; set;}
	public boolean IsProduct {get; set;}
	
	public string CurrentDate {
		get{
			if(CurrentDate == null){
				CurrentDate = Datetime.now().format('dd/MM/yyyy');
			}
			return CurrentDate;
		}
		set;
	 }
	
	public List<LineItem> LineItems {
		get{
			if(LineItems == null){
				LineItems = new List<LineItem>();
			}
			return LineItems;
		}
	 	set;
	 }
	 
	 //--------------------------- Edit All Order Line Item ----------------------------//
	public string OrderId {
		get{
			if(OrderId == null) OrderId = GetStringParameter('id');
			return OrderId;
		}
		set;
	}
	public boolean ShowFinalisedMessage {
		get{
			if(ShowFinalisedMessage == null) ShowFinalisedMessage = false;
			return ShowFinalisedMessage;
		} 
		set;
	}
	
	//--------------------------- DropDownList ----------------------------//
	
	// FreightMethod
	public List<SelectOption> FreightMethodList {
		get{
			if(FreightMethodList == null){
				FreightMethodList = new List<SelectOption>();
				FreightMethodList.add(new SelectOption('', '--Select--'));
				List<string> vals = Common.GetPicklistValues('OrderLineItem__c', 'Freight_Method__c');
				for(string val : vals){
					FreightMethodList.add(new SelectOption(val, val));
				}
			}
			return FreightMethodList;
		}
		private set;
	}
	
	//  DispatchPoint
	public List<SelectOption> DispatchPointList {
		get{
			if(DispatchPointList == null){
				DispatchPointList = new List<SelectOption>();
				DispatchPointList.add(new SelectOption('', '--Select--'));
				Store__c[] stores = [Select s.StoreCode__c, s.Name, s.Id From Store__c s Order By Name];
				for(Store__c store : stores){
					DispatchPointList.add(new SelectOption(store.Id, store.Name));
				}
			}
			return DispatchPointList;
		}
		private set;
	}
	
	public MultiLineItemController(){
			
	}
	
	public PageReference PageInit(){
		string id = GetStringParameter('id');
		
		string action = GetStringParameter('action'); // addOrderLine, editOrderLine, addProduct, editProduct, addQuoteLine, editQuoteLine
		
		IsOrder = (action == 'addOrderLine' || action == 'editOrderLine') ? true : false;
		IsProduct = (action == 'addProduct' || action == 'editProduct') ? true : false;
		if(action == 'addOrderLine'){
			string productIds = GetStringParameter('ids');
			LineItems = GetLineItemsByProductIds(productIds);
			
			Order__c orderC = [Select Id, Name From Order__c Where Id = :id];
			PageType = 'Add order line items for';
			PageDescription = orderC.Name;
			SubDescription = 'Add order line items for this order.';
		}
		else if(action == 'editOrderLine'){
			Order__c orderC = [Select Id, Name, Status__c From Order__c Where Id = :id];
			
			if(orderC.Status__c != null && orderC.Status__c.toLowerCase() != 'open'){
				ShowFinalisedMessage = true;
			}else{			
				LineItems = GetOrderLineItemsByOrderId(id);			
				
				PageType = 'Edit order line items for';
				PageDescription = orderC.Name;
				SubDescription = 'Edit order line items for this order.';
			}
		}
		else if(action == 'addProduct'){
			string productIds = GetStringParameter('ids');
		
			if(productIds != ''){
				string[] ids = productIds.split(',');
				LineItems = GetProducts(ids);
			}
			
			Opportunity opp = [Select Name, Id From Opportunity Where Id = :id];
			PageType = 'Add Products to';
			PageDescription = opp.Name;
			SubDescription = 'Add products for this opportunity.';
		}
		else if(action == 'editProduct'){
			LineItems = GetOpportunityLineItems(id);
			
			Opportunity opp = [Select Name, Id From Opportunity Where Id = :id];
			PageType = 'Edit Products for';
			PageDescription = opp.Name;
			SubDescription = 'Edit products for this opportunity.';
		}
		else if(action == 'addQuoteLine'){
			string productIds = GetStringParameter('ids');
			LineItems = GetLineItemsByProductIds(productIds);
			
			Quote quote = [Select Id, Name From Quote Where Id = :id];
			PageType = 'Add quote line items to';
			PageDescription = quote.Name;
			SubDescription = 'Add quote line items for this quote.';
		}	
		else if(action == 'editQuoteLine'){
			LineItems = GetQuoteLineItems(id);
			
			Quote quote = [Select Id, Name From Quote Where Id = :id];
			PageType = 'Edit quote line items for';
			PageDescription = quote.Name;
			SubDescription = 'Edit quote line items for this quote.';
		}
		
		return null;
	}
	
	public PageReference Cancel(){
		string id = GetStringParameter('id');	
	        
        string url = '/' + id;
		PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
	}
	
	public PageReference Save(){
		string id = GetStringParameter('id');
		string action = GetStringParameter('action');	
        if(!CheckData(LineItems)){
			return ApexPages.currentPage();
		}else{
			string url = '/' + id;

			if(action == 'addOrderLine'){
				AddOrderLineItems(LineItems, id);
			}
			else if(action == 'editOrderLine'){
				UpdateOrderLineItems(LineItems);
			}
			else if(action == 'addProduct'){
				AddOpportunityLineItems(LineItems, id);
			}
			else if(action == 'editProduct'){
				UpdateOpportunityLineItems(LineItems);
			}
			else if(action == 'addQuoteLine'){
				AddQuoteLineItems(LineItems, id);
			}	
			else if(action == 'editQuoteLine'){
				UpdateQuoteLineItems(LineItems);
			}	

			PageReference page = new PageReference(url);
	        page.setRedirect(true);
	        
	        return page;
		}
	}	
	
	//---------------------------------- Get Order/Quote line item by ProductIds----------------------------------
	private List<LineItem> GetLineItemsByProductIds(string productIds){
		string[] arrIds = productIds.split(',');
		
		List<LineItem> items = new List<LineItem>();
		
		Product2[] products = [Select p.SOH__c, p.SKU__c, p.Name, p.Id, p.Cost_Inc_GST__c, p.Cost_Ex_GST__c, p.Ticket_Price__c From Product2 p Where p.Id in :arrIds];
		
		for(Product2 product : products){
			LineItem item = new LineItem();
			item.LineItemName = product.Name;
			item.ProductId = product.Id;
			item.SKU = product.SKU__c;
			item.Title = product.Name;
			item.CostEx = string.valueOf(product.Cost_Ex_GST__c);
			item.CostInc = string.valueOf(product.Cost_Inc_GST__c);
			item.TicketPrice = string.valueOf(product.Ticket_Price__c);
			item.SKU = product.SKU__c;
			item.SalesPriceInc = string.valueOf(product.Ticket_Price__c);
			
			items.add(item);
		}
		
		return items;
	}
	
	/*---------------------------------------Order------------------------------------------------*/
		
	private void AddOrderLineItems(List<LineItem> orderLineItems, string orderId){
		for(LineItem item : orderLineItems){
			OrderLineItem__c orderLineItem = new OrderLineItem__c();
			orderLineItem.Name = item.LineItemName;
			orderLineItem.Product__c = item.ProductId;
			orderLineItem.Order__c = orderId;
			orderLineItem.Sales_Price_Inc__c = decimal.valueOf(item.SalesPriceInc.trim());
			orderLineItem.Quantity__c = decimal.valueOf(item.Quantity.trim());
			if(item.DispatchPoint != '') orderLineItem.DispatchPoint__c = item.DispatchPoint;
			if(item.FreightMethod != '') orderLineItem.Freight_Method__c = item.FreightMethod;
			orderLineItem.Status__c = Status_Open;
			
			insert orderLineItem;
		}
	}
	
	// ----------------------------------Edit Order Line Item----------------------------------
	private List<LineItem> GetOrderLineItemsByOrderId(string orderId){
		List<LineItem> items = new List<LineItem>();
				
		OrderLineItem__c[] lineItems = [Select Id, Name, Product__c, Product__r.Name, SKU__c, Freight_Method__c, DispatchPoint__c
											, Cost_Ex__c, Cost_Inc__c, Ticket_Price__c, Sales_Price_Ex__c, Sales_Price_Inc__c
											, Quantity__c, Total_Price_Ex__c, Total_Price_Inc__c, GP_percent__c, GP_dollar__c
										From OrderLineItem__c
										Where Order__c = :orderId];
										
		for(OrderLineItem__c lineItem : lineItems){
			LineItem item = new LineItem();
			item.Id = lineItem.Id;
			item.LineItemName = lineItem.Name;
			item.ProductId = lineItem.Product__c;
			item.SKU = lineItem.SKU__c;
			item.Title = lineItem.Product__r.Name;
			item.CostEx = string.valueOf(lineItem.Cost_Ex__c);
			item.CostInc = string.valueOf(lineItem.Cost_Inc__c);
			item.TicketPrice = string.valueOf(lineItem.Ticket_Price__c);
			item.SalesPriceInc = string.valueOf(lineItem.Sales_Price_Inc__c);
			item.Quantity = string.valueOf(lineItem.Quantity__c);
			item.FreightMethod = string.valueOf(lineItem.Freight_Method__c);
			item.DispatchPoint = string.valueOf(lineItem.DispatchPoint__c);
			item.GPDollor = string.valueOf(lineItem.GP_dollar__c);
			item.GPPercent = string.valueOf(lineItem.GP_percent__c);
			
			items.add(item);
		}
		
		return items;
	}	
		
	private void UpdateOrderLineItems(List<LineItem> lineItems){
		for(LineItem item : lineItems){
			OrderLineItem__c orderLineItem = [Select Name, Product__c, Sales_Price_Inc__c, Quantity__c, DispatchPoint__c, Freight_Method__c, Status__c
											From OrderLineItem__c
											Where Id = :item.Id];
												
			orderLineItem.Name = item.LineItemName;
			orderLineItem.Product__c = item.ProductId;
			orderLineItem.Sales_Price_Inc__c = decimal.valueOf(item.SalesPriceInc.trim());
			orderLineItem.Quantity__c = decimal.valueOf(item.Quantity.trim());
			if(item.DispatchPoint != '') orderLineItem.DispatchPoint__c = item.DispatchPoint;
			if(item.FreightMethod != '') orderLineItem.Freight_Method__c = item.FreightMethod;
			orderLineItem.Status__c = Status_Open;
			
			update orderLineItem;
		}
	}
	
	/*---------------------------------------Product------------------------------------------------*/
	// get Products by ids
	private List<LineItem> GetProducts(string[] productIds){
		List<LineItem> items = new List<LineItem>();
		
		Product2[] products = [Select p.SOH__c, p.SKU__c, p.Name, p.Id, p.Cost_Inc_GST__c, p.Cost_Ex_GST__c, p.Ticket_Price__c From Product2 p Where p.Id in :productIds];
		
		for(Product2 product : products){
			LineItem item = new LineItem();
			item.LineItemName = product.Name;
			item.ProductId = product.Id;
			item.SKU = product.SKU__c;
			item.Title = product.Name;
			item.CostEx = string.valueOf(product.Cost_Ex_GST__c);
			item.CostInc = string.valueOf(product.Cost_Inc_GST__c);
			item.TicketPrice = string.valueOf(product.Ticket_Price__c);
			item.SalesPriceInc = string.valueOf(product.Ticket_Price__c);
			
			items.add(item);
		}
		
		return items;
	}
	// Add Products To Opportunity
	private void AddOpportunityLineItems(List<LineItem> lineItems, string oppId){
		Opportunity opp = [Select Id, Name, Pricebook2Id From Opportunity Where Id = :oppId];
		
		if(opp.Pricebook2Id == null){
			Pricebook2 pricebook = [Select Id, Name From Pricebook2 Where IsStandard = true limit 1]; // Standard
			opp.Pricebook2Id = pricebook.Id;
			
			update opp;
		}		
		
		for(LineItem item : lineItems){
			PricebookEntry[] pricebookEntries = [Select Id, Name From PricebookEntry Where Product2Id = :item.ProductId And Pricebook2Id = :opp.Pricebook2Id];

			if(pricebookEntries != null && pricebookEntries.size() == 1){
				PricebookEntry pricebookEntry = pricebookEntries[0];
				
				OpportunityLineItem newItem = new OpportunityLineItem();
				newItem.OpportunityId = oppId;
				newItem.PricebookEntryId = pricebookEntry.Id;
				newItem.UnitPrice = decimal.valueOf(item.SalesPriceInc);
				newItem.Quantity = decimal.valueOf(item.Quantity);
				newItem.Description = item.Description;
				if(item.ServiceDate != null && item.ServiceDate != ''){
					newItem.ServiceDate = Date.parse(item.ServiceDate);
				}				
							
				insert newItem;
			}
		}
	}	
	
	//---------------------------------- Edit OpportunityLineItems ----------------------------------
	private List<LineItem> GetOpportunityLineItems(string oppId){
		List<LineItem> items = new List<LineItem>();		
		
		OpportunityLineItem[] oppLineItems = [Select o.UnitPrice, o.Quantity, o.PricebookEntry.Product2Id, o.PricebookEntry.Name, o.PricebookEntryId, o.Id, o.ServiceDate, o.Description
												, PricebookEntry.Product2.Name, PricebookEntry.Product2.Id, PricebookEntry.Product2.Cost_Ex_GST__c
												, PricebookEntry.Product2.Cost_Inc_GST__c, PricebookEntry.Product2.Ticket_Price__c
												, PricebookEntry.Product2.SKU__c
												From OpportunityLineItem o
												Where OpportunityId = :oppId];
				
		for(OpportunityLineItem oppLineItem : oppLineItems){
			LineItem item = new LineItem();
			item.Id = oppLineItem.Id;
			item.SalesPriceInc = string.valueOf(oppLineItem.UnitPrice);
			item.Quantity = string.valueOf(oppLineItem.Quantity);
			if(oppLineItem.ServiceDate != null) item.ServiceDate = DateTime.newInstance(oppLineItem.ServiceDate.year(), oppLineItem.ServiceDate.month(), oppLineItem.ServiceDate.day()).format('dd/MM/yyyy');
			item.Description = string.valueOf(oppLineItem.Description);
			item.LineItemName = oppLineItem.PricebookEntry.Product2.Name;
			item.ProductId = oppLineItem.PricebookEntry.Product2.Id;
			item.SKU = oppLineItem.PricebookEntry.Product2.SKU__c;
			item.Title = oppLineItem.PricebookEntry.Product2.Name;
			item.CostEx = string.valueOf(oppLineItem.PricebookEntry.Product2.Cost_Ex_GST__c);
			item.CostInc = string.valueOf(oppLineItem.PricebookEntry.Product2.Cost_Inc_GST__c);
			item.TicketPrice = string.valueOf(oppLineItem.PricebookEntry.Product2.Ticket_Price__c);
			
			items.add(item);
		}
		
		return items;
	}
	
	private void UpdateOpportunityLineItems(List<LineItem> lineItems){				
		for(LineItem lineItem : lineItems){
			OpportunityLineItem oppLineItem = [Select o.UnitPrice, o.Quantity, o.ServiceDate, o.Description From OpportunityLineItem o Where Id = :lineItem.Id];
			oppLineItem.UnitPrice = decimal.valueOf(lineItem.SalesPriceInc);
			oppLineItem.Quantity = decimal.valueOf(lineItem.Quantity);
			if(lineItem.ServiceDate != null && lineItem.ServiceDate != '') {
				oppLineItem.ServiceDate = Date.parse(lineItem.ServiceDate);
			}else{
				oppLineItem.ServiceDate = null;
			}
			oppLineItem.Description = lineItem.Description;
			
			update oppLineItem;
		}
	}
	
	/*---------------------------------------Quote------------------------------------------------*/
	// Add Quote line items
	private void AddQuoteLineItems(List<LineItem> lineItems, string quoteId){				
		Quote quote = [Select Id, Name, Pricebook2Id, Opportunity.Pricebook2Id, OpportunityId From Quote Where Id = :quoteId];
		if(quote.Opportunity.Pricebook2Id == null){
			Pricebook2 standardPricebook = [Select Id, Name From Pricebook2 Where IsStandard = true limit 1]; // Standard Pricebook
			
			Opportunity opp = [Select Id, Name, Pricebook2Id From Opportunity Where Id = : quote.OpportunityId];
			opp.Pricebook2Id = standardPricebook.Id;
			
			update opp;
			
			quote.Opportunity.Pricebook2Id = standardPricebook.Id;
		}
		if(quote.Pricebook2Id == null){
			quote.Pricebook2Id = quote.Opportunity.Pricebook2Id;
			update quote;
		}		
		
		for(LineItem item : lineItems){
			PricebookEntry[] pricebookEntries = [Select Id, Name From PricebookEntry Where Product2Id = :item.ProductId And Pricebook2Id = :quote.Pricebook2Id];
			
			if(pricebookEntries != null && pricebookEntries.size() == 1){
				PricebookEntry pricebookEntry = pricebookEntries[0];
				
				QuoteLineItem newItem = new QuoteLineItem();
				newItem.QuoteId = quoteId;
				newItem.PricebookEntryId = pricebookEntry.Id;
				newItem.UnitPrice = decimal.valueOf(item.SalesPriceInc);
				newItem.Quantity = decimal.valueOf(item.Quantity);				
							
				insert newItem;
			}
		}
	}
	// Edit Quote line items
	private List<LineItem> GetQuoteLineItems(string quoteId){
		List<LineItem> lineItems = new List<LineItem>();
		
		QuoteLineItem[] quoteLineItems = [Select q.UnitPrice, q.SKU__c, q.QuoteId, q.Quantity, q.PricebookEntryId, q.Model__c, q.ListPrice, q.LineItemNumber__c, q.Id 
							, PricebookEntry.Product2.Name, PricebookEntry.Product2.Id, PricebookEntry.Product2.Cost_Ex_GST__c
							, PricebookEntry.Product2.Cost_Inc_GST__c, PricebookEntry.Product2.Ticket_Price__c
							, PricebookEntry.Product2.SKU__c
							From QuoteLineItem q
							Where QuoteId = :quoteId];
		
		for(QuoteLineItem quoteLineItem : quoteLineItems){
			LineItem item = new LineItem();
			item.Id = quoteLineItem.Id;
			item.SalesPriceInc = string.valueOf(quoteLineItem.UnitPrice);
			item.Quantity = string.valueOf(quoteLineItem.Quantity);
			item.LineItemName = quoteLineItem.PricebookEntry.Product2.Name;
			item.ProductId = quoteLineItem.PricebookEntry.Product2.Id;
			item.SKU = quoteLineItem.PricebookEntry.Product2.SKU__c;
			item.Title = quoteLineItem.PricebookEntry.Product2.Name;
			item.CostEx = string.valueOf(quoteLineItem.PricebookEntry.Product2.Cost_Ex_GST__c);
			item.CostInc = string.valueOf(quoteLineItem.PricebookEntry.Product2.Cost_Inc_GST__c);
			item.TicketPrice = string.valueOf(quoteLineItem.PricebookEntry.Product2.Ticket_Price__c);
			
			lineItems.add(item);
		}
		
		return lineItems;
	}
	
	private void UpdateQuoteLineItems(List<LineItem> lineItems){
		for(LineItem item : lineItems){
			QuoteLineItem[] quoteLineItems = [Select Id, UnitPrice, Quantity From QuoteLineItem Where Id = :item.Id];
			
			if(quoteLineItems != null && quoteLineItems.size() == 1){
				QuoteLineItem quoteLineItem = quoteLineItems[0];
				
				quoteLineItem.UnitPrice = decimal.valueOf(item.SalesPriceInc);
				quoteLineItem.Quantity = decimal.valueOf(item.Quantity);				
							
				update quoteLineItem;
			}
		}
	}
	
	private boolean CheckData(List<LineItem> lineItems){
		boolean isValid = true;
		
		for(LineItem item : lineItems){
			string salesPrice = item.SalesPriceInc.trim();
			string quantity = item.Quantity.trim();
			string lineItemName = item.LineItemName.trim();
			string serviceDate = item.ServiceDate != null ? item.ServiceDate.trim() : '';
			
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
			
			item.InValidLineItemName = lineItemName == '' ? true : false;
			
			if(serviceDate != '' && !IsDate(serviceDate)) {
				item.InValidServiceDate = true;
			}else{
				item.InValidServiceDate = false;
			}
			
			if(item.InValidSalesPrice > 0 || item.InValidQuantity > 0 || item.InValidLineItemName || item.InValidServiceDate){
				isValid = false;
			}
		}
		
		return isValid;
	}
	
	private boolean IsDate(string dateStr){
		boolean isDate = true;
		
		try{	
			Date.parse(dateStr);
		}
		catch(exception ex){
			isDate = false;
		}
		
		return isDate;
	}

	private string GetStringParameter(string name){
		return ApexPages.currentPage().getParameters().get(name) != null ? ApexPages.currentPage().getParameters().get(name) : '';
	}

	public class LineItem{
		public string Id {get;set;}
		public string LineItemName {get;set;}
		public string ProductId {get;set;}
		public string SKU {get;set;}
		public string Title {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string TicketPrice {get;set;}
		public string SalesPriceInc {get;set;}
		public string Quantity {get;set;}
		public string GPDollor {get;set;}
		public string GPPercent {get;set;}
		public string FreightMethod {get;set;}
		public string DispatchPoint {get;set;}		
		
		public string ServiceDate {get;set;} // for add/edit product of opportunity
		public string Description {get;set;} // for add/edit product of opportunity
		
		public integer InValidQuantity {get;set;} // 1: empty 2: invalid
		public integer InValidSalesPrice {get;set;}
		public boolean InValidLineItemName {get;set;}
		public boolean InValidServiceDate {get;set;}
	}
}
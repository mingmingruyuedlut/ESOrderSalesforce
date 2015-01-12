public with sharing class AddOrderLineItemController {
	
	static final string Status_Open = 'Open';
	
	public List<OrderLineItem> OrderLineItems {
		get{
			if(OrderLineItems == null){
				OrderLineItems = new List<OrderLineItem>();
			}
			return OrderLineItems;
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
	
	public AddOrderLineItemController(){
		string addTo = GetStringParameter('addTo');
		string productIds = GetStringParameter('ids');
		
		if(productIds != ''){
			string[] ids = productIds.split(',');
			OrderLineItems = GetOrderLineItems(ids);
		}
	}
	
	private List<OrderLineItem> GetOrderLineItems(string[] productIds){
		List<OrderLineItem> items = new List<OrderLineItem>();
		
		Product2[] products = [Select p.SOH__c, p.SKU__c, p.Name, p.Id, p.Cost_Inc_GST__c, p.Cost_Ex_GST__c, p.Ticket_Price__c From Product2 p Where p.Id in :productIds];
		
		for(Product2 product : products){
			OrderLineItem item = new OrderLineItem();
			item.LineItemName = product.Name;
			item.ProductId = product.Id;
			item.SKU = product.SKU__c;
			item.Title = product.Name;
			item.CostEx = string.valueOf(product.Cost_Ex_GST__c);
			item.CostInc = string.valueOf(product.Cost_Inc_GST__c);
			item.TicketPrice = string.valueOf(product.Ticket_Price__c);
			item.SKU = product.SKU__c;
			
			items.add(item);
		}
		
		return items;
	}
	
	public PageReference Cancel(){
		string orderId = GetStringParameter('addTo');	
	        
        string url = '/' + orderId;
		PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
	}
	
	public PageReference Save(){
		string orderId = GetStringParameter('addTo');
			        
        if(!CheckData(OrderLineItems)){
			return ApexPages.currentPage();
		}else{
			SaveOrderLineItems(OrderLineItems, orderId);
			
			string url = '/' + orderId;
			PageReference page = new PageReference(url);
	        page.setRedirect(true);
	        
	        return page;
		}
	}
	
	public PageReference SaveAndMore(){
		string orderId = GetStringParameter('addTo');		
		
		if(!CheckData(OrderLineItems)){
			return ApexPages.currentPage();
		}else{
			SaveOrderLineItems(OrderLineItems, orderId);
			
			string url = '/apex/SelectSearchProduct?addTo=' + orderId;
			PageReference page = new PageReference(url);
	        page.setRedirect(true);
	        
	        return page;
		}
	}
	
	private boolean CheckData(List<OrderLineItem> orderLineItems){
		boolean isValid = true;
		
		for(OrderLineItem item : orderLineItems){
			string salesPrice = item.SalesPrice.trim();
			string quantity = item.Quantity.trim();
			string lineItemName = item.LineItemName.trim();
			
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
				
			if(item.InValidSalesPrice > 0 || item.InValidQuantity > 0 || item.InValidLineItemName){
				isValid = false;
			}
		}
		
		return isValid;
	}
	
	private void SaveOrderLineItems(List<OrderLineItem> orderLineItems, string orderId){
		for(OrderLineItem item : orderLineItems){
			OrderLineItem__c orderLineItem = new OrderLineItem__c();
			orderLineItem.Name = item.LineItemName;
			orderLineItem.Product__c = item.ProductId;
			orderLineItem.Order__c = orderId;
			orderLineItem.Sales_Price_Inc__c = decimal.valueOf(item.SalesPrice.trim());
			orderLineItem.Quantity__c = decimal.valueOf(item.Quantity.trim());
			if(item.DispatchPoint != '') orderLineItem.DispatchPoint__c = item.DispatchPoint;
			if(item.FreightMethod != '') orderLineItem.Freight_Method__c = item.FreightMethod;
			orderLineItem.Status__c = Status_Open;
			
			insert orderLineItem;
		}
	}
	
	private string GetStringParameter(string name){
		return ApexPages.currentPage().getParameters().get(name) != null ? ApexPages.currentPage().getParameters().get(name) : '';
	}

	public class OrderLineItem{		
		public string LineItemName {get;set;}
		public string ProductId {get;set;}
		public string SKU {get;set;}
		public string Title {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string TicketPrice {get;set;}
		public string SalesPrice {get;set;}
		public string Quantity {get;set;}
		public string GPDollor {get;set;}
		public string GPPercent {get;set;}
		public string FreightMethod {get;set;}
		public string DispatchPoint {get;set;}
		
		public integer InValidQuantity {get;set;} // 1: empty 2: invalid
		public integer InValidSalesPrice {get;set;}
		public boolean InValidLineItemName {get;set;}
	}
}
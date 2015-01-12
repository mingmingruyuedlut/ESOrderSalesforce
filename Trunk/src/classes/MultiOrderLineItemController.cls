public with sharing class MultiOrderLineItemController {
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
	
	public MultiOrderLineItemController(){
		/*
		string addTo = GetStringParameter('addTo');
		
		if(addTo != ''){ // add multi order line item
			string productIds = GetStringParameter('ids');
			
			if(productIds != ''){
				string[] ids = productIds.split(',');
				OrderLineItems = GetOrderLineItems(ids);
			}
		}else{ // edit multi order line item
			string orderId = GetStringParameter('orderId');
			
			OrderLineItems = GetOrderLineItemsByOrderId(orderId);
		}
		*/
		
		string orderId = GetStringParameter('orderId');
			
		OrderLineItems = GetOrderLineItemsByOrderId(orderId);
	}	
	
	private List<OrderLineItem> GetOrderLineItemsByOrderId(string orderId){
		List<OrderLineItem> items = new List<OrderLineItem>();
				
		OrderLineItem__c[] lineItems = [Select o.Id, o.Ticket_Price__c, o.Sales_Price_Inc__c, o.SKU__c, o.Quantity__c, o.Name, o.GP_percent__c, o.GP_dollar__c
										, o.Freight_Method__c, o.DispatchPoint__c, o.Cost_Inc__c, o.Cost_Ex__c, o.Product__c, o.Product__r.Name
										From OrderLineItem__c o
										Where o.Order__c = :orderId];
										
		for(OrderLineItem__c lineItem : lineItems){
			OrderLineItem item = new OrderLineItem();
			item.Id = lineItem.Id;
			item.LineItemName = lineItem.Name;
			item.ProductId = lineItem.Product__c;
			item.SKU = lineItem.SKU__c;
			item.Title = lineItem.Product__r.Name;
			item.CostEx = string.valueOf(lineItem.Cost_Ex__c);
			item.CostInc = string.valueOf(lineItem.Cost_Inc__c);
			item.TicketPrice = string.valueOf(lineItem.Ticket_Price__c);
			item.SalesPrice = string.valueOf(lineItem.Sales_Price_Inc__c);
			item.Quantity = string.valueOf(lineItem.Quantity__c);
			item.FreightMethod = string.valueOf(lineItem.Freight_Method__c);
			item.DispatchPoint = string.valueOf(lineItem.DispatchPoint__c);
			item.GPDollor = string.valueOf(lineItem.GP_dollar__c);
			item.GPPercent = string.valueOf(lineItem.GP_percent__c);
			
			items.add(item);
		}
		
		return items;
	}
	
	public PageReference Cancel(){
		string orderId = GetStringParameter('orderId');	
	        
        string url = '/' + orderId;
		PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
	}
	
	public PageReference Save(){
		string orderId = GetStringParameter('orderId');
			        
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
			OrderLineItem__c orderLineItem = [Select o.Ticket_Price__c, o.Sales_Price_Inc__c, o.SKU__c, o.Quantity__c, o.Product__c, o.Name, o.Id, o.GP_percent__c, o.GP_dollar__c
												, o.Freight_Method__c, o.DispatchPoint__c, o.Cost_Inc__c, o.Cost_Ex__c 
												From OrderLineItem__c o
												Where o.Id = :item.Id];
												
			orderLineItem.Name = item.LineItemName;
			orderLineItem.Product__c = item.ProductId;
			//orderLineItem.Order__c = orderId;
			orderLineItem.Sales_Price_Inc__c = decimal.valueOf(item.SalesPrice.trim());
			orderLineItem.Quantity__c = decimal.valueOf(item.Quantity.trim());
			if(item.DispatchPoint != '') orderLineItem.DispatchPoint__c = item.DispatchPoint;
			if(item.FreightMethod != '') orderLineItem.Freight_Method__c = item.FreightMethod;
			orderLineItem.Status__c = Status_Open;
			
			update orderLineItem;
		}
	}
	
	private string GetStringParameter(string name){
		return ApexPages.currentPage().getParameters().get(name) != null ? ApexPages.currentPage().getParameters().get(name) : '';
	}

	public class OrderLineItem{
		public string Id {get;set;}
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
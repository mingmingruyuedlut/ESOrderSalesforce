public with sharing class EditOrderLineItemController {
	private final OrderLineItem__c lineItem;	
	public EditOrderLineItemController(ApexPages.StandardController stdController) {
        this.lineItem = (OrderLineItem__c)stdController.getRecord();
        
        OrderLineItem__c item = [Select Ticket_Price__c, Status__c, Cost_Ex__c, Cost_Inc__c
        							, SKU__c, Quantity__c, Order__c, Name, Product_Group__c
		        					, Model__c, GP_percent__c, GP_dollar__c, Freight_Method__c, DispatchPoint__c
		        					, Sales_Price_Ex__c, Sales_Price_Inc__c, Total_Price_Ex__c, Total_Price_Inc__c
		        					, Order__r.Name, Order__r.Id, Product__r.Name, Product__r.Id
		    					 From OrderLineItem__c Where Id = :lineItem.Id Limit 1];
    					 
	 	OrderLineItem = ConvertOrderLineItem(item);
    }
    
    //--------------------------- Property ----------------------------//
	
	public OrderLineItemData OrderLineItem {get; set;}
	
	public boolean ShowOrderLineItem {get; set;}
	public boolean ShowMessage {get; set;}
	public string OrderId {get; set;}
	
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
	
	// if the order has been finalised, the order line item can't be edit
	public PageReference PageLoad(){
		string id = ApexPages.currentPage().getParameters().get('id').replace('/', '');
		
		OrderLineItem__c lineItem = [Select o.Order__r.Order_ID__c, o.Order__r.Status__c, o.Order__c, o.Name, o.Id From OrderLineItem__c o where id = :id];
		
		OrderId = lineItem.Order__c;
		
		if(lineItem.Order__r.Status__c != null && lineItem.Order__r.Status__c.toLowerCase() != 'open'){			
			ShowOrderLineItem = false;
			ShowMessage = true;
		}else{
			ShowOrderLineItem = true;
			ShowMessage = false;			
		}	
		return null;	
	}
    
    public PageReference Save(){			        
        if(!CheckData(OrderLineItem)){
			return ApexPages.currentPage();
		}else{
			SaveOrderLineItem(OrderLineItem);
			
			string retURL = ApexPages.currentPage().getParameters().get('retURL');
			if(!retURL.startsWith('/')) retURL = '/' + retURL;
			
			PageReference page = new PageReference(retURL);
	        page.setRedirect(true);
	        
	        return page;
		}
	}
	
	private void SaveOrderLineItem(OrderLineItemData item){
		OrderLineItem__c orderLineItem = [Select Name, Sales_Price_Inc__c, Quantity__c, DispatchPoint__c, Freight_Method__c
				    					From OrderLineItem__c Where Id = :lineItem.Id Limit 1];   					 
		
		orderLineItem.Name = item.LineItemName;
		orderLineItem.Sales_Price_Inc__c = decimal.valueOf(item.SalesPriceInc.trim());
		orderLineItem.Quantity__c = decimal.valueOf(item.Quantity.trim());
		orderLineItem.DispatchPoint__c = item.DispatchPoint;
		orderLineItem.Freight_Method__c = item.FreightMethod;
		
		update orderLineItem;
	}
	
	private boolean CheckData(OrderLineItemData item){
		boolean isValid = true;
		
		string salesPrice = item.SalesPriceInc.trim();
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
	
		return isValid;
	}
	
	public PageReference Cancel(){
		string retURL = ApexPages.currentPage().getParameters().get('retURL');
		if(!retURL.startsWith('/')) retURL = '/' + retURL;
		
		PageReference page = new PageReference(retURL);
        page.setRedirect(true);
        
        return page;
	}
    
    private OrderLineItemData ConvertOrderLineItem(OrderLineItem__c item){
    	OrderLineItemData itemData = new OrderLineItemData();
    	
    	itemData.Id = item.Id;
    	itemData.LineItemName = item.Name;
    	itemData.SKU = item.SKU__c;
    	itemData.Model = item.Model__c;
    	itemData.CostEx = FormatCurrency(item.Cost_Ex__c);
    	itemData.CostInc = FormatCurrency(item.Cost_Inc__c);
    	itemData.TicketPrice = FormatCurrency(item.Ticket_Price__c);
    	itemData.SalesPriceEx = FormatCurrency(item.Sales_Price_Ex__c);
    	itemData.SalesPriceInc = string.valueOf(item.Sales_Price_Inc__c);
    	itemData.Quantity = string.valueOf(item.Quantity__c);
    	itemData.TotalPriceEx = FormatCurrency(item.Total_Price_Ex__c);
    	itemData.TotalPriceInc = FormatCurrency(item.Total_Price_Inc__c);
    	itemData.GPDollor = FormatCurrency(item.GP_dollar__c);
    	itemData.GPPercent = FormatPercent(item.GP_percent__c);
    	itemData.ProductGroup = item.Product_Group__c;
    	itemData.FreightMethod = item.Freight_Method__c;
    	itemData.DispatchPoint = item.DispatchPoint__c;
    	itemData.Status = item.Status__c;
    	
    	itemData.ProductId = item.Product__r.Id;
    	itemData.ProductName = item.Product__r.Name;
    	itemData.OrderId = item.Order__r.Id;
    	itemData.OrderName = item.Order__r.Name;
    	
    	return itemData;
    }
    
    private string FormatCurrency(decimal money){
    	string result = '';
    	
    	if(money != null){
    		result = '$' + string.valueOf(money);
    	}
    	
    	return result;
    }
    
     private string FormatPercent(decimal percent){
    	string result = '';
    	
    	if(percent != null){
    		result = string.valueOf(percent) + '%';
    	}
    	
    	return result;
    }
    
    public class OrderLineItemData{
    	public string Id {get;set;}
    	public string LineItemName {get;set;}
    	
		public string SKU {get;set;}
		public string Model {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string TicketPrice {get;set;}
		public string SalesPriceEx {get;set;}
		public string SalesPriceInc {get;set;}
		public string Quantity {get;set;}
		public string TotalPriceEx {get;set;}
		public string TotalPriceInc {get;set;}
		public string GPDollor {get;set;}
		public string GPPercent {get;set;}
		public string ProductGroup {get;set;}
		public string FreightMethod {get;set;}
		public string DispatchPoint {get;set;}
		public string Status {get;set;}
		
		public string ProductId {get;set;}
		public string ProductName {get;set;}
		public string OrderId {get;set;}
		public string OrderName {get;set;}
		
		public integer InValidQuantity {get;set;} // 1: empty 2: invalid
		public integer InValidSalesPrice {get;set;}
		public boolean InValidLineItemName {get;set;}
	}
}
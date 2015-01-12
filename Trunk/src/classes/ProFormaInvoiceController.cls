public with sharing class ProFormaInvoiceController {
	public string Id{
		get {
			if(Id == null) {
				Id = ApexPages.currentPage().getParameters().get('id');
			}
			return Id;
		}
		set;
	}
		
	public string ImgUrl {get;set;}
	
	public List<OrderLineItem__c> OrderLineItemList {get; set;}
	public integer OrderLineItemTatolQty {get; set;}
	public Order__c OrderInfo {get; set;}
	public double GSTValue {get; set;}
	public string InvoiceDate {
		get {
			if(InvoiceDate == null) {
				datetime dt = datetime.now();
				InvoiceDate = dt.format('dd/MM/yyyy');
			}
			return InvoiceDate;
		}
		set;
	}
		
	public PageReference Init() {
		ImgUrl = Common.GetDocumentUrl('logo_commercial_png');
		GetOrderInfo();
		GetOrderLineItemList();
		return null;
	}
	
	private void GetOrderInfo(){
		OrderInfo = new Order__c();
		OrderInfo = [Select Order_Number__c, Total_Price_Inc__c, Total_Price_Ex__c, Billing_Account__r.Name, Billing_Account__r.ABN__c, Billing_Account__r.BillingStreet, Billing_Account__r.BillingCity, Billing_Account__r.BillingPostalCode, Billing_Account__r.BillingState, First_Name__c, Last_Name__c, Phone__c, Address_1__c, Address_2__c, Address_3__c, Suburb__c, Postcode__c, State__c 
					 	From Order__c
					 	where id =: Id];
		if(OrderInfo != null && OrderInfo.Total_Price_Inc__c != null && OrderInfo.Total_Price_Ex__c != null){
			GSTValue = OrderInfo.Total_Price_Inc__c - OrderInfo.Total_Price_Ex__c;
		}
	}
	
	private void GetOrderLineItemList(){
		OrderLineItemTatolQty = 0;
		OrderLineItemList = new List<OrderLineItem__c>();
		OrderLineItem__c[] orderLineItems = [Select SKU__c, Product_Group__c, Model__c, Name, Quantity__c, Sales_Price_Ex__c, Total_Price_Ex__c 
											 	From OrderLineItem__c 
												Where Order__r.Id =: Id];
		if(orderLineItems!=null){
		  for(OrderLineItem__c item: orderLineItems){
			 OrderLineItem__c currentOrderLineItem = new OrderLineItem__c();
		     if(item != null){
		     	 if(item.Quantity__c != null){
		     	 	OrderLineItemTatolQty += item.Quantity__c.intValue(); //calculate order line item total quantity
		     	 }
		     	 currentOrderLineItem.SKU__c = item.SKU__c;
		    	 currentOrderLineItem.Product_Group__c = item.Product_Group__c;
		    	 currentOrderLineItem.Model__c = item.Model__c;
		    	 currentOrderLineItem.Name = item.Name;
		    	 currentOrderLineItem.Quantity__c = item.Quantity__c;
		    	 currentOrderLineItem.Sales_Price_Ex__c = item.Sales_Price_Ex__c;
		    	 currentOrderLineItem.Total_Price_Ex__c = item.Total_Price_Ex__c;
		     }
		     OrderLineItemList.add(currentOrderLineItem);
		  }
		}
	}
}
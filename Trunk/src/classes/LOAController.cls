public with sharing class LOAController {
	public string OrderId{
		get {
			if(OrderId == null) {
				OrderId = ApexPages.currentPage().getParameters().get('id');
			}
			return OrderId;
		}
		set;
	}
	public string StoreId{
		get {
			if(StoreId == null) {
				StoreId = ApexPages.currentPage().getParameters().get('store');
			}
			return StoreId;
		}
		set;
	}
		
	public string ImgUrl {get;set;}
	
	public LetterOfAuthorityData LOA {get;set;}
			
	public PageReference Init() {
		
		ImgUrl = Common.GetDocumentUrl('logo_commercial_png');
				
		LOA = GetLetterOfAuthority(OrderId, StoreId);	
		
		return null;
	}
	
	private LetterOfAuthorityData GetLetterOfAuthority(string orderId, string storeId){
		Order__c ord = [Select o.Suburb__c, o.State__c, o.Phone__c, o.Order_Number__c, o.Order_ID__c, o.Name, o.Mobile__c, o.Postcode__c
						, o.Last_Name__c, o.First_Name__c, o.Email__c, o.Country__c, o.Address_3__c, o.Address_2__c, o.Address_1__c 
						From Order__c o
						Where Id = :OrderId];
						
		Store__c stroe = [Select s.Suburb__c, s.Store_Company__c, s.StoreCode__c, s.State__c, s.Postcode__c, s.Name, s.Id, s.Address2__c, s.Address1__c, s.Phone__c
							From Store__c s
							Where s.Id = :storeId];

		User user = [Select u.Username, u.Phone, u.Name, u.LastName, u.FirstName, u.Email, u.Fax
						From User u Where Id = :UserInfo.getUserId()];
						
		OrderLineItem__c[] lineItems = [Select o.SKU__c, o.Quantity__c, o.Model__c, o.Freight_Method__c
										//, o.DispatchPoint__r.StoreCode__c, o.DispatchPoint__r.Name, o.DispatchPoint__c 
										, o.Product__r.Name, o.Product__r.Short_Description__c
										From OrderLineItem__c o
										Where o.Order__c = :OrderId And o.DispatchPoint__c  = :StoreId];
										
		LetterOfAuthorityData loa = new LetterOfAuthorityData();
		loa.OrderNumber = ord.Order_Number__c;
		loa.PdfCreateDate = string.valueOf(Datetime.now().format('dd-MMM-yyyy'));
		
		loa.FirstName = ord.First_Name__c;
		loa.LastName = ord.Last_Name__c;
		loa.Phone = ord.Phone__c;
		loa.Mobile = ord.Mobile__c;
		loa.Email = ord.Email__c;
		loa.Address1 = ord.Address_1__c;
		loa.Address2 = ord.Address_2__c;
		loa.Address3 = ord.Address_3__c;
		loa.Suburb = ord.Suburb__c;
		loa.State = ord.State__c;
		loa.Country = ord.Country__c;
		loa.Postcode = ord.Postcode__c;
		
		loa.StoreCode = stroe.StoreCode__c;
		loa.StoreCompany = stroe.Store_Company__c;
		loa.StoreName = stroe.Name;
		loa.StoreAddress1 = stroe.Address1__c;
		loa.StoreAddress2 = stroe.Address2__c;
		loa.StoreState = stroe.State__c;
		loa.StoreSuburb = stroe.Suburb__c;
		loa.StorePostCode = stroe.Postcode__c;
		loa.StorePhone = stroe.Phone__c;
		
		decimal totalQty = 0;
		loa.Products = new Product[]{};
		for(OrderLineItem__c item : lineItems){
			Product product = new Product();
			product.StockCode = item.SKU__c;
			product.Model = item.Model__c;
			product.Format = item.Product__r.Name;
			product.Description = '';
			product.Qty = string.valueOf(item.Quantity__c);
			totalQty += item.Quantity__c;
			
			loa.Products.add(product);
		}
		loa.TotalQty = string.valueOf(totalQty);
		
		loa.CreatorName = user.Name;
		loa.CreatorPhone = user.Phone;
		loa.CreatorFax = user.Fax;
		loa.CreatorEmail = user.Email;
		
		return loa;
	}
	
	public class LetterOfAuthorityData{
		public string OrderNumber {get;set;}
		public string PdfCreateDate {get;set;}
		
		// end customer information
		public string FirstName {get;set;}
		public string LastName {get;set;}
		public string Phone {get;set;}
		public string Mobile {get;set;}
		public string Email {get;set;}
		public string Address1 {get;set;}
		public string Address2 {get;set;}
		public string Address3 {get;set;}
		public string Suburb {get;set;}
		public string State {get;set;}
		public string Country {get;set;}
		public string Postcode {get;set;}
		
		// collect goods from
		public string StoreCode {get;set;}
		public string StoreCompany {get;set;}
		public string StoreName {get;set;}
		public string StoreAddress1 {get;set;}
		public string StoreAddress2 {get;set;}
		public string StoreState {get;set;}
		public string StoreSuburb {get;set;}
		public string StorePostCode {get;set;}
		public string StorePhone {get;set;}
		
		// product info
		public Product[] Products {get;set;}
		public string TotalQty {get;set;}
		
		// pdf creator
		public string CreatorName {get;set;}
		public string CreatorPhone {get;set;}
		public string CreatorFax {get;set;}
		public string CreatorEmail {get;set;}
	}
	
	public class Product{
		public string StockCode {get;set;} // sku
		public string Model {get;set;}
		public string Format {get;set;}  // product name
		public string Description {get;set;}
		public string Qty {get;set;}
	}
}
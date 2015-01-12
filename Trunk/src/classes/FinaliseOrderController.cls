public with sharing class FinaliseOrderController {
	public string OrderId {get; set;}
	public boolean ShowErrorMessage {get; set;}
	public string ErrorMessage {get;set;}
	
	// ==== Credit Limit ====
	public CreditLimitInfo creLimitInfo {get; set;}  
    private string feedName = 'CustomerCredit';
    private string filterInfoName = 'CustomerID';
    private ITVDataFeedService itvDFService = new ITVDataFeedService();
    private ITVDataFeedService.DataFeedSoap dfSoap = new ITVDataFeedService.DataFeedSoap();
    private ITVDataFeedService.FilterInfo fInfo = new ITVDataFeedService.FilterInfo();
    private ITVDataFeedService.ArrayOfFilterInfo filterInfoArray = new ITVDataFeedService.ArrayOfFilterInfo();
    private ITVDataFeedService.ArrayOfString sArray = new ITVDataFeedService.ArrayOfString();
	// ==== Credit Limit ====
	
	
	public FinaliseOrderController(){
		OrderId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference Finalise(){
		string orderId = ApexPages.currentPage().getParameters().get('id');
		
		Order__c orderC = [Select o.Billing_Account__r.Credit_Type__c, o.Billing_Account__r.AccountNumber, o.Billing_Account__r.Name, o.PaymentMethod__c, o.Total_Price_Inc__c, o.Status__c, o.Name, o.Id, o.Version_Number__c From Order__c o where id = :orderId];
		
		if(orderC.Status__c.toLowerCase() == 'open'){
			// need notify sf user and don't finalise the order 
			if(orderC.Billing_Account__r.Credit_Type__c == 'Cash' && string.isBlank(orderC.PaymentMethod__c)){
				ShowErrorMessage = true;
				ErrorMessage = 'Please select the order payment type first.';
				
				return null;
			}
			// need notify sf user and also need finalise the order 
			if(orderC.Billing_Account__r.Credit_Type__c == 'Account' && JudgeAvailableCredit(orderC)) // call ITV web service -- judge available credit
			{
				ShowErrorMessage = true;
				ErrorMessage = 'Order exceeds Available Credit Limit. Please increase Credit Limit or apply payment to Account. This order has been sent to ' + GetOrderLineItemDespathPoints(orderId) + ' but cannot be processed until ' + orderC.Billing_Account__r.Name + '’s Available Credit Limit exceeds ' + ConvertToMoneyFormat(orderC.Total_Price_Inc__c) + '. Please contact your customer to advise.';
				UpdateOrderInfo(orderC, orderId);
				return null;
			}
			
			if(!UpdateOrderInfo(orderC, orderId)){
				return null;
			}
			string url = '/' + orderId;
			PageReference page = new PageReference(url);
	        page.setRedirect(true);
	        
	        return page;
		}
		else {
			ShowErrorMessage = true;
			ErrorMessage = 'The order has already been finalised.';
			
			return null;
		}
	}
	
	private boolean UpdateOrderInfo(Order__c orderC, string orderId){
		OrderLineItem__c[] lineItems = [select Id, Status__c, Freight_Method__c, DispatchPoint__c from OrderLineItem__c where Order__c = :orderId];
				
		// validate required data
		for(OrderLineItem__c lineItem : lineItems){
			
			if(lineItem.Freight_Method__c == null || lineItem.Freight_Method__c == '' || lineItem.DispatchPoint__c == null){
				
				ShowErrorMessage = true;
				ErrorMessage = 'Freight Method and Dispatch Point must be selected for all the line items.';
				return false;						
			}
		}
		
		orderC.ByPass_VR__c = true;
		orderC.Status__c = 'Finalised';
		orderC.Version_Number__c = GetAutoIncrementVersionNumber();
		update orderC;
		
		for(OrderLineItem__c lineItem : lineItems){
			lineItem.ByPass_VR__c = true;
			lineItem.Status__c = 'Finalised';
		}
		update lineItems;
		return true;
	}
	
	private boolean JudgeAvailableCredit(Order__c orderC){
		boolean creLimit = false;
		creLimitInfo = getCreditLimitInfo(orderC.Billing_Account__r.AccountNumber);
		if(creLimitInfo != null && creLimitInfo.AvailableCredit != null){
			if(orderC.Total_Price_Inc__c > creLimitInfo.AvailableCredit){
				creLimit = true;
			}
		}
		return creLimit;
	} 
	
	private string GetOrderLineItemDespathPoints(string orderId){
		string dps = '';		
		OrderLineItem__c[] lineItems = [select Id, DispatchPoint__r.Name from OrderLineItem__c where Order__c = :orderId];
		for(OrderLineItem__c lineItem : lineItems){			
			if(lineItem.DispatchPoint__r.Name != null){				
				dps += lineItem.DispatchPoint__r.Name + ',';					
			}
		}
		if(dps.endsWith(',')){
			dps = dps.substring(0, dps.length() - 1);
		}
		return dps;
	}
	
	private string ConvertToMoneyFormat(decimal price){
		if (price == null || Math.abs(price) < 0.005) return '$0.00';
	    String s = (price.setScale(2) + (price >= 0 ? 0.001 : -0.001)).format();
    	return '$' + s.substring(0, s.length() - 1);
	}
	
	public CreditLimitInfo getCreditLimitInfo(string customerId) {
		fInfo.Name = filterInfoName;
		string[] sArr = new string[] { customerId };
		sArray.string_x = sArr;
		fInfo.Values = sArray;
		filterInfoArray.FilterInfo = new ITVDataFeedService.FilterInfo[] {fInfo};
		ITVDataFeedService.ArrayOfArrayOfNV nvArrayArray = dfSoap.Feed(feedName, filterInfoArray, DateTime.now());
		
		CreditLimitInfo currentCreditLimitInfo = new CreditLimitInfo();
		for(ITVDataFeedService.ArrayOfNV aNv : nvArrayArray.ArrayOfNV){
			for(ITVDataFeedService.NV nv : aNv.NV){
				if(nv.N == 'CustomerID'){
					currentCreditLimitInfo.CustomerId = nv.V;
				}
				else if(nv.N == 'CreditLimit'){
					currentCreditLimitInfo.CreditLimit = Decimal.valueOf(nv.V);
				}
				else if(nv.N == 'AvailableCredit'){
					currentCreditLimitInfo.AvailableCredit = Decimal.valueOf(nv.V);
				}
				else if(nv.N == 'Balance'){
					currentCreditLimitInfo.Balance = Decimal.valueOf(nv.V);
				}
			}
		}
		return currentCreditLimitInfo;
	}
	
	private decimal GetAutoIncrementVersionNumber(){
		decimal versionNumber = 0;
		Increment_Version__c versionObj = new Increment_Version__c(Name = 'CacheVersion');
		insert versionObj;
		versionObj = [Select Version_Number__c From Increment_Version__c Where Name = 'CacheVersion' Limit 1];
		versionNumber = decimal.valueOf(versionObj.Version_Number__c);
		delete versionObj;
		return versionNumber;
	}
	
	public class CreditLimitInfo {
        public string CustomerId {get;set;}
        public decimal CreditLimit {get;set;}
        public decimal AvailableCredit {get;set;}
        public decimal Balance {get;set;}
        
        public CreditLimitInfo(){
          CustomerId = '';
          CreditLimit = 0;
          AvailableCredit = 0;
          Balance = 0;
        }
        
        public CreditLimitInfo(string cusId, decimal creLimit, decimal avaCredit, decimal bal){
          CustomerId = cusId;
          CreditLimit = creLimit;
          AvailableCredit = avaCredit;
          Balance = bal;
        }
     }
}
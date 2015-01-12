public with sharing class DashboardReportDetailController {

	private integer currentYear = date.today().year();
 	private integer currentMonth = date.today().month();
 	
 	private integer fYear = currentMonth < 7 ? currentYear - 1 : currentYear;
 	
 	// for date filed SOQL [financial year]
 	private date fyStartDate = date.newInstance(fYear, 7, 1);
	private date fyEndDate = date.newInstance(fYear + 1, 7, 1);
 	
 	//for datetime field SOQL [financial year]
 	private DateTime fyStartDateTime = DateTime.newInstance(fYear, 7, 1, 0, 0, 0);
	private DateTime fyEndDateTime = DateTime.newInstance(fYear + 1, 7, 1, 0, 0, 0);
 		
 	//for date field SOQL [current month]
	private date startDate = date.newInstance(currentYear, currentMonth, 1);
	private date endDate = date.newInstance(currentYear, currentMonth + 1, 1);
		
	//for datetime field SOQL [current month]
	private DateTime startDateTime = DateTime.newInstance(currentYear, currentMonth, 1, 0, 0, 0);
	private DateTime endDateTime = DateTime.newInstance(currentYear, currentMonth + 1, 1, 0, 0, 0);
	
	public List<OrderInfo> OrderInfoList { get; set; }

	public PageReference Init(){
		InitAllVariables();
		LoadDetailData();
		return null;
	}
	
	private void InitAllVariables(){
		OrderInfoList = new List<OrderInfo>();
	}
	
	private void LoadDetailData(){
		if(ApexPages.currentPage().getParameters().get('oid') != null && ApexPages.currentPage().getParameters().get('oid') != ''){
			LoadOrdersByPerson(Id.valueOf(ApexPages.currentPage().getParameters().get('oid')));
		}
		else if(ApexPages.currentPage().getParameters().get('aid') != null && ApexPages.currentPage().getParameters().get('aid') != ''){
			LoadOrdersByAccount(Id.valueOf(ApexPages.currentPage().getParameters().get('aid')));
		}
		else{
			LoadOrdersByClickChart();
		}
	}
	
	private void LoadOrdersByClickChart(){
		string reportType = ApexPages.currentPage().getParameters().get('type');
		if(reportType == 'ds' || reportType == 'dsgp'){
			LoadOrdersByMonth();
		}
		else if(reportType == 'ss' || reportType == 'ssgp'){
			string state = ApexPages.currentPage().getParameters().get('state');
			LoadOrdersByState(state);
		}
		else if(reportType == 'sps' || reportType == 'spsgp'){
			string pId = ApexPages.currentPage().getParameters().get('person');
			LoadOrdersByPersonMTD(Id.valueOf(pId));
		}
	}
	
	private void LoadOrdersByMonth(){
		Integer month = Integer.valueOf(ApexPages.currentPage().getParameters().get('month'));
		Integer year = Integer.valueOf(ApexPages.currentPage().getParameters().get('year'));
		DateTime currentStartDateTime = DateTime.newInstance(year, month, 1, 0, 0, 0);
		DateTime currentEndDateTime = DateTime.newInstance(year, month + 1, 1, 0, 0, 0);
		
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Close_Date__c >=: currentStartDateTime and Close_Date__c <: currentEndDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private void LoadOrdersByState(string state){
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Billing_Account__r.BillingState =: state and Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private void LoadOrdersByPerson(id personId){
		string timeType = ApexPages.currentPage().getParameters().get('timetype');
		if(timeType == 'MTD'){
			LoadOrdersByPersonMTD(personId);
		}
		else{
			LoadOrdersByPersonYTD(personId);
		}
	}
	
	
	private void LoadOrdersByPersonMTD(id personId){
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Billing_Account__r.OwnerId =: personId and Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private void LoadOrdersByPersonYTD(id personId){
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Billing_Account__r.OwnerId =: personId and Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private void LoadOrdersByAccount(id accountId){
		string timeType = ApexPages.currentPage().getParameters().get('timetype');
		if(timeType == 'MTD'){
			LoadOrdersByAccountMTD(accountId);
		}
		else{
			LoadOrdersByAccountYTD(accountId);
		}
	}
	
	private void LoadOrdersByAccountMTD(id accountId){
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Billing_Account__r.Id =: accountId and Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private void LoadOrdersByAccountYTD(id accountId){
		Order__c[] orderList = [Select Name, Id, Order_Number__c, Billing_Account__r.Name, Billing_Account__r.Id, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c, Status__c 
								From Order__c 
								Where Status__c = 'Closed' and Billing_Account__r.Id =: accountId and Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime];
		if(orderList != null && orderList.size() > 0){
			for(Order__c item : orderList){
				OrderInfoList.add(ConvertOrderToOrderInfo(item));
			}
		}
	}
	
	private OrderInfo ConvertOrderToOrderInfo(Order__c item){
		string name = item.Name;
		string id = (string)item.Id;
		string oNumber = item.Order_Number__c;
		string baName = item.Billing_Account__r.Name;
		string baId = item.Billing_Account__r.Id;
		decimal costInc = item.Total_Cost_Inc__c;
		decimal ticketPrice = item.Total_Ticket_Price__c;
		decimal priceInc = item.Total_Price_Inc__c;
		decimal gp = item.Total_GP_dollar__c;
		decimal gpPercent = item.Total_GP_percent__c;
		string oStatus = item.Status__c;
		OrderInfo currentOrderInfo = new OrderInfo(name, id, oNumber, baName, baId, costInc, ticketPrice, priceInc, gp, gpPercent, oStatus);
		return currentOrderInfo;
	}
	
	public class OrderInfo implements Comparable{
	   public string OrderName {get;set;}
	   public string OrderId {get;set;}
	   public string OrderUrl {get;set;}
	   public string OrderNumber {get;set;}
	   public string BillingAccountName {get;set;}
	   public string BillingAccountId {get;set;}
	   public string BillingAccountUrl {get;set;}
	   public decimal TotalCostInc {get;set;}
	   public decimal TotalTicketPrice {get;set;}
	   public decimal TotalPriceInc {get;set;}
	   public decimal TotalGP {get;set;}
	   public decimal TotalGPPercent {get;set;}
	   public string Status {get;set;}
	   
	   public OrderInfo(string name, string id, string oNumber, string baName, string baId, decimal costInc, decimal ticketPrice, decimal priceInc, decimal gp, decimal gpPercent, string oStatus){
	     OrderName = name;
	     OrderId = id;
	     OrderUrl = '../' + OrderId;
	     OrderNumber = oNumber;
	     BillingAccountName = baName;
	     BillingAccountId = baId;
	     BillingAccountUrl = '../' + BillingAccountId;
	     TotalCostInc = costInc;
	     TotalTicketPrice = ticketPrice;
	     TotalPriceInc = priceInc;
	     TotalGP = gp;
	     TotalGPPercent = gpPercent;
	     Status = oStatus;
	   }
	   
	   public Integer compareTo(Object objToCompare){
	   		return OrderName.compareTo(((OrderInfo)objToCompare).OrderName);
	   }
	}
	
}
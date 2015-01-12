global class SFOrderWebService {
	
	webService static List<Order> GetNewOrders(integer versionNumber){

		List<Order> finalOrderList = new List<Order>();
		
		List<Order__c> orderList = [Select Id, Order_Number__c, Version_Number__c, Create_Date__c, Total_Price_Inc__c, Reference_Number_1__c, Reference_Number_2__c, Delivery_Notes__c, PaymentMethod__c, First_Name__c, Last_Name__c, Phone__c, Mobile__c, Email__c, Address_1__c, Address_2__c, Address_3__c, Suburb__c, Postcode__c, State__c, Country__c, 
										Billing_Account__r.Name, Billing_Account__r.AccountNumber, Billing_Account__r.ABN__c, Billing_Account__r.Auto_Email_Invoice__c, Billing_Account__r.Credit_Type__c, Billing_Account__r.GP_ID__c, Billing_Account__r.PPSR__c, Billing_Account__r.VIP_Number__c, Billing_Account__r.Account_Contact__c, Billing_Account__r.Phone, Billing_Account__r.Fax, Billing_Account__r.Email__c, 
										Billing_Account__r.BillingStreet, Billing_Account__r.BillingCity, Billing_Account__r.BillingPostalCode, Billing_Account__r.BillingState, Billing_Account__r.BillingCountry, 
										Billing_Account__r.ShippingStreet, Billing_Account__r.ShippingCity, Billing_Account__r.ShippingPostalCode, Billing_Account__r.ShippingState, Billing_Account__r.ShippingCountry,
									(Select Id, SKU__c, Name, Quantity__c, Cost_Ex__c, Cost_Inc__c, DispatchPoint__c,  Freight_Method__c From OrderLineItems__r) 
									From Order__c 
									Where Version_Number__c >: versionNumber
									ORDER BY Version_Number__c ASC NULLS LAST];
									
		ConvertOrderObjToOrderInfo(finalOrderList, orderList);
		UpdateSendDateField(orderList);
		return finalOrderList;
	}
	
	webService static SFOrderResponse UpdateOrders(List<Order> orders) {

		List<Order__c> upsertOrderList = new List<Order__c>();
		List<OrderLineItem__c> upsertOrderLineItemList = new List<OrderLineItem__c>();
		List<Order__c> finalOrderList = new List<Order__c>();
		Set<string> orderNumberSet = new Set<string>();
        Map<string, id> orderNumberIdMap = new Map<string, id>();	//decrease number of SOQL queries. the max number of one request is 100.
		SFOrderResponse sfRes = new SFOrderResponse(true, '');
		
        ConvertOrderInfoToOrderObj(orders, upsertOrderList, upsertOrderLineItemList);
        
    	for(Order__c upsertOrd : upsertOrderList){
    		orderNumberSet.add(upsertOrd.Order_Number__c);
    	}
    	List<Order__c> currentOrderList = [Select Id, Order_Number__c From Order__c Where Order_Number__c in: orderNumberSet];
    	for(Order__c currentOrd : currentOrderList){
    		orderNumberIdMap.put(currentOrd.Order_Number__c, currentOrd.Id);
    	}
    	for(Order__c finalOrd : upsertOrderList){
    		if(orderNumberIdMap.get(finalOrd.Order_Number__c) != null){
    			finalOrd.Id = Id.valueOf(orderNumberIdMap.get(finalOrd.Order_Number__c));
    			finalOrderList.add(finalOrd);
    		}
    		else{
    			sfRes.Result = false;
    			sfRes.Message += 'This order doesn\'t exist in Salesforce. The order number is: ' + finalOrd.Order_Number__c + '\n'; 
    		}
    	}
    	
    	update finalOrderList;	// order just need to update
    	update upsertOrderLineItemList; //order line item just need to update
    	
    	return sfRes;
	}

	// Order --> Order__c
	public static void ConvertOrderInfoToOrderObj(List<Order> orders, List<Order__c> upsertOrderList, List<OrderLineItem__c> upsertOrderLineItemList){
		for(Order ord : orders){
			Order__c orderC = new Order__c();
			if(ord.OrderNumber != null){
				orderC.Order_Number__c = ord.OrderNumber;
			}
			if(ord.ITVOrderNumber != null){
				orderC.ITV_Order_Number__c = ord.ITVOrderNumber;
			}
			if(ord.AccountNumber != null){
				orderC.Billing_Account__c = GetAccountIdByAccountNumber(ord.AccountNumber);
			}
			if(ord.OrderDate != null){
				orderC.Create_Date__c = ConvertStrToDateTime(ord.OrderDate);
			}
			if(ord.OrderValue != null){
				orderC.Total_Price_Inc__c = double.valueOf(ord.OrderValue);
			}
			if(ord.Reference1 != null){
				orderC.Reference_Number_1__c = ord.Reference1;
			}
			if(ord.Reference2 != null){
				orderC.Reference_Number_2__c = ord.Reference2;
			}
			if(ord.DeliveryNotes != null){
				orderC.Delivery_Notes__c = ord.DeliveryNotes;
			}
			if(ord.PaymentMethod != null){
				orderC.PaymentMethod__c = ord.PaymentMethod;
			}
			if(ord.Status != null){
				orderC.Status__c = ord.Status;
			}
			if(ord.CloseDate != null){
				orderC.Close_Date__c = ConvertStrToDateTime(ord.CloseDate);
			}

			if(ord.EndCustomerInfo != null){
				if(ord.EndCustomerInfo.FirstName != null){
					orderC.First_Name__c = ord.EndCustomerInfo.FirstName;
				}
				if(ord.EndCustomerInfo.LastName != null){
					orderC.Last_Name__c = ord.EndCustomerInfo.LastName;
				}
				if(ord.EndCustomerInfo.Phone != null){
					orderC.Phone__c = ord.EndCustomerInfo.Phone;
				}
				if(ord.EndCustomerInfo.Mobile != null){
					orderC.Mobile__c = ord.EndCustomerInfo.Mobile;
				}
				if(ord.EndCustomerInfo.Email != null){
					orderC.Email__c = ord.EndCustomerInfo.Email;
				}
				if(ord.EndCustomerInfo.Address1 != null){
					orderC.Address_1__c = ord.EndCustomerInfo.Address1;
				}
				if(ord.EndCustomerInfo.Address2 != null){
					orderC.Address_2__c = ord.EndCustomerInfo.Address2;
				}
				if(ord.EndCustomerInfo.Address3 != null){
					orderC.Address_3__c = ord.EndCustomerInfo.Address3;
				}
				if(ord.EndCustomerInfo.Suburb != null){
					orderC.Suburb__c = ord.EndCustomerInfo.Suburb;
				}
				if(ord.EndCustomerInfo.Postcode != null){
					orderC.Postcode__c = ord.EndCustomerInfo.Postcode;
				}
				if(ord.EndCustomerInfo.State != null){
					orderC.State__c = ord.EndCustomerInfo.State;
				}
				if(ord.EndCustomerInfo.Country != null){
					orderC.Country__c = ord.EndCustomerInfo.Country;
				}
			}
			
			orderC.ByPass_VR__c = true;
	    	upsertOrderList.add(orderC);
			
			for(OrderLineItem oli : ord.OrderLineItemInfo){
				if(oli != null){
					OrderLineItem__c oliC = new OrderLineItem__c();
					if(oli.LineItemID != null){
						oliC.Id = Id.valueOf(oli.LineItemID);
					}
					if(oli.SKU != null){
						oliC.SKU__c = oli.SKU;
					}
					if(oli.Title != null){
						oliC.Name = oli.Title;
					}
					if(oli.Quantity != null){
						oliC.Quantity__c = double.valueOf(oli.Quantity);
					}
					if(oli.QuantityShipped != null){
						oliC.Quantity_Shipped__c = double.valueOf(oli.QuantityShipped);
					}
					if(oli.SalesPriceEx != null){
						oliC.Cost_Ex__c = double.valueOf(oli.SalesPriceEx);
					}
					if(oli.SalesPriceInc != null){
						oliC.Cost_Inc__c = double.valueOf(oli.SalesPriceInc);
					}
					if(oli.DispatchPoint != null){
						oliC.DispatchPoint__c = oli.DispatchPoint;
					}
					if(oli.FreightMethod != null){
						oliC.Freight_Method__c = oli.FreightMethod;
					}
					if(oli.Status != null){
						oliC.Status__c = oli.Status;
					}
					if(oli.CloseDate != null){
						oliC.Close_Date__c = ConvertStrToDateTime(oli.CloseDate);
					}
	
					if(oli.InvoiceNumber != null){
						string invoiceNum = '';
						for(string invNum : oli.InvoiceNumber){
							invoiceNum += invNum + ':';
						}
						oliC.Invoice_Number__c = invoiceNum.trim().removeEnd(':');
					}
					
					oliC.ByPass_VR__c = true;
		 			upsertOrderLineItemList.add(oliC);
				}
			}
		}
	}
	
	// Order__c --> Order 		
	public static void ConvertOrderObjToOrderInfo(List<Order> finalOrderList, List<Order__c> orderList){
		for(Order__c o : orderList){
			
			List<OrderLineItem> ordOrderLineItemInfo = new List<OrderLineItem>();
			for(OrderLineItem__c oli : o.OrderLineItems__r){
				string oliLineItemID =  oli.Id != null ? string.valueOf(oli.Id) : null;
				string oliSKU = oli.SKU__c != null ? string.valueOf(oli.SKU__c) : null;
				string oliTitle = oli.Name != null ? string.valueOf(oli.Name) : null;
				string oliQuantity = oli.Quantity__c != null ? string.valueOf(oli.Quantity__c) : null;
				string oliQuantityShipped = null;
				string oliSalesPriceEx = oli.Cost_Ex__c != null ? string.valueOf(oli.Cost_Ex__c) : null;
				string oliSalesPriceInc = oli.Cost_Inc__c != null ? string.valueOf(oli.Cost_Inc__c) : null;
				string oliDispatchPoint = oli.DispatchPoint__c != null ? string.valueOf(oli.DispatchPoint__c) : null;
				string oliFreightMethod = oli.Freight_Method__c != null ? string.valueOf(oli.Freight_Method__c) : null;
				string oliStatus = null; 
				string oliCloseDate = null; 
				List<string> oliInvoiceNumber = null;
				
				OrderLineItem oliInfo = new OrderLineItem(oliLineItemID, oliSKU, oliTitle, oliQuantity, oliQuantityShipped, oliSalesPriceEx, oliSalesPriceInc, oliDispatchPoint, oliFreightMethod, oliStatus, oliCloseDate, oliInvoiceNumber);
				ordOrderLineItemInfo.add(oliInfo);
			}
			
			string cAccountName = o.Billing_Account__r.Name;
			string cAccountNumber = o.Billing_Account__r.AccountNumber != null ? o.Billing_Account__r.AccountNumber : null;
			string cABN = o.Billing_Account__r.ABN__c != null ? o.Billing_Account__r.ABN__c : null;
			string cAutoEmailInvoice = o.Billing_Account__r.Auto_Email_Invoice__c != null ? string.valueOf(o.Billing_Account__r.Auto_Email_Invoice__c) : null;
			string cCreditType = o.Billing_Account__r.Credit_Type__c != null ? o.Billing_Account__r.Credit_Type__c : null;
			string cGPID = o.Billing_Account__r.GP_ID__c != null ? o.Billing_Account__r.GP_ID__c : null;
			string cPPSR = o.Billing_Account__r.PPSR__c != null ? o.Billing_Account__r.PPSR__c : null;
			string cVIPNumber = o.Billing_Account__r.VIP_Number__c != null ? o.Billing_Account__r.VIP_Number__c : null;
			string cAccountContact = o.Billing_Account__r.Account_Contact__c != null ? o.Billing_Account__r.Account_Contact__c : null;
			string cPhone = o.Billing_Account__r.Phone != null ? o.Billing_Account__r.Phone : null;
			string cFax = o.Billing_Account__r.Fax != null ? o.Billing_Account__r.Fax : null;
			string cEmail = o.Billing_Account__r.Email__c != null ? o.Billing_Account__r.Email__c : null;
			
			string bAddress = o.Billing_Account__r.BillingStreet != null ? o.Billing_Account__r.BillingStreet : null;
			string bSuburb = o.Billing_Account__r.BillingCity != null ? o.Billing_Account__r.BillingCity : null;
			string bPostcode = o.Billing_Account__r.BillingPostalCode != null ? o.Billing_Account__r.BillingPostalCode : null;
			string bState = o.Billing_Account__r.BillingState != null ? o.Billing_Account__r.BillingState : null;
			string bCountry = o.Billing_Account__r.BillingCountry != null ? o.Billing_Account__r.BillingCountry : null;
			CustomerBillingAddress cBillingAddress = new CustomerBillingAddress(bAddress, bSuburb, bPostcode, bState, bCountry);
			
			string sAddress = o.Billing_Account__r.ShippingStreet != null ? o.Billing_Account__r.ShippingStreet : null;
			string sSuburb = o.Billing_Account__r.ShippingCity != null ? o.Billing_Account__r.ShippingCity : null;
			string sPostcode = o.Billing_Account__r.ShippingPostalCode != null ? o.Billing_Account__r.ShippingPostalCode : null;
			string sState = o.Billing_Account__r.ShippingState != null ? o.Billing_Account__r.ShippingState : null;
			string sCountry = o.Billing_Account__r.ShippingCountry != null ? o.Billing_Account__r.ShippingCountry : null;
   			CustomerShippingAddress cShippingAddress = new CustomerShippingAddress(sAddress, sSuburb, sPostcode, sState, sCountry);
			
			Customer ordCustomerInfo = new Customer(cAccountName, cAccountNumber, cABN, cAutoEmailInvoice, cCreditType, cGPID, cPPSR, cVIPNumber, cAccountContact, cPhone, cFax, cEmail, cBillingAddress, cShippingAddress);
			
			string ecFirstName = o.First_Name__c != null ? o.First_Name__c : null;
			string ecLastName = o.Last_Name__c != null ? o.Last_Name__c : null;
			string ecPhone = o.Phone__c != null ? o.Phone__c : null;
			string ecMobile = o.Mobile__c != null ? o.Mobile__c : null;
			string ecEmail = o.Email__c != null ? o.Email__c : null;
			string ecAddress1 = o.Address_1__c != null ? o.Address_1__c : null;
			string ecAddress2 = o.Address_2__c != null ? o.Address_2__c : null;
			string ecAddress3 = o.Address_3__c != null ? o.Address_3__c : null;
			string ecSuburb = o.Suburb__c != null ? o.Suburb__c : null;
			string ecPostcode =  o.Postcode__c != null ? o.Postcode__c : null;
			string ecState = o.State__c != null ? o.State__c : null;
			string ecCountry = o.Country__c != null ? o.Country__c : null;
			EndCustomer ordEndCustomerInfo = new EndCustomer(ecFirstName, ecLastName, ecPhone, ecMobile, ecEmail, ecAddress1, ecAddress2, ecAddress3, ecSuburb, ecPostcode, ecState, ecCountry);
			
			string ordOrderNumber = o.Order_Number__c != null ? o.Order_Number__c : null;
			string ordITVOrderNumber = null;
			string ordVersionNumber = o.Version_Number__c != null ? string.valueOf(o.Version_Number__c) : null;
			string ordAccountNumber = o.Billing_Account__r.AccountNumber != null ? o.Billing_Account__r.AccountNumber : null;
			string ordOrderDate = o.Create_Date__c != null ? o.Create_Date__c.format('dd/MM/yyyy') : null;
			string ordOrderValue = o.Total_Price_Inc__c != null ? string.valueOf(o.Total_Price_Inc__c) : null;
			string ordReference1 = o.Reference_Number_1__c != null ? o.Reference_Number_1__c : null;
			string ordReference2 = o.Reference_Number_2__c != null ? o.Reference_Number_2__c : null;
			string ordDeliveryNotes = o.Delivery_Notes__c != null ? o.Delivery_Notes__c : null;
			string ordPaymentMethod = o.PaymentMethod__c != null ? o.PaymentMethod__c : null;
			string ordStatus = null;
			string ordCloseDate =  null;
			
			Order orderInfo = new Order(ordOrderNumber, ordITVOrderNumber, ordVersionNumber, ordAccountNumber, ordOrderDate, ordOrderValue, ordReference1, ordReference2, ordDeliveryNotes, ordPaymentMethod, ordStatus, ordCloseDate, ordCustomerInfo, ordEndCustomerInfo, ordOrderLineItemInfo);
			finalOrderList.add(orderInfo);
        }
	}
	
    private static void UpdateSendDateField(List<Order__c> orderList){
		List<Order__c> oList = new List<Order__c>();
		for(Order__c item : orderList){
			Order__c o = new Order__c();
			o.Id = item.Id;
			o.Sent_Date__c = date.today();
			o.ByPass_VR__c = true;
			oList.add(o);
		}
		update oList;
    }
	
	private static datetime ConvertStrToDateTime(string valueStr){
		datetime currentDateTime = datetime.now();
		integer year = 0;
		integer month = 0;
		integer day = 0;
		if(string.isNotBlank(valueStr))
		{
			string[] splitArray = valueStr.split('/');
			day = integer.valueOf(splitArray[0]);
			month = integer.valueOf(splitArray[1]);
			year = integer.valueOf(splitArray[2]);
			currentDateTime = datetime.newInstance(year, month, day, 0, 0, 0);
		}
		return currentDateTime;
	}
	
	private static id GetAccountIdByAccountNumber(string accNumber){
		Account[] accList = [Select Id From Account Where AccountNumber =: accNumber LIMIT 1];
		if(accList != null && accList.size() > 0){
			return accList[0].Id;
		}
		else{
			return null;
		}
	}

	global class Order {
   		webService string OrderNumber {get; set;}
   		webService string ITVOrderNumber {get; set;}
   		webService string VersionNumber {get; set;}
   		webService string AccountNumber {get; set;}
   		webService string OrderDate {get; set;}
   		webService string OrderValue {get; set;}
   		webService string Reference1 {get; set;}
   		webService string Reference2 {get; set;}
   		webService string DeliveryNotes {get; set;}
   		webService string PaymentMethod {get; set;}
   		webService string Status {get; set;}
   		webService string CloseDate {get; set;}
   		
   		webService Customer CustomerInfo {get; set;}
   		webService EndCustomer EndCustomerInfo {get; set;}
   		webService List<OrderLineItem> OrderLineItemInfo {get; set;}
   		
	   	public Order(string ordOrderNumber, string ordITVOrderNumber, string ordVersionNumber, string ordAccountNumber, string ordOrderDate, string ordOrderValue, string ordReference1, string ordReference2, string ordDeliveryNotes, string ordPaymentMethod, string ordStatus, string ordCloseDate, Customer ordCustomerInfo, EndCustomer ordEndCustomerInfo, List<OrderLineItem> ordOrderLineItemInfo){
	   		OrderNumber = ordOrderNumber;
	   		ITVOrderNumber = ordITVOrderNumber;
	   		VersionNumber = ordVersionNumber;
	   		AccountNumber = ordAccountNumber;
	   		OrderDate = ordOrderDate;
	   		OrderValue = ordOrderValue;
	   		Reference1 = ordReference1;
	   		Reference2 = ordReference2;
	   		DeliveryNotes = ordDeliveryNotes;
	   		PaymentMethod = ordPaymentMethod;
	   		Status = ordStatus;
	   		CloseDate = ordCloseDate;
	   		CustomerInfo = ordCustomerInfo;
	   		EndCustomerInfo = ordEndCustomerInfo;
	   		OrderLineItemInfo = ordOrderLineItemInfo;
	   	}
   }
   
   global class Customer {
   		webService string AccountName {get; set;}
   		webService string AccountNumber {get; set;}
   		webService string ABN {get; set;}
   		webService string AutoEmailInvoice {get; set;}
   		webService string CreditType {get; set;}
   		webService string GPID {get; set;}
   		webService string PPSR {get; set;}
   		webService string VIPNumber {get; set;}
   		webService string AccountContact {get; set;}
   		webService string Phone {get; set;}
   		webService string Fax {get; set;}
   		webService string Email {get; set;}
   		
   		webService CustomerBillingAddress BillingAddress {get; set;}
   		webService CustomerShippingAddress ShippingAddress {get; set;}
   		
   		public Customer(string cAccountName, string cAccountNumber, string cABN, string cAutoEmailInvoice, string cCreditType, string cGPID, string cPPSR, string cVIPNumber, string cAccountContact, string cPhone, string cFax, string cEmail, CustomerBillingAddress cBillingAddress, CustomerShippingAddress cShippingAddress){
   			AccountName = cAccountName;
   			AccountNumber = cAccountNumber;
   			ABN = cABN;
   			AutoEmailInvoice = cAutoEmailInvoice;
   			CreditType = cCreditType;
   			GPID = cGPID;
   			PPSR = cPPSR;
   			VIPNumber = cVIPNumber;
   			AccountContact = cAccountContact;
   			Phone = cPhone;
   			Fax = cFax;
   			Email = cEmail;
   			BillingAddress = cBillingAddress;
   			ShippingAddress = cShippingAddress;
   		}
   }
 
   
   global class CustomerBillingAddress{
   		webService string Address {get; set;}
   		webService string Suburb {get; set;}
   		webService string Postcode {get; set;}
   		webService string State {get; set;}
   		webService string Country {get; set;}
   		
   		public CustomerBillingAddress(string bAddress, string bSuburb, string bPostcode, string bState, string bCountry){
   			Address = bAddress;
   			Suburb = bSuburb;
   			Postcode = bPostcode;
   			State = bState;
   			Country = bCountry;
   		}
   }
   
   global class CustomerShippingAddress{
   		webService string Address {get; set;}
   		webService string Suburb {get; set;}
   		webService string Postcode {get; set;}
   		webService string State {get; set;}
   		webService string Country {get; set;}
   		
   		public CustomerShippingAddress(string sAddress, string sSuburb, string sPostcode, string sState, string sCountry){
   			Address = sAddress;
   			Suburb = sSuburb;
   			Postcode = sPostcode;
   			State = sState;
   			Country = sCountry;
   		}
   }
   
   global class EndCustomer {
   		webService string FirstName {get; set;}
   		webService string LastName {get; set;}
   		webService string Phone {get; set;}
   		webService string Mobile {get; set;}
   		webService string Email {get; set;}
   		webService string Address1 {get; set;}
   		webService string Address2 {get; set;}
   		webService string Address3 {get; set;}
   		webService string Suburb {get; set;}
   		webService string Postcode {get; set;}
   		webService string State {get; set;}
   		webService string Country {get; set;}
   		
   		public EndCustomer(string ecFirstName, string ecLastName, string ecPhone, string ecMobile, string ecEmail, string ecAddress1, string ecAddress2, string ecAddress3, string ecSuburb, string ecPostcode, string ecState, string ecCountry){
	   		FirstName = ecFirstName;
	   		LastName = ecLastName;
	   		Phone = ecPhone;
	   		Mobile = ecMobile;
	   		Email = ecEmail;
	   		Address1 = ecAddress1;
	   		Address2 = ecAddress2;
	   		Address3 = ecAddress3;
	   		Suburb = ecSuburb;
	   		Postcode = ecPostcode;
	   		State = ecState;
	   		Country = ecCountry;
	   	}
   }
 
   global class OrderLineItem {
   		webService string LineItemID {get; set;}
   		webService string SKU {get; set;}
   		webService string Title {get; set;}
   		webService string Quantity {get; set;}
   		webService string QuantityShipped {get; set;}
   		webService string SalesPriceEx {get; set;}
   		webService string SalesPriceInc {get; set;}
   		webService string DispatchPoint {get; set;}
   		webService string FreightMethod {get; set;}
   		webService string Status {get; set;}
   		webService string CloseDate {get; set;}
   		webService List<string> InvoiceNumber {get; set;}
   		
   		public OrderLineItem(string oliLineItemID, string oliSKU, string oliTitle, string oliQuantity, string oliQuantityShipped, string oliSalesPriceEx, string oliSalesPriceInc, string oliDispatchPoint, string oliFreightMethod, string oliStatus, string oliCloseDate, List<string> oliInvoiceNumber){
   			LineItemID = oliLineItemID;
   			SKU = oliSKU;
   			Title = oliTitle;
   			Quantity = oliQuantity;
   			QuantityShipped = oliQuantityShipped;
   			SalesPriceEx = oliSalesPriceEx;
   			SalesPriceInc = oliSalesPriceInc;
   			DispatchPoint = oliDispatchPoint;
   			FreightMethod = oliFreightMethod;
   			Status = oliStatus;
   			CloseDate = oliCloseDate;
   			InvoiceNumber = oliInvoiceNumber;
   		}
   }
   
   global class SFOrderResponse{
   		webService boolean Result {get; set;}
   		webService string Message {get; set;}
   		
   		public SFOrderResponse(boolean sfResult, string sfMessage){
   			Result = sfResult;
   			Message = sfMessage;
   		}
   }
}
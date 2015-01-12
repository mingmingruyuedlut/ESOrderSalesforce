trigger OrderLineItemTrigger on OrderLineItem__c (before insert, before update, after insert, after update, after delete) {
    if (Trigger.isBefore) { 
        if(trigger.isInsert || trigger.isUpdate){
            for(OrderLineItem__c lineItem : Trigger.new){
                Product2 product = [Select Name, SKU__c, Model__c, Product_Group__c, Cost_Inc_GST__c, Cost_Ex_GST__c, Ticket_Price__c
                					From Product2 Where Id = :lineItem.Product__c limit 1];
                   
            	lineItem.SKU__c = product.SKU__c;
                lineItem.Model__c = product.Model__c;
                lineItem.Product_Group__c = product.Product_Group__c;
                lineItem.Cost_Ex__c = product.Cost_Ex_GST__c;
                lineItem.Cost_Inc__c = product.Cost_Inc_GST__c;
                lineItem.Ticket_Price__c = product.Ticket_Price__c;
                if(trigger.isInsert) lineItem.Status__c = 'Open';
                if(lineItem.Status__c == 'Closed'){
                	SetOrderLineItemReportGroup(lineItem);
                }
                lineItem.Sales_Price_Ex__c = (lineItem.Sales_Price_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
                lineItem.Total_Price_Inc__c = lineItem.Sales_Price_Inc__c * lineItem.Quantity__c;
                lineItem.Total_Price_Ex__c = (lineItem.Total_Price_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
                
                if(product.Cost_Inc_GST__c != null){
                    lineItem.GP_dollar__c = ((lineItem.Sales_Price_Inc__c - product.Cost_Inc_GST__c) * lineItem.Quantity__c).setScale(2, RoundingMode.HALF_UP);
                    if(product.Cost_Inc_GST__c != 0){
                    	lineItem.GP_percent__c = ((lineItem.Sales_Price_Inc__c - product.Cost_Inc_GST__c) / product.Cost_Inc_GST__c).setScale(4, RoundingMode.HALF_UP) * 100;
                    }
                }
            }
        }
    }
    else
    {
    	if(trigger.isDelete){
    		for(OrderLineItem__c lineItem : Trigger.old){
	    		// update Total Price of order
	            UpdateOrder(lineItem.Order__c);
	            
	            // delete the related report group info
	            DeleteOrderLineItemReportGroup(lineItem);
	    	}  
    	}
    	else{
	    	for(OrderLineItem__c lineItem : Trigger.new){
	    		// update Total Price of order
	            UpdateOrder(lineItem.Order__c);
	    	}       
    	}         
    }
    
    // update Total Price of order
    private void UpdateOrder(string orderId){
    	decimal totalPrice = 0;
    	Order__c ord = [Select Id, Total_Cost_Ex__c, Total_Cost_Inc__c, Total_Ticket_Price__c, Total_Price_Ex__c, Total_Price_Inc__c, Total_GP_dollar__c, Total_GP_percent__c From Order__c Where Id = :orderId];
    	
    	ord.ByPass_VR__c = true;
    	ord.Total_Cost_Inc__c = 0;
    	ord.Total_Ticket_Price__c = 0;
    	ord.Total_Price_Inc__c = 0;
    	
    	for(OrderLineItem__c item : [Select Cost_Inc__c, Ticket_Price__c, Quantity__c, Total_Price_Inc__c From OrderLineItem__c Where Order__c = :orderId]){
    		ord.Total_Cost_Inc__c += item.Cost_Inc__c * item.Quantity__c;
			ord.Total_Ticket_Price__c += item.Ticket_Price__c * item.Quantity__c;
			ord.Total_Price_Inc__c += item.Total_Price_Inc__c;
    	}
    	ord.Total_Cost_Ex__c = (ord.Total_Cost_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
		ord.Total_Price_Ex__c = (ord.Total_Price_Inc__c / 1.1).setScale(2, RoundingMode.HALF_UP);
		if(ord.Total_Cost_Inc__c != null) {
			ord.Total_GP_dollar__c = (ord.Total_Price_Inc__c - ord.Total_Cost_Inc__c).setScale(2, RoundingMode.HALF_UP);
			if(ord.Total_Cost_Inc__c != 0) {
            	ord.Total_GP_percent__c = ((ord.Total_Price_Inc__c - ord.Total_Cost_Inc__c) / ord.Total_Cost_Inc__c).setScale(4, RoundingMode.HALF_UP) * 100;
			}
		}
		
		update ord;
    }
    
    
 	// Add report group for report with target
	private void SetOrderLineItemReportGroup(OrderLineItem__c lineItem){
		if(lineItem != null) {
			if(lineItem.Report_Group__c == null){
				Order__c orderC = [Select Id, Billing_Account__r.OwnerId, Billing_Account__r.BillingState, Billing_Account__r.Name, Billing_Account__r.Id From Order__c Where Id =: lineItem.Order__c];
				User userNameObj = [Select Name From User Where Id =: orderC.Billing_Account__r.OwnerId];
				Order_Target_Report_Group__c reportGroup = new Order_Target_Report_Group__c();
				reportGroup.Sales_Person__c = orderC.Billing_Account__r.OwnerId;
				reportGroup.Sales_Person_Label__c = userNameObj.Name;
				reportGroup.State__c = orderC.Billing_Account__r.BillingState;
				reportGroup.Billing_Account__c = orderC.Billing_Account__r.Id;
				reportGroup.Billing_Account_Label__c = orderC.Billing_Account__r.Name;
				Datetime dateTimetemp = lineItem.Close_Date__c;
				Date dateTemp = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());
				reportGroup.Sales_Month__c = dateTemp;
				insert reportGroup;
				
				lineItem.Report_Group__c = reportGroup.Id;
			}
		}
	}
	
	private void DeleteOrderLineItemReportGroup(OrderLineItem__c lineItem){
		if(lineItem != null && lineItem.Report_Group__c != null){
			Order_Target_Report_Group__c reportGroup = [Select Name, Id From Order_Target_Report_Group__c Where Id =: lineItem.Report_Group__c];
			delete reportGroup;
		}
	}
}
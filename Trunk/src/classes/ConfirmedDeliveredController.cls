public with sharing class ConfirmedDeliveredController {
	public string OrderId {get; set;}
	public boolean ShowOpenMessage {get; set;}
	public boolean ShowClosedMessage {get; set;}
	
	public ConfirmedDeliveredController(){
		OrderId = ApexPages.currentPage().getParameters().get('id');
	}
	
	public PageReference ConfirmedDelivered(){
		Order__c orderC = [Select o.Status__c, o.Name, o.Id From Order__c o where id = :OrderId];
		
		if(orderC.Status__c != null && orderC.Status__c.toLowerCase() == 'closed'){
			ShowOpenMessage = false;
			ShowClosedMessage = true;
		}		
		else if(orderC.Status__c == null || orderC.Status__c.toLowerCase() == 'open'){
			ShowOpenMessage = true;
			ShowClosedMessage = false;
		}
		else{ // Finalised,Initialised,Deleted,Initialised,Acknowledged,Picking,Cancelled
			SetOrderStatus(OrderId, 'Closed');
			string orderURL = '/' + OrderId;
			PageReference page = new PageReference(orderURL);
	        page.setRedirect(true);
        
        	return page;
		}
		
		return null;		
	}
	
	private void SetOrderStatus(string orderId, string status){
		Order__c orderC = [Select Id, Status__c, Close_Date__c From Order__c Where Id = :orderId];
		if(orderC != null) {
			orderC.ByPass_VR__c = true;
			orderC.Status__c = status;
			if(status == 'Closed'){
				orderC.Close_Date__c = datetime.now();
			}
			
			update orderC;
			
			OrderLineItem__c[] lineItems = [select Id, Status__c, Close_Date__c from OrderLineItem__c where Order__c = :orderId];
			for(OrderLineItem__c lineItem : lineItems){
				lineItem.ByPass_VR__c = true;
				lineItem.Status__c = status;
				if(status == 'Closed'){
					lineItem.Close_Date__c = datetime.now();
				}
			}
			update lineItems;
		}
	}
}
public with sharing class DeleteOrderLineItemController {
	private final OrderLineItem__c lineItem;
	public string Id {get;set;}
	public string OrderId {get; set;}
	public string RetUrl {get;set;}
	public string FailRetURL {get;set;}
	
	public DeleteOrderLineItemController(ApexPages.StandardController stdController) {
        this.lineItem = (OrderLineItem__c)stdController.getRecord();
        Id = this.lineItem.Id;
        
        RetUrl = ApexPages.currentPage().getParameters().get('retURL');
        if(RetUrl == null) RetUrl = '/';
        FailRetURL = ApexPages.currentPage().getParameters().get('failRetURL');
        if(FailRetURL == null) FailRetURL = RetUrl;
    }
	
	public PageReference DeleteOrderLineItem(){
		OrderLineItem__c lineItemC = [select Id, Order__c from OrderLineItem__c where Id = :Id];
		Order__c orderC = [Select Id, Status__c From Order__c where id = :lineItemC.Order__c];
		
		if(orderC.Status__c.toLowerCase() == 'open'){
			delete lineItemC;
			
			PageReference page = new PageReference(RetUrl);
	        page.setRedirect(true);
	        
	        return page;
		}
		
		return null;
	}
}
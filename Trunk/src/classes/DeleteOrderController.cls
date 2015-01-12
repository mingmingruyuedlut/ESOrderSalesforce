public with sharing class DeleteOrderController {
	private final Order__c ord;
	public string OrderId {get; set;}
	public string RetUrl {get;set;}
	public string FailRetURL {get;set;}
	
	public DeleteOrderController(ApexPages.StandardController stdController) {
        this.ord = (Order__c)stdController.getRecord();
        OrderId = this.ord.Id;
        RetUrl = ApexPages.currentPage().getParameters().get('retURL');
        if(RetUrl == null) RetUrl = '/';
        FailRetURL = ApexPages.currentPage().getParameters().get('failRetURL');
        if(FailRetURL == null) FailRetURL = RetUrl;
    }
	
	public PageReference DeleteOrder(){
		Order__c orderC = [Select Id, Status__c From Order__c where id = :OrderId];
		
		if(orderC.Status__c.toLowerCase() == 'open'){
			delete orderC;
			
			PageReference page = new PageReference(RetUrl);
	        page.setRedirect(true);
	        
	        return page;
		}
		
		return null;
	}
}
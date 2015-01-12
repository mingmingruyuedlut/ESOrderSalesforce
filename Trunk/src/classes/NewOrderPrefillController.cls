public with sharing class NewOrderPrefillController {
	public string RetUrl {get;set;}
	
	public NewOrderPrefillController(ApexPages.StandardController stdController) {
        RetUrl = '/a00/e?Name=NewOrder_Prefill_Name&nooverride=1';
    }
	
	public PageReference NewOrderPrefill(){
		PageReference page = new PageReference(RetUrl);
        page.setRedirect(true);
        return page;
	}
}
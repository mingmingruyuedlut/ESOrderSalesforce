public with sharing class TestController {
	
	public SearchCriteriaData SearchCriteria {
		get{
			if(SearchCriteria == null && ApexPages.currentPage().getParameters().get('search') != null){
				SearchCriteria = new SearchCriteriaData();
				SearchCriteria.SKU = ApexPages.currentPage().getParameters().get('sku');
				SearchCriteria.Model = ApexPages.currentPage().getParameters().get('model');
				SearchCriteria.Department = ApexPages.currentPage().getParameters().get('department');
			}
			return SearchCriteria;
		}
		set;
	}
	
	public List<SearchResultData> SearchResults {
		get{
			if(SearchResults == null && SearchCriteria != null){
				SearchResults = SearchProducts(SearchCriteria);
			}
			return SearchResults;
		}
		set;
	}
	
	public List<SelectOption> DepartmentList {
		get{
			if(DepartmentList == null){
				DepartmentList = new List<SelectOption>();
				List<string> vals = Common.GetPicklistValues('Product2', 'Department__c');
				for(string val : vals){
					DepartmentList.add(new SelectOption(val, val));
				}
			}
			return DepartmentList;
		}
		private set;
	}
	
	public string Department {get;set;}
	
	public string ReturnUrl {
		get{
			if(ReturnUrl == null){
				PageReference page = new PageReference('/apex/test');
			    page.getParameters().put('search', '');
			    page.getParameters().put('sku', SearchCriteria.SKU);
			    page.getParameters().put('model', SearchCriteria.Model);
			    page.getParameters().put('department', SearchCriteria.Department);
			    string url = page.getUrl();
			    ReturnUrl = EncodingUtil.urlEncode(url, 'UTF-8');
			}
			return ReturnUrl;
		}
		private set;
	}
	
	public PageReference Search(){
		SearchCriteria = new SearchCriteriaData();
		SearchCriteria.SKU = ApexPages.currentPage().getParameters().get('_sku');
		SearchCriteria.Model = ApexPages.currentPage().getParameters().get('_model');
		SearchCriteria.Department = Department;
		system.debug(Department);
		system.debug(SearchCriteria.Department);
		SearchResults = SearchProducts(SearchCriteria);

	    return ApexPages.currentPage();
	}
	
	private List<SearchResultData> SearchProducts(SearchCriteriaData sc){
		List<SearchResultData> results = new List<SearchResultData>();
		for(integer i=1;i<=10;i++){
			SearchResultData result = new SearchResultData();
			result.ID = '01tO0000000hFc5';
			result.SKU = sc.SKU + i;
			result.Model = sc.Model + i;
			result.Department = sc.Department + i;
			result.IsActive = true;
			results.add(result);
		}
		
		return results;
	}
	
	public PageReference Test(){
		return ApexPages.currentPage();
	}
		
	public class SearchCriteriaData{
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Department {get;set;}
		public string ProductGroup {get;set;}
	}
	
	public class SearchResultData{
		public string ID {get;set;}
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Department {get;set;}
		public string ProductGroup {get;set;}
		public boolean IsActive {get;set;}
	}
}
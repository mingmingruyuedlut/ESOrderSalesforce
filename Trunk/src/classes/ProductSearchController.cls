public with sharing class ProductSearchController {
	
	/*------------------------------------------ Constants ------------------------------------------*/
	static final string Equal = 'eq';
	static final string Not_Equal = 'ne';
	static final string Greater_Than = 'gt';
	static final string Greater_Than_Or_Equal = 'gtoe';
	static final string Less_Than = 'lt';
	static final string Less_Than_Or_Equal = 'ltoe';	
	static final integer Page_Size_Min = 500;
	static final integer Page_Size_Max = 3000;	
	static final integer Collection_Size_Max = 1000;	
	static final string Sort_ASC = 'asc';
	static final string Sort_DESC = 'desc';
	
	/*------------------------------------------ Properties ------------------------------------------*/
	//--------------------------- Select Search Product ----------------------------//
	public string OrderId {
		get{
			if(OrderId == null) OrderId = GetStringParameter('id');
			return OrderId;
		}
		set;
	}
	public boolean ShowFinalisedMessage {
		get{
			if(ShowFinalisedMessage == null) ShowFinalisedMessage = false;
			return ShowFinalisedMessage;
		} 
		set;
	}
	
	//--------------------------- Parameters ----------------------------//
	public string ParamSKU {get; set;}
	public string ParamModel {get;set;}
	public string ParamTitle {get;set;}
	public string ParamOnlineTitle {get;set;}
	public string ParamBrand {get;set;}
	public string ParamSupplier {get;set;}
	public string ParamDepartment {get;set;}
	public string ParamDepartmentSelected {get;set;}
	public string ParamDepartmentRange {get;set;}
	public string ParamProductGroup {get;set;}
	public string ParamProductGroupSelected {get;set;}
	public string ParamProductGroupRange {get;set;}
	public string ParamSeasonCode {get;set;}
	public string ParamSeasonCodeSelected {get;set;}
	public string ParamSeasonCodeRange {get;set;}
	public string ParamCostEx {get;set;}
	public string ParamCostExRange {get;set;}
	public string ParamCostInc {get;set;}
	public string ParamCostIncRange {get;set;}
	public string ParamTicketPrice {get;set;}
	public string ParamTicketPriceRange {get;set;}
	public string ParamSOH {get;set;}
	public boolean ParamAvailable {get;set;}
	public boolean ParamHasEnrichedContent {get;set;}
	
	// used for SelectSearchProduct page
	public string ParamProductIds {get;set;}
	public string ParamAddTo {get;set;} // order id
	
	public SearchCriteriaData SearchCriteria {get;set;}
	//--------------------------- Binding data  ----------------------------//
	public Transient List<List<SearchResultData>> SearchResultsList {get;set;}
	public SortUrlData SortUrl {get;set;}		
	public string ReturnUrl {get;set;}
	public string ShowMoreUrl {get;set;}
	public string ShowFewerUrl {get;set;}
	public boolean OverMaxPageSize {get;set;}
	public Validator ValidatorInput {get;set;}
	public boolean ShowProductList {get;set;}
	
	//--------------------------- DropDownList ----------------------------//
	
	// Department
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
	
	// Product Group
	public List<SelectOption> ProductGroupList {
		get{
			if(ProductGroupList == null){
				ProductGroupList = new List<SelectOption>();
				List<string> vals = Common.GetPicklistValues('Product2', 'Product_Group__c');
				for(string val : vals){
					ProductGroupList.add(new SelectOption(val, val));
				}
			}
			return ProductGroupList;
		}
		private set;
	}
		
	// Product Group
	public List<SelectOption> SeasonCodeList {
		get{
			if(SeasonCodeList == null){
				SeasonCodeList = new List<SelectOption>();
				List<string> vals = Common.GetPicklistValues('Product2', 'Season_Code__c');
				for(string val : vals){
					SeasonCodeList.add(new SelectOption(val, val));
				}
			}
			return SeasonCodeList;
		}
		private set;
	}
	
	public List<SelectOption> Region1List{
		get{
			if(Region1List == null){
				Region1List = new List<SelectOption>();
				Region1List.add(new SelectOption('eq', '='));
				Region1List.add(new SelectOption('ne', '≠'));
			}
			return Region1List;
		}
		private set;
	}
	public List<SelectOption> Region2List{
		get{
			if(Region2List == null){
				Region2List = new List<SelectOption>();
				Region2List.add(new SelectOption('gt', '>'));
				Region2List.add(new SelectOption('eq', '='));
				Region2List.add(new SelectOption('lt', '<'));
			}
			return Region2List;
		}
		private set;
	}
	
	/*------------------------------------------ Page init ------------------------------------------*/
	public ProductSearchController(){
		if(ApexPages.currentPage().getParameters().get('lnk') != null){
			SearchCriteria = GetUrlSearchCriteriaData();			
			SearchProduct(SearchCriteria);
			SetParamsBySearchCriteria(SearchCriteria);
		}else{		
			ShowProductList = false;
			ParamAvailable = true; // set default available to true
		}
		
		ParamAddTo = GetStringParameter('addTo'); // used for SelectSearchProduct page
	}
	
	/*------------------------------------------ Search ------------------------------------------*/
	public PageReference Search(){		
 	
		SearchCriteria = GetFormSearchCriteriaData();
		
		SearchProduct(SearchCriteria);		
		
	    return ApexPages.currentPage();  
	}
	
	public void SearchProduct(SearchCriteriaData sc){
		boolean isValid = ValidateInputs(sc);
			
		if(isValid == true){
			SearchResultsList = SearchSearchResultsList(sc);
			SortUrl = GetSortUrlData(sc);	
		}
		ShowProductList = SearchResultsList != null && SearchResultsList.size() > 0;
	}
	
	public boolean ValidateInputs(SearchCriteriaData sc){
		boolean isValid = true;
		
		Validator validator = new Validator();
		
		if(string.isNotEmpty(sc.SOH) && sc.SOH.isNumeric() == false) {
			isValid = false;
			validator.InValidSOH = true;
		}else{
			validator.InValidSOH = false;
		}
		
		if(string.isNotEmpty(sc.CostEx) && Common.IsDecimal(sc.CostEx) == false) {
			isValid = false;
			validator.InValidCostEx = true;
		}else{
			validator.InValidCostEx = false;
		}
		
		if(string.isNotEmpty(sc.CostInc) && Common.IsDecimal(sc.CostInc) == false) {
			isValid = false;
			validator.InValidCostInc = true;
		}else{
			validator.InValidCostInc = false;
		}
		
		if(string.isNotEmpty(sc.TicketPrice) && Common.IsDecimal(sc.TicketPrice) == false) {
			isValid = false;
			validator.InValidTicketPrice = true;
		}else{
			validator.InValidTicketPrice = false;
		}
		
		validator.InValid = !isValid;
		
		ValidatorInput = validator;
		
		return isValid;
	}
			
	public List<List<SearchResultData>> SearchSearchResultsList(SearchCriteriaData sc){
		List<List<SearchResultData>> resultList = new List<List<SearchResultData>>();
		List<SearchResultData> tempList = new List<SearchResultData>();
		
		integer index = 0;
		string queryString = GetSearchQuery(sc);
	    
		for(Product2 product : Database.query(queryString)){
			index++;
			
			if(index <= sc.Rows){
				tempList.add(ConvertToSearchResultData(product));
				
				if(tempList.size() == Collection_Size_Max){//limit of vf repeat components
					resultList.add(tempList);
					tempList = new List<SearchResultData>();
				}
			}
		}
		if(tempList.size() > 0){
			resultList.add(tempList);
		}
		
		SetPageInfo(sc, index);
		
		return resultList;
	}
	
	private SearchResultData ConvertToSearchResultData(Product2 product){
		SearchResultData result = new SearchResultData();
		
    	result.ID = (string)product.get('Id');
		result.SKU = product.get('SKU__c') != null ? (string)product.get('SKU__c') : '';
		result.Model = product.get('Model__c') != null ? (string)product.get('Model__c') : '';
		result.Title = product.get('Name') != null ? (string)product.get('Name') : '';
		result.Description = product.get('Short_Description__c') != null ? (string)product.get('Short_Description__c') : '';
		result.ProductGroup = product.get('Product_Group__c') != null ? (string)product.get('Product_Group__c') : '';
		result.CostEx = ConvertDecimalToString(product.get('Cost_Ex_GST__c'), 2);
		result.CostInc = ConvertDecimalToString(product.get('Cost_Inc_GST__c'), 2);
		result.GoCost = ConvertDecimalToString(product.get('Go_Cost__c'), 2);
		result.TicketPrice = ConvertDecimalToString(product.get('Ticket_Price__c'), 2);
		result.PromoPrice = ConvertDecimalToString(product.get('Promotion_Price__c'), 2);
		result.SeasonCode = product.get('Season_Code__c') != null ? (string)product.get('Season_Code__c') : '';
		result.SOH = ConvertDecimalToString(product.get('SOH__c'), 0);
		
		return result;
	}
	
	private void SetPageInfo(SearchCriteriaData sc, integer allRowsCount){
		ReturnUrl = GetSearchUrl(sc, sc.Rows);
		// fewer or more
	    integer pageSize = sc.Rows;
	    if(pageSize == Page_Size_Max && Page_Size_Max < allRowsCount){
	    	OverMaxPageSize = true;
	    }else{
	    	OverMaxPageSize = false;
	    }	    
	    if(OverMaxPageSize == true){
	    	ShowMoreUrl = '';
	    }else{		    
		    if(pageSize == Page_Size_Min && sc.Rows < allRowsCount){
		    	ShowMoreUrl = GetSearchUrl(sc, Page_Size_Max);
	    	}else{
		    	ShowMoreUrl = '';
	    	}
	    }
	    if(pageSize == Page_Size_Max && sc.Rows < allRowsCount){
	    	ShowFewerUrl = GetSearchUrl(sc, Page_Size_Min);
	    }else{
	    	ShowFewerUrl = '';
	    }
	}
	
	private string ConvertDecimalToString(object obj, integer scale){
		string result = '-';
		
		if(obj != null){
			decimal val = (decimal)obj;
			if(val > 0){
				result = string.valueOf(val.setScale(scale));
			}
		}
		
		return result;
	}
	
	private string GetSearchQuery(SearchCriteriaData sc){		
		string query = ' Select Id, SKU__c, Model__c, Department__c, Name, Ticket_Price__c, Season_Code__c, SOH__c, Promotion_Price__c, Product_Group__c, Go_Cost__c, Short_Description__c, Cost_Inc_GST__c, Cost_Ex_GST__c '
					 + ' From Product2 p Where ';
		
		// Avalible
	    if(sc.Available == true) query += ' Season_Code__c Not In (\'Q\',\'X\',\'EL\') ';
	    else query += ' Season_Code__c In (\'Q\',\'X\',\'EL\') ';
    
	    // SKU
	    if(string.isNotEmpty(sc.SKU)){	    	
	    	query += ' And SKU__c = \'' + string.escapeSingleQuotes(sc.SKU) + '\'';
	    }
	    // Model
	    if(string.isNotEmpty(sc.Model)){	    	
	    	//query += ' And Model__c Like \'%' + string.escapeSingleQuotes(sc.Model) + '%\'';
	    	query += ' And ' + GetLikeSql('Model__c', sc.Model);
	    }	    
	    // Title
	    if(string.isNotEmpty(sc.Title)){
	    	//query += ' And Name Like \'%' + string.escapeSingleQuotes(sc.Title) + '%\'';
	    	query += ' And ' + GetLikeSql('Name', sc.Title);
	    }	    
	    // Online Title
	    if(string.isNotEmpty(sc.OnlineTitle)){
	    	//query += ' And Online_Title__c Like \'%' + string.escapeSingleQuotes(sc.OnlineTitle) + '%\'';
	    	query += ' And ' + GetLikeSql('Online_Title__c', sc.OnlineTitle);
	    }	    	    
	    // Brand
	    if(string.isNotEmpty(sc.Brand)){
	    	//query += ' And Manufacturer__c Like \'%' + string.escapeSingleQuotes(sc.Brand) + '%\'';
	    	query += ' And ' + GetLikeSql('Manufacturer__c', sc.Brand);
	    }
	    // Supplier
	    if(string.isNotEmpty(sc.Supplier)){
	    	//query += ' And Supplier__c Like \'%' + string.escapeSingleQuotes(sc.Supplier) + '%\'';
	    	query += ' And ' + GetLikeSql('Supplier__c', sc.Supplier);
	    }
	    // SOH
	    if(string.isNotEmpty(sc.SOH) && sc.SOH.length() > 0){
	    	query += ' And SOH__c >= ' + sc.SOH + ' ';
	    }	    
	    // Department
	    if(string.isNotEmpty(sc.Department)){
	    	//System.debug(sc.Department);
	    	
	    	if(sc.DepartmentRange == Equal){
	    		query += ' And Department__c In (' + GenerateMultipleDataSql(sc.Department) + ') ';
	    	}else{
	    		query += ' And Department__c Not In (' + GenerateMultipleDataSql(sc.Department) + ') ';
	    	}	    	
	    }	    
	    // Product Group
	    if(string.isNotEmpty(sc.ProductGroup)){
	    	if(sc.ProductGroupRange == Equal){
	    		query += ' And Product_Group__c In (' + GenerateMultipleDataSql(sc.ProductGroup) + ') ';
	    	}else{
	    		query += ' And Product_Group__c Not In (' + GenerateMultipleDataSql(sc.ProductGroup) + ') ';
	    	}    	
	    }
	    // Season Code
	    if(string.isNotEmpty(sc.SeasonCode)){
	    	if(sc.SeasonCodeRange == Equal){
	    		query += ' And Season_Code__c In (' + GenerateMultipleDataSql(sc.SeasonCode) + ') ';
	    	}else{
	    		query += ' And Season_Code__c Not In (' + GenerateMultipleDataSql(sc.SeasonCode) + ') ';
	    	}    	
	    }
	    // Cost Ex.
	    if(string.isNotEmpty(sc.CostEx)){
	    	if(sc.CostExRange == Equal){
	    		query += ' And Cost_Ex_GST__c = ' + sc.CostEx;
	    	}else if(sc.CostExRange == Greater_Than){
	    		query += ' And Cost_Ex_GST__c > ' + sc.CostEx;
	    	}else{
	    		query += ' And Cost_Ex_GST__c < ' + sc.CostEx;
	    	}   	
	    }
	    // Cost Inc.
	    if(string.isNotEmpty(sc.CostInc)){
	    	if(sc.CostIncRange == Equal){
	    		query += ' And Cost_Inc_GST__c = ' + sc.CostInc;
	    	}else if(sc.CostIncRange == Greater_Than){
	    		query += ' And Cost_Inc_GST__c > ' + sc.CostInc;
	    	}else{
	    		query += ' And Cost_Inc_GST__c < ' + sc.CostInc;
	    	}   	
	    }
	    // Ticket Price
	    if(string.isNotEmpty(sc.TicketPrice)){
	    	if(sc.TicketPriceRange == Equal){
	    		query += ' And Ticket_Price__c = ' + sc.TicketPrice;
	    	}else if(sc.TicketPriceRange == Greater_Than){
	    		query += ' And Ticket_Price__c > ' + sc.TicketPrice;
	    	}else{
	    		query += ' And Ticket_Price__c < ' + sc.TicketPrice;
	    	}   	
	    }
	    // Has enriched content?
	    if(sc.HasEnrichedContent == true){
	    	query += ' And (Online__c = true ) ';
	    }else{
	    	query += ' And (Online__c = false ) ';
	    }
	    
	    // order by
	    if(string.isNotEmpty(sc.OrderBy)){
	    	query += ' Order By ' + FieldMapping(sc.OrderBy);
	    	if(string.isNotEmpty(sc.Dir)){
	    		query += ' ' + sc.Dir + ' ';
	    	}
	    }
	    
	    query += ' limit ' + string.valueOf(sc.Rows + 1);
	    	    
	    return query;
	}
	
	private string GetLikeSql(string fieldName, string val){
		string sql = fieldName + ' Like \'';
		
		if(val.contains('*')){
			sql += val.replace('*', '%');
		}else{
			sql += '%' + val + '%';
		}
		sql += '\' ';
				
		return sql;
	}
	
	private string GenerateMultipleDataSql(string multipleData){
		List<string> dataList = new List<string>();
		for(string s: multipleData.split(',')){
    		dataList.add('\'' + string.escapeSingleQuotes(s) + '\'');	   
    	}
    	
    	string sql = string.join(dataList, ',');
    	
    	return sql;
	}
	
	//--------------------------- sc ----------------------------//
	
	public SearchCriteriaData GetSearchCriteriaData(){
		SearchCriteriaData sc = ApexPages.currentPage().getParameters().get('lnk') != null ? GetUrlSearchCriteriaData(): GetFormSearchCriteriaData();
		return sc;
	}
	
	private SearchCriteriaData GetFormSearchCriteriaData(){
		SearchCriteriaData sc = new SearchCriteriaData();
		
		sc.SKU = ParamSKU != null ? ParamSKU.trim() : '';
		sc.Model = ParamModel != null ? ParamModel.trim() : '';
		sc.Title = ParamTitle != null ? ParamTitle.trim() : '';
		sc.OnlineTitle = ParamOnlineTitle != null ? ParamOnlineTitle.trim() : '';
		sc.Brand = ParamBrand != null ? ParamBrand.trim() : '';
		sc.Supplier = ParamSupplier != null ? ParamSupplier.trim() : '';
		sc.SOH = ParamSOH != null ? ParamSOH.trim() : '';
		sc.Department = ParamDepartment != null ? ParamDepartment.trim() : '';
		sc.DepartmentRange = ParamDepartmentRange != null ? ParamDepartmentRange.trim() : '';
		sc.ProductGroup = ParamProductGroup != null ? ParamProductGroup.trim() : '';
		sc.ProductGroupRange = ParamProductGroupRange != null ? ParamProductGroupRange.trim() : '';
		sc.SeasonCode = ParamSeasonCode != null ? ParamSeasonCode.trim() : '';
		sc.SeasonCodeRange = ParamSeasonCodeRange != null ? ParamSeasonCodeRange.trim() : '';
		sc.CostEx = ParamCostEx != null ? ParamCostEx.trim() : '';
		sc.CostExRange = ParamCostExRange != null ? ParamCostExRange.trim() : '';
		sc.CostInc = ParamCostInc != null ? ParamCostInc.trim() : '';
		sc.CostIncRange = ParamCostIncRange != null ? ParamCostIncRange .trim(): '';
		sc.TicketPrice = ParamTicketPrice != null ? ParamTicketPrice.trim() : '';
		sc.TicketPriceRange = ParamTicketPriceRange != null ? ParamTicketPriceRange.trim() : '';
		sc.Available = ParamAvailable;
		sc.HasEnrichedContent = ParamHasEnrichedContent;
		sc.OrderBy = '';
		sc.Dir = '';
		sc.Rows = Page_Size_Min;
		
		return sc;
	}
	private SearchCriteriaData GetUrlSearchCriteriaData(){
		SearchCriteriaData sc = new SearchCriteriaData();
		
		sc.SKU = GetStringParameter('sku');
		sc.Model = GetStringParameter('model');
		sc.Title = GetStringParameter('title');
		sc.OnlineTitle = GetStringParameter('ot');
		sc.Brand = GetStringParameter('brand');
		sc.Supplier = GetStringParameter('supplier');
		sc.SOH = GetStringParameter('soh');
		sc.Department = GetStringParameter('dpt');
		sc.DepartmentRange = GetStringParameter('dptr');
		sc.ProductGroup = GetStringParameter('pg');
		sc.ProductGroupRange = GetStringParameter('pgr');
		sc.SeasonCode = GetStringParameter('sc');
		sc.SeasonCodeRange = GetStringParameter('csr');
		sc.CostEx = GetStringParameter('ce');
		sc.CostExRange = GetStringParameter('cer');
		sc.CostInc = GetStringParameter('ci');
		sc.CostIncRange = GetStringParameter('cir');
		sc.TicketPrice = GetStringParameter('tp');
		sc.TicketPriceRange = GetStringParameter('tpr');		
		sc.Available = ApexPages.currentPage().getParameters().get('available') != null ? Boolean.valueOf(ApexPages.currentPage().getParameters().get('available')) : true;
		sc.HasEnrichedContent = ApexPages.currentPage().getParameters().get('enriched') != null ? Boolean.valueOf(ApexPages.currentPage().getParameters().get('enriched')) : false;		
		sc.OrderBy = GetStringParameter('order');
		sc.Dir = GetStringParameter('dir');
		sc.Rows = ApexPages.currentPage().getParameters().get('rows') != null ? integer.valueOf(ApexPages.currentPage().getParameters().get('rows')) : Page_Size_Min;
		
		return sc;
	}
	
	private string GetStringParameter(string name){
		return ApexPages.currentPage().getParameters().get(name) != null ? ApexPages.currentPage().getParameters().get(name) : '';
	}
	
	// when the SearchCriteria from url, reset the parameters
	private void SetParamsBySearchCriteria(SearchCriteriaData sc){
		ParamSKU = sc.SKU;
		ParamModel = sc.Model;
		ParamTitle = sc.Title;
		ParamOnlineTitle = sc.OnlineTitle;
		ParamBrand = sc.Brand;
		ParamSupplier = sc.Supplier;
		ParamDepartment = sc.Department;
		ParamDepartmentRange = sc.DepartmentRange;
		ParamProductGroup = sc.ProductGroup;
		ParamProductGroupRange = sc.ProductGroupRange;
		ParamSeasonCode = sc.SeasonCode;
		ParamSeasonCodeRange = sc.SeasonCodeRange;
		ParamCostEx = sc.CostEx;
		ParamCostExRange = sc.CostExRange;
		ParamCostInc = sc.CostInc;
		ParamCostIncRange = sc.CostIncRange;
		ParamTicketPrice = sc.TicketPrice;
		ParamTicketPriceRange = sc.TicketPriceRange;
		ParamSOH = sc.SOH;
		ParamAvailable = sc.Available;
		ParamHasEnrichedContent = sc.HasEnrichedContent;
	}
	
	public string GetSearchUrl(SearchCriteriaData sc, integer pageSize){
		string addTo = GetStringParameter('addTo');
		string pageName = addTo != '' ? 'SelectProductSearch' : 'ProductSearch';
		PageReference page = new PageReference('ProductSearch');
	    page.getParameters().put('lnk', '');
	    if(string.isNotEmpty(sc.SKU)) page.getParameters().put('sku', sc.SKU);
	    if(string.isNotEmpty(sc.Model)) page.getParameters().put('model', sc.Model);
	    if(string.isNotEmpty(sc.Title)) page.getParameters().put('title', sc.Title);
	    if(string.isNotEmpty(sc.OnlineTitle)) page.getParameters().put('ot', sc.OnlineTitle);
	    if(string.isNotEmpty(sc.Brand)) page.getParameters().put('brand', sc.Brand);
	    if(string.isNotEmpty(sc.Supplier)) page.getParameters().put('supplier', sc.Supplier);
	    if(string.isNotEmpty(sc.SOH)) page.getParameters().put('soh', sc.SOH);
	    if(string.isNotEmpty(sc.Department)) page.getParameters().put('dpt', sc.Department);
	    if(string.isNotEmpty(sc.Department) && string.isNotEmpty(sc.DepartmentRange)) page.getParameters().put('dptr', sc.DepartmentRange);
	    if(string.isNotEmpty(sc.ProductGroup)) page.getParameters().put('pg', sc.ProductGroup);
	    if(string.isNotEmpty(sc.ProductGroup) && string.isNotEmpty(sc.ProductGroupRange)) page.getParameters().put('pgr', sc.ProductGroupRange);
	    if(string.isNotEmpty(sc.SeasonCode)) page.getParameters().put('sc', sc.SeasonCode);
	    if(string.isNotEmpty(sc.SeasonCode) && string.isNotEmpty(sc.SeasonCodeRange)) page.getParameters().put('scr', sc.SeasonCodeRange);
	    if(string.isNotEmpty(sc.CostEx)) page.getParameters().put('ce', sc.CostEx);
	    if(string.isNotEmpty(sc.CostEx) && string.isNotEmpty(sc.CostExRange)) page.getParameters().put('cer', sc.CostExRange);
	    if(string.isNotEmpty(sc.CostInc)) page.getParameters().put('ci', sc.CostInc);
	    if(string.isNotEmpty(sc.CostInc) && string.isNotEmpty(sc.CostIncRange)) page.getParameters().put('cir', sc.CostIncRange);
	    if(string.isNotEmpty(sc.TicketPrice)) page.getParameters().put('tp', sc.TicketPrice);
	    if(string.isNotEmpty(sc.TicketPriceRange) && string.isNotEmpty(sc.TicketPrice)) page.getParameters().put('tpr', sc.TicketPriceRange);	    
	    if(sc.Available != null) page.getParameters().put('available', String.valueOf(sc.Available));
	    if(sc.HasEnrichedContent != null) page.getParameters().put('enriched', String.valueOf(sc.HasEnrichedContent));
	    if(string.isNotEmpty(sc.OrderBy)) page.getParameters().put('order', sc.OrderBy);
	    if(string.isNotEmpty(sc.Dir)) page.getParameters().put('dir', sc.Dir);
	    if(pageSize != null && pageSize > 0) page.getParameters().put('rows', String.valueOf(pageSize));
	    
	    // Select Search Product
	    if(addTo != '') page.getParameters().put('addTo', addTo);
	    
	    string url = page.getUrl();
	    //return EncodingUtil.urlEncode(url, 'UTF-8');
	    return url;
	}
	
	private SortUrlData GetSortUrlData(SearchCriteriaData sc){
		SortUrlData sortUrl = new SortUrlData();
		
		string orderBy = sc.OrderBy;
		string dir = sc.Dir;
							
		sc.Dir = GetDirString(orderBy, 'sku', dir);
		sc.OrderBy = 'sku';
		sortUrl.SKU = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'md', dir);
		sc.OrderBy = 'md';
		sortUrl.Model = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'tt', dir);
		sc.OrderBy = 'tt';
		sortUrl.Title = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'des', dir);
		sc.OrderBy = 'des';
		sortUrl.Description = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'pg', dir);
		sc.OrderBy = 'pg';
		sortUrl.ProductGroup = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'ce', dir);
		sc.OrderBy = 'ce';
		sortUrl.CostEx = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'ci', dir);
		sc.OrderBy = 'ci';
		sortUrl.CostInc = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'gc', dir);
		sc.OrderBy = 'gc';
		sortUrl.GoCost = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'tp', dir);
		sc.OrderBy = 'tp';
		sortUrl.TicketPrice = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'pp', dir);
		sc.OrderBy = 'pp';
		sortUrl.PromoPrice = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'c', dir);
		sc.OrderBy = 'sc';
		sortUrl.SeasonCode = GetSearchUrl(sc, sc.Rows);
		
		sc.Dir = GetDirString(orderBy, 'soh', dir);
		sc.OrderBy = 'soh';
		sortUrl.SOH = GetSearchUrl(sc, sc.Rows);
		
		return sortUrl;
	}
	
	private string GetDirString(string orderByParam, string orderBy, string dirParam){
		string dir = '';
		if(orderByParam == orderBy){
			dir = dirParam == Sort_DESC ? Sort_ASC : Sort_DESC;
		}else{
			dir = '';
		}
		return dir;
	}
	
	private string FieldMapping(string name){
		string fieldName = '';
		
		if(name == 'sku') fieldName = 'SKU__c';
		if(name == 'md') fieldName = 'Model__c';
		if(name == 'tt') fieldName = 'Name';
		if(name == 'des') fieldName = 'Description';
		if(name == 'pg') fieldName = 'Product_Group__c';
		if(name == 'ce') fieldName = 'Cost_Ex_GST__c';
		if(name == 'ci') fieldName = 'Cost_Inc_GST__c';
		if(name == 'gc') fieldName = 'Go_Cost__c';
		if(name == 'tp') fieldName = 'Ticket_Price__c';
		if(name == 'pp') fieldName = 'Promotion_Price__c';
		if(name == 'sc') fieldName = 'Season_Code__c';		
		if(name == 'soh') fieldName = 'SOH__c';
		
		return fieldName;
	}
	
	/*------------------------------------------ Select Search Product ------------------------------------------*/
	public PageReference SelectSerachProductInit(){
		string action = GetStringParameter('action'); // addOrderLine,  addProduct,  addQuoteLine
		if(action.toLowerCase() == 'addorderline'){
			string id = GetStringParameter('id');
			Order__c ord = [Select Status__c From Order__c Where Id = :id];
			if(ord.Status__c != null && ord.Status__c.toLowerCase() != 'open'){
				ShowFinalisedMessage = true;
			}
		}
		return null;
	}
	public PageReference SelectProducts(){
 		string action = GetStringParameter('action'); // addOrderLine,  addProduct,  addQuoteLine
		string id = GetStringParameter('id');
		string url = '/apex/MultiLineItem?action=' + action + '&id=' + id + '&ids=' + ParamProductIds;
				
		PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
	}
	public PageReference CancelProducts(){		
 	
		//string retUrl = GetStringParameter('retURL');
		string addTo = GetStringParameter('addTo');
		string url = '/' + addTo;
		
		PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
	}
	
	public class SearchCriteriaData{
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Title {get;set;}
		public string OnlineTitle {get;set;}
		public string Brand {get;set;}
		public string Supplier {get;set;}
		public string Department {get;set;}
		public string DepartmentRange {get;set;}
		public string ProductGroup {get;set;}
		public string ProductGroupRange {get;set;}
		public string SeasonCode {get;set;}
		public string SeasonCodeRange {get;set;}
		public string CostEx {get;set;}
		public string CostExRange {get;set;}
		public string CostInc {get;set;}
		public string CostIncRange {get;set;}
		public string TicketPrice {get;set;}
		public string TicketPriceRange {get;set;}
		public string SOH {get;set;}
		public boolean Available {get;set;}
		public boolean HasEnrichedContent {get;set;}
		public string OrderBy {get;set;}
		public string Dir {get;set;} // asc or desc
		public integer Rows {get;set;} // rows per page
	}
	
	public class SearchResultData{
		public string ID {get;set;}
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Department {get;set;}
		public string Title {get;set;}
		public string Description {get;set;}
		public string ProductGroup {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string GoCost {get;set;}		
		public string TicketPrice {get;set;}
		public string PromoPrice {get;set;}
		public string SeasonCode {get;set;}
		public string SOH {get;set;}
	}
	
	public class SortUrlData{
		public string SKU {get;set;}
		public string Model {get;set;}
		public string Title {get;set;}
		public string Description {get;set;}
		public string ProductGroup {get;set;}
		public string CostEx {get;set;}
		public string CostInc {get;set;}
		public string GoCost {get;set;}		
		public string TicketPrice {get;set;}
		public string PromoPrice {get;set;}
		public string SeasonCode {get;set;}
		public string SOH {get;set;}
	}
	
	public class Validator{
		public boolean InValid {get;set;}
		public boolean InValidSOH {get;set;}
		public boolean InValidCostEx {get;set;}
		public boolean InValidCostInc {get;set;}
		public boolean InValidTicketPrice {get;set;}
	}
}
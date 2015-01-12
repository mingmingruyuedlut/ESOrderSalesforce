public with sharing class SelectDispatchPointController {
	
	//--------------------------- Parameters ----------------------------//
	public string HaHa {get;set;}
	public string StrMul{get;set;}
	public string TotalCount {get;set;}
	public string strDispatchId {get;set;}	
	public string ShowFewerUrl {get;set;}
	public string ShowMoreUrl {get;set;}
	public Set<string> StoreIdSet = new Set<string>();
	public Set<string> DispatchIdList = new Set<string>();
	
	//--------------------------- Bind List ----------------------------//
	public List<OrderLineItem> OrderLineItemList {get; set;}
	public List<ProductModel> ProductList {get; set;}
 	public Map<string, string> StoreIdNameMap = new Map<string, string>();
 	
	//--------------------------- Page Init ----------------------------//
	public PageReference Init(){
		string orderId = ApexPages.currentPage().getParameters().get('id');
		OrderLineItemList = GetOrderLineItems(orderId);
		if(ApexPages.currentPage().getParameters().get('page') != null)
		{
			getInfoFromExternalService();
		}
		return null;
	}
	
	/*------------------------------------------ Order Line Items List ------------------------------------------*/
	public List<OrderLineItem> GetOrderLineItems(string orderId){	
		List<OrderLineItem> lineItemList = new List<OrderLineItem>();		
		List<Order__c> orderList = [Select Id, Order_Number__c, 
									(Select Id, Product__c, SKU__c, Name, Quantity__c, Sales_Price_Inc__c, GP_dollar__c, GP_percent__c, Freight_Method__c, DispatchPoint__c From OrderLineItems__r) 
									From Order__c 
									Where Id =: orderId];					
		ConvertOrderListToLineItemList(lineItemList, orderList);
		List<string> storeIdList = new List<string>();		
		storeIdList.addAll(StoreIdSet);
		GetStoreIdNameMap(storeIdList, StoreIdNameMap);		
		ChangeOrderLineItemListDispatchPointIdToName(StoreIdNameMap, lineItemList);
		return lineItemList;
	}
			 
	public void ConvertOrderListToLineItemList(List<OrderLineItem> lineItemList, List<Order__c> orderList){
		for(Order__c o : orderList){			
			for(OrderLineItem__c oli : o.OrderLineItems__r){				
				string oliLineItemID =  oli.Id != null ? string.valueOf(oli.Id) : '';
				string oliProductID = oli.Product__c != null ? string.valueOf(oli.Product__c) : '';
				string oliSKU = oli.SKU__c != null ? string.valueOf(oli.SKU__c) : '';
				string oliName = oli.Name != null ? string.valueOf(oli.Name) : '';
				string oliQuantity = oli.Quantity__c != null ? string.valueOf(oli.Quantity__c) : '';
				decimal oliSalesPriceInc = oli.Sales_Price_Inc__c != null ? oli.Sales_Price_Inc__c : 0;
				decimal oliGP = oli.GP_dollar__c != null ? oli.GP_dollar__c : 0;
				decimal oliGPPercent = oli.GP_percent__c != null ? oli.GP_percent__c : 0;
				string oliFreightMethod = oli.Freight_Method__c != null ? string.valueOf(oli.Freight_Method__c) : '';
				string oliDispatchPoint = oli.DispatchPoint__c != null ? string.valueOf(oli.DispatchPoint__c) : '';		
				//set DispatchPoint
				StoreIdSet.add(oliDispatchPoint); 				
				OrderLineItem oliInfo = new OrderLineItem(oliLineItemID, oliProductID, oliSKU, oliName, oliQuantity, oliSalesPriceInc, oliGP, oliGPPercent, oliFreightMethod, oliDispatchPoint);
				lineItemList.add(oliInfo);
			}
        }
	}
	
	public void GetStoreIdNameMap(List<string> storeIdList, Map<string, string> storeIdNameMap){
		List<Store__c> storeList = [Select Name, Id From Store__c Where Id =: storeIdList];
		for(Store__c store : storeList){
			storeIdNameMap.put(string.valueOf(store.Id), store.Name);
		}
	}
		
	private void ChangeOrderLineItemListDispatchPointIdToName(Map<string, string> storeIdNameMap, List<OrderLineItem> lineItemList){
		for(OrderLineItem oli : lineItemList){
			if(storeIdNameMap.get(oli.DispatchPoint) != null){
    			oli.DispatchPoint = storeIdNameMap.get(oli.DispatchPoint);
    		}
		}
	}

	/*------------------------------------------ Check Stock Click ------------------------------------------*/
	public pagereference CheckStock(){     			
		getInfoFromExternalService();	
		return null;
    }
    
    //--------------------------- Get Stock Id ----------------------------//
    public void GetPachId(string storeCode)
    {
    	List<Store__c> patchNList = [SELECT Id FROM Store__c WHERE StoreCode__c =: storeCode];
    	
    	//insert data
    	if(patchNList.size() == 0)
    	{   		
    		string url = 'https://corp-services.jbhifi.com.au/dev/api/Store/?apiKey=6EB40261BAF040BFA4F09DFF1B557190';
	        HttpRequest req = new HttpRequest();
	        req.setEndpoint(url);
	        req.setHeader('Content-Type','application/json');
	        req.setMethod('GET');
	        Http h = new Http();
	        HttpResponse res = h.send(req);
	        
	        List<StoreModel> m = (List<StoreModel>)JSON.deserialize(res.getBody(),List<StoreModel>.class);     
	        
	        for(StoreModel s : m)
		    {		
		    	if(s.StoreCode == storeCode)
		    	{
			    	Store__c tbStore = new Store__c(
					Name = s.Name,
					Address1__c = s.Address1,
					Address2__c = s.Address2,
					Phone__c = s.Phone,
					Postcode__c = s.StoreCode,
					State__c = s.State,
					Store_Company__c = s.StoreCompany,
					Suburb__c = s.Suburb,
					StoreCode__c=s.StoreCode
					);
					insert tbStore;
		    	}
		    }	
    	}

		List<Store__c> pList = [SELECT Id FROM Store__c WHERE StoreCode__c =: storeCode];
		for(Store__c o : pList)
		{
			strDispatchId = o.Id;
		}					
    }
    
    //--------------------------- Get Data From WS ----------------------------//
    public HttpResponse getInfoFromExternalService() {  
    	string itemsUrl = '';
    	string checkUrl = '';
    	string id = ApexPages.currentPage().getParameters().get('id');
    	string orderlineid = ApexPages.currentPage().getParameters().get('OrderLineId'); 
    	string selectedSku = ApexPages.currentPage().getParameters().get('SelectedSku');     
    	HaHa = 'start' + orderlineid + '----' + selectedSku;
    	if(selectedSku.contains(';'))
    	{
    		selectedSku = selectedSku.substring(0,selectedSku.length() - 1);
    	} 	
   	 		   	
    	//set webservice url
    	string url = 'https://corp-services.jbhifi.com.au/dev/api/Inventory/';
    	url += selectedSku + '/?';
    	url += 'apiKey=6EB40261BAF040BFA4F09DFF1B557190';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET'); 
        Http h = new Http();
        HttpResponse res = h.send(req);        

        List<ProductModel> m = (List<ProductModel>)JSON.deserialize(res.getBody(),List<ProductModel>.class);     
	    List<ProductModel> pList = new List<ProductModel>();
		TotalCount = string.valueOf(m.size());
		
		//set page	  
	    integer pageSize = 10;
	  	integer j = ApexPages.currentPage().getParameters().get('page') == null ? pageSize : integer.valueOf(ApexPages.currentPage().getParameters().get('page'));     
	    integer listSize = m.size();
	    //set more and fewer button 
	    if(listSize > pageSize)
	    {
	    	integer parms = 0;	    	
	    	if(ApexPages.currentPage().getParameters().get('page') == null)
	    	{
	    		parms = pageSize + pageSize;
	    		//set more url
	    		ShowMoreUrl = 'SelectDispatchPoint?';
	    		ShowMoreUrl += 'id=' + id;
	    		ShowMoreUrl += '&page=' + string.valueOf(parms);
	    		ShowMoreUrl += '&SelectedSku=' + selectedSku;
	    		ShowMoreUrl += '&OrderLineId=' + orderlineid;    		
	    		ShowFewerUrl = '';
	    	}
	    	else
	    	{
	    		parms = integer.valueOf(ApexPages.currentPage().getParameters().get('page'));	    		
	      		if(integer.valueOf(ApexPages.currentPage().getParameters().get('page')) > listSize)
	    		{
	    			ShowMoreUrl = '';
	    		}
	    		else
	    		{
		    		ShowMoreUrl = 'SelectDispatchPoint?';
		    		ShowMoreUrl += 'id=' + id;
		    		ShowMoreUrl += '&page=' + string.valueOf(parms  + pageSize);
		    		ShowMoreUrl += '&SelectedSku=' + selectedSku;
		    		ShowMoreUrl += '&OrderLineId=' + orderlineid;  		
	    		} 
	    		if((parms - pageSize) == 0)
	    		{
	    			ShowFewerUrl = '';
	    		}
	    		else
	    		{
	    			ShowFewerUrl = 'SelectDispatchPoint?';
		    		ShowFewerUrl += 'id=' + id;
		    		ShowFewerUrl += '&page=' + string.valueOf(parms - pageSize);
		    		ShowFewerUrl += '&SelectedSku=' + selectedSku;
		    		ShowFewerUrl += '&OrderLineId=' + orderlineid;  
	    		} 
	    	}	 	    	
	    }
	    else
	    {
	    	ShowMoreUrl = '';
	    }

		integer i = 0;
	    for(ProductModel s : m)
	    {
	    	i = i + 1;
	    	if(i < j + 1)
	    	{
		    	ProductModel model = new ProductModel();
		    	model.StoreName = s.StoreName;
		    	model.OnOrder = s.OnOrder;
		    	model.Quantity = s.Quantity;
		    	model.StockCode = s.StockCode;
		    	model.StoreId = s.StoreId;
		    	model.StoreState = s.StoreState;
		    	pList.add(model);
	    	}
	    }	    
	    ProductList = pList;
        return res;        
    }
    
    //--------------------------- Multiple Selected ----------------------------//
    @RemoteAction
    public static string MultipleShow(string skuArray,string mp,string orderid,string disSelected,string mInfo)
    {
    	string selectedSku = '';
    	List<string> splitList = skuArray.split(';');	   	
    	string itemsUrl = '';
    	string checkUrl = '';
    	
    	//get every sku id
    	for(string s : splitList)
    	{
    		selectedSku = s;
    		itemsUrl += 'item=' + s + '&';
    	}	
    	if(splitList.size() > 1)
    	{
    		 checkUrl = 'Search/?' + itemsUrl;
    	}
    	else
    	{
    		checkUrl = selectedSku + '/?';
    	} 
    			   	
    	//set webservice url
    	string url = 'https://corp-services.jbhifi.com.au/dev/api/Inventory/';
    	url += checkUrl;
    	url += 'apiKey=6EB40261BAF040BFA4F09DFF1B557190';   	
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(url);        
        req.setMethod('GET');
        req.setHeader('Content-Type', 'text/json');       
        Http h = new Http();
        HttpResponse res = h.send(req);  
        
        //get json
        List<ProductModel> arrJson = (List<ProductModel>)JSON.deserialize(res.getBody(),List<ProductModel>.class);  
        integer len = arrJson.size();
		List<ProductModel> myList = new List<ProductModel>();
		for(ProductModel s : arrJson)
	    {
	    	ProductModel model = new ProductModel();
	    	model.StoreName = s.StoreName;
	    	model.StockCode = s.StockCode;
	    	model.StoreId = s.StoreId;
	    	model.StoreState = s.StoreState;
	    	model.Quantity = s.Quantity;
	    	model.OnOrder = s.OnOrder;
	    	myList.add(model);
	    }
	    
	    //set page parameter
	    integer dataRow = splitList.size();
	    integer pageCount = 0;
	    integer pageSize = 10;
	    integer pageNum = 10;	    
	    if(mp != '')
	    {
	    	pageSize = integer.valueOf(mp);
	    }	
	    
	    //start html output    
	    string ouputStr = '';
        ouputStr += '<table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">';        
        string firstColumn = arrJson[0].StoreName;
        integer noRep = 0;
	    for(ProductModel jsonS : arrJson)
	    {
	    	if(jsonS.StoreName != 'Not Defined')
	    	{	    	
		    	if(jsonS.StoreName == firstColumn)
		    	{
		    		noRep = noRep + 1;
		    	}		    	
		    	if(noRep < 2)
		    	{
			    	 integer k = 0;
			    	 for(ProductModel mylistS : myList)
					 {					 	
					    	if(mylistS.StoreName == jsonS.StoreName)
					    	{
					    		if(pageCount < pageSize)
					    		{
					    	
						    		if(k == 0)
						    		{						    			
							    		ouputStr += '<tr class="headerRow"><th class="store" name="mulStockName">' + mylistS.StoreName + '</th><th class="store">' + mylistS.StoreState + '</th><th>Line item name</th><th>QTY</th><th>On order</th><th style="width: 20px;"><input type="checkbox" onclick="MulResultOrderRowClick(this)" /></th></tr>';
				                        ouputStr += '<tr class="dataRow even first"><td class="mulClsSName" style="text-indent:-9999px;" >' + mylistS.StoreName + '</td>';
				                        ouputStr += '<td class="mulClsSId" style="text-indent:-9999px;" >'+mylistS.StoreId+'</td><td class="mulClsSCode">' + mylistS.StockCode + '</td><td>' + mylistS.Quantity + '</td><td>' + mylistS.OnOrder + '</td><td class="hasCheckbox"><input type="radio" name="radioN0" onchange="MulResultOrderLineItemRowClick(this)" /></td></tr>';	    			
						    		}
						    		else
						    		{
						    			string radioName = 'radioN' + k;
						    			ouputStr += '<tr class="dataRow even first"><td class="mulClsSName" style="text-indent:-9999px;">' + mylistS.StoreName + '</td><td class="mulClsSId" style="text-indent:-9999px;" >'+mylistS.StoreId+'</td><td class="mulClsSCode">' + mylistS.StockCode + '</td><td>' + mylistS.Quantity + '</td><td>' + mylistS.OnOrder + '</td><td class="hasCheckbox"><input type="radio" name="' + radioName + '" onchange="MulResultOrderLineItemRowClick(this)" /></td></tr>';						    			
						    		}
						    		k = k+1;
						    		if(k == (dataRow))
						    		{
						    			pageCount = pageCount + 1;
						    		}
					    		}					    					 
					    	}					    	
					 }
		    	}
	    	}
	    } 
	    ouputStr += '</table> ';	
        return ouputStr;                   
    }
    
    public pagereference MultipleClick()
    {
    	string skuArray = ApexPages.currentPage().getParameters().get('allSeletedSku'); 
    	string mp = ApexPages.currentPage().getParameters().get('mulPage'); 
    	string orderid = ApexPages.currentPage().getParameters().get('orderlineId'); 
    	string disSelected = ApexPages.currentPage().getParameters().get('count'); 
    	string mInfo = ApexPages.currentPage().getParameters().get('allMultipleInfo');

    	string selectedSku = '';
    	List<string> splitList = skuArray.split(';');	   	
    	string itemsUrl = '';
    	string checkUrl = '';
    	
    	//get every sku id
    	for(string s : splitList)
    	{
    		selectedSku = s;
    		itemsUrl += 'item=' + s + '&';
    	}	
    	if(splitList.size() > 1)
    	{
    		 checkUrl = 'Search/?' + itemsUrl;
    	}
    	else
    	{
    		checkUrl = selectedSku + '/?';
    	} 
    			   	
    	//set webservice url
    	string url = 'https://corp-services.jbhifi.com.au/dev/api/Inventory/';
    	url += checkUrl;
    	url += 'apiKey=6EB40261BAF040BFA4F09DFF1B557190';   	
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(url);        
        req.setMethod('GET');
        req.setHeader('Content-Type', 'text/json');       
        Http h = new Http();
        HttpResponse res = h.send(req);  
        
        //get json
        List<ProductModel> arrJson = (List<ProductModel>)JSON.deserialize(res.getBody(),List<ProductModel>.class);  
        integer len = arrJson.size();
		List<ProductModel> myList = new List<ProductModel>();
		for(ProductModel s : arrJson)
	    {
	    	ProductModel model = new ProductModel();
	    	model.StoreName = s.StoreName;
	    	model.StockCode = s.StockCode;
	    	model.StoreId = s.StoreId;
	    	model.StoreState = s.StoreState;
	    	model.Quantity = s.Quantity;
	    	model.OnOrder = s.OnOrder;
	    	myList.add(model);
	    }
	    
	    //set page parameter
	    integer dataRow = splitList.size();
	    integer pageCount = 0;
	    integer pageSize = 10;
	    integer pageNum = 10;	    
	    if(mp != '')
	    {
	    	pageSize = integer.valueOf(mp);
	    }	
	    
	    //start html output    
	    string ouputStr = '';
        ouputStr += '<table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">';        
        string firstColumn = arrJson[0].StoreName;
        integer noRep = 0;
	    for(ProductModel jsonS : arrJson)
	    {
	    	if(jsonS.StoreName != 'Not Defined')
	    	{	    	
		    	if(jsonS.StoreName == firstColumn)
		    	{
		    		noRep = noRep + 1;
		    	}		    	
		    	if(noRep < 2)
		    	{
			    	 integer k = 0;
			    	 for(ProductModel mylistS : myList)
					 {					 	
					    	if(mylistS.StoreName == jsonS.StoreName)
					    	{
					    		if(pageCount < pageSize)
					    		{
					    	
						    		if(k == 0)
						    		{						    			
							    		ouputStr += '<tr class="headerRow"><th class="store" name="mulStockName">' + mylistS.StoreName + '</th><th class="store">' + mylistS.StoreState + '</th><th>Line item name</th><th>QTY</th><th>On order</th><th style="width: 20px;"><input type="checkbox" onclick="MulResultOrderRowClick(this)" /></th></tr>';
				                        ouputStr += '<tr class="dataRow even first"><td class="mulClsSName" style="text-indent:-9999px;" >' + mylistS.StoreName + '</td>';
				                        ouputStr += '<td class="mulClsSId" style="text-indent:-9999px;" >'+mylistS.StoreId+'</td><td class="mulClsSCode">' + mylistS.StockCode + '</td><td>' + mylistS.Quantity + '</td><td>' + mylistS.OnOrder + '</td><td class="hasCheckbox"><input type="radio" name="radioN0" onchange="MulResultOrderLineItemRowClick(this)" /></td></tr>';	    			
						    		}
						    		else
						    		{
						    			string radioName = 'radioN' + k;
						    			ouputStr += '<tr class="dataRow even first"><td class="mulClsSName" style="text-indent:-9999px;">' + mylistS.StoreName + '</td><td class="mulClsSId" style="text-indent:-9999px;" >'+mylistS.StoreId+'</td><td class="mulClsSCode">' + mylistS.StockCode + '</td><td>' + mylistS.Quantity + '</td><td>' + mylistS.OnOrder + '</td><td class="hasCheckbox"><input type="radio" name="' + radioName + '" onchange="MulResultOrderLineItemRowClick(this)" /></td></tr>';						    			
						    		}
						    		k = k+1;
						    		if(k == (dataRow))
						    		{
						    			pageCount = pageCount + 1;
						    		}
					    		}					    					 
					    	}					    	
					 }
		    	}
	    	}
	    } 
	    ouputStr += '</table> ';
		StrMul = ouputStr;
		return null;
    }
    
    /*------------------------------------------ Update ------------------------------------------*/
    //--------------------------- Multiple Save Button ----------------------------//
    public pagereference mulbtnUpdate()
    {
    	string stockInfo = ApexPages.currentPage().getParameters().get('StockInfo');   
		string id = ApexPages.currentPage().getParameters().get('id');	
			
		system.debug('0000000001:'+stockInfo);
		
		List<string> splitStock = stockInfo.split(';');
		if(splitStock.size() > 0)
		{
			for(string s : splitStock)
	    	{
	    		List<string> splitDContents = s.split(',');  		
		     	GetPachId(splitDContents[1]);     	   	
			    if(splitDContents[0].endsWith(';')){
			    	splitDContents[0] = splitDContents[0].substring(0, splitDContents[0].length() - 1);
			    }	
			    	    system.debug('0000000002:'+splitDContents[0]);
			   	OrderLineItem__c orderlineModel = [Select Id, DispatchPoint__c From OrderLineItem__c Where Id =: splitDContents[0]];
				orderlineModel.DispatchPoint__c = strDispatchId;
				update orderlineModel;
	    	}		 
		}
    	string url = '/apex/SelectDispatchPoint?id=' +id;
		PageReference page = new PageReference(url);
	    page.setRedirect(true);       
	    return page;
    }
       	  
    //--------------------------- Single Save Button ----------------------------//
    public pagereference btnUpdate(){  
    	string id = ApexPages.currentPage().getParameters().get('id');
    	string storeCode = ApexPages.currentPage().getParameters().get('StockName');     	
    	GetPachId(storeCode);     	   		    
		string orderLineId = ApexPages.currentPage().getParameters().get('OrderLineId'); 
	    if(orderLineId.endsWith(';')){
	    	orderLineId = orderLineId.substring(0, orderLineId.length() - 1);
	    }	    
	   	OrderLineItem__c orderlineModel = [Select Id, DispatchPoint__c From OrderLineItem__c Where Id =: orderLineId];
		orderlineModel.DispatchPoint__c = strDispatchId;
		update orderlineModel;

   		string url = '/apex/SelectDispatchPoint?id=' + id;
		PageReference page = new PageReference(url);
	    page.setRedirect(true);       
	    return page;
    }
    
    
    public pagereference ShowMore(){     			
		string id = ApexPages.currentPage().getParameters().get('id');
    	string orderlineid = ApexPages.currentPage().getParameters().get('OrderLineId'); 
    	string selectedSku = ApexPages.currentPage().getParameters().get('SelectedSku');
    	integer showCount = integer.valueOf(ApexPages.currentPage().getParameters().get('ShowCount'));
   	
    	if(selectedSku.contains(';'))
    	{
    		selectedSku = selectedSku.substring(0,selectedSku.length() - 1);
    	} 
    	
    	string url = 'https://corp-services.jbhifi.com.au/dev/api/Inventory/';
    	url += selectedSku + '/?';
    	url += 'apiKey=6EB40261BAF040BFA4F09DFF1B557190';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET'); 
        Http h = new Http();
        HttpResponse res = h.send(req);        

        List<ProductModel> m = (List<ProductModel>)JSON.deserialize(res.getBody(),List<ProductModel>.class);     
	    
	    
	    List<ProductModel> pList = new List<ProductModel>();

		integer i = 0;
	    for(ProductModel s : m)
	    {
	    	i = i + 1;
	    	if(i < showCount + 1)
	    	{
		    	ProductModel model = new ProductModel();
		    	model.StoreName = s.StoreName;
		    	model.OnOrder = s.OnOrder;
		    	model.Quantity = s.Quantity;
		    	model.StockCode = s.StockCode;
		    	model.StoreId = s.StoreId;
		    	model.StoreState = s.StoreState;
		    	pList.add(model);
	    	}
	    }	    
	    ProductList = pList;   		
		return null;
    }
    	
	/*------------------------------------------ Model ------------------------------------------*/
	public class OrderLineItem{
		public string Id {get;set;}
		public string ProductId {get;set;}
		public string SKU {get;set;}
		public string LineItemName {get;set;}
		public string Quantity {get;set;}
		public decimal SalesPriceInc {get;set;}
		public decimal GP {get;set;}
		public decimal GPPercent {get;set;}
		public string FreightMethod {get;set;}
		public string DispatchPoint {get;set;}
		
		public OrderLineItem(string oliId, string oliProductId, string oliSKU, string oliName, string oliQuantity, decimal oliSalesPriceInc, decimal oliGP, decimal oliGPPercent, string oliFreightMethod, string oliDispatchPoint ){
			Id = oliId;
			ProductId = oliProductId;
			SKU = oliSKU;
			LineItemName = oliName;
			Quantity = oliQuantity;
			SalesPriceInc = oliSalesPriceInc;
			GP = oliGP;
			GPPercent = oliGPPercent;
			FreightMethod = oliFreightMethod;
			DispatchPoint = oliDispatchPoint;
		}
	}
	
	public class ProductModel{
			public string StoreName {get;set;}
			public string StoreState {get;set;}
			public string StoreId {get;set;}
			public string StockCode {get;set;}
			public string Quantity {get;set;}
			public string OnOrder {get;set;}
	}
	
	public class StoreModel{
		public string Address1 {get;set;}
		public string Address2 {get;set;}
		public string Phone {get;set;}
		public string Postcode {get;set;}
		public string State {get;set;}
		public string StoreCode {get;set;}
		public string Suburb {get;set;}
		public string Name {get;set;}	
		public string StoreCompany {get;set;}	
	}		
	
	public class MultipleGroupModel
	{
		public string StoreName {get;set;}
		public List<ProductModel> productList {get;set;}		
	}
	
}
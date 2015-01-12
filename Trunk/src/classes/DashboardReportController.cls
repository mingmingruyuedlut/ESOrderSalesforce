public with sharing class DashboardReportController {
	
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
	
	private List<string> divisionSalesList { get; set; }
	private List<decimal> divisionSales_MTD { get; set; }
	private List<decimal> divisionTarge_MTD { get; set; }
	private List<decimal> divisionSalesGP_MTD { get; set; }
	private List<decimal> divisionTargeGP_MTD { get; set; }
	public string divisionSalesList_JSON { get; set; }
	public string divisionSales_MTD_JSON { get; set; }
	public string divisionTarge_MTD_JSON { get; set; }
	public string divisionSalesGP_MTD_JSON { get; set; }
	public string divisionTargeGP_MTD_JSON { get; set; } 
	public decimal divisionMax { get; set; }
	public decimal divisionGPMax { get; set; }
	
	private List<string> defaultStateList { get; set; }
	private List<string> stateList { get; set; }
	private List<string> tempStateList { get; set; }
	private List<decimal> stateSales_MTD { get; set; }
	private List<decimal> stateTarget_MTD { get; set; }
	private List<decimal> stateSalesGP_MTD { get; set; }
	private List<decimal> stateTargetGP_MTD { get; set; }
	public string stateList_JSON { get; set; }
	public string stateSales_MTD_JSON { get; set; }
	public string stateTarget_MTD_JSON { get; set; }
	public string stateSalesGP_MTD_JSON { get; set; }
	public string stateTargetGP_MTD_JSON { get; set; }
	public decimal stateMax { get; set; }
	public decimal stateGPMax { get; set; }
	
	
	public List<SalesPersonSales> personSalesTop10_MTD { get; set; }
	public List<SalesPersonSales> personSalesTop10_YTD { get; set; }
	
	
	private List<string> salesPersonIdList { get; set; }
	private List<string> salesPersonList { get; set; } 
	private List<string> tempSalesPersonList { get; set; } 
	private List<decimal> personSales_MTD { get; set; }
	private List<decimal> personTarget_MTD { get; set; }
	private List<decimal> personSalesGP_MTD { get; set; }
	private List<decimal> personTargetGP_MTD { get; set; }
	public string salesPersonIdList_JSON { get; set; }
	public string salesPersonList_JSON { get; set; }
	public string personSales_MTD_JSON { get; set; }
	public string personTarget_MTD_JSON { get; set; }
	public string personSalesGP_MTD_JSON { get; set; }
	public string personTargetGP_MTD_JSON { get; set; }
	public decimal personMax { get; set; }
	public decimal personGPMax { get; set; }
	
	
	public List<CustomerSales> accountSalesTop10_MTD { get; set; }
	public List<CustomerSales> accountSalesTop10_YTD { get; set; }

	
	private List<decimal> personFreight { get; set; }
	
	private integer index { get; set; }
	private Set<id> allOwnerIdList { get; set; }
	
	private Map<id, string> userIdAndNameMap { get; set; }
	
	public PageReference Init(){
		//InsertReportGroupInfo();
		//ChangeOrderInfo();
		//ChangeOrderItemInfo();
		//ChangeTargetInfo();
		//ChangeOrderTargetGroupInfo();
		//InitAllVariables();
		//GetDivisionSalesMTD();
		//GetDivisionTargetsMTD();
		//GetStateSalesMTD();
		//GetStateTargetsMTD();
		//GetPersonSalesMTD('Top10');
		//GetPersonSalesYTD('Top10');
		//GetPersonTargetsMTD('Top10');
		//GetAccountSalesMTD('Top10');
		//GetAccountSalesYTD('Top10');
		//ChangeProductInfo();
		//callShopKeeperService();
		//testUpsertMethod();
		return null;
	}
	
	 public void testUpsertMethod() { 
   		
   		List<Store__c> storeList = new List<Store__c>();
        
        Store__c store001 = new Store__c(Name = 'EricSun', Address1__c = 'EricSun', Address2__c = 'EricSun', Phone__c = '03 8530 7333', Postcode__c = '3148', State__c = 'VIC', StoreCode__c = '11111', Store_Company__c = 'JB-HiFi', Suburb__c = 'EricSun suburb');
		Store__c store002 = new Store__c(Name = 'EricSun', Address1__c = 'EricSun', Address2__c = 'EricSun', Phone__c = '03 8530 7333', Postcode__c = '3148', State__c = 'VIC', StoreCode__c = '189', Store_Company__c = 'JB-HiFi', Suburb__c = 'EricSun suburb');
		storeList.add(store001);
        storeList.add(store002);
        system.debug('----00001111----- store list info: ' + storeList);
        try {
	        upsert storeList StoreCode__c;
	    } catch (DmlException e) {
	        system.debug(e.getMessage());
	    }
	}
	
	public void callShopKeeperService() {

	    HttpRequest req = new HttpRequest();
	    HttpResponse res = new HttpResponse();
	    Http http = new Http();
	
	    req.setEndpoint('http://www.thomas-bayer.com/sqlrest/CUSTOMER/18/');
	    req.setMethod('GET');
	    //req.setHeader('Content-Type', 'application/json');
		//req.setHeader('Accept', 'application/json');
	    //req.setBody('');
	    req.setCompressed(true); // otherwise we hit a limit of 32000
	
	    try {
	        res = http.send(req);
	        system.debug('-----000001----- successful response: ' + res);
	        system.debug('-----000001----- successful response string: ' + res.toString());
 			system.debug('-----000001----- successful response STATUS: '+res.getStatus());
 			system.debug('-----000001----- successful response STATUS_CODE: '+res.getStatusCode());
 			system.debug('-----000001----- successful response Content: ' + res.getBody());
	    } catch(System.CalloutException e) {
	        System.debug('-----000002----- Callout error: '+ e);
	        System.debug('-----000003----- failed response:' + res.toString());
	    }
	
	}
	
	private void ChangeProductInfo(){
		List<Product2> productList = [Select p.SKU__c, p.IsActive From Product2 p Where p.SKU__c = '11190001'];
		for(Product2 p : productList){
			p.IsActive = false;
		}
		update productList;
	}
	
	private void ChangeOrderItemInfo(){
		List<OrderLineItem__c> oliList = [Select Id, Close_Date__c From OrderLineItem__c Where Status__c  = 'Closed'];
		List<OrderLineItem__c> finalOLIList = new List<OrderLineItem__c>();
		for(OrderLineItem__c oli : oliList){
			oli.Close_Date__c = datetime.now();
			oli.ByPass_VR__c = true;
			finalOLIList.add(oli);
		}
		update finalOLIList;
	}
	
	private void ChangeTargetInfo(){
		List<Target__c> targetList = [Select Month__c, Id From Target__c];
		List<Target__c> finalTargetList = new List<Target__c>();
		for(Target__c t : targetList){
			t.Month__c = date.today();
			finalTargetList.add(t);
		}
		system.debug('-------000001------' + finalTargetList.size());
		update finalTargetList;
	}
	
	private void ChangeOrderTargetGroupInfo(){
		List<Order_Target_Report_Group__c> groupList = [Select Sales_Month__c, Id From Order_Target_Report_Group__c];
		List<Order_Target_Report_Group__c> finalGroupList = new List<Order_Target_Report_Group__c>();
		for(Order_Target_Report_Group__c g : groupList){
			g.Sales_Month__c = date.today();
			finalGroupList.add(g);
		}
		system.debug('-------000002------' + finalGroupList.size());
		update finalGroupList;
	}
	
	private void InitAllVariables(){
		defaultStateList = new List<string>();
		defaultStateList.add('VIC');
		defaultStateList.add('TAS');
		defaultStateList.add('NSW');
		defaultStateList.add('QLD');
		defaultStateList.add('SA');
		defaultStateList.add('NT');
		defaultStateList.add('WA');
		
		divisionSalesList = new List<string>();
		divisionSales_MTD = new List<decimal>();
		divisionTarge_MTD = new List<decimal>();
		divisionSalesGP_MTD = new List<decimal>();
		divisionTargeGP_MTD = new List<decimal>();
		
		divisionSalesList_JSON = '';
		divisionSales_MTD_JSON = '';
		divisionTarge_MTD_JSON = '';
		divisionSalesGP_MTD_JSON = '';
		divisionTargeGP_MTD_JSON = '';
		
		tempStateList = new List<string>();
		tempSalesPersonList = new List<string>();
		
		userIdAndNameMap = new Map<id, string>();
		
		divisionMax = 0;
		divisionGPMax = 0;
		stateMax = 0;
		stateGPMax = 0;
		personMax = 0;
		personGPMax = 0;
	}
	
	
	private void GetDivisionSalesMTD(){
		boolean displayFlag = false;
		AggregateResult[] divisionSalesResults = new List<AggregateResult>();
		integer monthCount = currentMonth < 7 ? 6 + currentMonth : currentMonth - 6;
		for(integer i = 0; i < monthCount; i++){
			DateTime currentStartDateTime = DateTime.newInstance(fYear, 7 + i, 1, 0, 0, 0);
			DateTime currentEndDateTime = DateTime.newInstance(fYear, 8 + i, 1, 0, 0, 0);
			divisionSalesResults = [Select SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: currentStartDateTime and Close_Date__c <: currentEndDateTime and Status__c = 'Closed'];
													
			if(divisionSalesResults != null && divisionSalesResults.size()>0){
				if((divisionSalesResults[0].get('TotalSales') != null && (decimal)divisionSalesResults[0].get('TotalSales') != 0) || (divisionSalesResults[0].get('TotalGP') != null && (decimal)divisionSalesResults[0].get('TotalGP') != 0) || displayFlag){
					divisionSalesList.add(currentStartDateTime.format('MMMM yyyy'));
					divisionSales_MTD.add(divisionSalesResults[0].get('TotalSales') != null ? (decimal)divisionSalesResults[0].get('TotalSales') : 0);
					divisionSalesGP_MTD.add(divisionSalesResults[0].get('TotalGP') != null ? (decimal)divisionSalesResults[0].get('TotalGP') : 0);
					displayFlag = true;
				}
			}
		}		
		
		for (string d: divisionSalesList){
            divisionSalesList_JSON += '"'+ d +'",';
        }	
		for (decimal d: divisionSales_MTD){
            divisionSales_MTD_JSON += d +',';
            divisionMax = divisionMax < d ? d : divisionMax;
        }
        for (decimal d: divisionSalesGP_MTD){
            divisionSalesGP_MTD_JSON += d +',';
            divisionGPMax = divisionGPMax < d ? d : divisionGPMax;
        }
	}
	
	private void GetDivisionTargetsMTD(){
		boolean displayFlag = false;
		AggregateResult[] divisionTargetResults = new List<AggregateResult>();
		integer monthCount = currentMonth < 7 ? 6 + currentMonth : currentMonth - 6;
		for(integer i = 0; i < monthCount; i++){
			Date currentStartDate = Date.newInstance(fYear, 7 + i, 1);
			Date currentEndDate = Date.newInstance(fYear, 8 + i, 1);
			divisionTargetResults = [Select SUM(Target_Sales__c) TotalSales, SUM(Target_GP__c) TotalGP 
										From Target__c 
										Where Month__c >=: currentStartDate and Month__c <: currentEndDate];
														
			if(divisionTargetResults != null && divisionTargetResults.size()>0){
				if((divisionTargetResults[0].get('TotalSales') != null && (decimal)divisionTargetResults[0].get('TotalSales') != 0) || (divisionTargetResults[0].get('TotalGP') != null && (decimal)divisionTargetResults[0].get('TotalGP') != 0) || displayFlag){
					divisionTarge_MTD.add(divisionTargetResults[0].get('TotalSales') != null ? (decimal)divisionTargetResults[0].get('TotalSales') : 0);
					divisionTargeGP_MTD.add(divisionTargetResults[0].get('TotalGP') != null ? (decimal)divisionTargetResults[0].get('TotalGP') : 0);
					displayFlag = true;
				}
			}
		}
		
		for (decimal d: divisionTarge_MTD){
            divisionTarge_MTD_JSON += d +',';
            divisionMax = divisionMax < d ? d : divisionMax;
        }
        for (decimal d: divisionTargeGP_MTD){
            divisionTargeGP_MTD_JSON += d +',';
            divisionGPMax = divisionGPMax < d ? d : divisionGPMax;
        }
	}
	
	private void GetStateSalesMTD(){
		stateList_JSON = '';
		stateSales_MTD_JSON = '';
		stateSalesGP_MTD_JSON = '';
		stateList = new List<string>();
		stateSales_MTD = new List<decimal>();
		stateSalesGP_MTD = new List<decimal>();

		AggregateResult[] stateSalesResults = [Select Billing_Account__r.BillingState State, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
												From Order__c 
												Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed' and Billing_Account__r.BillingState in: defaultStateList
												GROUP BY Billing_Account__r.BillingState];
		if(stateSalesResults != null && stateSalesResults.size() > 0){
			for(AggregateResult item : stateSalesResults){ 
				stateList.add((string)item.get('State'));
				stateSales_MTD.add(item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0);
				stateSalesGP_MTD.add(item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0);
		    }
		}
		
		for (string d: stateList){
            stateList_JSON += '"'+ d +'",';
        }	
		for (decimal d: stateSales_MTD){
            stateSales_MTD_JSON += '"'+ d +'",';
            stateMax = stateMax < d ? d : stateMax;
        }
        for (decimal d: stateSalesGP_MTD){
            stateSalesGP_MTD_JSON += '"'+ d +'",';
            stateGPMax = stateGPMax < d ? d : stateGPMax;
        }
	}
	
	private void GetStateTargetsMTD(){
		stateTarget_MTD_JSON = '';
		stateTargetGP_MTD_JSON = '';
		stateTarget_MTD = new List<decimal>();
		stateTargetGP_MTD = new List<decimal>();
		
		AggregateResult[] stateTargetResults = [Select Sales_Person__r.State State, SUM(Target_Sales__c) TotalSales, SUM(Target_GP__c) TotalGP 
												From Target__c 
												Where Month__c >=: startDate and Month__c <: endDate and Sales_Person__r.State in: defaultStateList
												GROUP BY Sales_Person__r.State];
		if(stateTargetResults != null && stateTargetResults.size() > 0){
			for(AggregateResult item : stateTargetResults){ 
				tempStateList.add((string)item.get('State'));
				stateTarget_MTD.add(item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0);
				stateTargetGP_MTD.add(item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0);
		    }
		}
		
		stateTarget_MTD = CombineListValueByKey(stateList, tempStateList, stateTarget_MTD);
		stateTargetGP_MTD = CombineListValueByKey(stateList, tempStateList, stateTargetGP_MTD);
		
		for (decimal d: stateTarget_MTD){
            stateTarget_MTD_JSON += '"'+ d +'",';
            stateMax = stateMax < d ? d : stateMax;
        }
        for (decimal d: stateTargetGP_MTD){
            stateTargetGP_MTD_JSON += '"'+ d +'",';
            stateGPMax = stateGPMax < d ? d : stateGPMax;
        }
	}
	
	private List<decimal> CombineListValueByKey(List<string> salesKeyList, List<string> targetKeyList, List<decimal> targetList){
		List<decimal> tempList = new List<decimal>();
		for(string key : salesKeyList){
			boolean contiansFlag = false;
			integer index = 0;
			for(string targetKey : targetKeyList){
				if(key == targetKey){
					contiansFlag = true;
					break;
				}
				else{
					index++;
				}
			}
			if(contiansFlag){
				tempList.add(targetList.get(index));
			}
			else{
				tempList.add(0);
			}
		}
		return tempList;
	}
	
	private void GetPersonSalesMTD(String topType){
		personSalesTop10_MTD = new List<SalesPersonSales>();
		personSales_MTD = new List<decimal>();
		personSalesGP_MTD = new List<decimal>();
		salesPersonList = new List<string>();
		salesPersonIdList = new List<string>();
		
		salesPersonIdList_JSON = '';
		salesPersonList_JSON = '';
		personSales_MTD_JSON = '';
		personSalesGP_MTD_JSON = '';
		
		AggregateResult[] personSalesResults = new List<AggregateResult>();
		if(topType == 'Top10'){
			personSalesResults = [Select Billing_Account__r.OwnerId OwnerId, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.OwnerId
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 2];
		}
		else{
			personSalesResults = [Select Billing_Account__r.OwnerId OwnerId, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.OwnerId
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST];
		}
		
		if(personSalesResults != null && personSalesResults.size() > 0){
			userIdAndNameMap = GetAllSalesPersonNameList(personSalesResults);
		    for(AggregateResult item : personSalesResults){ 
				decimal ts = item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0;
				decimal tgp = item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0;
				personSales_MTD.add(ts);
				personSalesGP_MTD.add(tgp);
				SalesPersonSales currentSPS = new SalesPersonSales(userIdAndNameMap.get((id)item.get('OwnerId')), (string)item.get('OwnerId'), ts, tgp);
				personSalesTop10_MTD.add(currentSPS);
				salesPersonList.add(userIdAndNameMap.get((id)item.get('OwnerId')));
				salesPersonIdList.add((string)item.get('OwnerId'));
		    }
		}
		
		for (string d: salesPersonIdList){
			salesPersonIdList_JSON += '"'+ d +'",';
		}
		for (string d: salesPersonList){
            salesPersonList_JSON += '"'+ d +'",';
        }	
		for (decimal d: personSales_MTD){
            personSales_MTD_JSON += '"'+ d +'",';
            personMax = personMax < d ? d : personMax;
        }
        for (decimal d: personSalesGP_MTD){
            personSalesGP_MTD_JSON += '"'+ d +'",';
            personGPMax = personGPMax < d ? d : personGPMax;
        }
	}
	
	private void GetOwnerIdPamarater(AggregateResult[] results){
		allOwnerIdList = new Set<id>();
		if(results != null && results.size() > 0){
			for(AggregateResult item : results){ 
				allOwnerIdList.add((id)item.get('OwnerId'));
		    }
		}
	}
	
	private Map<id, string> GetAllSalesPersonNameList(AggregateResult[] results){
		Map<id, string> currentMap = new Map<id, string>();
		GetOwnerIdPamarater(results);
	    User[] userArray = [Select Id, Name From User Where Id in: allOwnerIdList];
	    if(userArray != null && userArray.size() > 0){
	    	for(User item : userArray ){
	    		currentMap.put((id)item.Id, item.Name);
	    	}
	    }
	    return currentMap;
	}
	
	private void GetPersonSalesYTD(String topType){
		personSalesTop10_YTD = new List<SalesPersonSales>();
		
		AggregateResult[] personSalesResults = new List<AggregateResult>();
		if(topType == 'Top10'){
			personSalesResults = [Select Billing_Account__r.OwnerId OwnerId, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.OwnerId
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 2];
		}
		else{
			personSalesResults = [Select Billing_Account__r.OwnerId OwnerId, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.OwnerId
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST];
		}
		if(personSalesResults != null && personSalesResults.size() > 0){
		    userIdAndNameMap = GetAllSalesPersonNameList(personSalesResults);
		    for(AggregateResult item : personSalesResults){ 
				decimal ts = item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0;
				decimal tgp = item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0;
				SalesPersonSales currentSPS = new SalesPersonSales(userIdAndNameMap.get((id)item.get('OwnerId')), (string)item.get('OwnerId'), ts, tgp);
				personSalesTop10_YTD.add(currentSPS);
		    }
		}
	}
	
	
	private void GetPersonTargetsMTD(String topType){
		personTarget_MTD = new List<decimal>();
		personTargetGP_MTD = new List<decimal>();
		personTarget_MTD_JSON = '';
		personTargetGP_MTD_JSON = '';
		
		AggregateResult[] personSalesResults = new List<AggregateResult>();
		if(topType == 'Top10'){
			personSalesResults = [Select Sales_Person__r.Id OwnerId, Sales_Person__r.Name PersonName, SUM(Target_Sales__c) TotalSales, SUM(Target_GP__c) TotalGP 
									From Target__c 
									Where Month__c >=: startDate and Month__c <: endDate
									GROUP BY Sales_Person__r.Id, Sales_Person__r.Name
									ORDER BY SUM(Target_Sales__c) DESC NULLS LAST LIMIT 2];
		}
		else{
			personSalesResults = [Select Sales_Person__r.Id OwnerId, Sales_Person__r.Name PersonName, SUM(Target_Sales__c) TotalSales, SUM(Target_GP__c) TotalGP 
									From Target__c 
									Where Month__c >=: startDate and Month__c <: endDate
									GROUP BY Sales_Person__r.Id, Sales_Person__r.Name
									ORDER BY SUM(Target_Sales__c) DESC NULLS LAST];
		}
		
		if(personSalesResults != null  && personSalesResults.size() > 0){
			userIdAndNameMap = GetAllSalesPersonNameList(personSalesResults);
			for(AggregateResult item : personSalesResults){ 
				decimal ts = item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0;
				decimal tgp = item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0;
				personTarget_MTD.add(ts);
				personTargetGP_MTD.add(tgp);
				tempSalesPersonList.add(userIdAndNameMap.get((id)item.get('OwnerId')));
		    }
		}
		
		personTarget_MTD = CombineListValueByKey(salesPersonList, tempSalesPersonList, personTarget_MTD);
		personTargetGP_MTD = CombineListValueByKey(salesPersonList, tempSalesPersonList, personTargetGP_MTD);
		
		for (decimal d: personTarget_MTD){
            personTarget_MTD_JSON += '"'+ d +'",';
            personMax = personMax < d ? d : personMax;
        }
        for (decimal d: personTargetGP_MTD){
            personTargetGP_MTD_JSON += '"'+ d +'",';
            personGPMax = personGPMax < d ? d : personGPMax;
        }
	}
	
	
	private void GetAccountSalesMTD(String topType){
		accountSalesTop10_MTD = new List<CustomerSales>();
		AggregateResult[] customerSalesResults = new List<AggregateResult>();
		if(topType == 'Top10'){
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 2];
		}
		else if(topType == 'Top50'){
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 50];
		}
		else{
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: startDateTime and Close_Date__c <: endDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST];
		}
		
		
		if(customerSalesResults != null && customerSalesResults.size() > 0){
			for(AggregateResult item : customerSalesResults){ 
				decimal ts = item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0;
				decimal tgp = item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0;
				CustomerSales currentCS = new CustomerSales((string)item.get('AccountName'), (string)item.get('AccountId'), ts, tgp);
				accountSalesTop10_MTD.add(currentCS);
		    }   
		}
	
	}
	
	private void GetAccountSalesYTD(String topType){
		accountSalesTop10_YTD = new List<CustomerSales>();
		AggregateResult[] customerSalesResults = new List<AggregateResult>();
		if(topType == 'Top10'){
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 2];
		}
		else if(topType == 'Top50'){
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST LIMIT 50];
		}
		else{
			customerSalesResults = [Select Billing_Account__r.Id AccountId, Billing_Account__r.Name AccountName, SUM(Total_Price_Inc__c) TotalSales, SUM(Total_GP_dollar__c) TotalGP 
									From Order__c 
									Where Close_Date__c >=: fyStartDateTime and Close_Date__c <: fyEndDateTime and Status__c = 'Closed'
									GROUP BY Billing_Account__r.Id, Billing_Account__r.Name
									ORDER BY SUM(Total_Price_Inc__c) DESC NULLS LAST];
		}
		
		if(customerSalesResults != null && customerSalesResults.size() > 0){
			for(AggregateResult item : customerSalesResults){ 
				decimal ts = item.get('TotalSales') != null ? (decimal)item.get('TotalSales') : 0;
				decimal tgp = item.get('TotalGP') != null ?(decimal)item.get('TotalGP') : 0;
				CustomerSales currentCS = new CustomerSales((string)item.get('AccountName'), (string)item.get('AccountId'), ts, tgp);
				accountSalesTop10_YTD.add(currentCS);
		    }
		}
	}
	
	
	public pagereference LoadAllAccount(){
        string topType = ApexPages.currentPage().getParameters().get('topType'); 
        string timeType = ApexPages.currentPage().getParameters().get('timeType'); 
        if(timeType == 'MTD'){
        	GetAccountSalesMTD(topType);
        }
        else{
        	GetAccountSalesYTD(topType);
        }
        return null;
    }
    
    public pagereference LoadAllSalespeople(){
        string topType = ApexPages.currentPage().getParameters().get('topType'); 
        string timeType = ApexPages.currentPage().getParameters().get('timeType'); 
        if(timeType == 'MTD'){
        	GetPersonSalesMTD(topType);
        	GetPersonTargetsMTD(topType);
        }
        else{
        	GetPersonSalesYTD(topType);
        }
        return null;
    }
	
	
	public class CustomerSales implements Comparable{
        public string AccountName {get;set;}
        public string AccountId {get;set;}
        public decimal TotalSales {get;set;}
        public decimal TotalGP {get;set;}
        
        public CustomerSales(string name, string id, decimal sales, decimal gp){
          AccountName = name;
          AccountId = id;
          TotalSales = sales;
          TotalGP = gp;
        }
       
        public Integer compareTo(Object objToCompare){
    		return (((CustomerSales)objToCompare).TotalSales - TotalSales).intValue();
    	}
     
     }
     
     public class SalesPersonSales implements Comparable{
        public string OwnerName {get;set;}
        public string OwnerId {get;set;}
        public decimal TotalSales {get;set;}
        public decimal TotalGP {get;set;}
        
        public SalesPersonSales(string name, string id, decimal sales, decimal gp){
          OwnerName = name;
          OwnerId = id;
          TotalSales = sales;
          TotalGP = gp;
        }
       
        public Integer compareTo(Object objToCompare){
    		return (((SalesPersonSales)objToCompare).TotalSales - TotalSales).intValue();
    	}
     
     }
}
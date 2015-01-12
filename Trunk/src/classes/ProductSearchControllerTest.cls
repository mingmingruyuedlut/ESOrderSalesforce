/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (seeAllData=true)
private class ProductSearchControllerTest {

    static testMethod void myUnitTest() {
        // Setup        
        User owner = [Select Id, Name From User limit 1];
        Account account = [Select Id, Name From Account limit 1];
        
        Product2 myProduct = new Product2(
        	Name = 'product',
        	SKU__c = 'E21191AE067422712339',
        	Model__c = 'model',
        	Manufacturer__c = 'manufacturer',
        	Description = 'description',
        	IsActive = true,
        	Ticket_Price__c = 10,
        	Supplier__c = 'supplier',
        	Short_Description__c = 'short description',
        	Season_Code__c = 'Q',
        	SOH__c = 20,
        	Promotion_Price__c = 10,
        	Product_Group__c = 'group1',
        	Online__c = false,
        	Online_Title__c = 'online tilte',
        	Long_Description__c = 'Long_Description',
        	Floor_Price__c = 10,
        	Department__c = 'Department',
        	Cost_Inc_GST__c = 10.1,
        	Cost_Ex_GST__c  = 10 	
        );
        insert myProduct;       
        
        Order__c myOrder = new Order__c();
		myOrder.Total_Price_Inc__c = 195;
		myOrder.Name = 'my order';
		myOrder.OwnerId = owner.Id;
		myOrder.Billing_Account__c = account.Id;
		myOrder.Sending_Account__c = account.Id;
		myOrder.Order_Notes__c = 'notes';
		myOrder.Status__c = 'Finalised';
		myOrder.ByPass_VR__c = true;
		myOrder.Create_Date__c = Date.today();		
		insert myOrder; 
                
        PageReference pageRef = Page.ProductSearch;
        Test.setCurrentPage(pageRef);	        
        
        ProductSearchController controller = new ProductSearchController();
        //controller.SearchCriteria = controller.GetSearchCriteriaData();        
        //PageReference p = controller.Search();
        
        List<string> departments = Common.GetPicklistValues('Product2', 'Department__c');
        List<string> productGroups = Common.GetPicklistValues('Product2', 'Product_Group__c');
        List<string> seasonCodes = Common.GetPicklistValues('Product2', 'Season_Code__c');
        system.assert(departments.size() == controller.DepartmentList.size());
        system.assert(productGroups.size() == controller.ProductGroupList.size());
        system.assert(seasonCodes.size() == controller.SeasonCodeList.size());
        system.assert(controller.Region1List.size() == 2);
        system.assert(controller.Region2List.size() == 3);
        
        //--------------------- url ---------------------//
        pageRef.getParameters().put('lnk', '');
        pageRef.getParameters().put('sku', myProduct.SKU__c);
        pageRef.getParameters().put('md', myProduct.Model__c);
        pageRef.getParameters().put('tt', myProduct.Name);
        pageRef.getParameters().put('pg', myProduct.Product_Group__c);
        pageRef.getParameters().put('pgr', 'eq');
        pageRef.getParameters().put('ce', string.valueOf(myProduct.Cost_Ex_GST__c));
    	pageRef.getParameters().put('cer', 'eq');
        pageRef.getParameters().put('ci', string.valueOf(myProduct.Cost_Inc_GST__c));
    	pageRef.getParameters().put('cir', 'eq');
        pageRef.getParameters().put('tp', string.valueOf(myProduct.Ticket_Price__c));
    	pageRef.getParameters().put('tpr', 'eq');
        pageRef.getParameters().put('soh', string.valueOf(myProduct.SOH__c));
        pageRef.getParameters().put('sc', string.valueOf(myProduct.Season_Code__c));        
        pageRef.getParameters().put('available', 'false');             
               	     
	    string url = '/apex/productsearch?available=false&ce=' + string.valueOf(myProduct.Cost_Ex_GST__c)
	    				+ '&cer=eq&ci=' + string.valueOf(myProduct.Cost_Inc_GST__c) + '&cir=eq&lnk=&md=' + myProduct.Model__c 
	    				+ '&pg=' + myProduct.Product_Group__c + '&pgr=eq&sc=' + myProduct.Season_Code__c + '&sku=' + myProduct.SKU__c 
	    				+ '&soh=' + string.valueOf(myProduct.SOH__c) + '&tp=' + string.valueOf(myProduct.Ticket_Price__c) 
	    				+ '&tpr=eq&tt=' + myProduct.Name;
	    				
		controller.SearchCriteria = controller.GetSearchCriteriaData(); 
		
	    // assert 
        system.debug('========================== url search ==========================');
        system.assert(controller.SearchCriteria.SKU == myProduct.SKU__c);
        system.assert(pageRef.getUrl() == url);  				
	    				
	    //--------------------- Form ---------------------//				
	    controller.ParamSKU = myProduct.SKU__c;
        controller.ParamModel = myProduct.Model__c;
        controller.ParamTitle = myProduct.Name;
        controller.ParamBrand = myProduct.Manufacturer__c;
        controller.ParamProductGroup = myProduct.Product_Group__c;
        controller.ParamProductGroupRange = 'eq';
        controller.ParamCostEx = string.valueOf(myProduct.Cost_Ex_GST__c);
    	controller.ParamCostExRange = 'eq';
        controller.ParamCostInc = string.valueOf(myProduct.Cost_Inc_GST__c);
    	controller.ParamCostIncRange = 'eq';
        controller.ParamTicketPrice = string.valueOf(myProduct.Ticket_Price__c);
    	controller.ParamTicketPriceRange = 'eq';
    	controller.ParamSeasonCode = 'Q';
    	controller.ParamSeasonCodeRange = 'eq';
        controller.ParamAvailable = false;	 
        controller.ParamSOH = string.valueOf(myProduct.SOH__c);				
	    
	    				
	    PageReference p = controller.Search();
	    				
        // assert  
        system.assert(controller.SearchResultsList.size() == 1);
        system.assert(controller.SearchResultsList[0][0].SKU == myProduct.SKU__c);
        
        
        //--------------------- Select Search Product ---------------------//   
        pageRef.getParameters().put('action', 'addOrderLine');
        pageRef.getParameters().put('addTo', myOrder.Id);
        pageRef.getParameters().put('id', myOrder.Id);
        controller.ParamProductIds = myProduct.Id;
        controller.SelectSerachProductInit();
        PageReference p2 = controller.SelectProducts();
        PageReference p3 = controller.CancelProducts();
        
        // assert
        system.debug('========================== Select Search ==========================');
        system.debug(p2.getUrl());
        system.assert(controller.ShowFinalisedMessage == true);
        system.assert(p2.getUrl() == '/apex/MultiLineItem?action=addOrderLine' + '&id=' + myOrder.Id + '&ids=' + myProduct.Id);  
        system.assert(p3.getUrl() == '/' + myOrder.Id);
        
    }
}
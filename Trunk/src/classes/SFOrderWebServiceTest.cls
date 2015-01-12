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
@isTest(SeeAllData = true)
private class SFOrderWebServiceTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // insert test data
		Account account001 = new Account(
			Name = 'Test Account 00000001',
			AccountNumber = '00001',
			ABN__c = '11',
			Auto_Email_Invoice__c = true,
			Credit_Type__c = 'Cash',
			GP_ID__c = '22',
			PPSR__c = '33',
			VIP_Number__c = '44',
			Account_Contact__c = '55',
			Phone = '66',
			Fax = '77',
			Email__c = '88@163.com',
			BillingStreet = '003',
			BillingCity  = '003',
			BillingPostalCode = '003',
			BillingState = '003',
			BillingCountry = '003',
			ShippingStreet = '003',
			ShippingCity = '003',
			ShippingPostalCode = '003',
			ShippingState = '003',
			ShippingCountry = '003'
		);
		insert account001;
        system.assert(account001.id != null);
        
        Product2 product001 = new Product2(
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
        insert product001;
        system.assert(product001.id != null);

        Order__c order001 = new Order__c();
		order001.Total_Price_Inc__c = 195;
		order001.Name = 'order001';
		order001.OwnerId = u.Id;
		order001.Billing_Account__c = account001.Id;
		order001.Sending_Account__c = account001.Id;
		order001.Order_Notes__c = 'notes';
		order001.Status__c = 'Open';
		order001.Create_Date__c = Date.today();
		order001.Total_Price_Inc__c = 1000;
		order001.Reference_Number_1__c = 'reference number 001';
		order001.Reference_Number_2__c = 'reference number 002';
		order001.Delivery_Notes__c = 'delivery notes';
		order001.PaymentMethod__c = 'PayInStore';
		insert order001;
		system.assert(order001.id != null);
		
		Store__c store001 = new Store__c( Name = 'store001', StoreCode__c = 'store code' ); 
		insert store001;
		system.assert(store001.id != null);

		OrderLineItem__c oli001 = new OrderLineItem__c();
		oli001.Product__c = product001.Id;
		oli001.Order__c = order001.Id;
		oli001.Sales_Price_Inc__c = 200;
		oli001.Total_Price_Inc__c = 195;
		oli001.Quantity__c = 2;
		oli001.DispatchPoint__c = store001.Id;
		oli001.Freight_Method__c = 'Pickup';
		oli001.Status__c = 'Open';
		oli001.SKU__c = 'A21191AE067422712339';
		oli001.Name = 'order line item 001';
		oli001.Cost_Inc__c = 1000;
		oli001.Cost_Ex__c = 1000;
		insert oli001;
		system.assert(oli001.id != null);
		
		order001.ByPass_VR__c = true;
		order001.Status__c = 'Finalised';
		update order001;
		system.assert(order001.id != null);
		
		//----------- SFOrderWebService.Order Test Data -----------//
		
		List<SFOrderWebService.Order> sfOrderList = new List<SFOrderWebService.Order>();
		
		SFOrderWebService.CustomerBillingAddress cba = new SFOrderWebService.CustomerBillingAddress('0', '0', '0', '0', '0');
		SFOrderWebService.CustomerShippingAddress csa = new SFOrderWebService.CustomerShippingAddress('1', '1', '1', '1', '1');
		SFOrderWebService.Customer c = new SFOrderWebService.Customer('Test Account 00000001', null, '11', 'true', 'Cash', '11', '11', '11', '11', '11', '11', '11@163.com', cba, csa);
		SFOrderWebService.EndCustomer ec = new SFOrderWebService.EndCustomer('22', '22', '22', '22', '22@163.com', '22', '22', '22', '22', '22', '22', '22');
		
		List<SFOrderWebService.OrderLineItem> sfOLIList = new List<SFOrderWebService.OrderLineItem>();
		List<string> invoiceNumberList = new List<string>();
		invoiceNumberList.add('3');
		SFOrderWebService.OrderLineItem sfOLI001 = new SFOrderWebService.OrderLineItem('a01O0000007yh7NIAQ', 'A21191AE067422712339', 'title', '3', '3', '3', '3', null, '3', 'Closed', ' ', invoiceNumberList);
		sfOLIList.add(sfOLI001);
		
		SFOrderWebService.Order sfOrder001 = new SFOrderWebService.Order('4', '4', '4', '4', ' ', '4', '4', '4', '4', '4', '4', ' ', c, ec, sfOLIList);
		
		sfOrderList.add(sfOrder001);
		
		
		//----------- SFOrderWebService.Order Test Data -----------//
		
		
        // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            // test GetNewOrders function
            List<SFOrderWebService.Order> orderList = SFOrderWebService.GetNewOrders(0);
            
            // test ConvertOrderInfoToOrderObj and ConvertOrderObjToOrderInfo functions
            List<Order__c> orderCList = new List<Order__c>();
            List<OrderLineItem__c> oliCList = new List<OrderLineItem__c>();
            SFOrderWebService.ConvertOrderInfoToOrderObj(sfOrderList, orderCList, oliCList);
            SFOrderWebService.ConvertOrderObjToOrderInfo(sfOrderList, orderCList);
            
            // test UpdateOrders function
            List<SFOrderWebService.Order> updateOrderList = new List<SFOrderWebService.Order>();
            if(orderList.size() > 0){
            	updateOrderList.add(orderList[0]);
            }
            SFOrderWebService.UpdateOrders(updateOrderList);
            
            // end test
            Test.stopTest();
        }
    }
}
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
private class ProFormaInvoiceControllerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // insert a billing customer account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.ABN__c = 'ABN';
        testAccount.BillingStreet = 'Billing Street';
        testAccount.BillingCity = 'Billing City';
        testAccount.BillingPostalCode = 'Billing Postal Code';
        testAccount.BillingState = 'Billing State';
        insert testAccount;
        system.assert(testAccount.id != null);
        
        // insert test order
		Order__c testOrder001 = new Order__c();
		testOrder001.Order_Number__c = 'number_001';
		testOrder001.Total_Price_Inc__c = 1000;
		testOrder001.Total_Price_Ex__c = 100;
		testOrder001.Billing_Account__c = testAccount.id;
		testOrder001.First_Name__c = 'first name 001';
		testOrder001.Last_Name__c = 'last name 0011';
		testOrder001.Phone__c = '123456';
		testOrder001.Address_1__c = 'Address1';
		testOrder001.Address_2__c = 'Address1';
		testOrder001.Address_3__c = 'Address1';
		testOrder001.Suburb__c = 'suburb';
		testOrder001.Postcode__c = 'post code';
		testOrder001.State__c = 'state';
		testOrder001.ByPass_VR__c = true;
		insert testOrder001;
        system.assert(testOrder001.id != null);
		
		Order__c testOrder002 = new Order__c();
		testOrder002.Order_Number__c = 'number_002';
		testOrder002.Billing_Account__c = testAccount.id;
		testOrder002.First_Name__c = 'first name 002';
		testOrder002.Last_Name__c = 'last name 002';
		testOrder002.Phone__c = '123456';
		testOrder002.Address_1__c = 'Address1';
		testOrder002.Address_2__c = 'Address1';
		testOrder002.Address_3__c = 'Address1';
		testOrder002.Suburb__c = 'suburb';
		testOrder002.Postcode__c = 'post code';
		testOrder002.State__c = 'state';
		testOrder002.ByPass_VR__c = true;
		insert testOrder002;
        system.assert(testOrder002.id != null);
		
		// insert test product
		Product2 testProduct001 = new Product2();
		testProduct001.Cost_Ex_GST__c = 1000;
		testProduct001.Cost_Inc_GST__c = 2000;
		testProduct001.Name = 'test product001';
		testProduct001.Model__c = 'Model';
		testProduct001.SKU__c = 'E21191AE067422712339';
		testProduct001.Ticket_Price__c = 123;
		insert testProduct001;
        system.assert(testProduct001.id != null);
		
		// insert test order line item (ps: many other fields are setted value in OrderLineItemTrigger)
		OrderLineItem__c testOrderLineItem001 = new OrderLineItem__c();
		testOrderLineItem001.Order__c = testOrder001.id;
		testOrderLineItem001.Name = 'order line item001';
		testOrderLineItem001.Quantity__c = 10;
		testOrderLineItem001.Sales_Price_Inc__c = 1000;
		testOrderLineItem001.ByPass_VR__c = true;
		testOrderLineItem001.Product__c = testProduct001.Id;
		insert testOrderLineItem001;
        system.assert(testOrderLineItem001.id != null);
		
		OrderLineItem__c testOrderLineItem002 = new OrderLineItem__c();
		testOrderLineItem002.Order__c = testOrder002.id;
		testOrderLineItem002.Name = 'order line item002';
		testOrderLineItem002.Quantity__c = 10;
		testOrderLineItem002.Sales_Price_Inc__c = 2000;
		testOrderLineItem002.ByPass_VR__c = true;
		testOrderLineItem002.Product__c = testProduct001.Id;
		insert testOrderLineItem002;
        system.assert(testOrderLineItem002.id != null);
		
		
         // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
          	Test.setCurrentPage(Page.ProFormaInvoice);
          
          	ProFormaInvoiceController con = new ProFormaInvoiceController();
	        string InvoiceDate = con.InvoiceDate;
          
          	//test order 001
          	ApexPages.currentPage().getParameters().put('id',testOrder001.id);
          	con.Init();
          	//test order 002
          	ApexPages.currentPage().getParameters().put('id',testOrder002.id);
          	con.Init();
            
            // end test
            Test.stopTest();
        }
    }
}
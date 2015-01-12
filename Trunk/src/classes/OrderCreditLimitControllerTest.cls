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
@isTest
private class OrderCreditLimitControllerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
     // insert test data
		Account account001 = new Account(
			Name = 'Test Account 0101',
			AccountNumber = 'IN1200047',
			Credit_Type__c = 'Account'
		);
		insert account001;
        system.assert(account001.id != null);
                
		Order__c myOrder = new Order__c(
			Total_Price_Inc__c = 195,
			Name = 'my order',
			Billing_Account__c = account001.Id,
			Sending_Account__c = account001.Id,
			Order_Notes__c = 'notes',
			Status__c = 'Open',
			Create_Date__c = Date.today()
        );		
		insert myOrder;
        system.assert(myOrder.Id != null);
        
        // run test as current test user
        system.runAs(u){     
        	// start test
            Test.startTest();         
            // This causes a fake response to be generated
          	Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            Test.setCurrentPage(Page.OrderCreditLimit);            
            ApexPages.StandardController sc = new ApexPages.StandardController(myOrder);                 
          	OrderCreditLimitController con = new OrderCreditLimitController(sc);         
            //test the constructor contains multiple parameters
          	OrderCreditLimitController.CreditLimitInfo testCLI = new OrderCreditLimitController.CreditLimitInfo('111', 1111.00, 1111.00, 1111.00);         	
            //end test
            Test.stopTest();
        }
    }
   
    private class WebServiceMockImpl implements WebServiceMock
	{
	    public void doInvoke(
	    	Object stub, Object request, Map<String, Object> response,
	        String endpoint, String soapAction, String requestName,
	        String responseNS, String responseName, String responseType){
	        if(request instanceof ITVDataFeedService.Feed_element)
	          {
	          // generate the fake data to test
	        	ITVDataFeedService.FeedResponse_element feedRes = new ITVDataFeedService.FeedResponse_element();
	        	ITVDataFeedService.ArrayOfArrayOfNV aaOfNV = new ITVDataFeedService.ArrayOfArrayOfNV();	        	 
	        	ITVDataFeedService.ArrayOfNV aOfNV = new ITVDataFeedService.ArrayOfNV();	        	
	        	ITVDataFeedService.NV nvCustomerID = new ITVDataFeedService.NV();
	        	nvCustomerID.N = 'CustomerID';
	        	nvCustomerID.V = 'IN1200047';
	        		        	
	        	ITVDataFeedService.NV nvCreditLimit = new ITVDataFeedService.NV();
	        	nvCreditLimit.N = 'CreditLimit';
	        	nvCreditLimit.V = '1000.11';
	        	
	        	ITVDataFeedService.NV nvAvailableCredit = new ITVDataFeedService.NV();
	        	nvAvailableCredit.N = 'AvailableCredit';
	        	nvAvailableCredit.V = '1000.11';
	        	
	        	ITVDataFeedService.NV nvBalance = new ITVDataFeedService.NV();
	        	nvBalance.N = 'Balance';
	        	nvBalance.V = '1000.11';
	        	
	        	ITVDataFeedService.NV[] nvArray = new ITVDataFeedService.NV[] { nvCustomerID, nvCreditLimit, nvAvailableCredit, nvBalance };	        	
	        	aOfNV.NV = nvArray;	        	
	        	ITVDataFeedService.ArrayOfNV[] aOfNVArray = new ITVDataFeedService.ArrayOfNV[] { aOfNV };	        	
	        	aaOfNV.ArrayOfNV = aOfNVArray;	        	
	        	feedRes.FeedResult = aaOfNV;
	        	response.put('response_x', feedRes);	          
	          }  
	    }
	}
}
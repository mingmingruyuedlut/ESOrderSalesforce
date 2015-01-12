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
private class DashboardReportDetailControllerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // to do insert test data
        u.State = 'VIC';
        update u;
        
        // insert test data
		Account testAcctount = new Account(
			Name = 'Test Account',
			BillingState = 'VIC',
			OwnerId = u.id
		);
		insert testAcctount;
		system.assert(testAcctount.id != null);
		
		Order__c testOrder = new Order__c(
			Name = 'Test Order',
			Billing_Account__c = testAcctount.Id,
			Total_Price_Inc__c = 80000,
			Total_GP_dollar__c = 80000,
			Close_Date__c = datetime.now(),
			Status__c = 'Closed',
		    ByPass_VR__c = true
		);
		insert testOrder;
		system.assert(testOrder.id != null);
        
        Target__c testTarget = new Target__c(
        	Name = 'Test Target',
        	Sales_Person__c = u.id,
        	Month__c = date.today(),
        	Target_Sales__c = 100000,
        	Target_GP__c = 100000
        );
        
        insert testTarget;
		system.assert(testTarget.id != null);
        
        // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
          
			Test.setCurrentPage(Page.DashboardReportDetail);
          	
          	// test Init function
          	DashboardReportDetailController con = new DashboardReportDetailController();
          	ApexPages.currentPage().getParameters().put('oid',u.id);
          	ApexPages.currentPage().getParameters().put('timetype','MTD');
	        con.Init();
          	ApexPages.currentPage().getParameters().put('timetype','YTD');
	        con.Init();
	        
	        ApexPages.currentPage().getParameters().put('oid','');
	        ApexPages.currentPage().getParameters().put('aid',testAcctount.id);
	        ApexPages.currentPage().getParameters().put('timetype','MTD');
	        con.Init();
            ApexPages.currentPage().getParameters().put('timetype','YTD');
	        con.Init();
            
            ApexPages.currentPage().getParameters().put('aid','');
            ApexPages.currentPage().getParameters().put('type','ds');
            ApexPages.currentPage().getParameters().put('month',string.valueOf(date.today().month()));
            ApexPages.currentPage().getParameters().put('year',string.valueOf(date.today().year()));
            con.Init();
            
            ApexPages.currentPage().getParameters().put('type','ss');
            ApexPages.currentPage().getParameters().put('state','VIC');
            con.Init();
            
            ApexPages.currentPage().getParameters().put('type','sps');
            ApexPages.currentPage().getParameters().put('person',u.id);
            ApexPages.currentPage().getParameters().put('timetype','MTD');
            con.Init();
            
            ApexPages.currentPage().getParameters().put('type','sps');
            ApexPages.currentPage().getParameters().put('person',u.id);
            ApexPages.currentPage().getParameters().put('timetype','YTD');
            con.Init();
            
            // end test
            Test.stopTest();
        }
    }
}
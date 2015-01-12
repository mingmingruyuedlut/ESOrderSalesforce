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
private class CreateProFormaInvoiceControllerTest {

    static testMethod void myUnitTest() {
         // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // insert test data
		Account testAcctount = new Account(
			Name = 'Test Account',
			Email__c = 'nelson.wu@fabricgroup.com.au',
			Account_Contact__c = 'someone'
		);
		insert testAcctount;
		system.assert(testAcctount.id != null);
		
		Order__c testOrder001 = new Order__c(
			Name = 'Test Order',
			Billing_Account__c = testAcctount.Id,
			Status__c = 'Open',
		    ByPass_VR__c = true
		);
		insert testOrder001;
		system.assert(testOrder001.id != null);
		
		Order__c testOrder002 = new Order__c(
			Name = 'Test Order002',
			Billing_Account__c = testAcctount.Id,
			Status__c = 'HaHa',
		    ByPass_VR__c = true
		);
		insert testOrder002;
		system.assert(testOrder002.id != null);
		testOrder002.Status__c = 'HaHa';
		update testOrder002;
		
		Order__c testOrder003 = new Order__c(
			Name = 'Test Order003',
			Billing_Account__c = testAcctount.Id,
			Status__c = 'NotOpen',
		    ByPass_VR__c = true
		);
		insert testOrder003;
		system.assert(testOrder003.id != null);
		testOrder003.Status__c = 'NotOpen';
		update testOrder003;
		
		testOrder002 = [select Id, Order_Number__c from Order__c where Id = :testOrder002.Id limit 1];
		string fileName = 'PFI-' + testOrder002.Order_Number__c + '.pdf';
		Attachment testAttachment = new Attachment(
	    	Name = fileName,
	    	ParentId = testOrder002.Id,
	    	Body = Blob.valueOf('dummy')
	    );
	    insert testAttachment;
	    system.assert(testAttachment.id != null);
		
		
         // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
          	Test.setCurrentPage(Page.CreateProFormaInvoice);
          
          	CreateProFormaInvoiceController con = new CreateProFormaInvoiceController();
          
          	//test order
          	ApexPages.currentPage().getParameters().put('id',testOrder001.id);
          	con.Create();
            
            //test order002
          	ApexPages.currentPage().getParameters().put('id',testOrder002.id);
          	con.Create();
          	
          	//test order003
          	ApexPages.currentPage().getParameters().put('id',testOrder003.id);
          	con.Create();
            
            // end test
            Test.stopTest();
        }
    }
}
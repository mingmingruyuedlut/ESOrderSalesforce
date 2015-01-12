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
private class LOAEmailTest {

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
		
		Order__c testOrder = new Order__c(
			Name = 'Test Order',
			Billing_Account__c = testAcctount.Id,
		    ByPass_VR__c = true
		);
		insert testOrder;
		system.assert(testOrder.id != null);
		
		testOrder = [select Id, Order_Number__c from Order__c where Id = :testOrder.Id limit 1];
		string fileName = 'LOA-' + testOrder.Order_Number__c + '-';
		Attachment testAttachment = new Attachment(
	    	Name = fileName,
	    	ParentId = testOrder.Id,
	    	Body = Blob.valueOf('dummy')
	    );
	    insert testAttachment;
	    system.assert(testAttachment.id != null);

        
        // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
          
          	LOAEmail con = new LOAEmail();
          	con.Init(testOrder.Id);
          	con.PrerequisiteValidation();
            con.GetEmailTo();
            con.GetEmailSubject();
            con.GetEmailBody();
            con.HasAttachment();
            con.GetAttachmentTitle();
            con.GetAttachments();
            con.CreateEmailAttachments();
            
            // end test
            Test.stopTest();
        }
    }
}
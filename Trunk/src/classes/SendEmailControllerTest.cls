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
private class SendEmailControllerTest {

    static testMethod void LOAEmail() {
        // setup
		Account acct = new Account(
			Name = 'My Account',
			Email__c = 'nelson.wu@fabricgroup.com.au',
			Account_Contact__c = 'someone'
		);
		insert acct;
		Order__c ord = new Order__c(
			Name = 'My Order',
			Billing_Account__c = acct.Id,
			Status__c = 'Open',
			ByPass_VR__c = true
		);
		insert ord;
		Store__c myStore = new Store__c(
			Suburb__c = 'suburb',
			Store_Company__c = 'fabric',
			StoreCode__c = 'storecode',
			State__c = 'VIC',
			Postcode__c = '1234',
			Name = 'STORE1',
			Address2__c = 'address2',
			Address1__c = 'address1',
			Phone__c = '11 2222 3333'
		);
		insert myStore;
		
		ord = [select Id, Order_Number__c from Order__c where Id = :ord.Id limit 1];
		string fileName = new CreateLOAController().GetLOAFileName(ord.Order_Number__c, myStore.Name);
		Attachment attachment = new Attachment(
	    	Name = fileName,
	    	ParentId = ord.Id,
	    	Body = Blob.valueOf('dummy')
	    );
	    insert attachment;	    
        
        // execute
        SendEmailController ctrl = new SendEmailController();
        ctrl.Type = 'loa';
        ctrl.Id = ord.Id;
        ctrl.EmailCC = '';
        ctrl.EmailBCC = '';
        ctrl.Init();
        ctrl.SwitchHTML();
        ctrl.SwitchText();
        ctrl.Cancel();
        ctrl.EmailSubject = 'This email is generated from Salesforce Unit Test Class: SendEmailControllerTest, please ignore.';
        ctrl.Send();
    }
}
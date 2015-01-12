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
private class SFAccountWebServiceTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // insert test data
		Account account001 = new Account(
			Name = 'Test Account 001',
			AccountNumber = '00001',
			ABN__c = '11',
			Auto_Email_Invoice__c = true,
			Credit_Type__c = 'Account',
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
		
		Account account002 = new Account(
			Name = 'Test Account 002',
			AccountNumber = '00002',
			ABN__c = '11',
			Auto_Email_Invoice__c = true,
			Credit_Type__c = 'Account',
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
		insert account002;
        system.assert(account002.id != null);
		
         // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();

            List<SFAccountWebService.SFAccount> sfaList = new List<SFAccountWebService.SFAccount>();
            SFAccountWebService.BillingAddress ba = new SFAccountWebService.BillingAddress('a', 'a', 'a', 'a', 'a');
            SFAccountWebService.ShippingAddress sa = new SFAccountWebService.ShippingAddress('a', 'a', 'a', 'a', 'a');
            SFAccountWebService.SFAccount sfa = new SFAccountWebService.SFAccount('Test Account 001', '00001', '11', 'true', 'ACCOUNT', 'a', 'a', 'a', 'a', 'a', 'a', 'a@163.com', ba, sa);
            sfaList.add(sfa);
            
            SFAccountWebService.UpsertAccount(sfaList);
            
            // end test
            Test.stopTest();
        }
    }
}
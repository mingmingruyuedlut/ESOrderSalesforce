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
private class ProductTriggerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // create test data 
        Product2 product001 = new Product2();
        product001.SKU__c = 'E21191AE067422712339';
        product001.Name = 'Test Produce';
        product001.Ticket_Price__c = 1000;
        
        Product2 product002 = new Product2();
        product002.SKU__c = 'E21191AE067422712338';
        product002.Name = 'Test Produce';
        product002.Ticket_Price__c = 1000;
        insert product002;
        system.assert(product002.id != null);
        
        Product2 product003 = new Product2();
        product003.SKU__c = 'E21191AE067422712337';
        product003.Name = 'Test Produce';
        product003.Ticket_Price__c = 1000;
        insert product003;
        system.assert(product003.id != null);
        
         // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            insert product001;
        	system.assert(product001.id != null);
            
            product002.Ticket_Price__c = 1000;
            update product002;
        	system.assert(product002.id != null);
        	
        	product003.Ticket_Price__c = 1212121;
        	update product003;
        	system.assert(product003.id != null);
            
            // end test
            Test.stopTest();
        }
    }
}
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
private class TargetTriggerTest {

    static testMethod void myUnitTest() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // create test data 
        Target__c target001 = new Target__c();
        target001.Name = 'Test Produce';
        target001.Sales_Person__c = u.Id;
        target001.Month__c = Date.today();
        target001.Target_Sales__c = 1000;
        target001.Target_GP__c = 2000;
       
       
         // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            insert target001;
        	system.assert(target001.id != null);
            
            // end test
            Test.stopTest();
        }
    }
}
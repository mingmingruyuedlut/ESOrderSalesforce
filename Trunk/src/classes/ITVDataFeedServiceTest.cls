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
private with sharing class ITVDataFeedServiceTest {

    static testMethod void coverTypes() {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            // cover inner class
            new ITVDataFeedService.ArrayOfNV();
            new ITVDataFeedService.ArrayOfFilterInfo();
            new ITVDataFeedService.Feed_element();
            new ITVDataFeedService.NV();
            new ITVDataFeedService.ArrayOfArrayOfNV();
            new ITVDataFeedService.ArrayOfString();
            new ITVDataFeedService.FeedResponse_element();
            new ITVDataFeedService.FilterInfo();
            new ITVDataFeedService.DataFeedSoap();
              
            // end test
            Test.stopTest();
        }
    }
    
    static testMethod void coverMethods()
    {
        // query for a test user
        User u = [select id from User where id =: UserInfo.getUserId() limit 1];
        system.assert(u.id != null);
        
        // run test as current test user
        system.runAs(u){
        
        	// start test
            Test.startTest();
            
            // cover method
            new ITVDataFeedService.DataFeedSoap().Feed(null, null, null);
              
            // end test
            Test.stopTest();
        }
    }
    
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
        	Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof ITVDataFeedService.Feed_element)
                response.put('response_x', new ITVDataFeedService.FeedResponse_element());
            return;
        }
    }
    
}
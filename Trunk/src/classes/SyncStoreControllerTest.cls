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
@isTest(SeeAllData=true)
private class SyncStoreControllerTest {
	
	private class HttpCalloutMockImpl implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse res = new HttpResponse();
	        res.setBody('[{"Address1":"LEVEL 4, OFFICE TOWER TWO","Address2":"CHADSTONE SHOPING CENTRE","Phone":"03 8530 7333","Postcode":"3148","State":"VIC","StoreCode":"1","StoreCompany":"JB Hi-Fi","Suburb":"CHADSTONE"},{"Address1":"LEVEL 2 TENANCY UR02 THE WELL","Address2":"793 BURKE RD","Phone":"03 9882 1372","Postcode":"3124","State":"VIC","StoreCode":"2","StoreCompany":"JB Hi-Fi","Suburb":"CAMBERWELL"}]');
	        res.setStatusCode(200);
	        return res;
    	}
	}
	
    static testMethod void myUnitTest() {
    	Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        SyncStoreController.getInfoFromExternalService();
    }
}
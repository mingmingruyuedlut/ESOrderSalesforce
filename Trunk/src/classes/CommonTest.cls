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
private class CommonTest {

	// test QuoteTrigger and QuoteLineItemTrigger
    static testMethod void myUnitTest() {
        Common.GetPicklistValues('Contact', 'Salutation');
        
        system.assert(Common.IsDecimal('0.2222'));
        system.assert(Common.IsDecimal('0'));
        system.assert(!Common.IsDecimal('.01'));
        system.assert(!Common.IsDecimal('2.'));
        system.assert(!Common.IsDecimal('aaa'));
        system.assert(!Common.IsDecimal('0.2222a'));
        system.assert(!Common.IsDecimal('a0.2222'));
        system.assert(Common.PadLeft('b', 3, 'a') == 'aab');
         
        StaticResource[] resources = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource limit 1]; 
        if(resources.size() == 1){
        	Common.GetResourceURL(resources[0].Name);
        }        
       
        Document[] docs = [select Id,DeveloperName, LastModifiedDate from Document limit 1];

        if(docs.size() == 1){
        	Common.GetDocumentUrl(docs[0].DeveloperName);
        }
    }
}
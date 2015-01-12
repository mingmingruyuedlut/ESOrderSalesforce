global class SyncStoreController implements Schedulable {
	
	//call the web service to get the store info
	global void execute(SchedulableContext SC) {
     	getInfoFromExternalService();
   }
   
   @future(callout=true)
   public static void getInfoFromExternalService() { 
   		
   		Set<string> StoreIdSet = new Set<string>();
   		List<Store__c> storeList = new List<Store__c>();
   		
		string url = 'https://corp-services.jbhifi.com.au/dev/api/Store/?apiKey=6EB40261BAF040BFA4F09DFF1B557190';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        List<StoreModel> m = (List<StoreModel>)JSON.deserialize(res.getBody(),List<StoreModel>.class);
        
        for(StoreModel s : m){
			Store__c store = new Store__c(Name = s.Name, Address1__c = s.Address1, Address2__c = s.Address2, Phone__c = s.Phone, Postcode__c = s.Postcode, State__c = s.State, StoreCode__c = s.StoreCode, Store_Company__c = s.StoreCompany, Suburb__c = s.Suburb);
			storeList.add(store);        	
        }
        
        upsert storeList StoreCode__c;
	} 
	
	
	public class StoreModel{
		public string Address1 {get;set;}
		public string Address2 {get;set;}
		public string Name {get;set;}
		public string Phone {get;set;}
		public string Postcode {get;set;}
		public string State {get;set;}
		public string StoreCode {get;set;}
		public string StoreCompany {get;set;}
		public string Suburb {get;set;}		
	}	
}
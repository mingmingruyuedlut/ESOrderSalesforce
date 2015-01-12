public with sharing class Common {
	public static string StandardPricebookId = null;
	
	public static List<String> GetPicklistValues(String ObjectApi_name, String Field_name){ 
		List<String> lstPickvals=new List<String>();
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
		Sobject Object_name = targetType.newSObject();
		Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
		Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
		List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
		for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
			lstPickvals.add(a.getValue());//add the value  to our final list
		}
		return lstPickvals;
	}
	
	public static string PadLeft(string source, integer length, string padString){
		 if(source == null) return null;
		 if(source.length() > length) return source;
		 
		 integer len = length - source.length();
		 for(integer i = 0; i < len; i++){
		 	source = padString + source;
		 }
		 return source;
	}
	
	public static boolean IsDecimal(string txt){
		boolean isDecimal = false;
		
		Pattern ptn = Pattern.Compile('^[0-9]+(.[0-9]+)?$');
		Matcher match = ptn.matcher(txt);
		
		if(match.Matches()){
		    isDecimal = true;
		}
		
		return isDecimal;
	}
	
	public static String GetResourceURL(String resourceName) {
		StaticResource resource = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName limit 1];

		if (resource != null) {
		   String namespace = resource.NamespacePrefix;
		   return '/resource/' 
		      + resource.SystemModStamp.getTime() + '/' 
		      + (namespace != null && namespace != '' ? namespace + '__' : '') 
		      + resourceName; 
		}
		else return '';	
	}
	
	public static string GetDocumentUrl(string uniqueName){
		Document doc = [select Id, LastModifiedDate from Document where DeveloperName = :uniqueName limit 1];
		
		if(doc != null){
			return 'http://c.' + InstanceName + '.content.force.com/servlet/servlet.ImageServer?' +
				'id=' + doc.Id +
				'&oid=' + Userinfo.getOrganizationId() +
				'&lastMod=' + doc.LastModifiedDate.getTime();
		}
		else return '';
	}
	
	private static string InstanceName{
		get {
			if(InstanceName == null){
				List<String> parts = System.URL.getSalesforceBaseUrl().getHost().remove('-api').split('\\.');
	            if (parts.size() == 3) InstanceName = parts[0];
	            else if (parts.size() == 5) InstanceName = parts[1];
	            else InstanceName = null;
			}
			return InstanceName;
		}
	}
}
public class CreditLimitController {
	//added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    // the actual account
    private Account a;   
    public CreditLimitInfo creLimitInfo {get; set;}   
    private string feedName = 'CustomerCredit';
    private string filterInfoName = 'CustomerID';
    private ITVDataFeedService itvDFService = new ITVDataFeedService();
    private ITVDataFeedService.DataFeedSoap dfSoap = new ITVDataFeedService.DataFeedSoap();    
    private ITVDataFeedService.FilterInfo fInfo = new ITVDataFeedService.FilterInfo();
    private ITVDataFeedService.ArrayOfFilterInfo filterInfoArray = new ITVDataFeedService.ArrayOfFilterInfo();
    private ITVDataFeedService.ArrayOfString sArray = new ITVDataFeedService.ArrayOfString();    
    //check creadit type
    public boolean CreditType {get;set;}  
    
    public CreditLimitController(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        this.a = (Account)controller.getRecord();
        this.creLimitInfo = getCreditLimitInfo(this.a);    
        //this.creLimitInfo = null;
        //WrapperCallShopKeeperService();
        //getBillingAccount();
    }
    
	public CreditLimitInfo getCreditLimitInfo(Account acc) {
		// call web service to get the credit limit by account id		
		string customerId = getCustomerId(acc);	
		if(!CreditType)
		{
			return null;
		}
		else
		{
			fInfo.Name = filterInfoName;						
			string[] sArr = new string[] { customerId };
			sArray.string_x = sArr;			
			fInfo.Values = sArray;			
			filterInfoArray.FilterInfo = new ITVDataFeedService.FilterInfo[] {fInfo};			
			ITVDataFeedService.ArrayOfArrayOfNV nvArrayArray = dfSoap.Feed(feedName, filterInfoArray, DateTime.now());
			CreditLimitInfo currentCreditLimitInfo = new CreditLimitInfo();
			if(nvArrayArray != null && nvArrayArray.ArrayOfNV != null){
				for(ITVDataFeedService.ArrayOfNV aNv : nvArrayArray.ArrayOfNV){
					for(ITVDataFeedService.NV nv : aNv.NV){
						if(nv.N == 'CustomerID'){
							currentCreditLimitInfo.CustomerId = nv.V;
						}
						else if(nv.N == 'CreditLimit'){
							currentCreditLimitInfo.CreditLimit = Decimal.valueOf(nv.V);
						}
						else if(nv.N == 'AvailableCredit'){
							currentCreditLimitInfo.AvailableCredit = Decimal.valueOf(nv.V);
						}
						else if(nv.N == 'Balance'){
							currentCreditLimitInfo.Balance = Decimal.valueOf(nv.V);
						}
					}
				}
			}
			return currentCreditLimitInfo;
		}	
	}
	
	private string getCustomerId(Account acc){
		string customerId = '';
		if(acc != null && acc.Id != null){
			List<Account> accList = [Select AccountNumber,Credit_Type__c From Account Where Id =: acc.Id];
			if(accList[0].Credit_Type__c == 'Cash')
			{
				CreditType = false;
			}
			else
			{
				CreditType = true;
				if(accList != null && accList.size() > 0){
				customerId = accList[0].AccountNumber;	
				}
			}			
		}
		return customerId;	
	}

	public class CreditLimitInfo {
        public string CustomerId {get;set;}
        public decimal CreditLimit {get;set;}
        public decimal AvailableCredit {get;set;}
        public decimal Balance {get;set;}
        
        public CreditLimitInfo(){
          CustomerId = '';
          CreditLimit = 0;
          AvailableCredit = 0;
          Balance = 0;
        }
        
        public CreditLimitInfo(string cusId, decimal creLimit, decimal avaCredit, decimal bal){
          CustomerId = cusId;
          CreditLimit = creLimit;
          AvailableCredit = avaCredit;
          Balance = bal;
        }
     }
}
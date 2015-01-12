public class OrderCreditLimitController {
	//added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    //the actual order
    private Order__c ord;
    //the billing account
    private Account billingAccout;
    
    public CreditLimitInfo creLimitInfo {get; set;}
    
    private string feedName = 'CustomerCredit';
    private string filterInfoName = 'CustomerID';
    private ITVDataFeedService itvDFService = new ITVDataFeedService();
    private ITVDataFeedService.DataFeedSoap dfSoap = new ITVDataFeedService.DataFeedSoap();
    
    private ITVDataFeedService.FilterInfo fInfo = new ITVDataFeedService.FilterInfo();
    private ITVDataFeedService.ArrayOfFilterInfo filterInfoArray = new ITVDataFeedService.ArrayOfFilterInfo();
    private ITVDataFeedService.ArrayOfString sArray = new ITVDataFeedService.ArrayOfString();
    
    public string Customer_ID {get;set;}
    public string Credit_Limit {get;set;}
    public string Available_Credit {get;set;}
    public string Balance {get;set;}
    public string TestForCass {get;set;}
    public boolean CreditType {get;set;}  
    
    public OrderCreditLimitController(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        this.ord = (Order__c)controller.getRecord();
        this.billingAccout = getBillingAccount();
        this.creLimitInfo = getCreditLimitInfo(this.billingAccout);  
    }
    
    public Account getBillingAccount(){  	
   		Account currentAcc = new Account();
    	List<Order__c> oList = [Select Billing_Account__r.Id,Billing_Account__r.Credit_Type__c, Billing_Account__r.Name, Billing_Account__r.AccountNumber From Order__c Where Id =: this.ord.Id];
    	CreditType = false;
    	if(oList[0].Billing_Account__r.Credit_Type__c != 'Cash')
    	{
    		CreditType = true;
    		if(oList != null && oList.size() > 0){
    		currentAcc.Id = oList[0].Billing_Account__r.Id;
			currentAcc.Name = oList[0].Billing_Account__r.Name;
			currentAcc.AccountNumber = oList[0].Billing_Account__r.AccountNumber;
			
			}
			return currentAcc;		
    	}
    	else
    	{
    		return null;
    	}
    }

	public CreditLimitInfo getCreditLimitInfo(Account acc) {
		// call web service to get the credit limit by account id
		if(CreditType)
		{
			fInfo.Name = filterInfoName;
			string customerId = getCustomerId(acc);
			string[] sArr = new string[] { customerId };
			sArray.string_x = sArr;			
			fInfo.Values = sArray;			
			filterInfoArray.FilterInfo = new ITVDataFeedService.FilterInfo[] {fInfo};			
			ITVDataFeedService.ArrayOfArrayOfNV nvArrayArray = dfSoap.Feed(feedName, filterInfoArray, DateTime.now());			
			CreditLimitInfo currentCreditLimitInfo = new CreditLimitInfo();
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
			return currentCreditLimitInfo;
		}
		else
		{
			return null;
		}
	}
	
	private string getCustomerId(Account acc){
		string customerId = '';
		if(acc != null && acc.Id != null){
			List<Account> accList = [Select AccountNumber From Account Where Id =: acc.Id];
			if(accList != null && accList.size() > 0){
				customerId = accList[0].AccountNumber;
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
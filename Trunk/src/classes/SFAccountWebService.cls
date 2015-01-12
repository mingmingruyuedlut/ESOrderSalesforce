global class SFAccountWebService {
	
    webService static SFAccountResponse UpsertAccount(List<SFAccount> accounts) {
        List<Account> currentAccList = new List<Account>();
        List<Account> finalAccList = new List<Account>();
        Set<string> accountNumberSet = new Set<string>();
        Map<string, id> accountNumberIdMap = new Map<string, id>();	//decrease number of SOQL queries. the max number of one request is 100.
        SFAccountResponse sfRes = new SFAccountResponse(true, '');
        
        ConvertSFAccountToAccountObj(accounts, currentAccList);
        
    	for(Account currentAcc : currentAccList){
    		accountNumberSet.add(currentAcc.AccountNumber);
    	}
    	List<Account> accList = [Select Id, AccountNumber From Account a Where AccountNumber in: accountNumberSet];
    	for(Account acc : accList){
    		accountNumberIdMap.put(acc.AccountNumber, acc.Id);
    	}
    	for(Account finalAcc : currentAccList){
    		if(accountNumberIdMap.get(finalAcc.AccountNumber) != null){
    			finalAcc.Id = Id.valueOf(accountNumberIdMap.get(finalAcc.AccountNumber));
    		}
    		finalAccList.add(finalAcc);
    	}
    	
    	upsert finalAccList;
    	return sfRes;
    }
    
    private static void ConvertSFAccountToAccountObj(List<SFAccount> accounts, List<Account> currentAccList){
    	
    	for(SFAccount sfacc : accounts){
    		if(sfacc != null){
	    		Account acc = new Account();
	    		
	    		acc.Name = sfacc.AccountName;
	    		if(sfacc.AccountNumber != null){
	    			acc.AccountNumber = sfacc.AccountNumber;
	    		}
	    		if(sfacc.ABN != null){
	    			acc.ABN__c = sfacc.ABN;
	    		}
	    		if(sfacc.AutoEmailInvoice != null){
	    			acc.Auto_Email_Invoice__c = Boolean.valueOf(sfacc.AutoEmailInvoice);
	    		}
	    		if(sfacc.CreditType != null){
	    			acc.Credit_Type__c = sfacc.CreditType;
	    		}
	    		if(sfacc.GPID != null){
	    			acc.GP_ID__c = sfacc.GPID;
	    		}
	    		if(sfacc.PPSR != null){
	    			acc.PPSR__c = sfacc.PPSR;
	    		}
	    		if(sfacc.VIPNumber != null){
	    			acc.VIP_Number__c = sfacc.VIPNumber;
	    		}
	    		if(sfacc.AccountContact != null){
	    			acc.Account_Contact__c = sfacc.AccountContact;
	    		}
	    		if(sfacc.Phone != null){
	    			acc.Phone = sfacc.Phone;
	    		}
	    		if(sfacc.Phone != null){
	    			acc.Fax = sfacc.Fax;
	    		}
	    		if(sfacc.Email != null){
	    			acc.Email__c = sfacc.Email;
	    		}
	    		
	    		if(sfacc.BillingAddressInfo != null){
	    			if(sfacc.BillingAddressInfo.Address != null){
		    			acc.BillingStreet = sfacc.BillingAddressInfo.Address;
	    			}
	    			if(sfacc.BillingAddressInfo.Suburb != null){
		    			acc.BillingCity = sfacc.BillingAddressInfo.Suburb;
	    			}
	    			if(sfacc.BillingAddressInfo.Postcode != null){
		    			acc.BillingPostalCode = sfacc.BillingAddressInfo.Postcode;
	    			}
	    			if(sfacc.BillingAddressInfo.Postcode != null){
		    			acc.BillingState = sfacc.BillingAddressInfo.State;
	    			}
	    			if(sfacc.BillingAddressInfo.Country != null){
		    			acc.BillingCountry = sfacc.BillingAddressInfo.Country;
	    			}
	    		}
	    		
	    		if(sfacc.ShippingAddressInfo != null){
	    			if(sfacc.ShippingAddressInfo.Address != null){
		    			acc.ShippingStreet = sfacc.ShippingAddressInfo.Address;
	    			}
	    			if(sfacc.ShippingAddressInfo.Suburb != null){
		    			acc.ShippingCity = sfacc.ShippingAddressInfo.Suburb;
	    			}
	    			if(sfacc.ShippingAddressInfo.Postcode != null){
		    			acc.ShippingPostalCode = sfacc.ShippingAddressInfo.Postcode;
	    			}
	    			if(sfacc.ShippingAddressInfo.State != null){
		    			acc.ShippingState = sfacc.ShippingAddressInfo.State;
	    			}
	    			if(sfacc.ShippingAddressInfo.Country != null){
		    			acc.ShippingCountry = sfacc.ShippingAddressInfo.Country;
	    			}
	    		}
	    		
	    		currentAccList.add(acc);
    		}
    	}
    }
    
    global class SFAccount {
   		webService string AccountName {get; set;}
   		webService string AccountNumber {get; set;}
   		webService string ABN {get; set;}
   		webService string AutoEmailInvoice {get; set;}
   		webService string CreditType {get; set;}
   		webService string GPID {get; set;}
   		webService string PPSR {get; set;}
   		webService string VIPNumber {get; set;}
   		webService string AccountContact {get; set;}
   		webService string Phone {get; set;}
   		webService string Fax {get; set;}
   		webService string Email {get; set;}
   		
   		webService BillingAddress BillingAddressInfo {get; set;}
   		webService ShippingAddress ShippingAddressInfo {get; set;}
   		
	   	public SFAccount(string sfaAccountName, string sfaAccountNumber, string sfaABN, string sfaAutoEmailInvoice, string sfaCreditType, string sfaGPID, string sfaPPSR, string sfaVIPNumber, string sfaAccountContact, string sfaPhone, string sfaFax, string sfaEmail, BillingAddress sfaBillingAddressInfo, ShippingAddress sfaShippingAddressInfo){
	   		AccountName = sfaAccountName;
	   		AccountNumber = sfaAccountNumber;
	   		ABN = sfaABN;
	   		AutoEmailInvoice = sfaAutoEmailInvoice;
	   		CreditType = sfaCreditType;
	   		GPID = sfaGPID;
	   		PPSR = sfaPPSR;
	   		VIPNumber = sfaVIPNumber;
	   		AccountContact = sfaAccountContact;
	   		Phone = sfaPhone;
	   		Fax = sfaFax;
	   		Email = sfaEmail;
	   		BillingAddressInfo = sfaBillingAddressInfo;
	   		ShippingAddressInfo = sfaShippingAddressInfo;
	   	}
   }
   
    global class BillingAddress {
   		webService string Address {get; set;}
   		webService string Suburb {get; set;}
   		webService string Postcode {get; set;}
   		webService string State {get; set;}
   		webService string Country {get; set;}

   		
	   	public BillingAddress(string baAddress, string baSuburb, string baPostcode, string baState, string baCountry){
	   		Address = baAddress;
	   		Suburb = baSuburb;
	   		Postcode = baPostcode;
	   		State = baState;
	   		Country = baCountry;
	   	}
   }
   
   global class ShippingAddress {
   		webService string Address {get; set;}
   		webService string Suburb {get; set;}
   		webService string Postcode {get; set;}
   		webService string State {get; set;}
   		webService string Country {get; set;}

   		
	   	public ShippingAddress(string saAddress, string saSuburb, string saPostcode, string saState, string saCountry){
	   		Address = saAddress;
	   		Suburb = saSuburb;
	   		Postcode = saPostcode;
	   		State = saState;
	   		Country = saCountry;
	   	}
   }
   
   global class SFAccountResponse{
   		webService boolean Result {get; set;}
   		webService string Message {get; set;}
   		
   		public SFAccountResponse(boolean sfResult, string sfMessage){
   			Result = sfResult;
   			Message = sfMessage;
   		}
   }
}
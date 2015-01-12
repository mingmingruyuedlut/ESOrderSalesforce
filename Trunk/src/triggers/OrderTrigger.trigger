trigger OrderTrigger on Order__c (after insert) {
	
	if (Trigger.isAfter) {	
		if(trigger.isInsert){
			for(Order__c order_c : Trigger.new){
				
				Order__c orderc = [Select o.Order_Number__c, o.Order_ID__c, o.Name, o.Id From Order__c o Where Id = : order_c.Id];
				string orderId = Common.PadLeft(string.valueOf(order_c.Order_ID__c), 6, '0');
				orderc.Order_Number__c = 'CM' + orderId.substring(0, 3) + '-' + orderId.substring(3, 6);
				if(orderc.Name == 'NewOrder_Prefill_Name'){
					orderc.Name = orderc.Order_Number__c;
				}
				update orderc;
				
			}
		}
	}
}
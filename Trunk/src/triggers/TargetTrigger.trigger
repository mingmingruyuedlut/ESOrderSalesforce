trigger TargetTrigger on Target__c (after insert, after update, after delete) {
	if(Trigger.isInsert){
		for(Target__c target : Trigger.new){
			if(target.Report_Group__c == null){
				User userObj = [Select Name, State From User Where Id =: target.Sales_Person__c];
				Order_Target_Report_Group__c reportGroup = new Order_Target_Report_Group__c();
				reportGroup.Sales_Person__c = target.Sales_Person__c;
				reportGroup.Sales_Person_Label__c = userObj.Name;
				reportGroup.State__c = userObj.State;
				reportGroup.Sales_Month__c = target.Month__c;
				insert reportGroup;
				
				Target__c currentTarget = [Select Report_Group__c From Target__c Where Id =: target.Id];
				currentTarget.Report_Group__c = reportGroup.Id;
				update currentTarget;
			}
		}
	}
	else if(Trigger.isDelete){
		for(Target__c target : Trigger.old){ 
    		if(target != null && target.Report_Group__c != null){
				Order_Target_Report_Group__c reportGroup = [Select Name, Id From Order_Target_Report_Group__c Where Id =: target.Report_Group__c];
				delete reportGroup;
			}
    	}  
	}
}
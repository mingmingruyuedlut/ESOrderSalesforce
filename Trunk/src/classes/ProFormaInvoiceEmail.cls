public with sharing class ProFormaInvoiceEmail implements IEmail {
	private Order__c ord;
	private Attachment[] attachments;
	
	public void Init(string id){
		ord = [select Id, Order_Number__c, Billing_Account__r.Email__c, Billing_Account__r.Account_Contact__c from Order__c where Id = :id limit 1];
		string fileName = new CreateProFormaInvoiceController().GetFileName(ord.Order_Number__c);
		attachments = [select Id, Name, Body from Attachment where ParentId = :id and Name = :fileName];
	}
	
	public string PrerequisiteValidation(){
		if(attachments.size() == 0) return 'Pro Forma Invoice has not been created, please go back to order to create the document.';
		else return null;
	}
	
	public string GetEmailTo() {
		return ord.Billing_Account__r.Email__c;
	}
	
	public string GetEmailSubject() {
		return 'Your Sales Order for Order ' + ord.Order_Number__c;
	}
	
	public string GetEmailBody() {
		User user = [select FirstName, LastName, Phone, Email, Profile.Name from User where id = :Userinfo.getUserId() limit 1];
		
		return '<p>Hi ' + ord.Billing_Account__r.Account_Contact__c + ',</p>' +
			'<p>Please find attached the Sales Order for Order ' + ord.Order_Number__c + '.</p>' +
			'<p>This document details the products and payment details for your order. Please make payment via one of the methods provided on the document. Once your payment has been received we will be in contact to finalise your order and arrange pickup/delivery.</p>' +
			'<p>If you have any questions about this order please do not hesitate to contact me on ' + user.Phone + '.</p>' +
			'<p>Thanks very much,</p>' +
			'<p>' +
				'Regards,<br/>' +
				'<b>' + user.FirstName + ' ' + user.LastName + '</b> | ' + user.Profile.Name + ' | JB Hi-Fi Commercial Division</br>' +
				'JB Hi-Fi Group Pty Ltd<br/>' +
				'--------------------------------------------------------------------------------------------<br/>' +
				'Commercial Mainline: <b>1300 746 752</b><br/>' +
				'Direct: <b>' + user.Phone + '</b> Fax: <b>03 8530 7640</b><br/>' +
				'E-Mail: ' + user.Email + ' | WWW: <a href="http://www.jbcommercial.com.au">http://www.jbcommercial.com.au</a><br/>' +
				'--------------------------------------------------------------------------------------------<br/>' +
				'<b>Postal Address:</b><br/>' +
				'JB Hi-Fi Commercial Division<br/>' +
				'PO Box 561, Chadstone Centre VIC 3148' +
			'</p>' +
			'<img height="48" src="' + Common.GetDocumentUrl('logo_commercial_png') + '"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="' + Common.GetDocumentUrl('telstra_partner_png') + '"/><br/><br/>' +
			'<a href="http://asp-au.secure-zone.net/v2/index.jsp?id=1187/1331/3782&lng=en"><img src="' + Common.GetDocumentUrl('learn_more_commercial_png') + '"/></a>';
	}
	
	public boolean HasAttachment() {
		return attachments != null && attachments.size() > 0;
	}
	
	public string GetAttachmentTitle() {
		return 'Pro Forma Invoice';
	}
	
	public AttachmentInfo[] GetAttachments(){	
		AttachmentInfo[] attachmentInfos = new AttachmentInfo[]{};
		for(Attachment attach : attachments){
			AttachmentInfo info = new AttachmentInfo();
			info.Name = attach.Name;
			info.Url = '/servlet/servlet.FileDownload?file=' + attach.Id;
			
			attachmentInfos.add(info);
		}
		
		return attachmentInfos;
	}
	
	public Messaging.EmailFileAttachment[] CreateEmailAttachments(){
		Messaging.EmailFileAttachment[] emailAttachments = new Messaging.EmailFileAttachment[]{};
		for(Attachment attach : attachments){
			Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
		    emailAttach.setContentType('application/pdf');
		    emailAttach.setFileName(attach.Name);
		    emailAttach.setInline(false);
		    emailAttach.Body = attach.Body;
		    
		    emailAttachments.add(emailAttach);
		}
		
	    return emailAttachments;
	}
}
public with sharing class LOAEmail implements IEmail {
	private Order__c ord;
	private Attachment[] attachments;
	
	public void Init(string id){
		ord = [select Id, Order_Number__c, Billing_Account__r.Email__c, Billing_Account__r.Account_Contact__c from Order__c where Id = :id limit 1];
		string fileNamePrefix = new CreateLOAController().GetLOAFileNamePrefix(ord.Order_Number__c);
		string likeFileNamePrefix = fileNamePrefix + '%';
		attachments = [select Id, Name, Body from Attachment where ParentId = :id and Name like :likeFileNamePrefix];
	}
	
	public string PrerequisiteValidation(){
		if(attachments.size() == 0) return 'Letter of Authority has not been created, please go back to order to create the document.';
		else return null;
	}
	
	public string GetEmailTo() {
		return ord.Billing_Account__r.Email__c;
	}
	
	public string GetEmailSubject() {
		return 'JB Hi-Fi Commercial – Order: ' + ord.Order_Number__c;
	}
	
	public string GetEmailBody() {
		User user = [select FirstName, LastName, Phone, Email, Profile.Name from User where id = :Userinfo.getUserId() limit 1];
		
		return '<p>Hi ' + ord.Billing_Account__r.Account_Contact__c + ',</p>' +
			'<p>Thank you for your order. Your payment has been confirmed. </p>' +
			'<p>Attached is your Letter of Authority for this order, detailing the items you have purchased and the store designated for collection.</p>' +
			'<p>Please print this document and present it to the manager to collect your goods. Please also ensure you have Photo ID available upon request.</p>' +
			'<p>Thank you for shopping with JB Hi-Fi Commercial. Please do not hesitate to contact us with any queries you may have.</p>' +
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
		return 'Letter of Authority';
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
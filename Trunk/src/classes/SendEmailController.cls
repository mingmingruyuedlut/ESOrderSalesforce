public with sharing class SendEmailController {
	private IEmail emailCtrl;
	
	// Accepted value:
	//   loa: Letter of Authority
	//   pfi: Pro Forma Invoice
	public string Type{
		get {
			if(Type == null) {
				Type = ApexPages.currentPage().getParameters().get('type');
			}
			return Type;
		}
		set;
	}
	// when Type is:
	//   loa: Id is order id
	//   pfi: Id is order id
	public string Id{
		get {
			if(Id == null) {
				Id = ApexPages.currentPage().getParameters().get('id');
			}
			return Id;
		}
		set;
	}
	
	public boolean PrerequisiteValidationFailed {get;set;}
	public string PrerequisiteValidationMsg {get;set;}
	
	public boolean TextFormat {get;set;}
	public string EmailTo {get;set;}
	public string EmailCC {get;set;}
	public string EmailBCC {get;set;}
	public string EmailSubject {get;set;}
	public string EmailBody {get;set;}
	
	public boolean DefaultAttach {get;set;}
	public string DefaultAttachTitle {get;set;}
	public AttachmentInfo[] DefaultAttachmentInfos {get;set;}
	
	public string MoreAttachName1 {get;set;}
	public blob MoreAttachBody1 {get;set;}
	public string MoreAttachName2 {get;set;}
	public blob MoreAttachBody2 {get;set;}
	public string MoreAttachName3 {get;set;}
	public blob MoreAttachBody3 {get;set;}
	
	public PageReference Init(){
		InitEmailController();
		TextFormat = false;
		DefaultAttach = false;
		PrerequisiteValidationFailed = false;
		
		if(emailCtrl != null){
			PrerequisiteValidationMsg = emailCtrl.PrerequisiteValidation();
			if(PrerequisiteValidationMsg != null) { // Display error message, hide email section
				PrerequisiteValidationFailed = true;
			}
			else {
				EmailTo = emailCtrl.GetEmailTo();
				EmailSubject = emailCtrl.GetEmailSubject();
				EmailBody = emailCtrl.GetEmailBody();
				if(emailCtrl.HasAttachment()){
					DefaultAttach = true;
					DefaultAttachTitle = emailCtrl.GetAttachmentTitle();
					DefaultAttachmentInfos = emailCtrl.GetAttachments();
				}
			}
		}

		return null;
	}
	
	private void InitEmailController(){
		if(Type.toLowerCase() == 'loa') emailCtrl = new LOAEmail();
		else if(Type.toLowerCase() == 'pfi') emailCtrl = new ProFormaInvoiceEmail();
		
		if(emailCtrl != null) emailCtrl.Init(Id);
	}
	
	public PageReference SwitchHTML(){
		TextFormat = false;
		return null;
	}
	
	public PageReference SwitchText(){
		TextFormat = true;
		return null;
	}
	
	public PageReference Send(){
		InitEmailController();
		
		List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
		
		if(emailCtrl != null && emailCtrl.HasAttachment()) attachments.addAll(emailCtrl.CreateEmailAttachments());
		
		if(MoreAttachBody1 != null) attachments.add(CreateEmailAttachment(MoreAttachName1, MoreAttachBody1));
		if(MoreAttachBody2 != null) attachments.add(CreateEmailAttachment(MoreAttachName2, MoreAttachBody2));
		if(MoreAttachBody3 != null) attachments.add(CreateEmailAttachment(MoreAttachName3, MoreAttachBody3));
		
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    mail.setUseSignature(false);
	    mail.setToAddresses(EmailTo.split(';',0));
	    if(EmailCC != '') mail.setCcAddresses(EmailCC.split(';',0));
	    if(EmailBCC != '') mail.setBccAddresses(EmailBCC.split(';',0));
	    mail.setSubject(EmailSubject);
	    if(TextFormat) mail.setPlainTextBody(EmailBody);
	    else mail.setHtmlBody(EmailBody);
	    if(attachments.size() > 0) mail.setFileAttachments(attachments); 
	 
	    // Send the email
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		PageReference page = new PageReference('/'+Id);
	    page.setRedirect(true);
	    return page;
	}
	
	public PageReference Cancel(){
		PageReference page = new PageReference('/'+Id);
	    page.setRedirect(true);
	    return page;
	}
	
	private Messaging.EmailFileAttachment CreateEmailAttachment(string name, blob body) {
		Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
	    emailAttach.setFileName(name);
	    emailAttach.setInline(false);
	    emailAttach.Body = body;
	    return emailAttach;
	}
}
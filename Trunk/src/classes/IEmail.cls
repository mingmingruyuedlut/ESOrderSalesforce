public virtual interface IEmail {
	void Init(string id);
	
	string PrerequisiteValidation();
		
	string GetEmailTo();
	string GetEmailSubject();
	string GetEmailBody();
	
	boolean HasAttachment();
	string GetAttachmentTitle();
	AttachmentInfo[] GetAttachments();
	Messaging.EmailFileAttachment[] CreateEmailAttachments();
}
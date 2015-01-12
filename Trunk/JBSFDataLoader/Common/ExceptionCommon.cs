using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;

namespace JBSF.DataLoader.Common
{
    public class ExceptionCommon
    {
        public static void HandleMappingError(string msg, string[] toEmails, string[] ccEmails)
        {
            MailMessage mailMsg = new MailMessage();
            foreach (var str in toEmails)
            {
                if (str == string.Empty) continue;
                mailMsg.To.Add(new MailAddress(str));
            }
            foreach (var str in ccEmails)
            {
                if (str == string.Empty) continue;
                mailMsg.CC.Add(new MailAddress(str));
            }
            mailMsg.Subject = "Salesforce Data Loader - Invoice - Reporting Groupd ID mapping error";
            mailMsg.Body = msg;
            mailMsg.IsBodyHtml = false;

            SmtpClient client = new SmtpClient();
            client.Send(mailMsg);
        }

        public static void HandleException(Exception e, string[] toEmails, string[] ccEmails)
        {
            MailMessage mailMsg = new MailMessage();
            foreach (var str in toEmails)
            {
                if (str == string.Empty) continue;
                mailMsg.To.Add(new MailAddress(str));
            }
            foreach (var str in ccEmails)
            {
                if (str == string.Empty) continue;
                mailMsg.CC.Add(new MailAddress(str));
            }
            mailMsg.Subject = "Salesforce Data Loader - Invoice failed";
            mailMsg.Body = e.ToString();
            mailMsg.IsBodyHtml = false;

            SmtpClient client = new SmtpClient();
            client.Send(mailMsg);
        }
    }
}

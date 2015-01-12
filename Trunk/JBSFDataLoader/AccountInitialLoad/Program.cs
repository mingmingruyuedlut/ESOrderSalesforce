using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.IO;
using System.Xml.Linq;
using JBSF.DataLoader.Common;

namespace AccountInitialLoad
{
    class Program
    {
        /// <summary>
        /// Initial Customer Import [Customer Object in ITV --> Account Object in SF]
        /// Initialize customers in SF before the SF system is live. 
        /// After SF system is live, new customers are only created in SF and this process is not needed.
        /// There is on dedicated process to export customer from SF to ITV. This is currently done by embeding customer info in order.
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            try
            {
                string cliqPath = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_PATH_KEY];
                string cliqUpsert = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_UPSERT_KEY];
                string feedPath = ConfigurationManager.AppSettings[JBSFConstants.FEED_PATH_KEY];
                int limits = int.Parse(ConfigurationManager.AppSettings[JBSFConstants.LIMITS_KEY]);
                string sfdcUsername = ConfigurationManager.AppSettings[JBSFConstants.SFDC_USERNAME_KEY];
                string sfdcPassword = ConfigurationManager.AppSettings[JBSFConstants.SFDC_PASSWORD_KEY];

                List<Account> accounts = AccountService.GetAccountListFromXml(feedPath);
                if (accounts.Count > 0)
                {
                    AccountService.GenerateUpsertAccountDataCSVFile(accounts, cliqPath, cliqUpsert, limits);
                    CLIqCommon.Upsert(cliqPath, cliqUpsert, sfdcUsername, sfdcPassword);
                }
            }
            catch (Exception e)
            {
                ExceptionCommon.HandleException(e, ConfigurationManager.AppSettings[JBSFConstants.MAIL_TO].Split(';'), ConfigurationManager.AppSettings[JBSFConstants.MAIL_CC].Split(';'));
            }
        }
    }
}

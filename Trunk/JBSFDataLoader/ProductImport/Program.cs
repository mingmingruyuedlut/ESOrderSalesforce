using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using JBSF.DataLoader.Common;

namespace ProductImport
{
    class Program
    {
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

                var products = ProductService.ReadDataFeed(feedPath);
                if (products.Count > 0)
                {
                    ProductService.Merge(products, cliqPath, cliqUpsert, limits);
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

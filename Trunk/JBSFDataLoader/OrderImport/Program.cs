using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using JBSF.DataLoader.Common;

namespace OrderImport
{
    class Program
    {
        /// <summary>
        /// Upsert order object info and order line item object info. 
        /// Upsert Account object is done in Account project beforce SF system is live.
        /// </summary>
        static void Main(string[] args)
        {
            try
            {
                string cliqPath = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_PATH_KEY];
                string cliqLineItemUpsert = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_LINE_ITEM_UPSERT_KEY];
                string cliqOrderUpsert = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_ORDER_UPSERT_KEY];
                int limits = int.Parse(ConfigurationManager.AppSettings[JBSFConstants.LIMITS_KEY]);

                string sfdcUsername = ConfigurationManager.AppSettings[JBSFConstants.SFDC_USERNAME_KEY];
                string sfdcPassword = ConfigurationManager.AppSettings[JBSFConstants.SFDC_PASSWORD_KEY];

                string orderUpsertXmlPath = ConfigurationManager.AppSettings[JBSFConstants.ORDER_UPSERT_XML_PATH_KEY];
                string sftpUsername = ConfigurationManager.AppSettings[JBSFConstants.SFTP_USERNAME_KEY];
                string sftpPassword = ConfigurationManager.AppSettings[JBSFConstants.SFTP_PASSWORD_KEY];

                List<Order> orderList = OrderService.GetOrderListFromXml(orderUpsertXmlPath, sftpUsername, sftpPassword);
                if (orderList.Count > 0)
                {
                    OrderLineItemService.UpsertLineItemData(orderList, cliqPath, cliqLineItemUpsert, limits, sfdcUsername, sfdcPassword);
                    OrderService.UpsertOrderData(orderList, cliqPath, cliqOrderUpsert, limits, UpsertOrderType.All, sfdcUsername, sfdcPassword);
                }
            }
            catch (Exception e)
            {
                ExceptionCommon.HandleException(e, ConfigurationManager.AppSettings[JBSFConstants.MAIL_TO].Split(';'), ConfigurationManager.AppSettings[JBSFConstants.MAIL_CC].Split(';'));
            }
        }
    }
}

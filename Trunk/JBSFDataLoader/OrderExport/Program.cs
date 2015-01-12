using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using JBSF.DataLoader.Common;

namespace OrderExport
{
    class Program
    {
        /// <summary>
        /// Export order and order line item data from salesforce
        /// </summary>
        static void Main(string[] args)
        {
            try
            {
                string cliqPath = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_PATH_KEY];
                string cliqOrderExport = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_ORDER_EXPORT_KEY];
                string cliqOrderQueryStr = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_ORDER_QUERY_STR_KEY];

                string cliqLineItemExport = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_LINE_ITEM_EXPORT_KEY];
                string cliqLineItmeQueryStr = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_LINE_ITEM_QUERY_STR_KEY];

                string sfdcUsername = ConfigurationManager.AppSettings[JBSFConstants.SFDC_USERNAME_KEY];
                string sfdcPassword = ConfigurationManager.AppSettings[JBSFConstants.SFDC_PASSWORD_KEY];

                string orderExportXmlPath = ConfigurationManager.AppSettings[JBSFConstants.ORDER_EXPORT_XML_PATH_KEY];
                string sftpUsername = ConfigurationManager.AppSettings[JBSFConstants.SFTP_USERNAME_KEY];
                string sftpPassword = ConfigurationManager.AppSettings[JBSFConstants.SFTP_PASSWORD_KEY];

                OrderService.ExportOrderData(cliqPath, cliqOrderExport, cliqOrderQueryStr);
                OrderLineItemService.ExportLineItemData(cliqPath, cliqLineItemExport, cliqOrderExport, cliqLineItmeQueryStr);
                List<Order> orderList = OrderService.GetOrderListFromCSV(cliqPath, cliqOrderExport, cliqLineItemExport);
                if (orderList.Count > 0)
                {
                    OrderService.GenerateXmlFile(orderList, orderExportXmlPath, sftpUsername, sftpPassword);
                }

                //update sent date field
                string cliqOrderUpsert = ConfigurationManager.AppSettings[JBSFConstants.CLIQ_ORDER_UPSERT_KEY];
                int limits = int.Parse(ConfigurationManager.AppSettings[JBSFConstants.LIMITS_KEY]);
                List<Order> orderIdList = OrderService.GetOrderIdListFromCSV(cliqPath, cliqOrderExport);
                if (orderIdList.Count > 0)
                {
                    OrderService.UpsertOrderData(orderIdList, cliqPath, cliqOrderUpsert, limits, UpsertOrderType.SentDate, sfdcUsername, sfdcPassword);
                }
            }
            catch (Exception e)
            {
                ExceptionCommon.HandleException(e, ConfigurationManager.AppSettings[JBSFConstants.MAIL_TO].Split(';'), ConfigurationManager.AppSettings[JBSFConstants.MAIL_CC].Split(';'));
            }
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml.Linq;
using System.Net;

namespace JBSF.DataLoader.Common
{
    public class OrderService
    {
        /// <summary>
        /// Generate upsert order csv file in read folder
        /// </summary>
        /// <param name="orderList"></param>
        /// <param name="cliqPath"></param>
        /// <param name="cliqUpsert"></param>
        /// <param name="limits"></param>
        public static void GenerateUpsertOrderCSVFile(List<Order> orderList, string cliqPath, string cliqUpsert, int limits, UpsertOrderType upsertType)
        {
            // cleanup write directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files) File.Delete(file);

            if (limits <= 0) limits = orderList.Count;

            for (int i = 0; i < Math.Ceiling(Convert.ToDouble(orderList.Count) / limits); i++)
            {
                using (var writer = new CsvFileWriter(string.Format("{0}\\{1}\\read\\{1}_{2}.csv", cliqPath, cliqUpsert, i + 1)))
                {
                    switch (upsertType)
                    {
                        case UpsertOrderType.All:
                            //add header
                            writer.WriteRow(GenerateOrderCSVHeader());
                            //add rows
                            for (int j = i * limits; j < Math.Min(orderList.Count, (i + 1) * limits); j++)
                            {
                                writer.WriteRow(GenerateOrderRowColumnsValue(orderList[j]));
                            }
                            break;
                        case UpsertOrderType.SentDate:
                            //add header
                            writer.WriteRow(GenerateOrderSentDateCSVHeader());
                            //add rows
                            for (int j = i * limits; j < Math.Min(orderList.Count, (i + 1) * limits); j++)
                            {
                                writer.WriteRow(GenerateOrderSentDateRowColumnsValue(orderList[j]));
                            }
                            break;
                    }
                }
            }
        }

        static List<string> GenerateOrderCSVHeader()
        {
            return JBSFConstants.ORDER_CSV_HEADER.Split(',').ToList();
        }

        static List<string> GenerateOrderRowColumnsValue(Order order)
        {
            List<string> columns = new List<string>();
            columns.Add(order.OrderNumber);
            columns.Add(order.ITVOrderNumber);
            columns.Add(order.AccountNumber);
            columns.Add(order.OrderDate);
            columns.Add(order.OrderValue);
            columns.Add(order.Reference1);
            columns.Add(order.Reference2);
            columns.Add(order.DeliveryNotes);
            columns.Add(order.PaymentMethod);
            columns.Add(order.Status);
            columns.Add(order.CloseDate);
            columns.Add(order.OrderEndCustomer.FirstName);
            columns.Add(order.OrderEndCustomer.LastName);
            columns.Add(order.OrderEndCustomer.Phone);
            columns.Add(order.OrderEndCustomer.Mobile);
            columns.Add(order.OrderEndCustomer.Email);
            columns.Add(order.OrderEndCustomer.Address1);
            columns.Add(order.OrderEndCustomer.Address2);
            columns.Add(order.OrderEndCustomer.Address3);
            columns.Add(order.OrderEndCustomer.Suburb);
            columns.Add(order.OrderEndCustomer.Postcode);
            columns.Add(order.OrderEndCustomer.State);
            columns.Add(order.OrderEndCustomer.Country);
            columns.Add(order.ByPassVR);    //ByPass_VR__c = true
            return columns;
        }

        static List<string> GenerateOrderSentDateCSVHeader()
        {
            return JBSFConstants.ORDER_SENT_DATE_CSV_HEADER.Split(',').ToList();
        }

        static List<string> GenerateOrderSentDateRowColumnsValue(Order order)
        {
            List<string> columns = new List<string>();
            columns.Add(order.OrderNumber);
            columns.Add(DateTime.Now.ToString());
            columns.Add("true");    //ByPass_VR__c
            return columns;
        }

        /// <summary>
        /// Get order list from xml file
        /// </summary>
        /// <param name="orderUpsertXmlPath">order upsert xml path</param>
        /// <returns></returns>
        public static List<Order> GetOrderListFromXml(string orderUpsertXmlPath, string sftpUsername, string sftpPassword)
        {
            List<Order> orderList = new List<Order>();
            MemoryStream xmlFileStream = new MemoryStream();
            DownloadByFtp(orderUpsertXmlPath, xmlFileStream, false, sftpUsername, sftpPassword);

            XDocument doc = XDocument.Load(xmlFileStream);

            if (doc.Root.HasElements)
            {
                orderList = (from order in doc.Root.Elements("Order")
                             select new Order
                             {
                                 OrderNumber = order.Element("OrderNumber").Value,
                                 ITVOrderNumber = order.Element("ITVOrderNumber").Value,
                                 AccountNumber = order.Element("AccountNumber").Value,
                                 OrderDate = order.Element("OrderDate").Value,
                                 OrderValue = order.Element("OrderValue").Value,
                                 Reference1 = order.Element("Reference1").Value,
                                 Reference2 = order.Element("Reference2").Value,
                                 DeliveryNotes = order.Element("DeliveryNotes").Value,
                                 PaymentMethod = order.Element("PaymentMethod") != null ? order.Element("PaymentMethod").Value : string.Empty,
                                 Status = order.Element("Status").Value,
                                 CloseDate = order.Element("CloseDate").Value,
                                 OrderBillingCustomer = GetBillingCustomerInfoFromXml(order),
                                 OrderEndCustomer = GetEndCustomerInfoFromXml(order),
                                 OrderLineItem = GetLineItemListFromXml(order)
                             }).ToList();
            }

            return orderList;
        }

        static BillingCustomer GetBillingCustomerInfoFromXml(XElement order)
        {
            BillingCustomer billingCustomerInfo = new BillingCustomer();
            billingCustomerInfo.AccountNumber = order.Element("AccountNumber").Value;
            return billingCustomerInfo;
        }

        static EndCustomer GetEndCustomerInfoFromXml(XElement order)
        {
            EndCustomer endCustomerInfo = new EndCustomer();
            endCustomerInfo.FirstName = order.Element("EndCustomer").Element("FirstName").Value;
            endCustomerInfo.LastName = order.Element("EndCustomer").Element("LastName").Value;
            endCustomerInfo.Phone = order.Element("EndCustomer").Element("Phone").Value;
            endCustomerInfo.Mobile = order.Element("EndCustomer").Element("Mobile").Value;
            endCustomerInfo.Email = order.Element("EndCustomer").Element("Email").Value;
            endCustomerInfo.Address1 = order.Element("EndCustomer").Element("Address1").Value;
            endCustomerInfo.Address2 = order.Element("EndCustomer").Element("Address2").Value;
            endCustomerInfo.Address3 = order.Element("EndCustomer").Element("Address3").Value;
            endCustomerInfo.Suburb = order.Element("EndCustomer").Element("Suburb").Value;
            endCustomerInfo.Postcode = order.Element("EndCustomer").Element("Postcode").Value;
            endCustomerInfo.State = order.Element("EndCustomer").Element("State").Value;
            endCustomerInfo.Country = order.Element("EndCustomer").Element("Country").Value;
            return endCustomerInfo;
        }

        static List<OrderLineItem> GetLineItemListFromXml(XElement order)
        {
            List<OrderLineItem> lineItemList = new List<OrderLineItem>();

            lineItemList = (from item in order.Elements("LineItems").Elements("LineItem")
                            select new OrderLineItem
                            {
                                LineItemID = item.Element("LineItemID").Value,
                                SKU = item.Element("SKU").Value,
                                Title = item.Element("Title").Value,
                                Quantity = item.Element("Quantity").Value,
                                SalesPriceEx = item.Element("SalesPriceEx").Value,
                                SalesPriceInc = item.Element("SalesPriceInc").Value,
                                DispatchPoint = item.Element("DispatchPoint").Value,
                                FreightMethod = item.Element("FreightMethod").Value,
                                Status = item.Element("Status").Value,
                                CloseDate = item.Element("CloseDate").Value,
                                InvoiceNumber = item.Element("InvoiceNumber").Value
                            }).ToList();

            return lineItemList;
        }

        /// <summary>
        /// Export order data from saleforce. 
        /// Generate order csv file in write folder through call dataloader.
        /// </summary>
        /// <param name="cliqPath"></param>
        /// <param name="cliqExport"></param>
        /// <param name="cliqQueryStr"></param>
        public static void ExportOrderData(string cliqPath, string cliqExport, string cliqQueryStr)
        {
            CLIqCommon.Export(cliqPath, cliqExport, cliqQueryStr);
        }

        /// <summary>
        /// Get order list from csv file
        /// </summary>
        /// <param name="cliqPath"></param>
        /// <param name="cliqOrderExport"></param>
        /// <param name="cliqLineItemExport"></param>
        /// <returns></returns>
        public static List<Order> GetOrderListFromCSV(string cliqPath, string cliqOrderExport, string cliqLineItemExport)
        {
            List<OrderLineItem> lineItemList = OrderLineItemService.GetLineItemListFromCSV(cliqPath, cliqLineItemExport);
            List<Order> orderList = new List<Order>();

            string[] files = Directory.GetFiles(string.Format("{0}\\{1}\\write", cliqPath, cliqOrderExport));

            foreach (string filePath in files)
            {
                List<string> columns = new List<string>();
                using (var reader = new CsvFileReader(filePath))
                {
                    reader.ReadRow(columns); // ignore header
                    while (reader.ReadRow(columns))
                    {
                        orderList.Add(MergeOrderInfo(columns, lineItemList));
                    }
                }
            }

            return orderList;
        }

        static Order MergeOrderInfo(List<string> columns, List<OrderLineItem> lineItemList)
        {
            BillingCustomer billingCustomerInfo = new BillingCustomer();
            billingCustomerInfo.AccountNumber = columns[8];
            billingCustomerInfo.CreditType = columns[9];

            EndCustomer endCustomerInfo = new EndCustomer();
            endCustomerInfo.FirstName = columns[10];
            endCustomerInfo.LastName = columns[11];
            endCustomerInfo.Phone = columns[12];
            endCustomerInfo.Mobile = columns[13];
            endCustomerInfo.Email = columns[14];
            endCustomerInfo.Address1 = columns[15];
            endCustomerInfo.Address2 = columns[16];
            endCustomerInfo.Address3 = columns[17];
            endCustomerInfo.Suburb = columns[18];
            endCustomerInfo.Postcode = columns[19];
            endCustomerInfo.State = columns[20];
            endCustomerInfo.Country = columns[21];

            Order orderInfo = new Order();
            orderInfo.OrderId = columns[0];
            orderInfo.OrderNumber = columns[1];
            orderInfo.AccountNumber = columns[8];
            orderInfo.OrderDate = columns[2];
            orderInfo.OrderValue = columns[3];
            orderInfo.Reference1 = columns[4];
            orderInfo.Reference2 = columns[5];
            orderInfo.DeliveryNotes = columns[6];
            orderInfo.PaymentMethod = columns[7];
            orderInfo.OrderBillingCustomer = billingCustomerInfo;
            orderInfo.OrderEndCustomer = endCustomerInfo;
            orderInfo.OrderLineItem = lineItemList.FindAll(o => o.OrderID == columns[0]);

            return orderInfo;
        }

        /// <summary>
        /// Generate order xml file
        /// </summary>
        /// <param name="orderList">data source</param>
        /// <param name="orderExportXmlPath">order export xml path</param>
        public static void GenerateXmlFile(List<Order> orderList, string orderExportXmlPath, string sftpUsername, string sftpPassword)
        {
            GenerateAccountAccountOrderXmlFile(orderList, orderExportXmlPath, sftpUsername, sftpPassword);
            GenerateCashAccountOrderXmlFile(orderList, orderExportXmlPath, PaymentType.Prepay, sftpUsername, sftpPassword);
            GenerateCashAccountOrderXmlFile(orderList, orderExportXmlPath, PaymentType.PayInStore, sftpUsername, sftpPassword);
        }

        /// <summary>
        /// Generate amount account order xml file
        /// </summary>
        /// <param name="orderList">data source</param>
        /// <param name="orderExportXmlPath">order export xml path</param>
        static void GenerateAccountAccountOrderXmlFile(List<Order> orderList, string orderExportXmlPath, string sftpUsername, string sftpPassword)
        {
            XDocument orderDoc = new XDocument(
                new XElement("Orders",
                    from orderItem in orderList
                    where orderItem.OrderBillingCustomer.CreditType == "Account"
                    select new XElement("Order",
                               new XElement("OrderNumber", orderItem.OrderNumber),
                               new XElement("AccountNumber", orderItem.AccountNumber),
                               new XElement("OrderDate", orderItem.OrderDate),
                               new XElement("OrderValue", orderItem.OrderValue),
                               new XElement("Reference1", orderItem.Reference1),
                               new XElement("Reference2", orderItem.Reference2),
                               new XElement("DeliveryNotes", orderItem.DeliveryNotes),
                               new XElement("EndCustomer",
                                    new XElement("FirstName", orderItem.OrderEndCustomer.FirstName),
                                    new XElement("LastName", orderItem.OrderEndCustomer.LastName),
                                    new XElement("Phone", orderItem.OrderEndCustomer.Phone),
                                    new XElement("Mobile", orderItem.OrderEndCustomer.Mobile),
                                    new XElement("Email", orderItem.OrderEndCustomer.Email),
                                    new XElement("Address1", orderItem.OrderEndCustomer.Address1),
                                    new XElement("Address2", orderItem.OrderEndCustomer.Address2),
                                    new XElement("Address3", orderItem.OrderEndCustomer.Address3),
                                    new XElement("Suburb", orderItem.OrderEndCustomer.Suburb),
                                    new XElement("Postcode", orderItem.OrderEndCustomer.Postcode),
                                    new XElement("State", orderItem.OrderEndCustomer.State),
                                    new XElement("Country", orderItem.OrderEndCustomer.Country)
                                   ),
                               new XElement("LineItems",
                                    from item in orderItem.OrderLineItem
                                    select new XElement("LineItem",
                                                new XElement("LineItemID", item.LineItemID),
                                                new XElement("SKU", item.SKU),
                                                new XElement("Title", item.Title),
                                                new XElement("Quantity", item.Quantity),
                                                new XElement("SalesPriceEx", item.SalesPriceEx),
                                                new XElement("SalesPriceInc", item.SalesPriceInc),
                                                new XElement("DispatchPoint", item.DispatchPoint),
                                                new XElement("FreightMethod", item.FreightMethod)
                                               )
                                   )
                )));

            if (orderDoc.Root.HasElements)
            {
                using (MemoryStream xmlFileStream = new MemoryStream())
                {
                    orderDoc.Save(xmlFileStream);
                    xmlFileStream.Flush();
                    xmlFileStream.Position = 0;
                    UploadByFtp(orderExportXmlPath, xmlFileStream, "AccountOrder", "AccountOrders.xml", sftpUsername, sftpPassword);
                    xmlFileStream.Close();
                }
            }
        }

        /// <summary>
        /// Generate cash account order xml file
        /// </summary>
        /// <param name="orderList">data source</param>
        /// <param name="orderExportXmlPath">order export xml path</param>
        static void GenerateCashAccountOrderXmlFile(List<Order> orderList, string orderExportXmlPath, PaymentType payType, string sftpUsername, string sftpPassword)
        {
            XDocument orderDoc = new XDocument(
                new XElement("Orders",
                    from orderItem in orderList
                    where orderItem.OrderBillingCustomer.CreditType == "Cash" && orderItem.PaymentMethod == payType.ToString()
                    select new XElement("Order",
                               new XElement("OrderNumber", orderItem.OrderNumber),
                               new XElement("AccountNumber", orderItem.AccountNumber),
                               new XElement("OrderDate", orderItem.OrderDate),
                               new XElement("OrderValue", orderItem.OrderValue),
                               new XElement("Reference1", orderItem.Reference1),
                               new XElement("Reference2", orderItem.Reference2),
                               new XElement("DeliveryNotes", orderItem.DeliveryNotes),
                               new XElement("PaymentMethod", orderItem.PaymentMethod),
                               new XElement("EndCustomer",
                                    new XElement("FirstName", orderItem.OrderEndCustomer.FirstName),
                                    new XElement("LastName", orderItem.OrderEndCustomer.LastName),
                                    new XElement("Phone", orderItem.OrderEndCustomer.Phone),
                                    new XElement("Mobile", orderItem.OrderEndCustomer.Mobile),
                                    new XElement("Email", orderItem.OrderEndCustomer.Email),
                                    new XElement("Address1", orderItem.OrderEndCustomer.Address1),
                                    new XElement("Address2", orderItem.OrderEndCustomer.Address2),
                                    new XElement("Address3", orderItem.OrderEndCustomer.Address3),
                                    new XElement("Suburb", orderItem.OrderEndCustomer.Suburb),
                                    new XElement("Postcode", orderItem.OrderEndCustomer.Postcode),
                                    new XElement("State", orderItem.OrderEndCustomer.State),
                                    new XElement("Country", orderItem.OrderEndCustomer.Country)
                                   ),
                               new XElement("LineItems",
                                    from item in orderItem.OrderLineItem
                                    select new XElement("LineItem",
                                                new XElement("LineItemID", item.LineItemID),
                                                new XElement("SKU", item.SKU),
                                                new XElement("Title", item.Title),
                                                new XElement("Quantity", item.Quantity),
                                                new XElement("SalesPriceEx", item.SalesPriceEx),
                                                new XElement("SalesPriceInc", item.SalesPriceInc),
                                                new XElement("DispatchPoint", item.DispatchPoint),
                                                new XElement("FreightMethod", item.FreightMethod)
                                               )
                                   )
                )));

            if (orderDoc.Root.HasElements)
            {
                using (MemoryStream xmlFileStream = new MemoryStream())
                {
                    orderDoc.Save(xmlFileStream);
                    UploadByFtp(orderExportXmlPath, xmlFileStream, payType == PaymentType.Prepay ? "PrepayOrder" : "PayInStoreOrder", payType.ToString() + "Orders.xml", sftpUsername, sftpPassword);
                    xmlFileStream.Close();
                }
            }
        }

        /// <summary>
        /// Upsert order data
        /// </summary>
        /// <param name="orderList"></param>
        /// <param name="cliqPath"></param>
        /// <param name="cliqOrderUpsert"></param>
        /// <param name="limits"></param>
        public static void UpsertOrderData(List<Order> orderList, string cliqPath, string cliqOrderUpsert, int limits, UpsertOrderType upsertType, string sfdcUsername, string sfdcPassword)
        {
            OrderService.GenerateUpsertOrderCSVFile(orderList, cliqPath, cliqOrderUpsert, limits, upsertType);
            CLIqCommon.Upsert(cliqPath, cliqOrderUpsert, sfdcUsername, sfdcPassword);
        }

        /// <summary>
        /// Get order list that just contains id information from csv file
        /// </summary>
        /// <param name="cliqPath"></param>
        /// <param name="cliqExport"></param>
        /// <returns></returns>
        public static List<Order> GetOrderIdListFromCSV(string cliqPath, string cliqExport)
        {
            List<Order> orderList = new List<Order>();

            string[] files = Directory.GetFiles(string.Format("{0}\\{1}\\write", cliqPath, cliqExport));

            foreach (string filePath in files)
            {
                List<string> columns = new List<string>();
                using (var reader = new CsvFileReader(filePath))
                {
                    reader.ReadRow(columns); // ignore header
                    while (reader.ReadRow(columns))
                    {
                        orderList.Add(new Order
                        {
                            OrderId = columns[0],
                            OrderNumber = columns[1]
                        });
                    }
                }
            }

            return orderList;
        }


        /// <summary>
        /// download the file from ftp server
        /// </summary>
        /// <param name="uri">uri</param>
        /// <param name="stream">stream</param>
        /// <param name="isInternalAuth">isInternalAuth</param>
        public static void DownloadByFtp(string uri, MemoryStream stream, bool isInternalAuth, string sftpUserName, string sftpPassword)
        {
            if (!uri.Contains("ftp://"))
                uri = "ftp://" + uri;
                
            FtpWebRequest request = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));
            if (!isInternalAuth)
                request.Credentials = new NetworkCredential(sftpUserName, sftpPassword);
            request.KeepAlive = false;
            request.Method = WebRequestMethods.Ftp.DownloadFile;
            request.UseBinary = true;

            FtpWebResponse response = (FtpWebResponse)request.GetResponse();
            Stream responseStream = response.GetResponseStream();
            int len = 0;

            do
            {
                byte[] buffer = new byte[2048];
                len = responseStream.Read(buffer, 0, buffer.Length);
                stream.Write(buffer, 0, len);
            } while (len > 0);

            responseStream.Close();
            response.Close();

            stream.Position = 0;
        }


        /// <summary>
        /// update the file to ftp server
        /// </summary>
        /// <param name="ftpAddress">ftp address</param>
        /// <param name="fileStream">file stream</param>
        /// <param name="fileName">file name on ftp server</param>
        public static void UploadByFtp(string ftpAddress, MemoryStream fileStream, string folderName, string fileName, string sftpUsername, string sftpPassword)
        {
            string uri = string.Empty;
            if (ftpAddress.Contains("ftp://"))
            {
                uri = ftpAddress;
            }
            else
            {
                uri = "ftp://" + ftpAddress;
            }
            if (!string.IsNullOrEmpty(folderName)) 
            {
                uri = uri.TrimEnd('/') + "/" + folderName;
            }
            if (!string.IsNullOrEmpty(fileName))
            {
                uri = uri.TrimEnd('/') + "/" + fileName;
            }
            FtpWebRequest request = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));
            request.Credentials = new NetworkCredential(sftpUsername, sftpPassword);
            request.KeepAlive = false;
            request.Method = WebRequestMethods.Ftp.UploadFile;
            request.UseBinary = true;
            request.ContentLength = fileStream.Length;

            byte[] buffer = fileStream.GetBuffer();
            Stream stream = request.GetRequestStream();
            stream.Write(buffer, 0, buffer.Length);
            stream.Close();
        }

    }
}

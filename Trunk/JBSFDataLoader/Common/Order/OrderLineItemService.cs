using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace JBSF.DataLoader.Common
{
    public class OrderLineItemService
    {
        /// <summary>
        /// Generate upsert order line item csv file in read folder
        /// </summary>
        /// <param name="lineItemList"></param>
        /// <param name="cliqPath"></param>
        /// <param name="cliqUpsert"></param>
        /// <param name="limits"></param>
        public static void GenerateUpsertLineItemCSVFile(List<OrderLineItem> lineItemList, string cliqPath, string cliqUpsert, int limits)
        {
            // cleanup write directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files) File.Delete(file);

            if (limits <= 0) limits = lineItemList.Count;

            for (int i = 0; i < Math.Ceiling(Convert.ToDouble(lineItemList.Count) / limits); i++)
            {
                using (var writer = new CsvFileWriter(string.Format("{0}\\{1}\\read\\{1}_{2}.csv", cliqPath, cliqUpsert, i + 1)))
                {
                    //add header
                    writer.WriteRow(GenerateLineItemCSVHeader());
                    //add rows
                    for (int j = i * limits; j < Math.Min(lineItemList.Count, (i + 1) * limits); j++)
                    {
                        writer.WriteRow(GenerateLineItemRowColumnsValue(lineItemList[j]));
                    }
                }
            }
        }

        static List<string> GenerateLineItemCSVHeader()
        {
            return JBSFConstants.LINE_ITEM_CSV_HEADER.Split(',').ToList();
        }

        static List<string> GenerateLineItemRowColumnsValue(OrderLineItem lineItem)
        {
            List<string> columns = new List<string>();
            columns.Add(lineItem.LineItemID);
            columns.Add(lineItem.SKU);
            columns.Add(lineItem.Title);
            columns.Add(lineItem.Quantity);
            columns.Add(lineItem.SalesPriceEx);
            columns.Add(lineItem.SalesPriceInc);
            columns.Add(lineItem.DispatchPoint);
            columns.Add(lineItem.FreightMethod);
            columns.Add(lineItem.Status);
            columns.Add(lineItem.CloseDate);
            columns.Add(lineItem.InvoiceNumber);
            columns.Add(lineItem.ByPassVR);    //ByPass_VR__c = true
            return columns;
        }

        /// <summary>
        /// Export order line item data from saleforce. 
        /// Generate order line item csv file in write folder through call dataloader.
        /// </summary>
        /// <param name="cliqPath"></param>
        /// <param name="cliqLineItemExport"></param>
        /// <param name="cliqOrderExport"></param>
        /// <param name="cliqBaseQueryStr"></param>
        public static void ExportLineItemData(string cliqPath, string cliqLineItemExport, string cliqOrderExport, string cliqBaseQueryStr)
        {
            string cliqQueryStr = GenerateOrderLineItemQueryStr(cliqPath, cliqOrderExport, cliqBaseQueryStr);
            CLIqCommon.Export(cliqPath, cliqLineItemExport, cliqQueryStr);
        }

        static string GenerateOrderLineItemQueryStr(string cliqPath, string cliqOrderExport, string cliqBaseQueryStr)
        {
            string cliqQueryStr = cliqBaseQueryStr + " Where Order__r.Id in (";
            List<Order> orderIdList = OrderService.GetOrderIdListFromCSV(cliqPath, cliqOrderExport);
            int length = orderIdList.Count;
            for (int i = 0; i < length; i++)
            {
                if (i == length - 1)
                {
                    cliqQueryStr += "'" + orderIdList[i].OrderId + "')";
                }
                else
                {
                    cliqQueryStr += "'" + orderIdList[i].OrderId + "', ";
                }
            }

            return cliqQueryStr;
        }

        /// <summary>
        /// Get order line item list from csv file.
        /// </summary>
        /// <param name="cliqPath"></param>
        /// <param name="cliqExport"></param>
        /// <returns></returns>
        public static List<OrderLineItem> GetLineItemListFromCSV(string cliqPath, string cliqExport)
        {
            List<OrderLineItem> lineItemList = new List<OrderLineItem>();

            string[] files = Directory.GetFiles(string.Format("{0}\\{1}\\write", cliqPath, cliqExport));

            foreach (string filePath in files)
            {
                List<string> columns = new List<string>();
                using (var reader = new CsvFileReader(filePath))
                {
                    reader.ReadRow(columns); // ignore header
                    while (reader.ReadRow(columns))
                    {
                        lineItemList.Add(new OrderLineItem
                        {
                            LineItemID = columns[0],
                            SKU = columns[1],
                            Title = columns[2],
                            Quantity = columns[3],
                            SalesPriceEx = columns[4],
                            SalesPriceInc = columns[5],
                            DispatchPoint = columns[6],
                            FreightMethod = columns[7],
                            OrderID = columns[8]
                        });
                    }
                }
            }

            return lineItemList; ;
        }

        /// <summary>
        /// Upsert order line item data.
        /// </summary>
        /// <param name="orderList"></param>
        /// <param name="cliqPath"></param>
        /// <param name="cliqLineItemUpsert"></param>
        /// <param name="limits"></param>
        public static void UpsertLineItemData(List<Order> orderList, string cliqPath, string cliqLineItemUpsert, int limits, string sfdcUsername, string sfdcPassword)
        {
            List<OrderLineItem> lineItemList = new List<OrderLineItem>();
            lineItemList = (from lineItem in orderList
                            from item in lineItem.OrderLineItem
                            where !lineItemList.Contains(item)
                            select item).ToList();

            OrderLineItemService.GenerateUpsertLineItemCSVFile(lineItemList, cliqPath, cliqLineItemUpsert, limits);
            CLIqCommon.Upsert(cliqPath, cliqLineItemUpsert, sfdcUsername, sfdcPassword);
        }
    }
}

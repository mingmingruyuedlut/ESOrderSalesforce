using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JBSF.DataLoader.Common
{
    public class OrderLineItem
    {
        public string LineItemID { get; set; }
        public string SKU { get; set; }
        public string Title { get; set; }
        public string Quantity { get; set; }
        public string SalesPriceEx { get; set; }
        public string SalesPriceInc { get; set; }
        public string DispatchPoint { get; set; }
        public string FreightMethod { get; set; }
        public string Status { get; set; }
        public string CloseDate { get; set; }
        public string InvoiceNumber { get; set; }
        public string OrderID { get; set; }
        public string ByPassVR { get { return "true"; } }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JBSF.DataLoader.Common
{
    public class Order
    {
        public string OrderId { get; set; }
        public string OrderNumber { get; set; }
        public string ITVOrderNumber { get; set; }
        public string AccountNumber { get; set; }
        public string OrderDate { get; set; }
        public string OrderValue { get; set; }
        public string Reference1 { get; set; }
        public string Reference2 { get; set; }
        public string DeliveryNotes { get; set; }
        public string PaymentMethod { get; set; }
        public string Status { get; set; }
        public string CloseDate { get; set; }
        public BillingCustomer OrderBillingCustomer { get; set; }
        public EndCustomer OrderEndCustomer { get; set; }
        public List<OrderLineItem> OrderLineItem { get; set; }
        public string ByPassVR { get { return "true"; } }
    }

    public enum UpsertOrderType
    {
        All,
        SentDate
    }

    public enum PaymentType
    { 
        Prepay,
        PayInStore
    }
}

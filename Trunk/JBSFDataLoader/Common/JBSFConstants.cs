using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JBSF.DataLoader.Common
{
    public class JBSFConstants
    {
        //csv header
        public const string ORDER_SENT_DATE_CSV_HEADER = "ORDER_NUMBER__C,SENT_DATE__C,BYPASS_VR__C";
        public const string ORDER_CSV_HEADER = "ORDER_NUMBER__C,ITV_ORDER_NUMBER__C,ACCOUNTNUMBER__C,CREATE_DATE__C,TOTAL_PRICE_INC__C,REFERENCE_NUMBER_1__C,REFERENCE_NUMBER_2__C,DELIVERY_NOTES__C,PAYMENTMETHOD__C,STATUS__C,CLOSE_DATE__C,FIRST_NAME__C,LAST_NAME__C,PHONE__C,MOBILE__C,EMAIL__C,ADDRESS_1__C,ADDRESS_2__C,ADDRESS_3__C,SUBURB__C,POSTCODE__C,STATE__C,COUNTRY__C,BYPASS_VR__C";
        public const string LINE_ITEM_CSV_HEADER = "ID,SKU__C,NAME,QUANTITY__C,COST_EX__C,COST_INC__C,DISPATCHPOINT__C,FREIGHT_METHOD__C,STATUS__C,CLOSE_DATE__C,INVOICE_NUMBER__C,BYPASS_VR__C";
        //public const string PRODUCT_CSV_HEADER = "SKU__C,NAME,MODEL__C,MANUFACTURER__C,SUPPLIER__C,DEPARTMENT__C,PRODUCT_GROUP__C,ONLINE_TITLE__C,ONLINE__C,SEASON_CODE__C,SOH__C,COST_EX_GST__C,COST_INC_GST__C,FLOOR_PRICE__C,TICKET_PRICE__C,PROMOTION_PRICE__C,SHORT_DESCRIPTION__C,LONG_DESCRIPTION__C";
        public const string PRODUCT_CSV_HEADER = "MODEL__C,SKU__C,NAME,PLU__C,GO_COST__C,TICKET_PRICE__C,PROMOTION_PRICE__C,INVOICE_COST_INC__C,INVOICE_COST_EX__C,REBATE__C,ONLINE_TITLE__C,DESCRIPTION,MANUFACTURER__C,ISACTIVE,DEPARTMENT__C,PRODUCT_GROUP__C,ONLINE__C,LONG_DESCRIPTION__C,SHORT_DESCRIPTION__C,SEASON_CODE__C,RELEASE_DATE__C,LAST_MODIFIED_DATE__C,FEATURES__C,ONLINE_CATEGORY__C,PACKAGING__C,PACKAGING_HEIGHT_MM__C,PACKAGING_LENGTH_MM__C,PACKAGING_WIDTH_MM__C,PACKAGING_WEIGHT_KG__C,PRODUCT_HEIGHT_MM__C,PRODUCT_LENGTH_MM__C,PRODUCT_WIDTH_MM__C,PRODUCT_WEIGHT_KG__C,SOH__C,SCANBACK_VALUE__C,COST_INC_GST__C,COST_EX_GST__C,SCANBACK_VALUE_START__C,SCANBACK_VALUE_CEASE__C,PROMOTION_PRICE_START__C,PROMOTION_PRICE_CEASE__C";
        public const string ACCOUNT_CSV_HEADER = "ID,NAME,ACCOUNTNUMBER,ABN__C,GP_ID__C,BILLINGSTREET,BILLINGCITY,BILLINGPOSTALCODE,BILLINGSTATE,PHONE,TAX__C,EMAIL__C,CREDIT_TYPE__C";
        
        //email
        public const string MAIL_TO = "mail_to";
        public const string MAIL_CC = "mail_cc";
        
        //cliq path key
        public const string CLIQ_PATH_KEY = "dataloader_cliq_path";
        public const string CLIQ_EXPORT_KEY = "dataloader_cliq_export";
        public const string CLIQ_UPSERT_KEY = "dataloader_cliq_upsert";
        public const string FEED_PATH_KEY = "feed";
        public const string LIMITS_KEY = "limits";
        public const string SFDC_USERNAME_KEY = "sfdc.username";
        public const string SFDC_PASSWORD_KEY = "sfdc.password";

        //order export
        public const string CLIQ_ORDER_EXPORT_KEY = "dataloader_cliq_export_order";
        public const string CLIQ_ORDER_QUERY_STR_KEY = "sfdc.extractionSOQL.order";

        //lineitem export
        public const string CLIQ_LINE_ITEM_EXPORT_KEY = "dataloader_cliq_export_orderlineitem";
        public const string CLIQ_LINE_ITEM_QUERY_STR_KEY = "sfdc.extractionSOQL.orderlineitem";

        public const string ORDER_EXPORT_XML_PATH_KEY = "order_xml_export_path";

        //upsert
        public const string CLIQ_LINE_ITEM_UPSERT_KEY = "dataloader_cliq_upsert_orderlineitem";
        public const string CLIQ_ORDER_UPSERT_KEY = "dataloader_cliq_upsert_order";

        public const string ORDER_UPSERT_XML_PATH_KEY = "order_xml_upsert_path";

        //export and upsert flag
        public const string EXPORT_DATA_FLAG_KEY = "export_data_flag";
        public const string UPSERT_EXPORT_DATA_FLAG_KEY = "upsert_data_flag";

        //sftp
        public const string SFTP_USERNAME_KEY = "sftp_username";
        public const string SFTP_PASSWORD_KEY = "sftp_password";
    }
}

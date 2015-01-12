using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml.Linq;
using JBSF.DataLoader.Common;

namespace AccountInitialLoad
{
    public class AccountService
    {
        public static List<Account> GetAccountListFromXml(string feedPath)
        {
            List<Account> accountList = new List<Account>();
            if (File.Exists(feedPath))
            {
                XDocument doc = XDocument.Load(feedPath);

                accountList = (from order in doc.Root.Elements("Customer")
                               select new Account
                               {
                                   AccountID = string.Empty,
                                   AccountName = order.Element("AccountName").Value,
                                   AccountNumber = order.Element("AccountNumber").Value,
                                   ABN = order.Element("ABN").Value,
                                   GPID = order.Element("GPID").Value,
                                   Address = order.Element("Address").Value,
                                   Suburb = order.Element("Suburb").Value,
                                   Postcode = order.Element("Postcode").Value,
                                   State = order.Element("State").Value,
                                   Phone = order.Element("Phone").Value,
                                   Tax = order.Element("Tax").Value,
                                   Email = order.Element("Email").Value,
                                   CreditType = order.Element("CreditType").Value
                               }).ToList();
            }

            return accountList;
        }

        public static void GenerateUpsertAccountDataCSVFile(List<Account> accountList, string cliqPath, string cliqUpsert, int limits)
        {
            // cleanup write directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files) File.Delete(file);

            if (limits <= 0) limits = accountList.Count;

            for (int i = 0; i < Math.Ceiling(Convert.ToDouble(accountList.Count) / limits); i++)
            {
                using (var writer = new CsvFileWriter(string.Format("{0}\\{1}\\read\\{1}_{2}.csv", cliqPath, cliqUpsert, i + 1)))
                {
                    //add header
                    writer.WriteRow(GenerateAccountCSVHeader());
                    //add rows
                    for (int j = i * limits; j < Math.Min(accountList.Count, (i + 1) * limits); j++)
                    {
                        writer.WriteRow(GenerateAccountRowColumnsValue(accountList[j]));
                    }
                }
            }
        }

        static List<string> GenerateAccountCSVHeader()
        {
            return JBSFConstants.ACCOUNT_CSV_HEADER.Split(',').ToList();
        }

        static List<string> GenerateAccountRowColumnsValue(Account account)
        {
            List<string> columns = new List<string>();
            columns.Add(account.AccountID);
            columns.Add(account.AccountName);
            columns.Add(account.AccountNumber);
            columns.Add(account.ABN);
            columns.Add(account.GPID);
            columns.Add(account.Address);
            columns.Add(account.Suburb);
            columns.Add(account.Postcode);
            columns.Add(account.State);
            columns.Add(account.Phone);
            columns.Add(account.Tax);
            columns.Add(account.Email);
            columns.Add(account.CreditType);
            return columns;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using JBSF.DataLoader.Common;

namespace ProductImport
{
    public class ProductService
    {
        public static void GenerateUpsertFile(List<Product> products, string cliqPath, string cliqUpsert, int limits)
        {
            // cleanup write directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files) File.Delete(file);

            if (limits <= 0) limits = products.Count;

            for (int i = 0; i < Math.Ceiling(Convert.ToDouble(products.Count) / limits); i++)
            {
                using (var writer = new CsvFileWriter(string.Format("{0}\\{1}\\read\\{1}_{2}.csv", cliqPath, cliqUpsert, i + 1)))
                {
                    //add header
                    writer.WriteRow(GenerateProductCSVHeader());
                    //add rows
                    for (int j = i * limits; j < Math.Min(products.Count, (i + 1) * limits); j++)
                    {
                        writer.WriteRow(GenerateProductRowColumnsValue(products[j]));
                    }
                }
            }
        }

        static List<string> GenerateProductCSVHeader()
        {
            return JBSFConstants.PRODUCT_CSV_HEADER.Split(',').ToList();
        }

        static List<string> GenerateProductRowColumnsValue(Product product)
        {
            List<string> columns = new List<string>();
            columns.Add(product.Model);
            columns.Add(product.SKU);
            columns.Add(product.Name);
            columns.Add(product.PLU);
            columns.Add(product.GoCost);
            columns.Add(product.TicketPrice);
            columns.Add(product.PromotionPrice);
            columns.Add(product.InvoiceCostInc);
            columns.Add(product.InvoiceCostEx);
            columns.Add(product.Rebate);
            columns.Add(product.OnlineTitle);
            columns.Add(product.Description);
            columns.Add(product.Manufacturer);
            columns.Add(product.IsActive);
            columns.Add(product.Department);
            columns.Add(product.ProductGroup);
            columns.Add(product.Online);
            columns.Add(product.LongDescription);
            columns.Add(product.ShortDescription);
            columns.Add(product.SeasonCode);
            columns.Add(product.ReleaseDate);
            columns.Add(product.LastModifiedDate);
            columns.Add(product.Features);
            columns.Add(product.OnlineCategory);
            columns.Add(product.Packaging);
            columns.Add(product.PackagingHeight);
            columns.Add(product.PackagingLength);
            columns.Add(product.PackagingWidth);
            columns.Add(product.PackagingWeight);
            columns.Add(product.ProductHeight);
            columns.Add(product.ProductLength);
            columns.Add(product.ProductWidth);
            columns.Add(product.ProductWeight);
            columns.Add(product.SOH);
            columns.Add(product.ScanbackValue);
            columns.Add(product.CostInc);
            columns.Add(product.CostEx);
            columns.Add(product.ScanbackValueStart);
            columns.Add(product.ScanbackValueCease);
            columns.Add(product.PromotionPriceStart);
            columns.Add(product.PromotionPriceCease);
            return columns;
        }

        public static List<Product> ReadDataFeed(string feedPath)
        {
            var products = new List<Product>();
            if (!File.Exists(feedPath)) return products;

            List<string> columns = new List<string>();
            using (var reader = new CsvFileReader(feedPath))
            {
                reader.ReadRow(columns); // ignore header
                while (reader.ReadRow(columns))
                {
                    products.Add(new Product
                    {
                        Model = columns[1].Trim('"'),
                        SKU = columns[2].Trim('"'),
                        Name = columns[3].Trim('"'),
                        PLU = columns[4].Trim('"'),
                        GoCost = columns[5].Trim('"'),
                        TicketPrice = columns[6].Trim('"'),
                        PromotionPrice = columns[8].Trim('"'),
                        InvoiceCostInc = columns[9].Trim('"'),
                        InvoiceCostEx = columns[10].Trim('"'),
                        Rebate = columns[13].Trim('"'),
                        OnlineTitle = columns[15].Trim('"'),
                        Description = columns[16].Trim('"'),
                        Manufacturer = columns[17].Trim('"'),
                        IsActive = columns[18].Trim('"').Equals("1") ? "0" : "1", // 1 ==> true(select checkbox), 0 ==> false(unselect checkbox)
                        Department = columns[20].Trim('"'),
                        ProductGroup = columns[21].Trim('"'),
                        Online = columns[22].Trim('"'),
                        LongDescription = GenerateLongDescription(columns[23].Trim('"'), columns[30].Trim('"')),
                        ShortDescription = columns[24].Trim('"'),
                        SeasonCode = columns[25].Trim('"'),
                        ReleaseDate = columns[26].Trim('"'),
                        LastModifiedDate = columns[27].Trim('"'),
                        Features = columns[28].Trim('"'),
                        OnlineCategory = columns[29].Trim('"'),
                        ImageURL = columns[30].Trim('"'),
                        Packaging = columns[31].Trim('"'),
                        PackagingHeight = columns[32].Trim('"'),
                        PackagingLength = columns[33].Trim('"'),
                        PackagingWidth = columns[34].Trim('"'),
                        PackagingWeight = columns[35].Trim('"'),
                        ProductHeight = columns[36].Trim('"'),
                        ProductLength = columns[37].Trim('"'),
                        ProductWidth = columns[38].Trim('"'),
                        ProductWeight = columns[39].Trim('"'),
                        SOH = columns[40].Trim('"'),
                        ScanbackValue = columns[41].Trim('"'),
                        CostEx = columns[42].Trim('"'),
                        CostInc = columns[43].Trim('"'),
                        ScanbackValueStart = columns[44].Trim('"'),
                        ScanbackValueCease = columns[45].Trim('"'),
                        PromotionPriceStart = columns[46].Trim('"'),
                        PromotionPriceCease = columns[47].Trim('"')
                    });
                }
            }

            return products;
        }

        static string GenerateLongDescription(string originalLongDes, string imageUrl)
        {
            string longDes = originalLongDes;
            if (!string.IsNullOrEmpty(imageUrl))
            {
                longDes = "<img alt=\"User-added image\" style=\"float:left; padding-right:10px;\" src=\"" + imageUrl + "\"></img>" + originalLongDes;
            }
            return longDes;
        }

        public static void Merge(List<Product> products, string cliqPath, string cliqUpsert, int limits)
        {
            // cleanup read directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files) File.Delete(file);

            ProductService.GenerateUpsertFile(products, cliqPath, cliqUpsert, limits);
        }
    }
}

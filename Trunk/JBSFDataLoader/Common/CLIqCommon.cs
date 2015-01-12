using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Xml;
using System.Diagnostics;

namespace JBSF.DataLoader.Common
{
    public class CLIqCommon
    {
        static StringBuilder cmd_output = new StringBuilder();

        public static void Export(string cliqPath, string cliqExport, string queryStr)
        {
            // cleanup write directory
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\write", cliqPath, cliqExport));
            foreach (var file in files) File.Delete(file);

            if (!string.IsNullOrEmpty(queryStr))
            {
                string configPath = string.Format("{0}\\{1}\\config\\process-conf.xml", cliqPath, cliqExport);
                var xmlConfig = new XmlDocument();
                xmlConfig.Load(configPath);
                xmlConfig.DocumentElement.SelectSingleNode("//map/entry[@key='sfdc.extractionSOQL']").Attributes["value"].Value = queryStr;
                xmlConfig.Save(configPath);
            }

            // export
            var success = ExecCliq(cliqPath, cliqExport);

            if (!success)
            {
                throw new Exception(string.Format("Salesforce Data Loader {0} failed.\r\n"
                        + "See the command line output below, and check the log directory for additional information.\r\n"
                        + "{1}",
                    cliqExport, cmd_output.ToString()));
            }
        }

        public static void Upsert(string cliqPath, string cliqUpsert, string username, string password)
        {
            // Upsert
            var files = Directory.GetFiles(string.Format("{0}\\{1}\\read", cliqPath, cliqUpsert));
            foreach (var file in files)
            {
                // process-conf.xml
                string configPath = string.Format("{0}\\{1}\\config\\process-conf.xml", cliqPath, cliqUpsert);
                var xmlConfig = new XmlDocument();
                xmlConfig.Load(configPath);
                xmlConfig.DocumentElement.SelectSingleNode("//map/entry[@key='dataAccess.name']").Attributes["value"].Value = file;
                xmlConfig.DocumentElement.SelectSingleNode("//map/entry[@key='sfdc.username']").Attributes["value"].Value = username;
                xmlConfig.DocumentElement.SelectSingleNode("//map/entry[@key='sfdc.password']").Attributes["value"].Value = password;
                xmlConfig.Save(configPath);

                // export
                var success = ExecCliq(cliqPath, cliqUpsert);

                if (!success)
                {
                    throw new Exception(string.Format("Salesforce Data Loader {0} failed at processing {1}.\r\n"
                        + "See the command line output below, and check the log directory for additional information.\r\n"
                        + "{2}",
                    cliqUpsert, Path.GetFileName(file), cmd_output.ToString()));
                }
            }
        }

        static bool ExecCliq(string cliqPath, string cliqName)
        {
            Process p = new Process();
            p.StartInfo = new ProcessStartInfo();
            p.StartInfo.WorkingDirectory = string.Format("{0}\\{1}", cliqPath, cliqName);
            p.StartInfo.FileName = string.Format("{0}\\{1}\\{1}.bat", cliqPath, cliqName);
            p.StartInfo.CreateNoWindow = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.OutputDataReceived += new DataReceivedEventHandler(OutputDataReceived);
            cmd_output.Clear();
            p.Start();
            p.BeginOutputReadLine();
            p.WaitForExit();
            if (p.ExitCode != 0)
                return false;
            else
            {
                bool success = true;

                var dir = new DirectoryInfo(string.Format("{0}\\{1}\\log", cliqPath, cliqName));
                var file = dir.GetFiles("error*.*", SearchOption.TopDirectoryOnly).OrderByDescending(f => f.LastWriteTime).First();

                using (StreamReader sr = new StreamReader(file.FullName))
                {
                    string line = sr.ReadLine();
                    if (string.IsNullOrEmpty(line)) // error log file should at least contain header line, otherwise, process was failed.
                    {
                        success = false;
                    }
                    else
                    {
                        line = sr.ReadLine();
                        if (!string.IsNullOrEmpty(line)) // error log has error lines
                            success = false;
                    }
                    sr.Close();
                }

                return success;
            }
        }

        static void OutputDataReceived(object sender, DataReceivedEventArgs e)
        {
            cmd_output.AppendLine(e.Data);
            Console.WriteLine(e.Data);
        }
    }
}

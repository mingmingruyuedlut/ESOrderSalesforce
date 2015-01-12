SET DLPATH="C:\Program Files (x86)\salesforce.com\Data Loader"
SET DLCONF="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Upsert_OrderLineItem\config"
SET DLDATA="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Upsert_OrderLineItem\write"
call %DLPATH%\Java\bin\java.exe -cp %DLPATH%\* -Dsalesforce.config.dir=%DLCONF% com.salesforce.dataloader.process.ProcessRunner process.name=Upsert_OrderLineItem
REM To rotate your export files, uncomment the line below
REM copy %DLDATA%\Upsert_OrderLineItem.csv %DLDATA%\%date:~10,4%%date:~7,2%%date:~4,2%-%time:~0,2%-Upsert_OrderLineItem.csv

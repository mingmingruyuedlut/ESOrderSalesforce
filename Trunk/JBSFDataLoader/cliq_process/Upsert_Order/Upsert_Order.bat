SET DLPATH="C:\Program Files (x86)\salesforce.com\Data Loader"
SET DLCONF="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Upsert_Order\config"
SET DLDATA="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Upsert_Order\write"
call %DLPATH%\Java\bin\java.exe -cp %DLPATH%\* -Dsalesforce.config.dir=%DLCONF% com.salesforce.dataloader.process.ProcessRunner process.name=Upsert_Order
REM To rotate your export files, uncomment the line below
REM copy %DLDATA%\Upsert_Order.csv %DLDATA%\%date:~10,4%%date:~7,2%%date:~4,2%-%time:~0,2%-Upsert_Order.csv

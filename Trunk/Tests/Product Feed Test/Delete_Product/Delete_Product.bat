SET DLPATH="C:\Program Files (x86)\salesforce.com\Data Loader"
SET DLCONF="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Delete_Product\config"
SET DLDATA="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Delete_Product\write"
call %DLPATH%\Java\bin\java.exe -cp %DLPATH%\* -Dsalesforce.config.dir=%DLCONF% com.salesforce.dataloader.process.ProcessRunner process.name=Delete_Product
REM To rotate your export files, uncomment the line below
REM copy %DLDATA%\Delete_Product.csv %DLDATA%\%date:~10,4%%date:~7,2%%date:~4,2%-%time:~0,2%-Delete_Product.csv

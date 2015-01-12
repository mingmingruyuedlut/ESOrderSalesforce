#!/bin/sh
export DLPATH="C:\Program Files (x86)\salesforce.com\Data Loader"
export DLCONF="C:\Program Files (x86)\salesforce.com\Data Loader\cliq_process\Delete_Product\config"
java -cp "$DLPATH/*" -Dsalesforce.config.dir=$DLCONF com.salesforce.dataloader.process.ProcessRunner process.name=Delete_Product

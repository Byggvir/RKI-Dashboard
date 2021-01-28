# RKI-Dashboard
Download and evaluted data from RKI-dashboard with R.

# Setup MariaDb

Script: bin/setup

File: SQL/setup.sql

# Stored procedures

The Rscripts use stored procedure located in SQL/*.sql

# Download of RKI Dashboard data

File: bin/download_dashboard

Because the download is very slow from my DSL connection I download the data as CSV file to my server and compress it with gzip. After the compression I publish the gz file on my server.

For local use I download the data from my sever.

# Creating the MariaDB RKI

The local Download creates a MariaDB **RKI**. The tables are recreated with every download, because there is no trustworthy identifier to merge old entries with new ones.

## Warning

The data is updates daily by the **Rober Koch Institute (RKI)**. But the qualtiy assurence needs a lot improvement. Obviously different employies use different scripts to extract and upload the dashboard data.

The field of the **ObjectId** is sometimes the first field, sometimes the field before **Meldedatum**.

Sometime data is missing.


Quellenvermerk: Robert Koch-Institut (RKI), dl-de/by-2-0 [arcgis](https://www.arcgis.com/home/item.html?id=f10774f1c63e40168479a1feb6c7ca74)




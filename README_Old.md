Missouri Vehicle Stops Disparity Index Scraping
 R code and instructions on how to scrape the disparity index for Missouri traffics stops for the years 2000 to 2022 from the 2022 Missouri Vehicle Stops Report.
 This consists of the annual disparity index data for police traffic stops broken down by ethnicity from 546 Missouri police departments.
 
 The file`Missouri_RDI_Index.xlsx.` contains the cleaned, scrapped data from the  R script. 
 The 2022 PDF and PDF for year specific traffic stops data are available from: https://ago.mo.gov/get-help/vehicle-stops-report/.
 
 ##Instructions for running the R scraping script
 
 Instructions to download rJava (required for pdf scraping with tabulapdf) are available from: https://github.com/ropensci/tabulapdf/.
 
 Once installed, you may have to find where your local install version of Java is on your computer
 by typing 'where java' in the command prompt. 
 
 Before running the script, you may need to tell R where to find your local install version
 by setting your system environment - i.e. Sys.setenv(JAVA_HOME="insert/your/path/java"). 
 
 Files/scripts

 `vsrreport2022.pdf`: The pdf report where the vehicle disparity index tables for years 2000 to 2022 can be found.
 
 `rdi_scraping_2000_2022.R`: The R code to scrape the pdf and extract the data into a xlsx file.
 
 `Missouri_RDI_Index.xlsx`: The xlsx file with the output from the scraping file. Sheet 1 (RDI) contains
 the Racial Disparity Index in the "wide" format, while Sheet 2 (RDI_long) displays the output in the "long"
 format. 

Variable Descriptions

Missouri_RDI_Index.xlsx(Sheet = RDI)
| Column | Description | 
|---|---|
| `dept_year_id`|  Department Year ID - starting with 1.1 - first department, year 2000.|
| `department`  | Name of the police department.|
| `year`  |Observation year/time period.|
| `white` | RDI for white drivers who were stopped.|
| `black` | RDI for black drivers who were stopped.|
| `hispanic` | RDI for hispanic drivers who were stopped.|
| `native_american` | RDI for native american drivers who were stopped.|
| `asian` | RDI for asian drivers who were stopped.|
| `other` | RDI for drivers who stopped who do not fit into previous race categories.|


Missouri_RDI_Index.xlsx(Sheet = RDI_long)
| Column | Description | 
|---|---|
| `dept_year_id`|  Department Year ID - starting with 1.1 - first department, year 2000.|
| `department`  | Name of the police department.|
| `year`  |Observation year/time period.|
| `race`  |Race of driver stopped: white, black, hispanic, native ameriacn, asian, or other.|
| `disparity_index`  |Value of the disparity index|


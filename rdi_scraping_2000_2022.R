##R script for cleaning the Missouri Motor Vehicle stops data
#See the README for instructions on installing rJava and tabulapdf.
#Note: both rJava and tabula pdf are required for pdf scraping. 

#install pacman for loading in packages
# install.packages("pacman")

#You may have to set your system environment for r Java and tabulapdf - do this prior to loading rjava and tabulapdf.
#This tells your computer where to find the local install of java.
#Sys.setenv(JAVA_HOME="insert/your/path/java")


#Load in packages
pacman::p_load(tidyverse,
               janitor, #cleaning names/duplicates
               rJava,   #required for tabula pdf
               tabulapdf, #scraping pdfs with java
               pdfsearch, #extracting pdf headers
               pdftools, #working with pdfs
               openxlsx) #exporting multiple sheets


#Find the headings for tables using the headings search from pdf search. 
headings <- pdfsearch::heading_search("vsrreport2022.pdf", 
                                      full_line = FALSE,
                                      headings = c('Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5'),
                                      pdf_toc = TRUE,
                                      path = TRUE)

#Headings look slightly off - for example a bunch of departments are on the wrong page.
#It looks like pdf search is struggling to identify the page numbers of tables
#for county sherrif's offices.
#In addition, Table 1 for Adrian Police Department is on page 18 of the pdf,
#but the heading identifies it as being on page 22. 
#Clearly pdfsearch is struggling to identify the correct page numbers for the tables. 

#Create a dataframe of department names from the keyword from the headings. 
departments_names <- headings |> 
  dplyr::distinct(keyword)


#Instead of relying on pdfsearch we can exploit the pattern for each table to create
#a custom list of table numbers for each department. 

#Table of contents goes from page 11 to page 3827 by 7, - 
#with a new department every 7 pages.
table_numbers <- seq(11, 3827, by = 7) |> 
  #convert to dataframe
  as.data.frame() |> 
  #rename the column name to table_1
  dplyr::rename(table_1 = `seq(11, 3827, by = 7)`)

#Fill in the table names by exploiting that every table starts on its own page
#from where its position is in the table of contents. 
table_numbers <- table_numbers |>  
  dplyr::mutate(table_2 = table_1 + 2,
                table_3 = table_1 + 3,
                table_4 = table_1 + 5,
                table_5 = table_1 + 6)

#Bind the departments and table numbers together.
table_numbers <- dplyr::bind_cols(departments_names, table_numbers) |> 
                 dplyr::rename(department = keyword) |> 
                 as.matrix()


#Put departments into a list with elements for each department. 
departments_list <- split(departments_names, 1:nrow(departments_names))


#Extract the racial disparity index for each department overtime - 
#pointing the extract_tables function at the page number for table 3 for each department. 
table_3s <- tabulapdf::extract_tables(file = "vsrreport2022.pdf",
                                      #the table numbers for all the table 3s are in column 4.
                                      pages = table_numbers[,4],
                                      output = "tibble")


#Column bind the department list to the table_3s to create a label for each department
table_3_output <- purrr::map2(departments_list, table_3s, cbind)

#Rowbind all the lists together
table_3_output <- do.call(rbind, table_3_output) 

#Rename the departments and variables columns
table_3_output <- table_3_output |> 
  dplyr::rename(year = `...1`,
         department = keyword) |> 
         janitor::clean_names()


#Replace the dots with na for all relevant columns
table_3_output <- table_3_output |> 
  dplyr::mutate(across(white:other, ~na_if(.,".")))



#Add in unique id based on the rownames and departments
table_3_output <- table_3_output |> 
  tibble::rownames_to_column("dept_year_id") |> 
  dplyr::mutate(dept_year_id = paste0("dept_", dept_year_id))


#Create a table with the racial disparity index in the long format.
table_3_output_long <- tidyr::pivot_longer(table_3_output,
                                    cols = c(white, black, hispanic, native_american, asian, other),
                                    names_to = "race",
                                    values_to = "dispartiy_index")

#Write to xlsx - with each table as a different sheet
# use write.xlsx from openxlsx

#save different outputs as sheets
sheets <- list('RDI' = table_3_output, 'RDI_long' = table_3_output_long)

#Write to xlsx
# write.xlsx(sheets, file = 'Missouri_RDI_Index.xlsx')

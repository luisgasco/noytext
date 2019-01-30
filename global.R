# Load libraries to be used in this shiny app
library(shiny)
library(shinydashboard) 
library(shinyjs)
library(shinyBS)
library(shinythemes)
library(mongolite)
library(rintrojs)
library(dplyr)
library(tidyr)
library(stringr)
library(shinyWidgets)
library(jsonlite)
# Ensure that the www folder is visible by the app
addResourcePath("www", "www")

# Create variable with the current working directory
current_path <- getwd()

# Invoke and create the functions that will be used in server.R and ui.R -----------
source(paste0(current_path,"/extra_code/build_survey_questions.R"))
source(paste0(current_path,"/extra_code/load_config_files.R"))
source(paste0(current_path,"/extra_code/initialize_db_connection.R"))
source(paste0(current_path,"/extra_code/build_ui_interface.R"))










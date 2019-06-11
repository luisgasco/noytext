######################################################################################
######################################################################################
###                                                                                ###
###                              GLOBAL.R                                          ###
###  This is the GLOBAL function for Noytext app. Author: @LuisGasco               ###
###                                                                                ###
######################################################################################
######################################################################################

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
library(stringi)
library(digest)
# Ensure that the www folder is visible by the app
addResourcePath("www", "www")

# Create variable with the current working directory
current_path <- getwd()

# # I have move this variables to server, since they need to be there for not being shared withing all concurrent users.
# # Create global variables
# list_values<-list()
# 
# # Create reactive values -----------------------------
# # reactive value to check that the login was correct and show the annotationUI()
# correct_login <- reactiveVal(value=FALSE)
# 
# # Change value to TRUE when the login is correct. We use it for not showing the login page again
# # Use to show the login page only the first time the user click on "ejecutar label" page
# first_time_shown_label <- reactiveVal(value=FALSE)
# 
# # We use this reactive value to control when the tab "ejecutar_label" is clicked. And then use its value 
# # (if TRUE) to show the annotationUI directly without the loginpage
# touch_label_tab <- reactiveVal(value=FALSE)
# 
# # User name. We create the global variable with NULL value
# user_name <- NULL
# 
# 

# Invoke and create the functions that will be used in server.R and ui.R -----------
source(paste0(current_path,"/extra_code/build_survey_questions.R"))
source(paste0(current_path,"/extra_code/load_config_files.R"))
source(paste0(current_path,"/extra_code/initialize_db_connection.R"))
source(paste0(current_path,"/extra_code/build_ui_interface.R"))










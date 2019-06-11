######################################################################################
######################################################################################
###                                                                                ###
###                              UI.R                                              ###
###  This is the UI function of the app Noytext. Author: @LuisGasco                ###
###                                                                                ###
######################################################################################
######################################################################################

# Function to detect if user is on a mobile phone
mobileDetect <- function(inputId, value = 0) {
  tagList(
    singleton(tags$head(tags$script(src = "www/js/mobile.js"))),
    tags$input(id = inputId,
               class = "mobile-element",
               type = "hidden")
  )
}

ui<-tagList(
  mobileDetect('isMobile'),
  # textOutput('isItMobile'), #Activate if we wannt to debug is mobileDetect is working
  gen_navbar_elem(gen_conf)
)

library(shiny)
library(shinydashboard) 
library(shinyjs)
library(shinyBS)
library(leaflet)
library(shinythemes)
library(shinydashboard)
library(mongolite)
library(rintrojs)
library(shinyBS)


help <- c("<h3>First, you have to select the language of tweets you want to label. Once you selected the language, you should wait a moment in order the server retrieves the info from database</h3>",
          "<h3>Here you can see the content of the tweet to be labeled</h3>",
          "Read the tweet",
          "<h3>When you select an option, you have to click here before going to the next tweet</h3>",
          "<h3>Click next to load the next tweet</h3>",
           "<h3>Start collaborating clicking here! Thank you!</h3>")


radioTooltip <- function(id, choice, title, placement = "bottom", trigger = "hover", options = NULL){
  
  options = shinyBS:::buildTooltipOrPopoverOptionsList(title, placement, trigger, options)
  options = paste0("{'", paste(names(options), options, sep = "': '", collapse = "', '"), "'}")
  bsTag <- shiny::tags$script(shiny::HTML(paste0("
    $(document).ready(function() {
      setTimeout(function() {
        $('input', $('#", id, "')).each(function(){
          if(this.getAttribute('value') == '", choice, "') {
            opts = $.extend(", options, ", {html: true});
            $(this.parentElement).tooltip('destroy');
            $(this.parentElement).tooltip(opts);
          }
        })
      }, 500)
    });
  ")))
  htmltools::attachDependencies(bsTag, shinyBS:::shinyBSDep)
}
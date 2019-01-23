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

addResourcePath("www", "www")

current_path <- getwd()
# HELP TEXTs CONFIGURATION FILES ------------------------
help_text_path <- paste0(current_path,"/config_files/HelpTexts_conf.txt")
help<-read.table(help_text_path, header = FALSE, sep = ":",col.names = c("NºHelp","Instruction"))[,2]

# GENERAL CONFIGURATION FILES ------------------------
gen_conf_text_path <- paste0(current_path,"/config_files/GeneralUI_conf.txt")
gen_conf<-plyr::ldply(strsplit(readLines(gen_conf_text_path),":"),rbind)
names(gen_conf) <- c("element","text_title","logical","file")
gen_conf$element <- as.character(gen_conf$element)
gen_conf$text_title <- as.character(gen_conf$text_title)
gen_conf$logical <- as.character(gen_conf$logical)
gen_conf$file <- as.character(gen_conf$file)

# MONGODB DATABASE CONFIGURATION FILES ------------------
mongo_conf_text_path <- paste0(current_path,"/config_files/MongoDB_conf.txt")
mongo_conf<-read.table(mongo_conf_text_path, header = FALSE, sep = ":",col.names = c("parameter","value"),stringsAsFactors = FALSE)[,2]


# SURVEY CONF------------------
survey_conf_text_path <- paste0(current_path,"/config_files/Survey_conf.txt")
survey_needed <- as.logical(read.table(survey_conf_text_path,header=FALSE,sep=":", nrows=1)[,2])
survey_num_questions <- as.numeric(read.table(survey_conf_text_path,header=FALSE,sep=":",skip = 1, nrows=1,stringsAsFactors = FALSE)[,2])

survey_questions <- read.table(survey_conf_text_path,header=FALSE,sep=":",skip = 2,
                               nrows=survey_num_questions,stringsAsFactors = FALSE,
                               col.names = c("q_number","q_type","q_id","q_text","q_aditional"))

survey_questions$q_aditional <- strsplit(survey_questions$q_aditional,";")

survey_mandatory <-strsplit(read.table(survey_conf_text_path,header=FALSE,sep=":",
                                       skip=2+survey_num_questions,nrows=1,
                                       stringsAsFactors = FALSE)[,2],
                            ";")[[1]]
# BUILD SURVEY ----------------------------
create_question <- function(question){
  if(question$q_type=="textInput"){
    out <- textInput(question$q_id, question$q_text, question$q_aditional)
  }else if(question$q_type=="checkboxInpupt"){
    out<-checkboxInput(question$q_id, question$q_text, FALSE)
  }else if(question$q_type=="sliderInput"){
    out<-sliderInput(question$q_id, question$q_text, as.numeric(question$q_aditional[[1]][1]),
                      as.numeric(question$q_aditional[[1]][2]), as.numeric(question$q_aditional[[1]][3]), ticks = FALSE)
  }else if(question$q_type=="selectInput"){
    out<-selectInput(question$q_id, question$q_text,
                     question$q_aditional[[1]])
  }# WE HAVE TO ADD MORE OPTIONS
}
build_survey <- function(survey_questions){
  q_list <- list()
  for(i in 1:nrow(survey_questions)){
    q_list[[i]] <- create_question(survey_questions[i,])
  }
  
  
  survey<-div(shinyjs::useShinyjs(),
              id = "form",
              q_list,
              actionButton("submit", "Submit", class = "btn-primary")
            )
  return(survey)
  }



# Function to create HELP tab html content: ---------------
help_content <- function(help){
  tagList(
    introjsUI(),
    # Add introJS to the page
    introBox(
      fluidRow(align="center",
               radioButtons("idioma_ayuda", label = h3("Language:"),
                            choices = list("Spanish" = "es", "English" = "en"),
                            inline = TRUE,
                            selected = character(0))),
      data.step = 1,
      data.intro = help[1]
    ),
    introBox(
      fluidRow(align="center",
               tagList(
                 tags$ul(class="timeline",
                         tags$li(
                           div(class="avatar",
                               img(src=gsub("normal", "500x500", "https://cdn1.iconfinder.com/data/icons/freeline/32/account_friend_human_man_member_person_profile_user_users-256.png")),
                               div(class="hover",
                                   div(class="icon-twitter"))
                           ),
                           div(class="bubble-container",
                               div(class="bubble",
                                   h3(paste0('@',"example_user")),
                                   br(),
                                   "Here is where you will see the text content you have to label"
                                   
                               ),
                               div(class="over-bubble")))))
      ),
      data.step = 2,
      data.intro = help[2]
    ),
    introBox(
      fluidRow(align="center",
               tags$div(class="radio_ayuda",
                        shinyjs::disabled(radioButtons("radio_ayuda", label = h3("Categories:"),
                                                       choices = list("Noise complaint" = "r_perc_neg",
                                                                      "Enjoying noises or sounds" = "r_perc_pos",
                                                                      "Acoustic noise news or opinions about acoustic noise news" = "ruido_noticias_amb",
                                                                      "Others" = "ruido_noacustica"), 
                                                       selected = character(0))
                        ))),
      data.step = 3,
      data.intro = help[3]
    ),
    introBox(
      shinyjs::disabled(fluidRow(align="center",
                                 tags$div(class="guardar_ayuda",actionButton("guardar_ayuda", label = "-- Save --")))),
      data.step = 4,
      data.intro = help[4]
    ),
    tags$div(),
    introBox(
      shinyjs::disabled(fluidRow(align="center",
                                 tags$div(class="siguiente_ayuda",actionButton("siguiente_ayuda", label = "-- Next --")))),
      data.step = 5,
      data.intro = help[5]
    )
  )
}

# Function to create LABEL tab html content: -----------------
label_content <- function(){
  tagList(
    useShinyjs(),
    tags$head(includeScript("google-analytics.js"),
              tags$link(rel = "stylesheet", type = "text/css", href = "http://netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css"),
              tags$link(rel = "stylesheet", type = "text/css", href = "http://fonts.googleapis.com/css?family=Quicksand:300,400"),
              tags$link(rel = "stylesheet", type = "text/css", href = "http://fonts.googleapis.com/css?family=Lato:400,300"),
              tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
              tags$style(".content {background-color: white; }"),
              tags$style(".content-wrapper{background-color: white; }"),
              tags$script(src="getIP.js"),
              tags$script("
                                   Shiny.addCustomMessageHandler('resetValue', function(variableName) {
                                   Shiny.onInputChange(variableName, null);
                                   });
                                   ")
    ),
    fluidRow(align="center",column(width=12,
                                   radioButtons("idioma", label = h3("Language"),
                                                choices = list("Spanish" = "es", "English" = "en"),
                                                inline = TRUE,
                                                selected = character(0)))),
    # actionButton("show", "Show modal dialog")),
    shinyjs::hidden(
      div(id="columna",
          fluidRow(column(width=12,
                          uiOutput("texto")
          )),
          
          fluidRow(
            column(width=12,align="center",
                   shinyjs::disabled(uiOutput('uiRadioButtons')),
                   shinyjs::disabled(actionButton("guardar", label = "-- Save --")),
                   shinyjs::disabled(actionButton("siguiente", label = "-- Next --"))
            )
            
          ))),
    fluidRow(column(width=12,align="center",
                    uiOutput('texto_value_radio')
    ))
  )
}

# Define css style in tabs of navBar:
hide_show_class <- function(value){
  if(value == "TRUE"){
    #SHOW THE TAB
    out_class <- "display: block"
  }else if(value == "FALSE"){
    #DONT SHOW THE TAB
    out_class <- "display: none;"
  }
  out_class
}

# Function to generate navbar elements depending gen_conf:
gen_navbar_elem <- function(gen_conf){
  navbar<- navbarPage(
            id="tabs",
            theme = shinytheme(gen_conf[6,]$text_title),  # <--- To use a theme, uncomment this
            title=gen_conf[1,]$text_title,
            tabPanel(gen_conf[2,]$text_title, includeHTML(gen_conf[2,]$file)),
            tabPanel(gen_conf[3,]$text_title,
                     value = "ejecutar_help",
                     help_content(help)),
            tabPanel(gen_conf[4,]$text_title,
                     value = "ejecutar_label",
                     class="labeltab",
                     label_content()
            ),
            tabPanel(gen_conf[5,]$text_title,
                     includeHTML(gen_conf[5,]$file))
          )
  # Now we change the class of <ul> elements for not being shown to user # ADD A CLAS STYLE AND ADD THE CSS CONTENT MANUALLY
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[1]]$children[[1]]$attribs$style <- hide_show_class(gen_conf[2,]$logical)
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[2]]$children[[1]]$attribs$style  <- hide_show_class(gen_conf[3,]$logical)
  # navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[3]]$attribs$class 
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[4]]$children[[1]]$attribs$style <-hide_show_class(gen_conf[5,]$logical)
  output_w_style <- tagList(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    navbar
  )

  return(output_w_style)
}





# TOOLPITS FOR RADIOBUTTONS
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


# Autentication functions:
inputIp <<- function(inputId, value=''){
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "ipaddr", value=as.character(value), type="text", style="display:none;")
  )
}
inputUserid <<- function(inputId, value='') {
  #   print(paste(inputId, "=", value))
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "userid", value=as.character(value), type="text", style="display:none;")
  )
}

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
inputIp <- function(inputId, value=''){
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "ipaddr", value=as.character(value), type="text", style="display:none;")
  )
}
inputUserid <- function(inputId, value='') {
  #   print(paste(inputId, "=", value))
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "userid", value=as.character(value), type="text", style="display:none;")
  )
}

tagList(
  # Campos invisibles que contienen el checksum (fingerprint) de la ip y del navegador del usuario
  # generados utilizandos las funciones de www/js/ se suponen que son únicos por cada usuario
  inputIp("ipid"),
  inputUserid("fingerprint"),
  # textOutput("testtext"),
  # shinythemes::themeSelector(),
  navbarPage(
    id="tabs",
    theme = shinytheme("sandstone"),  # <--- To use a theme, uncomment this
    title=("Labtweet - I2A2 Research Group"),
    tabPanel("Information", includeHTML("intro.html")),
    tabPanel("Help",
             value = "ejecutar_help",
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
             )),
    tabPanel(introBox("Label",
                      data.step = 6,
                      data.intro = help[6]),
             value = "ejecutar_label",
             class="labeltab",
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
    ),
    
    
    tabPanel("About",
             includeHTML("index.html"))
  )
)

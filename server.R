
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


# install help package install_install_github("FrissAnalytics/shinyJsTutorials/tutorials/materials4/FrissIntroJSBasic")
# con <<- mongo(db = "INAD_db_clean_tagged", collection = "INAD_collection", url = "mongodb://localhost:27017")

 # con <<- mongo(db = "clean_data_twitter_database", collection = "twitter_collection", url = "mongodb://localhost:27017")
#ESTA ES LA QUE SE UTILIZA EN EL SERVER 
# con <<- mongo(db = "database_a_utilizar", collection = "twitter_collections_no_responses", url = "mongodb://localhost:27017")
#LA DE PRUEBAS
con <<- mongo(db = mongo_conf[3], collection = mongo_conf[4], url = paste0("mongodb://",mongo_conf[1],":",mongo_conf[2]))
  
server <- function(input, output,session) {
  # output$testtext <- renderText(paste("     fingerprint: ", input$fingerprint, "     ip: ", input$ipid))
  #Hasta que no se toca botón empezar, no se carga
    # Cuando detecta un cambio en esa expresión, se ejecuta todo
  #PONER DENTRO DEL MODAL ESTO http://r-posts.com/slickr/
  observeEvent(c(input$siguiente,input$idioma), ignoreNULL = FALSE,ignoreInit = TRUE,{
      shinyjs::show("columna")
      shinyjs::disable("radio")
      #Wait some seconds to enable de radio buttos (because we have to show the text before marking it)
      delay(1,shinyjs::enable("radio"))
      delay(1,shinyjs::disable("siguiente"))
      delay(1,shinyjs::disable("guardar"))
      output$uiRadioButtons <- renderUI({tagList(radioButtons("radio", label = h3("Categories:"),
                                                      choices = list("Noise complaint" = "r_perc_neg",
                                                                     "Enjoying noises or sounds" = "r_perc_pos",
                                                                     "Acoustic noise news or opinions about acoustic noise news" = "ruido_noticias_amb",
                                                                     "Others" = "ruido_noacustica"), 
                                                      selected = character(0)),
        radioTooltip(id = "radio", choice = "r_perc_neg", title = "The person is complaining about a noise source, or sound, such as neighbors, traffic, aircrafts...", placement = "right", trigger = "hover"),
        radioTooltip(id = "radio", choice = "r_perc_pos", title = "The person is making a positive statement about a noise source, or sound, such as his/her own music, birds... ", placement = "right", trigger = "hover"),
        radioTooltip(id = "radio", choice = "ruido_noticias_amb", title = "The text content is a piece of news about acoustics, an opinion about a piece of new about that topic, or a statement about acoustics that is not a subjective opinion.", placement = "right", trigger = "hover"),
        radioTooltip(id = "radio", choice = "ruido_noacustica", title = "The content does not fit with other labels", placement = "right", trigger = "hover"))})
      #Cogemos un tweet aleatorio de los no categorizados aún
      idioma <<-input$idioma
      tweet <<- con$aggregate(paste0('[ {"$match":{"lang":"',idioma,'"}},
                                     {"$match":{"tipo_tweet.1": {"$exists": 0}}},
                                    {"$sample":{"size": 1}}]'))
      #Mostramos el tweet
      output$texto <- renderUI({
        validate(
          need(tweet$text, "Please, select the language in which you want to label the texts"
          )
        )
        fluidRow(
        tagList(
          tags$ul(class="timeline",
                  tags$li(
                    div(class="avatar",
                        img(src=gsub("normal", "400x400", tweet$user$profile_image_url)),
                        div(class="hover",
                            div(class="icon-twitter"))
                    ),
                    div(class="bubble-container",
                        div(class="bubble",
                            h3(paste0('@',tweet$user$screen_name)),
                            br(),
                            if ("extended_tweet" %in% names(tweet)){
                              tweet$extended_tweet$full_text
                            } else{
                              tweet$text
                            }
                            
                        ),
                        div((paste0(tweet$tipo_tweet,"    "))),
                        div((paste0(tweet$"_id"))),
                        div(class="over-bubble"))))
        ))
      })

      updateRadioButtons(session, "radio", selected = character(0))
      session$sendCustomMessage(type = "resetValue", message = "radio")
      
      #Esto se puede borrar
      output$texto_value_radio <-renderText({paste0("Valor radio",input$radio)})
      
    })
  
  observeEvent(input$radio,{
    shinyjs::enable("guardar")
  })
  
  observeEvent(input$guardar,{
    #Asignamos el radio$input a una variable para actualizar despues la base de datos
    shinyjs::enable("siguiente")
    value <- input$radio
    ip_val <- toString(input$ipid)
    ip_md5 <- toString(input$fingerprint)
    if(!is.null(value)){
      #Actualizamos la entrada de la vase de datos
      con$update(query = paste0('{"_id": { "$oid" : "', tweet$"_id", '" } }'),
                 update =  paste0('{"$push": {"tipo_tweet": {"label":"', value,'","ip":"',ip_val,'","md5":"',ip_md5,'"}}}'))
      output$texto_value_radio <-renderText({paste0("Datos escritos con la caracteristica:",value)})
      output$texto_value_radio <-renderText({paste0("Datos escritos al id:",tweet$"_id")})
    }
  })
  
  # start introjs when button is pressed with custom options and events
  observeEvent( input$tabs,if(input$tabs=="ejecutar_help"){
                                 introjs(session, options = list("nextLabel"="Next",
                                                                 "prevLabel"="Previous",
                                                                 "skipLabel"="Skip"))
                                  })
  
  observeEvent(input$go_label,{
    ## Switch active tab to 'Page 1'
    updateTabsetPanel(session, "tabs",
                      selected = "ejecutar_label")
  })
  observeEvent(input$go_help,{
    ## Switch active tab to 'Page 1'
    updateTabsetPanel(session, "tabs",
                      selected = "ejecutar_help")
  })
  
  # Modal window for the survey:
  dataModal <- function(failed = FALSE) {
    modalDialog(
      textInput("user_name", "Define your user name",
                placeholder = 'Try "mtcars" or "abc"'
      ),
      span('You should use this user if you want to collaborate in the future'),
      if (failed)
        div(tags$b("Invalid name of data object", style = "color: red;")),
      
      footer = tagList(
        modalButton("Cancel"),
        actionButton("login_signin", "Sign/Login")
      )
    )
  }
  dataModal2 <- function(failed = FALSE) {
    modalDialog(
      build_survey(survey_questions),
      footer = tagList(
        modalButton("Cancel")
      )
    )
  }
  
  
  
  observeEvent(input$tabs, if((input$tabs == "ejecutar_label")&(survey_needed==TRUE)){
    showModal(dataModal())
  })
  observeEvent(input$login_signin,{
    #CHECK IF THE USER IS ON THE DATABASE
    # IF IT ISNT ON THE DABASE WE SHOW HIM THE SURVEY
    showModal(dataModal2())
    # IF IT IS ON ThE DATABASE WE CLOSE THE MODAL
    # removeModal(dataModal())
  })
  
  
  
  observeEvent(input$submit, {
    # WE NEED TO CREATE A FUNCTION TO SAVE THE SURVEY RESULT TO MONGODB (to the account of the user) saveData(formData())
    shinyjs::reset("form")
    removeModal()
  })
  
  #SURVEY MANDATORY FIELDS----------
  # observe({
  #   mandatoryFilled <-
  #     vapply(survey_mandatory,
  #            function(x) {
  #              !is.null(input[[x]]) && input[[x]] != ""
  #            },
  #            logical(1))
  #   mandatoryFilled <- all(mandatoryFilled)
  #   
  #   shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
  # }) 
  # 
}
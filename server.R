
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
con_user <<- mongo(db = mongo_conf[3], collection = mongo_conf[5], url = paste0("mongodb://",mongo_conf[1],":",mongo_conf[2]))
num_annotations <<- as.numeric(mongo_conf[6])

server <- function(input, output,session) {
  # output$testtext <- renderText(paste("     fingerprint: ", input$fingerprint, "     ip: ", input$ipid))
  #Hasta que no se toca botón empezar, no se carga
  
  # Function to create the graphical interface for annotating, as well as the saving in database -------------
  show_annotating_UI <- function(){
        shinyjs::show("columna")
        shinyjs::enable("radio")
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
        texto_ann <<- con$aggregate(paste0('[
                                       {
                                       "$project":{
                                       "text":1,
                                       "total_annotations":{
                                       "$size":{"$ifNull": ["$text_annotations",[]]}
                                       },
                                       "text_annotation":1
                                       }
                                       },
                                       {"$match":{"total_annotations":{"$lt":',num_annotations,'}}},
                                       {"$sample":{"size":1}}
                                       ]'))
        
        #Mostramos el tweet
        output$texto <- renderUI({
          # validate(
          #   need(texto$text, "Please, select the language in which you want to label the texts"
          #   )
          # )
          fluidRow(
            tagList(
              tags$ul(class="timeline",
                      tags$li(
                        div(class="bubble-container",
                            div(class="bubble",
                                texto_ann$text
                            ),
                            div(class="over-bubble"))))
            ))
        })
        
        updateRadioButtons(session, "radio", selected = character(0))
        session$sendCustomMessage(type = "resetValue", message = "radio")
        
        #Esto se puede borrar
        output$texto_value_radio <-renderText({paste0("Valor radio",input$radio)})
  }
  
  # Function to prepare the query to save the survey data for a user ---------
  prepare_survey_query <- function(survey_questions){
    # I NEED TO PUT THIS CODE IN A FUNCTION, BUT I HAVE TO LEARN HOW TO PROGRAM SHINY WITH MODULES TO PASS INPUT DATA TO A FUNCTION --------------
    string_ini<-'{"$set": {"survey": {'
    #First, we get the values of inputs:
    list_values<-list()
    for(i in 1:nrow(survey_questions)){
      list_values[[i]]<- eval(parse(text=paste0("input$",survey_questions$q_id[i])))
      # print(i,as.character(list_values[[i]]),sep="--")
    }
    string_med <- list()
    #Now we add those values in the query
    for(i in 1:nrow(survey_questions)){
      string_med[[i]] <- paste0('"',survey_questions$q_number[i],'":"',list_values[[i]],'"')
      # print(i,list_values[[i]],sep="--")
    }
    #Concatenate elements of the list
    library(stringi)
    string_med_fin<-paste(stri_join_list(string_med, sep = "", collapse = NULL),sep="",collapse=",")
    final_update_query<-paste0(string_ini,string_med_fin,'}}}')
  }
  
    # Cuando detecta un cambio en esa expresión, se ejecuta todo
  #PONER DENTRO DEL MODAL ESTO http://r-posts.com/slickr/
  observeEvent({
    input$siguiente
    input$login_signin
  }, {show_annotating_UI()},ignoreInit = TRUE,ignoreNULL = TRUE)
  observeEvent(input$radio,{
    shinyjs::enable("guardar")
  })
  observeEvent(input$guardar,{
    #Asignamos el radio$input a una variable para actualizar despues la base de datos
    shinyjs::enable("siguiente")
    value <- input$radio
    ip_val <- toString(input$ipid)
    if(!is.null(value)){
      
      #Actualizamos la entrada de la vase de datos
      # con$update(query = paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" } }'),
      #            update =  paste0('{"$push": {"text_annotation": {"label":"', value,'","user_id":"',input$user_name,'"}}}'))
      #Incluimos el id del tweet en el listado del usuario
      
      # Buscamos el tweet anotado en la base de datos. Si hay un elemento de ese tweet modificado por el usuario, lo actualizamos
      update_or_create <- con$find(query = paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":"',input$user_name,'" }'))
      #If nrow(update_or_create) es distinto de 0, el campo existe por lo que hay que hacer update
      if(nrow(update_or_create)!=0){
        con$update(query=paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":"',input$user_name,'" }'),
                 update=paste0('{"$set" : { "text_annotation.$.label":"',value,'"}}'))
      }else{ # Si no añadimos el array
        con$update(query=paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":{"$ne":"',input$user_name,'" }}'),
                 update=paste0('{"$addToSet" : { "text_annotation":{"label":"',value,'","user_id":"',input$user_name,'"}}}'))
      }
      #We do the same with user data
      update_or_create2 <- con_user$find(query = paste0('{"user":"',input$user_name,'","annotated_texts.tweet_id":"',texto_ann$"_id",'"}'))
      if(nrow(update_or_create2)!=0){
        con_user$update(query=paste0('{"user":"',input$user_name,'","annotated_texts.tweet_id":"',texto_ann$"_id",'"}'),
                   update=paste0('{"$set" : { "annotated_texts.$.label":"',value,'"}}'))
      }else{
        con_user$update(query=paste0('{"user":"',input$user_name,'","annotated_texts.tweet_id":{"$ne":"',texto_ann$"_id",'"}}'),
                   update=paste0('{"$addToSet" : { "annotated_texts":{"label":"',value,'","tweet_id":"',texto_ann$"_id",'"}}}'))
      }
      # con_user$update(query = paste0('{"user":"',input$user_name,'"}'),
      #            update =  paste0('{"$push": {"annotated_texts": {"label":"', value,'","tweet_id":"',texto_ann$"_id",'"}}}'))
      output$texto_value_radio <-renderText({paste0("Datos escritos con la caracteristica:",value)})
      output$texto_value_radio <-renderText({paste0("Datos escritos al id:",texto_ann$"_id")})
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
        # modalButton("Cancel")
      )
    )
  }
  
  # Logic functions for survey data ------------------------
  observeEvent(input$tabs,
               if((input$tabs == "ejecutar_label")&(survey_needed==TRUE)){
                  showModal(dataModal())
                }else if((input$tabs == "ejecutar_label")){
                  show_annotating_UI()
                })
  observeEvent(input$login_signin,{
    #CHECK IF THE USER IS ON THE DATABASE
    user_name <- input$user_name
    print(user_name)
    value <- con_user$find(paste0('{"user":"',user_name,'"}')) # Change con byh con_user
    # IF IT ISNT ON THE DABASE WE SHOW HIM THE SURVEY
    if(nrow(value)==0){
      # We create a document for the new user in the user_collection
      print("we create the new user in the database")
      con_user$insert(paste0('{"user":"',user_name,'"}'))
      showModal(dataModal2())
    }else{
      print("user found in database")
      removeModal()
    }
  })
  observeEvent(input$submit, {
    # WE NEED TO CREATE A FUNCTION TO SAVE THE SURVEY RESULT TO MONGODB (to the account of the user) saveData(formData())
    # We update the user document with the survey results:
    # Update the user document with survey results first we use function to generate the update query:
    
    user_name <- input$user_name
    
    #---------------------
    print("Saving survey data")
    con_user$update(query = paste0('{"user":"',user_name,'"}'),
                    update = prepare_survey_query(survey_questions))
    print("Survey data saved")
    shinyjs::reset("form")
    removeModal()
  })

}
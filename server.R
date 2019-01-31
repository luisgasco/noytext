######################################################################################
######################################################################################
###                                                                                ###
###                              SERVER.R                                          ###
###  This is the server function of the app Noytext. Author: @LuisGasco            ###
###                                                                                ###
######################################################################################
######################################################################################

server <- function(input, output,session) {
  
  # Needed functions-------------------------
  
  # Function to create the graphical interface for annotating, as well as the saving the data inthe database
  show_annotating_UI <- function(){
        # Show UI with JS
        shinyjs::show("columna")
        shinyjs::enable("radio")
        
        #Wait some seconds to enable de radio buttos (because we have to show the text before marking it)
        delay(1,shinyjs::enable("radio"))
        delay(1,shinyjs::disable("siguiente"))
        delay(1,shinyjs::disable("guardar"))
        
        # Render the radioButtons
        output$uiRadioButtons <- renderUI({tagList(radioButtons("radio", label = h3("Categories:"),
                                                                choiceNames = list(annotation_texts$text[1],annotation_texts$text[2],
                                                                                   annotation_texts$text[3],annotation_texts$text[4]),
                                                                choiceValues = list(annotation_texts$id[1],annotation_texts$id[2],
                                                                                    annotation_texts$id[3],annotation_texts$id[4]),
                                                                selected = character(0)),
                                                   radioTooltip(id = "radio", choice = annotation_texts$id[1], title = annotation_texts$tooltip_text[1], placement = "right", trigger = "hover"),
                                                   radioTooltip(id = "radio", choice = annotation_texts$id[2], title = annotation_texts$tooltip_text[2], placement = "right", trigger = "hover"),
                                                   radioTooltip(id = "radio", choice = annotation_texts$id[3], title = annotation_texts$tooltip_text[3], placement = "right", trigger = "hover"),
                                                   radioTooltip(id = "radio", choice = annotation_texts$id[4], title = annotation_texts$tooltip_text[4], placement = "right", trigger = "hover"))})
        
        # Recover a random text from database
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
        
        # Show the text
        output$texto <- renderUI({
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
        
        # This is just an indicator to test if the app is saving the data correctly in the database
        # output$texto_value_radio <-renderText({paste0("Valor radio",input$radio)})
  }
  
  # Function to prepare the query to save the survey data for a user
  prepare_survey_query <- function(survey_questions){
    
    string_ini<-'{"$set": {"survey": {'
    
    #First, we get the values of inputs:
    for(i in 1:nrow(survey_questions)){
      
      # If the input is NULL, we add a 0-length character element (to avoid future errors)
      list_values[[i]]<- as.character(eval(parse(text=paste0("input$",survey_questions$q_id[i]))))
      
    }
    
    # Substitute 0-length elements,empty strings or NA to "Empty")
    list_values<-lapply(list_values, function(x) if((is.na(x))||(x=="")|(length(x) == 0)){"Empty" }else{x} ) 
    
    string_med <- list()
    #Now we add those values in the query
    for(i in 1:nrow(survey_questions)){
      
      # If the question content is a vector, we need to convert the vector into a JSON object
      if (length(list_values[[i]])==1){
        
        string_med[[i]] <- paste0('"',survey_questions$q_number[i],'":"',list_values[[i]],'"')
        
      }else {
        
        string_med[[i]] <- paste0('"',survey_questions$q_number[i],'":',toJSON(list_values[[i]]))
        
      }
    }
    
    #Concatenate elements of the list
    string_med_fin<-paste(stri_join_list(string_med, sep = "", collapse = NULL),sep="",collapse=",")
    final_update_query<-paste0(string_ini,string_med_fin,'}}}')
  }
  
  
  
  
  # Annotating tab logic --------------------------------
  # If there is a click on "siguiente" button, or in the login_signing button (modal), the annotating UI is shown.
  observeEvent({
    input$siguiente
    input$login_signin
  }, {show_annotating_UI()},ignoreInit = TRUE,ignoreNULL = TRUE)
  
  # Activate guardar (save) button when a radiobutton is selected
  observeEvent(input$radio,{
    shinyjs::enable("guardar")
  })
  
  # Save the content of radiobutton when guardar button is clicked
  observeEvent(input$guardar,{
    #Asignamos el radio$input a una variable para actualizar despues la base de datos
    shinyjs::enable("siguiente")
    value <- input$radio
    ip_val <- toString(input$ipid)
    if(!is.null(value)){
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
  
  
  
  
  
  # Help tab Logic -------------------------
  # start introjs when button is pressed with custom options and events
  observeEvent( input$tabs,if(input$tabs=="ejecutar_help"){
                                 introjs(session, options = list("nextLabel"="Next",
                                                                 "prevLabel"="Previous",
                                                                 "skipLabel"="Skip"))
                                  })
  
  
  # Index.html logic------------------------------
  # This part only works with the index.html buttons
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
  
  
  
  
  
  # Modal functions----------------------------------
  # Modal windows for the survey:
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
  
  
  # Logic functions for survey data-----------------
  # When click on annotating tab, show datamodal if survey is configured to be shown. If not, show the annotating UI
  observeEvent(input$tabs,if((input$tabs == "ejecutar_label")&(survey_needed==TRUE)){
                  showModal(dataModal())
                }else if((input$tabs == "ejecutar_label")){
                  show_annotating_UI()
                })
  # Logical operations when user writes his name on the first datamodal.
  observeEvent(input$login_signin,{
    
    #CHECK IF THE USER IS ON THE DATABASE
    user_name <- input$user_name
    print(user_name)
    value <- con_user$find(paste0('{"user":"',user_name,'"}')) # Change con byh con_user
    
    # IF IT ISNT ON THE DABASE WE SHOW HIM THE SURVEY
    if(nrow(value)==0){
      
      # We create a document for the new user in the user_collection and we show him the survey
      print("we create the new user in the database")
      con_user$insert(paste0('{"user":"',user_name,'"}'))
      showModal(dataModal2())
      
    }else{
      
      #If user is found on the database we close the modal and show him the annotating interface
      print("user found in database")
      removeModal()
      
    }
  })
  
  # Logical operations when user clicks on submit button in the survey
  observeEvent(input$submit, {
    # WE NEED TO CREATE A FUNCTION TO SAVE THE SURVEY RESULT TO MONGODB (to the account of the user) saveData(formData())
    # We update the user document with the survey results:
    # Update the user document with survey results but first we use function to generate the update query:
    user_name <- input$user_name
    print("Saving survey data")
    con_user$update(query = paste0('{"user":"',user_name,'"}'),
                    update = prepare_survey_query(survey_questions))
    print("Survey data saved")
    shinyjs::reset("form")
    removeModal()
  })

  
}
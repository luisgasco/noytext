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
  
  # Function show or hide login & logout button depending on survey_needed variable 
   button_logout <- function(){
     if (survey_needed == TRUE){
       output$App_Panel <-   renderUI({
         list(
           actionButton("login_btn_nav","LOGIN"),
           actionButton("logout","LOGOUT")
         )
       })
     }else {
       output$App_Panel <-   renderUI({
         list(
           shinyjs::hidden(actionButton("login_btn_nav","LOGIN")),
           shinyjs::hidden(actionButton("logout","LOGOUT"))
         )
       })
     }
   
   }
   button_logout()

   
  # Annotating tab logic --------------------------------
  # If there is a click on "siguiente" button, or in the login_signing button (modal), the annotating UI is shown.
  observeEvent({
    input$siguiente
    # correct_login()
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
      update_or_create <- con$find(query = paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":"',user_name,'" }'))
      #If nrow(update_or_create) es distinto de 0, el campo existe por lo que hay que hacer update
      if(nrow(update_or_create)!=0){
        con$update(query=paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":"',user_name,'" }'),
                 update=paste0('{"$set" : { "text_annotation.$.label":"',value,'"}}'))
      }else{ # Si no añadimos el array
        con$update(query=paste0('{"_id": { "$oid" : "', texto_ann$"_id", '" },"text_annotation.user_id":{"$ne":"',user_name,'" }}'),
                 update=paste0('{"$addToSet" : { "text_annotation":{"label":"',value,'","user_id":"',user_name,'"}}}'))
      }
      #We do the same with user data
      update_or_create2 <- con_user$find(query = paste0('{"user":"',user_name,'","annotated_texts.tweet_id":"',texto_ann$"_id",'"}'))
      if(nrow(update_or_create2)!=0){
        con_user$update(query=paste0('{"user":"',user_name,'","annotated_texts.tweet_id":"',texto_ann$"_id",'"}'),
                   update=paste0('{"$set" : { "annotated_texts.$.label":"',value,'"}}'))
      }else{
        con_user$update(query=paste0('{"user":"',user_name,'","annotated_texts.tweet_id":{"$ne":"',texto_ann$"_id",'"}}'),
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
  
  
  
  # Observe event of logout button on nav. If correct_login is FALSE user is out, so nothing happens. If not, reset reactive values, user_name and hide content of label tab--------
  observeEvent(input$logout,{
    if(correct_login()){
      correct_login(FALSE)
      # first_time_shown_label(TRUE)
      # touch_label_tab(FALSE)
      user_name <<- NULL
      shinyjs::hide("columna")
      print("reactive_works")
    }else{}
    
  },ignoreInit = TRUE,ignoreNULL = TRUE)
  # Observe event of login_btn_nav. If correct_login is TRUE user is inside, so nothing happes. If not, show login modasl
  observeEvent({
    input$login_btn_nav},if(correct_login()){}else{
      showModal(login_modal())
    },ignoreInit = TRUE,ignoreNULL = TRUE)
  
  
  
  
  # Modal functions to show modal popups----------------------------------
  # Modal windows to input data to create user account
  dataModal <- function(failed = FALSE) {
    modalDialog(id="creation",
      textInput("user_name", "Define your user name",
                placeholder = 'Write your user name',width="100%"
      ),
      passwordInput("user_pass", "Define your password", value = "",width="100%"),
      bsAlert("alert"),
      span('You should use this user if you want to collaborate in the future'),
      actionButton(inputId="account_created",label= "Create",width="100%",style="background-color:green"),
      if (failed)
        div(tags$b("Invalid name of data object", style = "color: red;")),
      footer = tagList(
        # actionButton(inputId="back_to_login",label= "Go back"),
        modalButton("Cancel")
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
  login_modal <- function(failed = FALSE) {
    modalDialog(id="login_modal",
                textInput("user_name", "Write your user name",
                          placeholder = 'Write your user name',width="100%"
                ),
                passwordInput("user_pass", "Write your password", value = "",width="100%"),
                bsAlert("alert"),
                actionButton("login_signin", "Login",width="100%"),
                hr(),
                actionButton("create_account", "Create account",width="50%",
                             style="background-color:transparent; color:black; border: 2px solid #3e3f3a; font-weight:bold"),
                if (failed)
                  div(tags$b("Invalid name of data object", style = "color: red;")),
                
                footer = tagList(
                  # actionButton(inputId="back_to_login",label= "Go back"),
                  modalButton("Cancel")
                )
    )
  }
  
  
  
  # Logic functions for survey data and login-----------------
  # Change value of reacttive value touch_label_tab:
  observeEvent(input$tabs,{
    if(input$tabs == "ejecutar_label"){
      touch_label_tab(TRUE)
    }else{
      touch_label_tab(FALSE)
    }
  })

  # If user touch label tab and he is not logged, it will be shown the login page
  # But if survey_needed==FALSE then show directy the column
  observeEvent({touch_label_tab()},
               if((correct_login()==TRUE) | (survey_needed==FALSE)){show_annotating_UI()}else{showModal(login_modal())},
               ignoreInit = TRUE,ignoreNULL = TRUE)
  
  # When click on annotating tab, show datamodal if survey is configured to be shown. If not, show the annotating UI
  observeEvent({correct_login() },{if(((!correct_login()))&(survey_needed==TRUE)){
                  showModal(login_modal())
                  touch_label_tab(FALSE)
                }else {
                  show_annotating_UI()
                }},ignoreInit = TRUE,ignoreNULL = TRUE)
  
  # Show the modal popup to create an account:
  observeEvent(input$create_account,{
    removeModal()
    showModal(dataModal())
    
  })
  
  # When account_created, we show user the survey:
  observeEvent(input$account_created,{
    
    user_name <<- input$user_name
    user_password <- digest(input$user_pass,"sha256")
    # Check if the user exists:
    value <- con_user$find(paste0('{"user":"',user_name,'"}')) 
    # closeAlert(session, "exampleAlert")
    
    # Check that the username is written, if not an alert is shon
    if(input$user_name== ""){
      
      # Close previous alerts
      closeAlert(session, "exampleAlert")
      
      createAlert(session, "alert", "exampleAlert", title = "Information",
                  content = "Enter a username", append = FALSE)
      
    }
    # If password or user is empty or less than 5 characters an alert is shown
    if((input$user_pass == "")|(nchar(input$user_pass)<5)){
      
      # Close previous alerts
      closeAlert(session, "exampleAlert")

      createAlert(session, "alert", "exampleAlert", title = "Information",
                  content = "You have to define a password of at least 5 characters", append = FALSE)
      shinyjs::reset("creation")
    }
    # If the user is not on the database, we create his document and show him the survey
    else if(nrow(value)==0){
      
      con_user$insert(paste0('{"user":"',user_name,'","pass":"',user_password,'"}'))
      removeModal()
      showModal(dataModal2())
      
    }
    # If there is a document with that username, an alert is shown
    else{
        # Close previous alerts
        closeAlert(session, "exampleAlert")
        #If user exists on the database we reset the modal
        createAlert(session, "alert", "exampleAlert", title = "Information", 
                    content = "That user exists, please try another user name", append = FALSE)
        shinyjs::reset("creation")
    }
  })
  
  # Logical operations when user writes his name on the first datamodal.
  observeEvent(input$login_signin,{
    
    #CHECK IF THE USER IS ON THE DATABASE
    user_name <<- input$user_name
    user_password <- digest(input$user_pass,"sha256")
    
    # Check if the user exists
    value <<- con_user$find(paste0('{"user":"',user_name,'"}')) # Change con byh con_user
    
    
    # IF IT ISNT ON THE DABASE WE SHOW HIM THE SURVEY
    if(nrow(value)==0){
      closeAlert(session, "exampleAlert")
      createAlert(session, "alert", "exampleAlert", title = "Information",
                  content = "That user do not exists in the database", append = FALSE)
      shinyjs::reset("login_modal")
    }
    # If user name and password are the samen than the database one, close the modal and show results
    else if((user_name==value$user)&(user_password==value$pass)){
      # We create a document for the new user in the user_collection and we show him the survey
      removeModal()
      correct_login(TRUE)
      first_time_shown_label(TRUE)
    } 
    # If code arrives here is because the password is not correct
    else {
      closeAlert(session, "exampleAlert")
      createAlert(session, "alert", "exampleAlert", title = "Information",
                  content = "Your password is not correct", append = FALSE)
    }
    
  })
  
  # Logical operations when user clicks on submit button in the survey
  observeEvent(input$submit, {
    # WE NEED TO CREATE A FUNCTION TO SAVE THE SURVEY RESULT TO MONGODB (to the account of the user) saveData(formData())
    # We update the user document with the survey results:
    # Update the user document with survey results but first we use function to generate the update query:
    user_name <<- input$user_name
    print("Saving survey data")
    con_user$update(query = paste0('{"user":"',user_name,'"}'),
                    update = prepare_survey_query(survey_questions))
    print("Survey data saved")
    shinyjs::reset("form")
    removeModal()
    first_time_shown_label(TRUE)
    correct_login(TRUE)
    show_annotating_UI()
    
  })
  
  
  

  
}
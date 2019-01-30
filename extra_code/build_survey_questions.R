#######################################################################################################
#######################################################################################################
###                                                                                                 ###
###                                    BUILD_SURVEY_QUESTIONS.R:                                    ###
###  THESE FUNCTIONS ALLOW THE PROGRAM TO GENERATE THE QUESTIONS THAT WILL BE ASKED IN THE SURVEY.  ###
###                                                                                                 ###
#######################################################################################################
#######################################################################################################

#' Create a input object depending on parameters of 'questions'
#' 
#' \code{create_question}
#' 
#' @param question A dataframe's row with information about the question
#' 
#'
#' @return A shiny input object based on 'question' data
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
create_question <- function(question){
  if(question$q_type=="textInput"){
    out <- textInput(question$q_id, question$q_text, question$q_aditional,width = "100%")
  }else if(question$q_type=="checkboxInput"){
    out<-checkboxInput(question$q_id, question$q_text, as.logical(question$q_aditional),width = "100%")
  }else if(question$q_type=="sliderInput"){
    out<-sliderInput(question$q_id, question$q_text, as.numeric(question$q_aditional[[1]][1]),
                     as.numeric(question$q_aditional[[1]][2]), as.numeric(question$q_aditional[[1]][3]), ticks = FALSE,width = "100%")
  }else if(question$q_type=="selectInput"){
    out<-selectInput(question$q_id, question$q_text,
                     question$q_aditional[[1]],width = "100%")
  }else if(question$q_type=="selectInputMultiple"){
    out<-selectInput(question$q_id, question$q_text,
                     c("Choose one" = "",question$q_aditional[[1]]),multiple=TRUE,selectize=TRUE,width = "100%")
  }else if(question$q_type=="checkboxGroupInput"){# Good for small number of options
    out<- checkboxGroupInput(question$q_id, question$q_text,choices=question$q_aditional[[1]],width = "100%")
  }else if(question$q_type=="radioButtons"){
    out <- radioButtons(question$q_id, question$q_text,choices=question$q_aditional[[1]])
  }else if(question$q_type=="numericInput"){
    out <- numericInput(question$q_id, question$q_text,value=as.numeric(question$q_aditional[[1]][1]),
                        min=as.numeric(question$q_aditional[[1]][2]),max=as.numeric(question$q_aditional[[1]][3]),width = "100%")
  }
  else if(question$q_type=="sliderTextInput"){# FROM shinywidgets
    out <- sliderTextInput(question$q_id, question$q_text,grid=TRUE,force_edges=TRUE,choices=question$q_aditional[[1]])
  }else if(question$q_type=="pickerInput"){ # FROM shinywidgets
    out <- pickerInput(question$q_id, question$q_text,multiple=TRUE,choices = question$q_aditional[[1]],
                           options = list('actions-box'=TRUE,
                                          'size'=10,
                                          'selected-text-format' = "count",
                                          'count-selected-text' = "{0} options choosed (on a total of {1})"),width = "100%")
  }else{
    print("Revise the name of the variable")
  }
  
  # WE HAVE TO ADD MORE OPTIONS
}


#' Build an html text that will be the body of the survey
#' 
#' \code{build_survey}
#' 
#' @param survey_questions A dataframe with info about the survey questions
#' 
#' @return Html string
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
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

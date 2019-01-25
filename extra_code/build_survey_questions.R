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

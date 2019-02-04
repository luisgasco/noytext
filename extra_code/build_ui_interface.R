######################################################################################
######################################################################################
###                                                                                ###
###                              BUILD_UI_INTERFACE:                               ###
###  THESE FUNCTIONS BUILD THE GENERAL STRUCTURE OF THE APP GRAPHICAL INTERFACE'.  ###
###                                                                                ###
######################################################################################
######################################################################################

#' Build the help panelTab with the associated introjs scripts
#' 
#' \code{help_content}
#' 
#' @param help A dataframe with information with the data help steps
#'
#' @return A HTML list
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
help_content <- function(help){
  tagList(
    useShinyjs(),
    introjsUI(),
    introBox(
      fluidRow(align="center",
               tagList(
                 tags$ul(class="timeline",
                         tags$li(
                           div(class="bubble-container",
                               div(class="bubble",
                                   "Here is where you will see the text content you have to label"
                               ),
                               div(class="over-bubble")))))
      ),
      data.step = 1,
      data.intro = help[1]
    ),
    introBox(
      fluidRow(align="center",
               tags$div(class="radio_ayuda",
                        shinyjs::disabled(radioButtons("radio_ayuda", label = h3("Categories:"),
                                                       choiceNames = list(annotation_texts$text[1],annotation_texts$text[2],
                                                                            annotation_texts$text[3],annotation_texts$text[4]),
                                                       choiceValues = list(annotation_texts$id[1],annotation_texts$id[2],
                                                                            annotation_texts$id[3],annotation_texts$id[4]),
                                                    
                                                       selected = character(0))
                        ))),
      data.step = 2,
      data.intro = help[2]
    ),
    introBox(
      shinyjs::disabled(fluidRow(align="center",
                                 tags$div(class="guardar_ayuda",actionButton("guardar_ayuda", label = "-- Save --")))),
      data.step = 3,
      data.intro = help[3]
    ),
    tags$div(),
    introBox(
      shinyjs::disabled(fluidRow(align="center",
                                 tags$div(class="siguiente_ayuda",actionButton("siguiente_ayuda", label = "-- Next --")))),
      data.step = 4,
      data.intro = help[4]
    )
  )
}


#' Build the HTML structure of the panel used to annotate texts
#' 
#' \code{label_content}
#' 
#' @return A HTML list
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
label_content <- function(){
  tagList(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "http://netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css"),
              tags$link(rel = "stylesheet", type = "text/css", href = "http://fonts.googleapis.com/css?family=Quicksand:300,400"),
              tags$link(rel = "stylesheet", type = "text/css", href = "http://fonts.googleapis.com/css?family=Lato:400,300"),
              tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
              tags$style(".content {background-color: white; }"),
              tags$style(".content-wrapper{background-color: white; }"),
              tags$script("
                          Shiny.addCustomMessageHandler('resetValue', function(variableName) {
                          Shiny.onInputChange(variableName, null);
                          });
                          ")
              ),
    div(id="columna",
        fluidRow(column(width=12,
                        uiOutput("texto")
        )),
        
        fluidRow(
          column(width=12,align="center",
                 (uiOutput('uiRadioButtons')),
                 shinyjs::disabled(actionButton("guardar", label = "-- Save --")),
                 shinyjs::disabled(actionButton("siguiente", label = "-- Next --"))
          )
          
        )),
    fluidRow(column(width=12,align="center",
                    uiOutput('texto_value_radio')
    ))
    )
  }


#' Define a CSS style parameter in tabs of the navBar. This function define the class 
#' style="display:none" in pages that user decide not to use or show in the final 
#' version of the webapp.
#' 
#' \code{hide_show_class}
#' 
#' @param A value taken from the GeneralUI_conf.txt that has been read in "load_config_files.R" 
#' 
#' @return A string
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
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


#' Create the general structure of the app using shinythemes. The function generates a navbarPage
#' depending on GeneralUI_conf.txt defined parameters
#' 
#' \code{gen_navbar_elem}
#' 
#' @param gen_conf A dataframe taken from the GeneralUI_conf.txt that has been read in "load_config_files.R" 
#' 
#' @return A HTML list
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
gen_navbar_elem <- function(gen_conf){
  navbar<- navbarPage(
    id="tabs",
    theme = shinytheme(gen_conf[6,]$text_title),  # <--- To use a theme, uncomment this
    title=div(a(href="https://luisgasco.github.io/noytext_web/",
                target="_blank",
                # shiny::tags$style('border-bottom:"#fff0"'),
                img(src="www/img/logo_noytext_white.png", width="150px")),
              gen_conf[1,]$text_title),
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
             includeHTML(gen_conf[5,]$file)))
  # Now we change the class of <ul> elements for not being shown to user # ADD A CLAS STYLE AND ADD THE CSS CONTENT MANUALLY
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[1]]$children[[1]]$attribs$style <- hide_show_class(gen_conf[2,]$logical)
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[2]]$children[[1]]$attribs$style  <- hide_show_class(gen_conf[3,]$logical)
  # navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[3]]$attribs$class 
  navbar[[3]][[1]][[3]][[1]][[3]][[2]][[3]][[1]][[4]]$children[[1]]$attribs$style <-hide_show_class(gen_conf[5,]$logical)
  output_w_style <- tagList(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    tags$head(tags$link(rel = "icon", type = "image/png", href = "www/img/logo_circle.png"),
              tags$title("Noytext")),
    navbar,
    HTML(paste("<script>var parent = document.getElementsByClassName('navbar-nav');
               parent[0].insertAdjacentHTML( 'afterend', '<ul class=\"nav navbar-nav navbar-right\"><li class=\"disabled\"><strong>",uiOutput('App_Panel'),"</strong></ul>' );</script>"))
  )
  
  return(output_w_style)
}


#' Create the tooltips for radiobuttons in the annotating tab.
#' 
#' \code{radioTooltip}
#' 
#' @author Luis Gascó Sánchez
#' 
#' 
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

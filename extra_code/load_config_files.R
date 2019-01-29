###########################################################################
###########################################################################
###                                                                     ###
###                        LOAD_CONFIG_FILES.R:                         ###
###         READ THE CONFIGURATION FILES TO PERSONALIZE NOYTEXT         ###
###                                                                     ###
###########################################################################
###########################################################################


# HELP TEXTs CONFIGURATION FILES ------------------------
help_text_path <- paste0(current_path,"/config_files/HelpTexts_conf.txt")
help<-read.table(help_text_path, header = FALSE, sep = ":",col.names = c("NºHelp","Instruction"),blank.lines.skip=TRUE)[,2]

# GENERAL CONFIGURATION FILES ------------------------
gen_conf_text_path <- paste0(current_path,"/config_files/GeneralUI_conf.txt")
gen_conf<- read.table(gen_conf_text_path,header=FALSE,blank.lines.skip = TRUE)
gen_conf<- gen_conf %>% separate(V1,":",into=c("element","text_title","logical","file"),
                                 extra = "merge")
  

# MONGODB DATABASE CONFIGURATION FILES ------------------
mongo_conf_text_path <- paste0(current_path,"/config_files/MongoDB_conf.txt")
mongo_conf<-read.table(mongo_conf_text_path, header = FALSE, sep = ":",
                       col.names = c("parameter","value"),stringsAsFactors = FALSE,
                       blank.lines.skip=TRUE)[,2]


# SURVEY CONF------------------
survey_conf_text_path <- paste0(current_path,"/config_files/Survey_conf.txt")
survey_text <- read.table(survey_conf_text_path,header=FALSE,sep=":",stringsAsFactors = FALSE,
                          blank.lines.skip=TRUE, fill = TRUE)
names(survey_text) <-c("q_number","q_type","q_id","q_text","q_aditional")

survey_needed <- as.logical(survey_text$q_type[1])
survey_num_questions <- as.numeric(survey_text$q_type[2])


survey_questions <- survey_text[c(3:(3+survey_num_questions-1)),]
survey_questions$q_aditional <- strsplit(survey_questions$q_aditional,";")

# NOT IMPLEMENTED YET
survey_mandatory <-strsplit(survey_text[c(2+survey_num_questions+1),"q_type"],";")[[1]]

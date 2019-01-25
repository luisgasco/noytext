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
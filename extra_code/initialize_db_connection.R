######################################################################################################################
######################################################################################################################
###                                                                                                                ###
###                                          INITIALIZE_DB_CONNECTION.R:                                           ###
###  STARTS THE CONNECTION TO THE DATABASE FROM THE DATA OBTAINED FROM THE CONFIGURATION FILE 'MONGODB_CONF.TXT'.  ###
###                                                                                                                ###
######################################################################################################################
######################################################################################################################

#' Conection to MongoDB collection with texts to be annotated
con <- mongo(db = mongo_conf[3], collection = mongo_conf[4], url = paste0("mongodb://",mongo_conf[1],":",mongo_conf[2]))

#' Conection to MongoDB collection with users
con_user <- mongo(db = mongo_conf[3], collection = mongo_conf[5], url = paste0("mongodb://",mongo_conf[1],":",mongo_conf[2]))

#' Maximum number of annotations for each text
num_annotations <- as.numeric(mongo_conf[6])
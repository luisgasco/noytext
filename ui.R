
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


tagList(
  # Campos invisibles que contienen el checksum (fingerprint) de la ip y del navegador del usuario
  # generados utilizandos las funciones de www/js/ se suponen que son únicos por cada usuario
  inputIp("ipid"),
  inputUserid("fingerprint"),
  # Produce UI
  useShinyjs(),
  gen_navbar_elem(gen_conf)
)

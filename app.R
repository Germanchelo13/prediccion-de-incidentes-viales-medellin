library(DT) # print table beutefull
library(sf) # manupulación geolocalizaciones
library(tmap)  # graficos interactivos de mapas
library(dplyr) # manejo de funciones
library(shiny) # aplicacion
library(plotly) # graficos 
library(shinydashboard)
library(tidyverse)
library(shinycssloaders)# to add a loader while graph is populating

mapa_medellin<-st_read('Barrio_Vereda.shp')


!T

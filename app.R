library(sf) # manupulación geolocalizaciones
library(dplyr) # manejo de funciones
library(ggrepel)
library(shiny) # aplicacion
library(plotly) # graficos 
library(shinydashboard)
library(daterangepicker)
library(tidyverse)
library(rjson)
library(shinycssloaders)# to add a loader while graph is populating

url_github<-"https://github.com/Germanchelo13/prediccion-de-incidentes-viales-medellin.git"
mapa_medellin<-st_read('barrios_cluster/barrios_cluster.shp')
prediccion<-read.csv("datos_pronostico_2021_2022.csv")
prediccion$FECHA_ACCIDENTE_ <-(as.POSIXct(prediccion$FECHA_ACCIDENTE, format="%Y-%m-%d", tz="UTC")) 
var_clusters<-c( 'ACCIDENTES por KM cuadrado 2015', 'ACCIDENTES por KM cuadrado 2016',
                 'ACCIDENTES por KM cuadrado 2017', 'ACCIDENTES por KM cuadrado 2018',
                 'ACCIDENTES por KM cuadrado 2019', 'MUERTES 2015', 'MUERTES 2016',
                 'MUERTES 2017', 'MUERTES 2018', 'MUERTES 2019')

names(mapa_medellin)<-c('BARRIO', 'SHAPEAREA', 'SHAPELEN', 
                        'ACCIDENTES por KM cuadrado 2015', 'ACCIDENTES por KM cuadrado 2016',
                        'ACCIDENTES por KM cuadrado 2017', 'ACCIDENTES por KM cuadrado 2018',
                        'ACCIDENTES por KM cuadrado 2019', 'MUERTES 2015', 'MUERTES 2016',
                        'MUERTES 2017', 'MUERTES 2018', 'MUERTES 2019', 'CLUSTER','geometry'
                        )
for (var_ in var_clusters[-1]){
  mapa_medellin[[var_]]<-round(mapa_medellin[[var_]])
} 


usuario<- fluidPage(
  dashboardPage(
    # header princial
    dashboardHeader(title="Accidentes Medellín",
                    # titleWidth = 400, 
                    tags$li(class="dropdown",
                            tags$a(href=url_github, 
                                   icon("github"), 
                                   "Source Code", 
                                   target="_blank"))),
    # left 
    dashboardSidebar(
      sidebarMenu(id="sidebar",
                  fluidRow(style='height:5vh'),
                  menuItem("Problematica", tabName="intro", icon=icon("users")),
                  menuItem(text= "Accidentes 2015 2022",tabName = "series",icon = icon("chart-line")),
                  menuItem(text= "Accidentes Barrios",tabName = "map",icon = icon("earth-americas"))
      )  ),
    # itmes
    dashboardBody(tabItems (
      # mapa
      tabItem(tabName="map",
              tabBox(id="t3",width= 12,
                     # puntos universidades
                     tabPanel(title="Información por barrio",
                              icon=icon('map'),
                              fluidPage(
                                fluidRow( uiOutput("text_geo") ), 
                                fluidRow(column(6,
                                                selectInput(inputId ="cluster" ,label= "Seleccione el cluster",
                                                            choices =unique(mapa_medellin$CLUSTER),multiple = F,
                                                            selected =unique(mapa_medellin$CLUSTER)[1] )),
                                         column(6, selectInput(inputId ="estado" ,label= "Seleccione una Variable",
                                                               choices =var_clusters,multiple = F) ) )
                                ,fluidRow( uiOutput("text_geo2") ), 
                                fluidRow( plotlyOutput("map_plot") )
                               ))
                     
              )),
      tabItem(tabName = 'series',
              tabBox(id='t3',width= 12,tabPanel(
                HTML('<i class="fa-duotone fa-chart-scatter"></i>Numeric'),icon=icon('chart-line'),
                fluidPage( fluidRow(uiOutput("intro_series") ),
                  fluidRow(column( 6,
                                   daterangepicker("rangos_fecha",
                                                     "Seleccione entre que fechas quiere los accidentes",
                                       style = paste0(
                                         "background-color: chartreuse; ",
                                         "box-shadow: 0 30px 40px 0 rgba(16, 36, 94, 0.2);"
                                       ),
                                       start="2021-01-01 UTC",
                                       end = max(prediccion$FECHA_ACCIDENTE_),
                                       min = min(prediccion$FECHA_ACCIDENTE_),
                                       max= max(prediccion$FECHA_ACCIDENTE_)
                                     )),column(6,uiOutput('resumen'))) ,
                                     fluidRow(plotlyOutput('serie_plot')) 
                                                ))
              )),
      # item descripcion 
      tabItem(tabName = 'intro',fluidRow(style='height:5vh'),
              tabBox(id='t3',width=12,tabPanel(HTML('<i class="fa-solid fa-book"></i> Contexto'), 
                                               fluidPage(
                                                 fluidRow(uiOutput('intro_'))
                                               ))) )
    )
    
    )
  )
)
servidor<-function(input, output) {
  output$intro_series<-renderUI({
    HTML("El número de accidentes en el tiempo, el 2014 a 2020 son 
         los valores reales, a partir del 2021 a 2022 se tiene el pronóstico.")
    
  })
  output$text_geo<-renderUI({
  HTML("Este mapa considera 320 barrios y veredas en la ciudad de Medellín,
    seleccione el grupo de barrios y la accidentalidad según el año.") })
  output$text_geo2<- renderUI({
 HTML(paste("<center> <b>", input$estado,"</b> </center><br> Busca los barrios de interés</br> "  ))
  })
  output$intro_<-renderUI({
    HTML("
    <br><h2>Accidentes viales en Medellín</h6>
    </br>
  ¿Se ha preguntado como es el comportamiento de los accidentes en la ciudad de Medellín?
  En esta aplicación puede interactuar con la información desde el año 2015 y 2022, 
  también puedes analizar la información por barrio.
  
  <iframe width='560' height='315' src='https://www.youtube.com/embed/lH5U8K_BASs' 
title='YouTube video player' frameborder='0' allow='accelerometer; autoplay; 
clipboard-write; encrypted-media; gyroscope; picture-in-picture'
allowfullscreen></iframe>

           <b> Miembros:</b>
   <h5> &#9658 <a href='https://www.linkedin.com/in/germ%C3%A1n-alonso-pati%C3%B1o-hurtado-828783241/' target='_blank'>
  <i class='fab fa-linkedin' role='presentation' aria-label='linkedin icon'></i>
  Germán Patiño
</a> Estudiante de Estadística en la Universidad Nacional de Colombia.<h5/>
  <h5> &#9658 David Andres Cano Gonzalez Estudiante de ingenieria en sistemas en la Universidad Nacional de Colombia. <h5/>

  <h5> &#9658 David Garcia Blandon Estudiante de ingenieria en sistemas en la Universidad Nacional de Colombia. <h5/>
  <h5> &#9658 <a href='https://www.linkedin.com/in/juan-pablo-buitrago-diaz-5b960922b/' target='_blank'> 
  <i class='fab fa-linkedin' role='presentation' aria-label='linkedin icon'></i>
  Juan Pablo Buitrago Diaz
</a> Estudiante de ingenieria en sistemas en la Universidad Nacional de Colombia. <h5/>

         ")
  })
  

  output$map_plot<-renderPlotly({
    # reactive(input$cluster)
    filtro_<- is.null(input$cluster) | is.element(mapa_medellin$CLUSTER,input$cluster)
    # print(sum(filtro_))
    columnas_<-which( is.element(names(mapa_medellin),
                                 c("BARRIO","descripcion","CLUSTER",input$estado )))
    # 
    mapa_medellin_temp=mapa_medellin[filtro_,]
    
    fig<- ggplot(mapa_medellin_temp,aes(tooltip=BARRIO))+
      # geom_text_repel(aes(label=descripcion), size=5)+
      geom_sf(aes(fill=get(input$estado ) ))+
      labs(fill=" " )+
      xlim(-75.71739,-75.48462 )+
      ylim(6.162904,6.374872)
    
    plotly::ggplotly( fig )

}
   )


  # mapa university 
#  output$map_plot <- renderTmap({
  #   
  #   filtro<-is.element(datos_geo$CLUSTER,  input$cluster) | is.null(input$cluster)
  #   
  #   filtro2<-is.element(datos_geo$st_fips, input$estado ) | is.null(input$estado)
  #   #    tmap_mode('view') %>%
  #   tm_shape(shp = datos_geo[filtro & filtro2,])+ # coordenadas lat long
  #     tm_dots(size = 0.05,col = "CLUSTER",popup.vars=c('address',var_numeric,var_cat)) })
  # values<-reactiveValues(universidad=c(), url_1=c(),url_2=c())
  # output$map_plot_state <- renderTmap({
  #   tm_shape(mapa_usa )+
  #     tm_polygons('Cluster_top',popup.vars= c("mean_TUITFTE" ,
  #                                             "mean_INEXPFTE", "Cluster_1","Cluster_2","Cluster_3","Cluster_4"))
 #   }
#    )
#  observeEvent(input$map_plot_marker_click,{
#    click_<-input$map_plot_marker_click
    # filtro<-paste('X',datos$OPEID,sep='')==click_$id
    # uni_click<-datos[filtro,c('address','INSTURL')]
    # filtro<-!is.element(values$universidad,uni_click[1]$address)
    # values$universidad<-c(values$universidad[filtro], uni_click[1]$address)
    # values$url_1<-c(values$url_1[filtro], uni_click[2]$INSTURL)
    # 
    # print(values$universidad)
    # output$urls<- renderUI({ 
    #   
    #   contar<-3
    #   n_<-length(values$universidad)
    #   text_<-list(tags$b('Show last 6 university.'),tags$br())
    #   indice<-n_
    #   while(indice>0 & n_-indice<7  ){
    #     text_[[contar]]<-tags$b( values$universidad[indice])
    #     text_[[contar+1]]<-HTML(values$url_1[indice])
    #     contar<-contar+2
    #     indice<-indice-1
    #   }
    #   print(text_)
    #   tagList(text_)
   # })
 # })
  #,escape=1)
  output$resumen<- renderUI({
    fechas_<-input$rangos_fecha
    filtro_fecha<-(prediccion$FECHA_ACCIDENTE_>=fechas_[1] &
                     prediccion$FECHA_ACCIDENTE_<=fechas_[2] )   
    texto_<-paste("<br> Resumen estadístico Número de accidentes: </br>
    <br> Entre las fechas ",fechas_[1]," y " ,fechas_[2],"</br>",
                  "<style>
  .tb { border-collapse: collapse; width:100px; }
  .tb th, .tb td { padding: 5px; border: solid 1px #777; }
  .tb th { background-color: lightblue; }
</style>
                  <table class='tb'><tr>",
                  "<th scope='row'> Tipo accidente </th>",
                   "<th> Total </th>
                  <th> Promedio </th>
                  <th> Q1 </th>
                  <th> Q2 </th>
                  <th> Q3 </th>
                  </tr><tr>",sep="" )
    for (clase in unique(prediccion$CLASE_ACCIDENTE)){
      filtro_clase <-prediccion$CLASE_ACCIDENTE==clase & filtro_fecha
      texto_<-paste(texto_, "<th>", clase,"</th><td>", 
                    as.character(round(sum(prediccion[filtro_clase ,"Y"])) )
                    ,"</td>",sep="" )
      texto_<-paste(texto_, "<td>", 
                    as.character(round(mean(prediccion[filtro_clase,"Y"])) )
                    ,"</td>",sep="" )
      texto_<-paste(texto_, "<td>", 
                    as.character(round( quantile(prediccion[filtro_clase,"Y"],0.25)) )
                    ,"</td>",sep="" )
      texto_<-paste(texto_, "<td>", 
                    as.character(round( quantile(prediccion[filtro_clase,"Y"],0.5)) )
                    ,"</td>",sep="" )
      texto_<-paste(texto_, "<td>", 
                    as.character(round( quantile(prediccion[filtro_clase,"Y"],0.75)) )
                    ,"</td></tr>",sep="" )
    }
    texto_<-paste(texto_," </table>",sep="" )
    HTML(texto_)
    
  })

  output$serie_plot<- renderPlotly({
    fechas_<-input$rangos_fecha
    filtro_inicio<-prediccion[,'FECHA_ACCIDENTE_']>=fechas_[1]
    filtro_fin<-prediccion[,'FECHA_ACCIDENTE_']<=fechas_[2]
    prediccion_temp<-prediccion[filtro_inicio & filtro_fin,] 
    
    plot_ly() %>%
      add_lines(x=prediccion_temp[,'FECHA_ACCIDENTE_'], y=prediccion_temp[,"Y"],
                  color=prediccion_temp[,'CLASE_ACCIDENTE']  ) %>%
      layout(xaxis=list(title= 'Fecha del Accidente.' ),
             yaxis=list(title= "Número de accidentes en Medellín." ),
             legend=list(title=list(text='Tipo de accidente.')))
  })
}
shinyApp(
  ui = usuario,
  
  server = servidor
)



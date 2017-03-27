# Brier Score and Visual for survey predictions and results
# last update:2017-03-26

appStatusQuality <- function(){
        tabPanel('Qualität', br(),
                 fluidRow(
                         column(1),
                         column(10,
                                span('an'),
                                textOutput('surveyCount', inline = TRUE), 
                                span('Umfragen teilgenommen'),
                                br(),
                                span('dabei'),
                                textOutput('responseCount', inline = TRUE),
                                span('Vorhersagen getroffen'),
                                h2('Brier-Score'), 
                                verbatimTextOutput('brierScore'),
                                h2('Kalibrierung'),
                                plotlyOutput('calibrationChart')
                         )
                 )
        )
}
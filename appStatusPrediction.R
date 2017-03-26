# list of all Predictions
# last update:2017-03-26

appStatusPrediction <- function(){
        tabPanel('Umfragen', br(),
                 DT::dataTableOutput('predictionList')
        )
}
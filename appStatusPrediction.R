# list of all Predictions
# last update:2017-03-26

appStatusPrediction <- function(){
        tabPanel('Umfragen', br(),
                 bsModal('forecastTableDialog',
                         'Vorhersagen',
                         trigger = NA,
                         size='large',
                         DT::dataTableOutput('forecastTable')
                 ),
                 DT::dataTableOutput('predictionList'),
                 actionButton('showForecasts',
                              'Vorhersagen anzeigen',
                              icon = icon('search'))
        )
}
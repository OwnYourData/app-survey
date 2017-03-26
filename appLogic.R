# application specific logic
# last update: 2017-02-13

source('srvEmail.R', local=TRUE)
source('srvScheduler.R', local=TRUE)

source('appLogicSurvey.R', local=TRUE)

# any record manipulations before storing a record
appData <- function(record){
        record
}

getRepoStruct <- function(repo){
        appStruct[[repo]]
}

repoData <- function(repo){
        data <- data.frame()
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']],
                                repo)
                data <- readItems(app, url)
        }
        data
}

# anything that should run only once during startup
appStart <- function(){
        surveyList()
}

output$predictionList <- DT::renderDataTable(datatable({
        data.frame()
}, options = list(
        language = list(
                url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/German.json')
)
))

output$surveyCount <- renderText({
        15
})

output$responseCount <- renderText({
        20
})

output$brierScore <- renderText({
        0.22
})

output$calibrationChart <- renderPlotly({
        pdf(NULL)
        outputPlot <- plotly_empty()
        dev.off()
        outputPlot
})

observeEvent(input$saveForecastInput, {
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']], 
                                       '.response'))
                data <- list(date = as.character(input$dateInput),
                             survey = input$surveySelect,
                             option = input$sforecastSelect,
                             confidence = input$confidenceValue,
                             note = input$noteInput,
                             '_oydRepoName' = 'Vorhersage')
                writeItem(app, url, data)
                createAlert(session, 'saveForecastInfo', alertId = 'saveTask',
                            style = 'success', append = FALSE,
                            content = 'Daten gespeichert')
        }
})

observeEvent(input$surveySelect, {
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], app[['app_key']])
                selItem <- input$surveySelect
                recs <- readItems(app, url)
                save(recs, selItem, file='tmpDebug.RData')
                opts <- recs[recs$name == selItem, 'options']
                if(length(opts) > 0){
                        currOptions <- lapply(strsplit(recs[recs$name == selItem, 'options'], ';'), 
                                              trimws)[[1]]
                        updateSelectInput(session, 'forecastSelect', 
                                          choices = currOptions,
                                          selected = currOptions[1])
                } else {
                        updateSelectInput(session, 'forecastSelect', 
                                          choices = c('leer'), 
                                          selected = 'leer')
                }
        }
})
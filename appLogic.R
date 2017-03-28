# application specific logic
# last update: 2017-02-13

source('srvDateselect.R', local=TRUE)
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
        data <- currDataDateSelect()
        app <- currApp()
        url <- itemsUrl(app[['url']],
                        paste0(app[['app_key']], '.response'))
        prediction <- readItems(app, url)
        if(nrow(data) > 0){
                data$order <- 1:nrow(data)
                cnts <- data.frame(table(unlist(prediction$survey)))
                data <- merge(data, cnts, by.x='name', by.y='Var1',
                              all.x=TRUE, all.y=FALSE)
                last <- aggregate(prediction[order(prediction$date), 'option'], 
                                  by=list(prediction[order(prediction$date), 'survey']), 
                                  FUN=tail, n=1)
                data <- merge(data, last, by.x='name', by.y='Group.1',
                              all.x=TRUE, all.y=FALSE)
                data <- data[order(data$order), ]
                data <- data[, c('date', 'name', 'Freq','x', 'result')]
                colnames(data) <- c('Datum', 'Name', '# Prognosen', 'letzte Vorhersage', 'Ergebnis')
        }
        data
        
}, 
        options = list(
                language = list(
                        url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/German.json'),
                aoColumnDefs = list(list(targets=4, class='dt-right'))),
        selection = 'single'
))

observeEvent(input$showForecasts, {
        selItem <- input$predictionList_rows_selected
        if(is.null(selItem)){
                createAlert(session, 'taskInfo', 'nothingSelect',
                            style = 'warning', append = FALSE,
                            title = 'Details für Auswahl',
                            content = 'Es ist keine Umfrage ausgewählt.')
        } else {
                closeAlert(session, 'nothingSelect')
                output$forecastTable <- DT::renderDataTable(datatable({
                        surveys <- currDataDateSelect()
                        app <- currApp()
                        url <- itemsUrl(app[['url']],
                                        paste0(app[['app_key']], '.response'))
                        data <- readItems(app, url)
                        data <- data[data$survey == surveys[selItem, 'name'], 
                                     c('date', 'option', 'confidence', 'note')]
                        colnames(data) <- c('Datum', 'Vorhersage', 'Konfidenz', 'Notiz')
                        data
                }, 
                selection = 'none', 
                options = list(language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/German.json'),
                               # aoColumnDefs = list(list(targets=2, class='dt-right')),
                               order = list(list(1, 'desc')),
                               searching = FALSE,
                               lengthChange = FALSE,
                               pageLength = 10
                               )))
                toggleModal(session, 'forecastTableDialog')
        }
})

output$surveyCount <- renderText({
        nrow(currDataDateSelect())
})

output$responseCount <- renderText({
        data <- currDataDateSelect()
        if(nrow(data) > 0){
                app <- currApp()
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']], '.response'))
                prediction <- readItems(app, url)
                cnts <- data.frame(table(unlist(prediction$survey)))
                data <- merge(data, cnts, by.x='name', by.y='Var1',
                              all.x=TRUE, all.y=FALSE)
                sum(data$Freq)
        } else {
                0
        }
})

output$brierScore <- renderText({
        data <- currDataDateSelect()
        if(nrow(data) > 0){
                app <- currApp()
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']], '.response'))
                prediction <- readItems(app, url)
                responses <- merge(data, prediction, by.x='name', by.y='survey',
                              all.x=FALSE, all.y=TRUE)
                responses <- responses[!is.na(responses$result), 
                                       c('result', 'option', 'confidence')]
                responses$answer <- 0
                responses[responses$result == responses$option, 'answer'] <- 1
                responses$g <- 1
                responses$confidence <- as.numeric(responses$confidence) / 100
                brierscore(answer ~ confidence, data=responses, group='g')$mnbrier[[1]]
        } else {
                NA
        }
})

output$calibrationChart <- renderPlotly({
        pdf(NULL)
        outputPlot <- plotly_empty()
        data <- currDataDateSelect()
        if(nrow(data) > 0){
                app <- currApp()
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']], '.response'))
                prediction <- readItems(app, url)
                responses <- merge(data, prediction, by.x='name', by.y='survey',
                                   all.x=FALSE, all.y=TRUE)
                responses <- responses[!is.na(responses$result), 
                                       c('result', 'option', 'confidence')]
                responses$confidence <- as.numeric(responses$confidence)/100
                answer <- vector()
                forecast <- vector()
                
                check <- 0
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                check <- 0.2
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                check <- 0.4
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                check <- 0.6
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                check <- 0.8
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                check <- 1
                cnt <- nrow(responses[responses$confidence == check, ])
                if(cnt > 0){
                        answer <- c(answer, check)
                        forecast <- c(forecast, nrow(responses[responses$confidence == check &
                                                                       responses$result == responses$option, ])/cnt)
                }
                
                df <- data.frame(answer, forecast)
                axis <- list(
                        mirror = "ticks",
                        gridcolor = toRGB("gray80"),
                        gridwidth = 2,
                        linecolor = toRGB("black"),
                        linewidth = 6,
                        range=c(0,1)
                )
                outputPlot <- plot_ly(type='scatter') %>%
                        add_markers(x=df$answer, y=df$forecast, mode="point", marker=list(size=18), name='') %>%
                        add_lines(x=c(0,1), y=c(0,1), line=list(color='rgb(205, 12, 24)', width=4), name='') %>%
                        layout(xaxis = axis, yaxis = axis, showlegend = FALSE, width=400, height=400)
        }
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
                             option = input$forecastSelect,
                             confidence = input$confidenceValue,
                             note = input$noteInput,
                             '_oydRepoName' = 'Vorhersage')
                writeItem(app, url, data)
                createAlert(session, 'saveForecastInfo', alertId = 'saveTask',
                            style = 'success', append = FALSE,
                            content = 'Daten gespeichert')
                
                updateDateInput(session, 'dateInput', 
                                value = as.character(Sys.Date()))
                updateSelectInput(session, 'surveySelect', selected = '')
                updateSelectInput(session, 'forecastSelect',
                                  choices = '', selected = '')
                updateSliderInput(session, 'confidenceValue', value = 60)
                updateTextAreaInput(session, 'noteInput', value = '')
        }
})

observeEvent(input$surveySelect, {
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], app[['app_key']])
                selItem <- input$surveySelect
                recs <- readItems(app, url)
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

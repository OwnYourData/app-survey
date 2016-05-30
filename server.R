# OYD: Umfragen - last update:2016-05-27
# Manifest for survey app ================================
'
encode with https://www.base64encode.org/
{
        "name":"Survey App",
        "identifier":"eu.ownyourdata.survey",
        "type":"external",
        "description":"perform and evaluate surveys",
        "permissions":["eu.ownyourdata.survey:read",
                       "eu.ownyourdata.survey:write",
                       "eu.ownyourdata.survey:update",
                       "eu.ownyourdata.survey:delete",
                       "eu.ownyourdata.survey.ngo:read",
                       "eu.ownyourdata.survey.ngo:write",
                       "eu.ownyourdata.survey.ngo:update",
                       "eu.ownyourdata.survey.ngo:delete",
                       "eu.ownyourdata.survey.ngo.config:read",
                       "eu.ownyourdata.survey.ngo.config:write",
                       "eu.ownyourdata.survey.ngo.config:update",
                       "eu.ownyourdata.survey.ngo.config:delete"]
}
ew0KICAgICAgICAibmFtZSI6IlN1cnZleSBBcHAiLA0KICAgICAgICAiaWRlbnRpZmllciI6ImV1Lm93bnlvdXJkYXRhLnN1cnZleSIsDQogICAgICAgICJ0eXBlIjoiZXh0ZXJuYWwiLA0KICAgICAgICAiZGVzY3JpcHRpb24iOiJwZXJmb3JtIGFuZCBldmF1bGF0ZSBzdXJ2ZXlzIiwNCiAgICAgICAgInBlcm1pc3Npb25zIjpbImV1Lm93bnlvdXJkYXRhLnN1cnZleTpyZWFkIiwNCiAgICAgICAgICAgICAgICAgICAgICAgImV1Lm93bnlvdXJkYXRhLnN1cnZleTp3cml0ZSIsDQogICAgICAgICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zdXJ2ZXk6dXBkYXRlIiwNCiAgICAgICAgICAgICAgICAgICAgICAgImV1Lm93bnlvdXJkYXRhLnN1cnZleTpkZWxldGUiLA0KICAgICAgICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc3VydmV5Lm5nbzpyZWFkIiwNCiAgICAgICAgICAgICAgICAgICAgICAgImV1Lm93bnlvdXJkYXRhLnN1cnZleS5uZ286d3JpdGUiLA0KICAgICAgICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc3VydmV5Lm5nbzp1cGRhdGUiLA0KICAgICAgICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc3VydmV5Lm5nbzpkZWxldGUiLA0KICAgICAgICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc3VydmV5Lm5nby5jb25maWc6cmVhZCIsDQogICAgICAgICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zdXJ2ZXkubmdvLmNvbmZpZzp3cml0ZSIsDQogICAgICAgICAgICAgICAgICAgICAgICJldS5vd255b3VyZGF0YS5zdXJ2ZXkubmdvLmNvbmZpZzp1cGRhdGUiLA0KICAgICAgICAgICAgICAgICAgICAgICAiZXUub3dueW91cmRhdGEuc3VydmV5Lm5nby5jb25maWc6ZGVsZXRlIl0NCn0=
'

# Setup and config ========================================
# install.packages(c('shiny', 'shinyBS', 'RCurl', 'jsonlite', 'dplyr'), repos='https://cran.rstudio.com/')
library(shiny)
library(RCurl)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(lattice)

first <- TRUE

# Shiny Server ============================================
shinyServer(function(input, output, session) {
        output$upgradeLink <- renderText({
                renderUpgrade(session)
        })
        
# Survey specific functions ==============================
        currRepo <- reactive({
                url <- input$pia_url
                app_key <- input$app_key
                app_secret <- input$app_secret
                if(is.null(url) |
                   is.null(app_key) | 
                   is.null(app_secret)) {
                        vector()
                } else {
                        if((nchar(url) > 0) & 
                           (nchar(app_key) > 0) & 
                           (nchar(app_secret) > 0)) {
                                if(input$showPiaSetup){
                                        if(input$localSave == TRUE) {
                                                save(url, 
                                                     app_key, 
                                                     app_secret, 
                                                     file=paste0('~/',
                                                                 appName,
                                                                 'Credentials.RData'))
                                        } else {
                                                # if (file.exists('~/surveyCredentials.RData'))
                                                #         file.remove('~/surveyCredentials.RData')
                                        }
                                }
                                getRepo(url, app_key, app_secret)
                        } else {
                                vector()
                        }
                }
        })

        currData <- function(){
                repo <- currRepo()
                category <- 'ngo' #input$surveySelect
                if(length(repo) > 0) {
                        url <- itemsUrl(repo[['url']], 
                                        paste0(repo[['app_key']], 
                                               '.', category))
                        piaData <- readItems(repo, url)
                        # if(nrow(piaData)>0){
                        #         names(piaData)[names(piaData) == 'value'] <- 
                        #                 category
                        # }
                } else {
                        piaData <- data.frame()
                }
                piaData
        }

        plotData <- function(category){
                if(first) {
                        if(grepl('.herokuapp.com', session$clientData$url_hostname)) {
                                internetAlert(session, 'https://www.ownyourdata.eu/apps/')
                        }
                        first <<- FALSE                  
                }
                closeAlert(session, 'noDataAlert')
                data <- currData()
                if(nrow(data) > 0) {
                        # plotCategory(data, category)
                        # !!!fix_me!!!
                } else {
                        createAlert(session, 'noData', 'noDataAlert', style='info', title='Keine Daten vorhanden',
                                    content='Erfasse Datensätze oder abonniere ein periodisches Email zur Datensammlung.', append=FALSE)
                }
        }

        saveCategory <- function(repo, category, date, value){
                if(!is.null(date)){
                        piaData <- currData()
                        existData <- piaData[piaData$date == date, ]
                        data <- list(date=date, 
                                     value=value)
                        url <- itemsUrl(repo[['url']], 
                                        paste0(repo[['app_key']], '.', category))
                        if (nrow(existData) > 0) {
                                if(is.na(value) | is.null(value)){
                                        deleteRecord(repo, url, existData$id)
                                } else {
                                        updateRecord(repo, url, data, existData$id)
                                }
                        } else {
                                if(!is.na(value) & !is.null(value)){
                                        writeRecord(repo, url, data)
                                }
                        }
                }                
        }

# Survey specific output fields ==========================
        values = reactiveValues()
        setHot = function(x) values[["dataSheet"]] = x
        
        observe({
                if(!is.null(input$dataSheet))
                        values[["dataSheet"]] <- hot_to_r(input$dataSheet)
        })

        output$exportCSV <- downloadHandler(
                filename = paste0(appName, '.csv'),
                content = function(file) {
                        write.csv(values[["dataSheet"]], file)
                }
        )
        
        observe({
                newRecords <- values[["dataSheet"]]
                if (!is.null(newRecords)) {
                        newRecords <- cbind(newRecords, NA)
                        colnames(newRecords) <- c('Wert', 'dummy')
                        oldRecords <- currData()
                        if(nrow(oldRecords)>0) {
                                oldRecords <- oldRecords[,c('value')]
                        } else {
                                oldRecords <- as.data.frame(matrix(NA, ncol=1, nrow=1))
                        }
                        oldRecords <- cbind(oldRecords, NA)
                        colnames(oldRecords) <- c('Wert', 'dummy')
                        oldRecords <- as.data.frame(oldRecords)
                        oldRecords$Wert <- as.numeric(oldRecords$Wert)

                        # # check new and updated records
                        # repo <- currRepo()
                        # updatedRecords <- sqldf('SELECT * FROM newRecords EXCEPT SELECT * FROM oldRecords')
                        # if(nrow(updatedRecords)>0){
                        #         for(i in 1:nrow(updatedRecords)){
                        #                 rec <- updatedRecords[i,]
                        #                 # !!!fix_me!!!
                        #         }
                        # }
                        # 
                        # # check for deleted records
                        # deletedRecords <- sqldf('SELECT * FROM oldRecords EXCEPT SELECT * FROM newRecords')
                        # if(nrow(deletedRecords) > 0) {
                        #         for(i in 1:nrow(deletedRecords)){
                        #                 rec <- deletedRecords[i,]
                        #                 # !!!fix_me!!!
                        #                 # saveCategory(repo, 'water', rec$Datum, NA)
                        #         }
                        # }
                }
        })

        output$dataSheet = renderRHandsontable({
                if (!is.null(input$dataSheet)) {
                        DF = hot_to_r(input$dataSheet)
                        DF <- DF[!is.na(DF$Wert),]
                        if(nrow(DF) == 0){
                                DF <- data.frame(Wert = as.numeric(0))
                        } else {
                                DF <- rbind(DF, c(NA, NA))       
                        }
                        colnames(DF) <- c('id', 'Wert')
                } else {
                        DF <- currData()
                        if(nrow(DF)>0){
                                DF <- DF[,c('id', 'value')]
                                DF <- as.data.frame(cbind(DF, NA))
                                colnames(DF) <- c('id', 'Wert')
                                DF <- DF[!is.na(DF$Wert),]
                                DF <- rbind(DF, c(NA, NA))
                        } else {
                                DF <- as.data.frame(matrix(NA, ncol=2, nrow=1))
                                colnames(DF) <- c('id', 'Wert')
                        }
                        DF$Wert <- as.integer(DF$Wert)
                }
                setHot(DF)
                if(nrow(DF)>20) {
                        rhandsontable(DF[, c('id', 'Wert')], useTypes=TRUE, height=400) %>%
                                hot_table(highlightCol=TRUE, highlightRow=TRUE,
                                          allowRowEdit=TRUE)
                } else {
                        rhandsontable(DF[, c('id', 'Wert')], useTypes=TRUE) %>%
                                hot_table(highlightCol=TRUE, highlightRow=TRUE,
                                          allowRowEdit=TRUE)
                }
        })
        
        plotHistogram <- function(){
                data <- currData()
                theta <- input$surveyResult
                ggplot(data, aes(x=as.numeric(data$value))) +
                        geom_histogram() +
                        geom_vline(aes(xintercept = theta), color='green', size=1) +
                        xlab('Schätzung') + 
                        ylab('Anzahl')
        }
        
        output$plotHistogram <- renderPlot({
                input$dataSheet
                input$refreshBtn
                plotHistogram()
        })
        
        plotBoxplot <- function(){
                theta <- input$surveyResult
                data <- currData()
                bwplot(as.numeric(data$value), xlab='Schätzung',
                       key=list(space='top', columns=3,
                                text=list(lab=c('50%:', '95%:', 'Median:',
                                                'Ausreißer:', 'Durchschnitt:', 'Ergebnis:')),
                                lines=list(
                                        pch = c(0,NA,16,1,4,NA),
                                        col = c('blue', 'blue', 'black', 'blue',
                                                'blue', 'green'),
                                        type = c('p', 'l', 'p', 'p', 'p', 'l'),
                                        lwd = c(NA, 1, NA, NA, NA, 3),
                                        cex = c(2, NA, 1.5, 1.5, 1.7, NA),
                                        lty = c(NA, 2, NA, NA, NA, 1))),
                       panel = function(x,y,...) {
                               panel.bwplot(x,y,...)
                               panel.points(x=mean(as.numeric(data$value)),y, pch=4, cex=1.7, col='blue')
                               panel.abline(v=theta, col='green', lwd=3)
                       })
        }

        output$plotBoxplot <- renderPlot({
                input$dataSheet
                input$refreshBtn
                plotBoxplot()
        })
        
        output$participants <- renderText({
                input$dataSheet
                input$refreshBtn
                data <- currData()
                n <- length(which(!is.na(data$value)))
                paste('<strong>Teilnehmer:</strong>',
                      nrow(data))
        })

        output$crowdPrediction <- renderText({
                input$dataSheet
                input$refreshBtn
                data <- currData()
                n <- length(which(!is.na(data$value)))
                crowd <- mean(as.numeric(data$value), na.rm = T)
                
                paste('<strong>Crowd Prediction:</strong>',
                      format(round(crowd, 2), nsmall = 2))
        })
        
        output$crowdError <- renderText({
                input$dataSheet
                input$refreshBtn
                data <- currData()
                n <- length(which(!is.na(data$value)))
                crowd <- mean(as.numeric(data$value))
                theta <- input$surveyResult
                err2 <- (crowd - theta)^2
                
                paste('<strong>Crowd Fehler:</strong>',
                      format(round(err2, 2), nsmall = 2))
        })
        
        output$avgError <- renderText({
                input$dataSheet
                input$refreshBtn
                data <- currData()
                n <- length(which(!is.na(data$value)))
                theta <- input$surveyResult
                avg2 <- sum((as.numeric(data$value) - theta)^2)/n

                paste('<strong>durchschnittlicher Fehler:</strong>',
                      format(round(avg2, 2), nsmall = 2))
        })
        
        output$diversity <- renderText({
                input$dataSheet
                input$refreshBtn
                data <- currData()
                n <- length(which(!is.na(data$value)))
                crowd <- mean(as.numeric(data$value), na.rm = T)
                div2 <- sum((as.numeric(data$value) - crowd)^2)/n
                
                paste('<strong>Streuung:</strong>',
                      format(round(div2, 2), nsmall = 2))
        })
        
        output$current_token <- renderText({
                repo <- currRepo()
                if (length(repo) == 0) {
                        '<strong>Token:</strong> nicht verfügbar'
                } else {
                        paste0('<strong>Token:</strong><br><small>', 
                               repo[['token']], '</small>')
                }
        })
        
        output$curr_records <- renderText({
                data <- currData()
                paste('<strong>Datensätze:</strong>',
                      nrow(data))
        })
})

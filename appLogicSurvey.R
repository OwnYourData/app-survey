# configure surveys
# last update: 2017-03-26

# get stored surveys
readSurveyItems <- function(){
        app <- currApp()
        surveyItems <- data.frame()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], app[['app_key']])
                surveyItems <- readItems(app, url)
                if(nrow(surveyItems) > 0){
                        rownames(surveyItems) <- surveyItems$name
                        surveyItems <- surveyItems[, c('date', 
                                                       'tags', 
                                                       'options', 
                                                       'result', 
                                                       'resultUrl', 
                                                       'active', 
                                                       'id'), 
                                                   drop=FALSE]
                }
        }
        surveyItems
}

surveyList <- function(){
        allItems <- readSurveyItems()
        if(nrow(allItems) > 0){
                # appStatusDateSelect
                currTags <- unique(lapply(
                        strsplit(
                                paste(allItems$tags, collapse = ';'), 
                                ';'), trimws)[[1]])
                currTags <- currTags[currTags != '']
                updateSelectInput(
                        session,
                        'tagSelect',
                        choices = c('alle', currTags),
                        selected = 'alle')

                # appSourceSurvey
                updateSelectInput(
                        session,
                        'surveyList',
                        choices = rownames(allItems),
                        selected = NA)
                
                # appSourceInput
                updateSelectInput(session, 'surveySelect',
                                  choices = rownames(allItems),
                                  selected = rownames(allItems)[1])
                currOptions <- lapply(strsplit(allItems[1, 'options'], ';'), 
                                      trimws)[[1]]
                updateSelectInput(session, 'forecastSelect', 
                                  choices = currOptions,
                                  selected = currOptions[1])
        } else {
                # appStatusDateSelect
                updateSelectInput(
                        session,
                        'tagSelect',
                        choices = c('alle'),
                        selected = 'alle')
                
                # appSourceSurvey
                updateSelectInput(
                        session,
                        'surveyList',
                        choices = rownames(allItems),
                        selected = NA)
                
                # appSourceInput
                updateSelectInput(session, 'surveySelect',
                                  choices = c('keine vorhanden'),
                                  selected = 'keine vorhanden')
                updateSelectInput(session, 'forecastSelect', 
                                  choices = c('leer'),
                                  selected = 'leer')
                
        }
}

# show attributes on selecting an item
observeEvent(input$surveyList, {
        selItem <- input$surveyList
        if(length(selItem)>1){
                selItem <- selItem[1]
                updateSelectInput(session, 'surveyList', selected = selItem)
        }
        allItems <- readSurveyItems()
        selItemName <- selItem
        selItemTags <- allItems[rownames(allItems) == selItem, 'tags']
        selItemDate <- allItems[rownames(allItems) == selItem, 'date']
        selItemOpts <- allItems[rownames(allItems) == selItem, 'options']
        selItemResult <- allItems[rownames(allItems) == selItem, 'result']
        selItemResultUrl <- allItems[rownames(allItems) == selItem, 'resultUrl']
        updateTextInput(session, 'surveyItemName',
                        value = selItemName)
        updateTextInput(session, 'surveyItemTags',
                        value = selItemTags)
        updateDateInput(session, 'surveyItemDate',
                        value = selItemDate)
        updateTextInput(session, 'surveyItemOptions',
                        value = selItemOpts)
        updateTextInput(session, 'surveyItemResult',
                        value = selItemResult)
        # updateTextInput(session, 'surveyItemResultUrl',
        #                 value = selItemResultUrl)
})

observeEvent(input$addSurveyItem, {
        errMsg <- ''
        itemName <- input$surveyItemName
        itemTags <- input$surveyItemTags
        itemDate <- input$surveyItemDate
        itemOptions <- input$surveyItemOptions
        itemResult <- input$surveyItemResult
        # itemResultUrl <- input$surveyItemResultUrl
        
        allItems <- readSurveyItems()
        if(itemName %in% rownames(allItems)){
                errMsg <- 'Name bereits vergeben'
        }
        if(errMsg == ''){
                app <- currApp()
                url <- itemsUrl(app[['url']], app[['app_key']])
                data <- list(
                        name   = itemName,
                        tags = itemTags,
                        date = as.character(itemDate),
                        options = itemOptions,
                        result = itemResult,
                        resultUrl = '', #itemResultUrl,
                        active = TRUE,
                        '_oydRepoName' = 'Umfrage'
                )
                writeItem(app, url, data)
                initNames <- rownames(allItems)
                updateSelectInput(session, 'surveyList',
                                  choices = c(initNames, itemName),
                                  selected = NA)
                updateTextInput(session, 'surveyItemName',
                                value = '')
                updateTextInput(session, 'surveyItemTags',
                                value = '')
                updateDateInput(session, 'surveyItemDate',
                                value = NULL)
                updateTextInput(session, 'surveyItemOptions',
                                value = '')
                updateTextInput(session, 'surveyItemResult',
                                value = '')
                updateTextInput(session, 'surveyItemResultUrl',
                                value = '')
        }
        closeAlert(session, 'mySurveyItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'mySurveyItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        surveyList()
})

observeEvent(input$updateSurveyItem, {
        errMsg   <- ''
        selItem  <- input$surveyList
        itemName <- input$surveyItemName
        itemTags <- input$surveyItemTags
        itemDate <- input$surveyItemDate
        itemOptions <- input$surveyItemOptions
        itemResult <- input$surveyItemResult
        # itemResultUrl <- input$surveyItemResultUrl
        if(is.null(selItem)){
                errMsg <- 'Keine Umfrage ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readSurveyItems()
                app <- currApp()
                id <- allItems[rownames(allItems) == selItem, 'id']
                url <- itemsUrl(app[['url']], app[['app_key']])
                data <- list(
                        name   = itemName,
                        tags = itemTags,
                        date = as.character(itemDate),
                        options = itemOptions,
                        result = itemResult,
                        resultUrl = '', #itemResultUrl,
                        active = TRUE
                )
                updateItem(app, url, data, id)
                newRowNames <- rownames(allItems)
                newRowNames[newRowNames == selItem] <- itemName
                updateSelectInput(session, 'surveyList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'surveyItemName',
                                value = '')
                updateTextInput(session, 'surveyItemTags',
                                value = '')
                updateDateInput(session, 'surveyItemDate',
                                value = NULL)
                updateTextInput(session, 'surveyItemOptions',
                                value = '')
                updateTextInput(session, 'surveyItemResult',
                                value = '')
                # updateTextInput(session, 'surveyItemResultUrl',
                #                 value = '')
        }
        closeAlert(session, 'mySurveyItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'mySurveyItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        surveyList()
})

observeEvent(input$delSurveyList, {
        errMsg  <- ''
        selItem <- input$surveyList
        if(is.null(selItem)){
                errMsg <- 'Keine Umfrage ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readSurveyItems()
                newRowNames <- rownames(allItems)
                app <- currApp()
                url <- itemsUrl(app[['url']], app[['app_key']])
                id <- allItems[rownames(allItems) == selItem, 'id']
                deleteItem(app, url, id)
                newRowNames <- newRowNames[newRowNames != selItem]
                allItems <- allItems[rownames(allItems) != selItem, ]
                updateSelectInput(session, 'surveyList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'surveyItemName',
                                value = '')
                updateTextInput(session, 'surveyItemTags',
                                value = '')
                updateDateInput(session, 'surveyItemDate',
                                value = NULL)
                updateTextInput(session, 'surveyItemOptions',
                                value = '')
                updateTextInput(session, 'surveyItemResult',
                                value = '')
                # updateTextInput(session, 'surveyItemResultUrl',
                #                 value = '')
        }
        closeAlert(session, 'mySurveyItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'mySurveyItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        surveyList()
})

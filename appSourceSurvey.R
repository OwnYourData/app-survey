# configure Predictions
# last update:2017-03-26

appSourceSurvey <- function(){
        tabPanel('Umfragen', br(),
                 helpText('Konfiguriere hier deine Umfragen.', style='display:inline'), 
                 br(), br(),
                 fluidRow(
                         column(4,
                                selectInput('surveyList',
                                            'Umfragen:',
                                            surveyUiList,
                                            multiple=TRUE, 
                                            selectize=FALSE,
                                            size=12),
                                actionButton('delSurveyList', 'Entfernen', 
                                             icon('trash'))),
                                # actionButton('archiveSurveyList', 'Archivieren',
                                #              icon('archive'))),
                         column(8,
                                textInput('surveyItemName', 'Name:', value = ''),
                                textInput('surveyItemTags', 'Bereiche:', value = ''),
                                dateInput('surveyItemDate', 'End-Datum:', lang = 'de'),
                                textInput('surveyItemOptions', 'Optionen:', value = ''),
                                textInput('surveyItemResult', 'Ergebnis:', value = ''),
                                # textInput('surveyItemResultUrl', 'Quelle für Ergebnis:', value = ''),
                                br(),
                                actionButton('addSurveyItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateSurveyItem', 
                                             'Aktualisieren', icon('edit'))#,
                                # actionButton('loadSurveyItem', 
                                #              'Ergebnis laden', icon('download'))
                         )
                 )
        )
}

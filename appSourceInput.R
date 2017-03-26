# collect Data
# last update:2017-03-26

appSourceInput <- function(){
        tabPanel('Datenerfassung', br(),
                 fluidRow(
                         column(2,
                                img(src='write.png',
                                    width='70px',
                                    style='margin-left:40px;')),
                         column(9,
                                helpText('Erfasse hier eine neue Vorhersage.'),
                                dateInput('dateInput',
                                          label = 'Datum',
                                          language = 'de'),
                                selectInput('surveySelect', 
                                            label = 'Umfrage',
                                            choices = c('leer'),
                                            selected = 'leer'),
                                selectInput('forecastSelect', 
                                            label = 'Vorhersage',
                                            choices = c('leer'),
                                            selected = 'leer'),
                                sliderInput('confidenceValue',
                                            'Konfidenz',
                                            min = 0, max = 100, value = 60,
                                            step = 20, post='%'),
                                tags$label('Notiz:'),
                                br(),
                                tags$textarea(id='noteInput',
                                              rows=2, cols=80,
                                              ''),
                                br(),br(),
                                bsAlert('saveForecastInfo'),
                                actionButton('saveForecastInput', 'Speichern',
                                             icon('save'))
                         )
                 )
        )
}
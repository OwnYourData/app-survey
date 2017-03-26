# global constants available to the app
# last update:2016-01-17

# constants required for every app
appName <- 'survey'
appTitle <- 'Vorhersagen'
app_id <- 'eu.ownyourdata.survey'
helpUrl <- 'https://www.ownyourdata.eu/apps/vorhersagen'
mobileUrl <- 'https://vorhersagen-mobil.datentresor.org'

# definition of data structure
currRepoSelect <- ''
appRepos <- list(Umfrage = 'eu.ownyourdata.survey',
                 Vorhersage = 'eu.ownyourdata.survey.response',
                 Verlauf = 'eu.ownyourdata.survey.log')
appStruct <- list(
        Umfrage = list(
                fields      = c('date', 'name', 'tags', 'options', 'result', 'resultUrl', 'active'),
                fieldKey    = 'name',
                fieldTypes  = c('date', 'string', 'string', 'string', 'string', 'string', 'boolean'),
                fieldInits  = c('empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'true'),
                fieldTitles = c('Datum', 'Name', 'Bereiche', 'Optionen', 'Ergebnis', 'Ergebnis URL', 'aktiv'),
                fieldWidths = c(150, 200, 200, 200, 100, 200, 50)),
        Vorhersage = list(
                fields      = c('date', 'survey', 'option', 'confidence', 'note'),
                fieldKey    = 'date',
                fieldTypes  = c('date', 'string', 'string', 'integer', 'string'),
                fieldInits  = c('empty', 'empty', 'empty', 100, 'empty'),
                fieldTitles = c('Datum', 'Vorhersage', 'Antwort', 'Sicherheit', 'Notiz'),
                fieldWidths = c(150, 200, 200, 50, 300)),
        Verlauf = list(
                fields      = c('date', 'description'),
                fieldKey    = 'date',
                fieldTypes  = c('date', 'string'),
                fieldInits  = c('empty', 'empty'),
                fieldTitles = c('Datum', 'Text'),
                fieldWidths = c(150, 450)))

# Version information
currVersion <- "0.3.0"
verHistory <- data.frame(rbind(
        c(version = "0.3.0",
          text    = "erstes Release")
))

# app specific constants
surveyUiList <- vector()
source("appStatusDateSelect.R")
source("appStatusSurveySelect.R")
source("appStatusItems.R")

tabAppStatusUI <- function(){
        fluidRow(
                column(1),
                column(10,
                       h3('Anzeige'),
                       #tabAppStatusDateSelectUI(),
                       tabAppStatusSurveySelectUI(),
                       bsAlert('noData'),
                       hr(),
                       tabAppStatusItemsUI(),
                       bsAlert("noPIA"))
        )
}
# layout for section "Source"
# last update: 2016-10-06

source('appSourceSurvey.R')
source('appSourceInput.R')

appSource <- function(){
        fluidRow(
                column(12,
                       # uiOutput('desktopUiSourceItemsRender')
                       tabsetPanel(type='tabs',
                                   appSourceSurvey(),
                                   appSourceInput()
                       )
                )
        )
}

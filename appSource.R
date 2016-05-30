tabAppSourceUI <- function(){
        fluidRow(
                column(1),
                column(10,
                       tabsetPanel(
                               type="tabs",
                               tabPanel("Web Umfrage",
                                        fluidRow(
                                                column(2,
                                                       img(src='survey-icon.jpg',width='100px')),
                                                column(9,
                                                       helpText('hier kannst du die Umfragen konfigurieren')
                                                )
                                        )
                                )
                       )
                )
        )
}
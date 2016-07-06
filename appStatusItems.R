tabAppStatusItemsUI <- function(){
        tabsetPanel(type='tabs',
                tabPanel('Histogramm', 
                         plotOutput(outputId = 'plotHistogram', height = '300px')),
                tabPanel('Boxplot', 
                         plotOutput(outputId = 'plotBoxplot', height = '200px')),
                tabPanel('Diversity Prediction Theorem', 
                         fluidRow(
                                 column(6,
                                        br(),
                                        p(htmlOutput('participants')),
                                        p(htmlOutput('crowdPrediction')),
                                        p(htmlOutput('crowdMedian'))),
                         column(6,
                                        br(),
                                        p(htmlOutput('crowdError')),
                                        p(htmlOutput('avgError')),
                                        p(htmlOutput('diversity')))
                         ),
                         img(src='https://s3-eu-west-1.amazonaws.com/crowdstatusimages/cpt.png',width='600px'))
        )
}

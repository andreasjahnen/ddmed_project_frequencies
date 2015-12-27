library(shiny)
library(ggplot2)  

load("doseData.Rda")

shinyUI(navbarPage(
    "", tabPanel(
        "Radiation Exposure Frequency",
        sidebarLayout(
            sidebarPanel(
                HTML("This application lets you expore the data collected during the <a href=\"http://www.ddmed.eu\" target=\"_blank\">DDMED II project</a>"),
                HTML(".<br/> Please read the <b>help section</b> on the top navigation bar for details.</p>"),
                
                # Input parameters for the model:
                radioButtons("outcome", label = h3("Outcome variables"),
                             choices = list(
                                 "GDP" = 1, 
                                 "Radiologists per 1000" = 2, 
                                 "CT Scanners per Million" = 2, 
                                 "GPs per Million" = 4),
                             selected = 1),
                radioButtons("regression", label = h3("Regression variables"),
                             choices = list(
                                 "Number of xRay per 1000" = 1, 
                                 "Number of CT per 1000" = 2, 
                                 "Number of NM per 1000" = 3, 
                                 "Number of IV per 1000" = 4, 
                                 "Total Frequencies" = 5),
                             selected = 1),
                checkboxGroupInput(
                    'show_countries',  label = h3('Country data to select:'),
                    choices = as.character(doseData$Country), 
                    selected = as.character(doseData$Country)
                )
            ),
            
            # Display the data and the results here:
            mainPanel(
                "Find below the selected radiation dose data:",
                DT::dataTableOutput('doseDataDT'),
                actionButton("goButton", "Calculate Regression and plot result!"),
                verbatimTextOutput("nText"),
                plotOutput("plot1", click = "plot_click")

            ))
        ),
        
        # for the help:
        tabPanel("Help",
                 mainPanel(
                         includeMarkdown("help.Rmd")
                 )
    )
))
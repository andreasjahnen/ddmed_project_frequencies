library(shiny)
library(ggplot2)
library("xlsx")

ggplotRegression <- function (fit) {
    
    require(ggplot2)
    
    ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
        geom_point() +
        stat_smooth(method = "lm", col = "red") +
        labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                           "Intercept =",signif(fit$coef[[1]],5 ),
                           " Slope =",signif(fit$coef[[2]], 5),
                           " P =",signif(summary(fit)$coef[2,4], 5)))
}

#setwd("/home/jahnen/Dropbox/Learning/Data Science Degree/Developing Data Products/week 3/")

population <- read.xlsx("./data/xray_top20_20130109cleaned.xls", 1)
xray_top20_frequencies <- read.xlsx("./data/xray_top20_20130109cleaned.xls", 2)
detailedQ <- read.xlsx("./data/results-survey54177_20130102cleanded.xls", 1)

# merge the two variables into one data frame:
xray_top20_frequencies$code <- xray_top20_frequencies$Country.Code
analysisData <- data.frame(population, xray_top20_frequencies, by="code")
analysisData <- data.frame(analysisData, detailedQ, by="code")

temp <- merge(population, xray_top20_frequencies, by.population = "code", by.xray_top20_frequencies = "Country.Code")
analysisData <- merge(temp, detailedQ, by.temp = "code", by.detailedQ = "code")

finalData <- subset(analysisData, select=c("code", "population", "GDP", "CT.head", "CT.neck", "CT.chest", "CT.spine", "CT.abdomen", "CT.pelvis", "CT.trunk....", "Chest.Thorax", "Cervical.spine", "Thoracic.spine", "Lumbar.spine..inc.LSJ.", "Mammography", "Abdomen", "Pelvis...hip", "Ba.meal", "Ba.enema", "Ba.follow.through", "IVU", "Cardiac.angiography", "PTCA", "X2.1..212.", "X2.1..211.", "X3.1..314.", "Country.Code" ))

# divide CTHead frequency by 1000 as it is given per million:
finalData$CT.head_per1000 <- sapply(finalData$CT.head, function(x) x/1000)
finalData$CT.neck_per1000 <- sapply(finalData$CT.neck, function(x) x/1000)
finalData$CT.chest_per1000 <- sapply(finalData$CT.chest, function(x) x/1000)
finalData$CT.spine_per1000 <- sapply(finalData$CT.spine, function(x) x/1000)
finalData$CT.abdomen_per1000 <- sapply(finalData$CT.abdomen, function(x) x/1000)
finalData$CT.pelvis_per1000 <- sapply(finalData$CT.pelvis, function(x) x/1000)
finalData$CT.trunk...._per1000 <- sapply(finalData$CT.trunk...., function(x) x/1000)

# calculate categories:
finalData$NumberofCTper1000 <- (finalData$CT.head_per1000 + finalData$CT.neck_per1000 + finalData$CT.chest_per1000 + finalData$CT.spine_per1000 + finalData$CT.abdomen_per1000 + finalData$CT.pelvis_per1000 + finalData$CT.trunk...._per1000)

# calculate the xray procedures per 1000 and the sum:
finalData$Chest.Thorax_per1000 <- sapply(finalData$Chest.Thorax, function(x) x/1000)
finalData$Cervical.spine_per1000 <- sapply(finalData$Cervical.spine, function(x) x/1000)
finalData$Thoracic.spine_per1000 <- sapply(finalData$Thoracic.spine, function(x) x/1000)
finalData$Lumbar.spine..inc.LSJ._per1000 <- sapply(finalData$Lumbar.spine..inc.LSJ., function(x) x/1000)
finalData$Mammography_per1000 <- sapply(finalData$Mammography, function(x) x/1000)
finalData$Pelvis...hip_per1000 <- sapply(finalData$Pelvis...hip, function(x) x/1000)
finalData$Abdomen_per1000 <- sapply(finalData$Abdomen, function(x) x/1000)

finalData$NumberofXRayper1000 <- (finalData$Chest.Thorax_per1000 + finalData$Cervical.spine_per1000 + finalData$Thoracic.spine_per1000 + finalData$Lumbar.spine..inc.LSJ._per1000 + finalData$Mammography_per1000 + finalData$Pelvis...hip_per1000 + finalData$Abdomen_per1000)

# calculate the nm procedures per 1000 and the sum:
finalData$Ba.meal_per1000 <- sapply(finalData$Ba.meal, function(x) x/1000)
finalData$Ba.enema_per1000 <- sapply(finalData$Ba.enema, function(x) x/1000)
finalData$Ba.follow.through_per1000 <- sapply(finalData$Ba.follow.through, function(x) x/1000)
finalData$IVU_per1000 <- sapply(finalData$IVU, function(x) x/1000)

finalData$NumberofNMper1000 <- (finalData$Ba.meal_per1000 + finalData$Ba.enema_per1000 + finalData$Ba.follow.through_per1000 + finalData$IVU_per1000)

# calculate the nm procedures per 1000 and the sum:
finalData$PTCA_per1000 <- sapply(finalData$PTCA, function(x) x/1000)

finalData$NumberofInterventionalper1000 <- (finalData$PTCA_per1000)

# calculate total 
finalData$TotalFrequency <- (finalData$NumberofInterventionalper1000 + finalData$NumberofNMper1000 + finalData$NumberofXRayper1000 + finalData$NumberofCTper1000)

# Calculate values from the detailed questionnaire:
finalData$NumberOfCTScanners_perMillion <- (finalData$X3.1..314./finalData$population)
finalData$NumberRadiologists_perMillion <- (finalData$X2.1..212./finalData$population)
finalData$NumberGPs_perMillion <- (finalData$X2.1..211./finalData$population)

# load reimbursement system:
#reimbursement <- read.xlsx("/home/jahnen/data_analysis/ddmed/reimbursement.xls", 1)
#country <- read.xlsx("/home/jahnen/data_analysis/ddmed/reimbursement.xls", 2)


#temp <- merge(country, reimbursement, by.country = "Country", by.reimbursement = "Country")
#testData <- merge(finalData, temp, by.finalData = "code", by.temp = "code")

doseData <- subset(finalData, select=c("Country.Code", "population", "GDP", "NumberRadiologists_perMillion", "NumberOfCTScanners_perMillion", "NumberGPs_perMillion", "NumberofXRayper1000", "NumberofCTper1000", "NumberofNMper1000", "NumberofInterventionalper1000", "TotalFrequency" ))
names(doseData) <- c("Country", "Population", "GDP", "Radiologist_per1000", "CTScanners_perMillion", "GPs_perMillion", "Xray_per1000", "CT_per1000", "NM_per1000", "IV_per1000", "Total")

shinyServer(function(input, output) {
    
    output$outcome <- renderPrint({ input$outcome })
    output$regression <- renderPrint({ input$regression })
    
    regressionPlot <- eventReactive(input$goButton, {
        "Calculating regression"
        
        workData <- doseData[doseData$Country %in% input$show_countries, ]
        out <- workData[ , (2+as.numeric(input$outcome))]
        reg <- workData[ , (6+as.numeric(input$regression))]
        
        workData.lm <- lm(out ~ reg, data = workData)
        output$lm <- renderText(workData.lm)
        
        output$plot1 <- renderPlot({
            ggplotRegression(workData.lm)
        })
    })
    
    output$nText <- renderText({
        regressionPlot()
    })
    
    output$doseDataDT <- DT::renderDataTable(
        DT::datatable(doseData[doseData$Country %in% input$show_countries, ]), server = TRUE
    )
    

    # customize the length drop-down menu; display 5 rows per page by default
    output$mytable3 <- DT::renderDataTable({
        DT::datatable(iris, options = list(lengthMenu = c(5, 30, 50), pageLength = 5))
    })
    
})
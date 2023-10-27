# R shiny app that will allow you to upload a .fastq and
# convert it to a .fasta using seqtk

library(shiny)
library(reticulate)
library(bslib)
library(shinycssloaders)

# Lazy need it to work
outname <- "sample.fasta"

# User input for .fasta file upload
ui <- shinyUI(fluidPage(
  theme = bs_theme(bootswatch = "sandstone"),
  titlePanel("AIN Seqtk Fastq to Fasta"),
    sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose .fastq file to upload",
        accept = c(".fastq", ".fastq.gz", ".fq", ".fq.gz")),
      actionButton("convert", "CONVERT FASTQ TO FASTA")),
    mainPanel(
      withSpinner(verbatimTextOutput("results"))),
  ),
  tabPanel("Output FASTA",
      fluidPage(
        headerPanel("FASTA Output"),
        downloadButton("downloadData", "Download")
      )
  )
))

# Uses conda to run seqtk to convert .fastq to .fasta
server <- function(input, output, session) {
  data <- eventReactive(input$convert, {
        # Makes output file have .fasta extension
        outname <- sub(".*", "sample.fasta", input$file1)
        command <- paste("conda run -n seqtk seqtk seq -a", input$file1, ">", outname)
        system(command, intern = TRUE)

        outcheck <- grep(outname, system("ls", intern = TRUE))

        if (length(outcheck) > 0) {
          outtext <- "Conversion completed succesfully"
        } else {
          outtext <- "Conversion failed"
        }

        combo <- list(outtext = outtext)

        return(combo)})

  fasta <- reactiveFileReader(3000,
                              session,
                              filePath = outname,
                              readFunc = readLines)

  output$results <- renderText({
    data()$outtext
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(outname)
    },
    content = function(file) {
      writeLines(fasta(), file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)

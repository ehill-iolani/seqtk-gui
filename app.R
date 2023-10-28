# R shiny app that will allow you to upload a .fastq and
# convert it to a .fasta using seqtk

library(shiny)
library(reticulate)
library(shinycssloaders)

# Lazy; I need it to work so thats why this is here. yeah yeah its bad practice
# but I dont care. I'll fix it later.
outname <- "output.fasta"

# User input for .fasta file upload
ui <- shinyUI(fluidPage(
  # theme = bs_theme(bootswatch = "sandstone"),
  titlePanel("AIN Seqtk Fastq to Fasta"),
    sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose .fastq file to upload",
        accept = c(".fastq", ".fastq.gz", ".fq", ".fq.gz")),
      actionButton("convert", "CONVERT FASTQ TO FASTA"),
      downloadButton("downloadData", "Download Results")),
    mainPanel(
      withSpinner(verbatimTextOutput("results")))
  )
))

# Uses conda to run seqtk to convert .fastq to .fasta
server <- function(input, output, session) {
  data <- eventReactive(input$convert, {
        # Makes output file have .fasta extension
        outname <- sub(".*", "sample.fasta", input$file1)
        command <- paste0("seqtk seq -a ", input$file1, " >", " /home/", outname)
        system(command, intern = TRUE)

        # Checks if file was created
        fileout <- paste0("/home/", outname)
        outcheck <- grep(fileout, system("ls", intern = TRUE))

        # If it was created, return success message
        if (length(outcheck) > 0) {
          outtext <- "Conversion completed succesfully"
        } else {
          outtext <- "Conversion failed"
        }

        combo <- list(outtext = outtext)

        return(combo)})

  # Reads in .fasta file generated from the conversion
  fasta <- reactiveFileReader(3000,
                              session,
                              filePath = outname,
                              readFunc = readLines)

  # Displays success or fail message
  output$results <- renderText({
    data()$outtext
  })

  # Downloads .fasta file
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

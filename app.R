# R shiny app that will allow you to upload a .fastq and
# convert it to a .fasta using seqtk

library(shiny)
library(reticulate)
library(bslib)
library(shinycssloaders)

# User input for .fasta file upload
ui <- shinyUI(fluidPage(
  theme = bs_theme(bootswatch = "litera"),
  titlePanel("AIN Seqtk Fastq to Fasta"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose .fastq file to upload",
                accept = c(".fastq", ".fastq.gz", ".fq", ".fq.gz")),
      actionButton("convert", "CONVERT FASTQ TO FASTA")),
    mainPanel(
      withSpinner(verbatimTextOutput("results"))),
  )
))

# Use a shell script to run the remote_blast.sh script
server <- function(input, output) {
  data <- eventReactive(input$convert, {
        outname <- sub("\\..*$", ".fasta", input$file1)
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

  output$results <- renderText({
    data()$outtext
  })
}

# Run the application
shinyApp(ui = ui, server = server)

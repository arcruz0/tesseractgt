#' Launches the interactive addin to correct "ground truth" .gt.txt files in a folder.
#'
#' @export

correct_gt_txt <- function(){
  ui <- miniUI::miniPage(

    shinyjs::useShinyjs(),

    miniUI::gadgetTitleBar("Tesseract training labeler"),

    miniUI::miniContentPanel(
      shiny::tags$style("#text {font-size:20px;}"),
      shiny::fillCol(
        shiny::fillRow(
          shiny::uiOutput("folderInput"),
          shiny::uiOutput("imageInput")
        ),
        shiny::plotOutput("imagePlot", height = "100%"),
        shiny::fillRow(
          shiny::uiOutput("textInput"),
        ),
        shiny::fillRow(shiny::actionButton("update", "Overwrite file and next",
                                           class = "btn-warning"))
      ),
      padding = 4
    )
  )

  server <- function(input, output, session) {

    output$folderInput <- shiny::renderUI({

      folders <- list.dirs(recursive = F, full.names = T) |>
        stringr::str_subset("\\.\\/[^\\.]") |>
        stringr::str_remove("^\\.\\/") |>
        stringr::str_c("/")

      shiny::selectInput(inputId = "folder",
                         label = "Subfolder with images:",
                         choices = c(folders, ""), selected = "")
    })

    r_prefix <- shiny::reactive({
      shiny::req(input$folder)
      prefix <- list.files(input$folder) |>
        stringr::str_subset("\\.(png|tiff{0,1})$") |>
        stringr::str_remove("\\d+\\.(png|tiff{0,1})$") |>
        unique()

      if (length(prefix) == 1){
        prefix
      } else {
        stop("There is not a unique prefix for images in training folder!")
      }
    })

    r_image_format <- shiny::reactive({
      shiny::req(input$folder)
      file_format <- list.files(input$folder) |>
        stringr::str_extract("\\.(png|tiff{0,1})$") |>
        unique() |>
        stats::na.omit()

      if (length(file_format) == 1){
        file_format
      } else {
        stop("There is not a unique file format for images in training folder!")
      }

    })

    r_image_files <- shiny::reactive({
      shiny::req(input$folder)

      list.files(input$folder, full.names = T) |>
        stringr::str_subset("\\.(png|tiff{0,1})$")
    })

    output$imageInput <- shiny::renderUI({

      list_choices <- as.list(r_image_files())

      names(list_choices) <- r_image_files() |>
        stringr::str_remove(stringr::str_c("^", input$folder, "\\/"))

      shiny::selectInput(inputId = "image",
                         label = "Image:",
                         choices = list_choices)
    })

    output$textInput <- shiny::renderUI({
      shiny::req(input$image, input$folder)

      fpath_text <- input$image |>
        stringr::str_replace(r_image_format(), ".gt.txt")

      file_contents <- try(suppressWarnings(readLines(fpath_text)), silent = T)

      if (inherits(file_contents, "try-error")){
        if (attr(file_contents, "condition")$message == "cannot open the connection"){
          file_contents <- ""
          writeLines(" ", fpath_text, sep = "")
        } else {
          stop("Unknown error")
        }
      }

      file_contents <- stringr::str_trim(file_contents)

      shiny::textAreaInput("text", label = "Text:", rows = 2,
                           value = file_contents, width = "100%")
    })

    output$imagePlot <- shiny::renderPlot({
      shiny::req(input$image, input$folder)
      fpath <- input$image

      graphics::par(bg = NA, mar = rep(0, 4), oma = rep(0, 4))

      if (r_image_format() %in% c(".tiff", ".tif")){
        tiff::readTIFF(fpath) |> grDevices::as.raster() |> plot()
      } else if (r_image_format() %in% c(".png")){
        png::readPNG(fpath) |> grDevices::as.raster() |> plot()
      } else {
        stop("Unknown image format.")
      }

    })

    shiny::observe({
      shiny::req(input$text)

      shinyjs::runjs(
        stringr::str_c(
          "$('textarea').attr({",
          "spellcheck: 'false', autocapitalize: 'off',",
          "autocomplete: 'off', autocorrect: 'off'",
          "});"
        )
      )
    })

    shiny::observeEvent(input$update, {
      shiny::req(input$image, input$folder)

      Sys.sleep(.5) # sleep so image and text can update when going fast

      fpath <- input$image |>
        stringr::str_replace(r_image_format(), ".gt.txt")
      writeLines(input$text, fpath, sep = "")

      current_position <- which(input$image == r_image_files())

      if (current_position == length(r_image_files())){
        shiny::showNotification("Reached last image", duration = 3, type = "message")
      } else(
        shiny::updateSelectInput(inputId = "image",
                                 selected = r_image_files()[current_position + 1])
      )
    })

    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })

  }
  viewer <- shiny::paneViewer(minHeight = 800)

  shiny::runGadget(ui, server, viewer = viewer)
}

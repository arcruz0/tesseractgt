#' Create "ground truth" .gt.txt files in a folder of images
#'
#' @param folder A path to a folder with images.
#' @param extension A file extension, e.g., "png". Also accepts regex, e.g., "png|tif".
#' @param engine A Tesseract engine, made with `tesseract::tesseract()`.
#' @param verbose Whether to print messages about each processed image. Defaults to `FALSE`.
#'
#' @return Nothing. But .gt.txt "ground truth" files are created in the specified folder.
#' @export

create_gt_txt <- function(folder, extension, engine = NULL, verbose = FALSE){

  # Ensure the extension does not have a leading dot
  extension <- stringr::str_remove(extension, "^\\.")

  # List all image files in the folder with the given extension
  image_files <- list.files(folder, pattern = paste0("\\.", extension, "$"), full.names = TRUE)

  # Print initial message
  cat(sprintf("Found %s image files\n", length(image_files)))

  # Debug: Print the list of found image files
  if (verbose){
    cat("Found image files:\n")
    print(image_files)
  }

  if (length(image_files) == 0) {
    cat("No image files found with extension:", extension, "in folder:", folder, "\n")
    return()
  }

  # Create corresponding .gt.txt file paths for each image
  text_files <- image_files |>
    stringr::str_replace(stringr::str_c("\\.", extension, "$"), ".gt.txt")

  # find text files that already exist and ask user whether to overwrite them
  text_files_extant <- list.files(folder, pattern = paste0("\\.", "gt.txt", "$"), full.names = TRUE)

  text_files_already <- intersect(text_files, text_files_extant)

  if (length(text_files_already) > 0){
    user_choice <- menu(
      choices = c("Yes, overwrite them", "No, don't overwrite them"),
      title = sprintf("Found %s text files already corresponding to images. Do you want to overwrite them?",
                      length(text_files_already))
    )
    if (user_choice != 1){
      text_files <- setdiff(text_files, text_files_already)
    }
  }

  counter_s <- 0

  for (i in 1:length(image_files)){
    if (verbose){
      cat("Processing file:", image_files[i], "\n")
      cat("Writing to:", text_files[i], "\n")
    }

    # Extract text using the Tesseract engine if provided, else set to an empty string
    if (!is.null(engine)){
      vector_ocr_i <- tesseract::ocr(image_files[i], engine = engine)
    } else {
      vector_ocr_i <- ""
    }

    # Check if image file exists before attempting to read
    if (!file.exists(image_files[i])) {
      if (verbose) cat("Image file does not exist:", image_files[i], "\n")
      next
    }

    # Error handling for file writing
    tryCatch({
      writeLines(text = vector_ocr_i, con = text_files[i], sep = "\n")
      counter_s <- counter_s + 1
      if (verbose) cat("Successfully wrote to file:", text_files[i], "\n")
    }, error = function(e) {
      if (verbose) cat("Error writing to file:", text_files[i], "\n")
      if (verbose) cat("Error message:", e$message, "\n")
    })
  }

  # Print final message
  if (counter_s > 0){
    cat(sprintf("Succesfully wrote %s text file%s\n",
                counter_s, ifelse(counter_s > 1, "s", "")))
  } else {
    cat("No text files were written\n")
  }

}


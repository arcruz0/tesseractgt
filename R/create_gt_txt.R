#' Create "ground truth" .gt.txt files in a folder of images
#'
#' @param folder A path to a folder with images.
#' @param extension A file extension, e.g., "png". Also accepts regex, e.g., "png|tif".
#' @param engine A Tesseract engine, made with `tesseract::tesseract()`.
#'
#' @return Nothing. But .gt.txt "ground truth" files are created in the specified folder.
#' @export


create_gt_txt <- function(folder, extension, engine = NULL){
  
  # Ensure the extension does not have a leading dot
  extension <- stringr::str_remove(extension, "^\\.")
  
  # List all image files in the folder with the given extension
  image_files <- list.files(folder, pattern = paste0("\\.", extension, "$"), full.names = TRUE)
  
  # Debug: Print the list of found image files
  cat("Found image files:\n")
  print(image_files)
  
  if (length(image_files) == 0) {
    cat("No image files found with extension:", extension, "in folder:", folder, "\n")
    return()
  }
  
  # Create corresponding .gt.txt file paths for each image
  text_files <- image_files |>
    stringr::str_replace(stringr::str_c("\\.", extension, "$"), ".gt.txt")
  
  for (i in 1:length(image_files)){
    cat("Processing file:", image_files[i], "\n")
    cat("Writing to:", text_files[i], "\n")
    
    # Extract text using the Tesseract engine if provided, else set to an empty string
    if (!is.null(engine)){
      vector_ocr_i <- tesseract::ocr(image_files[i], engine = engine)
    } else {
      vector_ocr_i <- ""
    }
    
    # Check if image file exists before attempting to read
    if (!file.exists(image_files[i])) {
      cat("Image file does not exist:", image_files[i], "\n")
      next
    }
    
    # Error handling for file writing
    tryCatch({
      writeLines(text = vector_ocr_i, con = text_files[i], sep = "\n")
      cat("Successfully wrote to file:", text_files[i], "\n")
    }, error = function(e) {
      cat("Error writing to file:", text_files[i], "\n")
      cat("Error message:", e$message, "\n")
    })
  }
}


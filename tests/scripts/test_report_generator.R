#!/usr/bin/env Rscript
if (!require(ggplot2)) {
  install.packages("ggplot2")
}

library(ggplot2)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Please enter file path and output directory.")
}

data_file <- args[1]
output_directory <- args[2]

data <- read.table(data_file,
                   header = TRUE,
                   sep = "\t",
                   fill = TRUE,
                   row.names = NULL)

start_regions <- list()
end_regions <- list()
length_regions <- list()
mismatch_regions <- list()

for (i in 1:3) {
  region <- data[data$Insertion.region == i, ]
  
  start_regions[[i]] <- region[, grep("S$", names(region))]
  start_regions[[i]]$SeqName <- region$SeqName
  
  end_regions[[i]] <- region[, grep("E$", names(region))]
  end_regions[[i]]$SeqName <- region$SeqName
  
  length_regions[[i]] <- region[, grep("L$", names(region))]
  length_regions[[i]]$SeqName <- region$SeqName
  
  mismatch_regions[[i]] <- region[, grep("M$", names(region))]
  mismatch_regions[[i]]$SeqName <- region$SeqName
}

data_sets <- list(start_regions, end_regions, length_regions, mismatch_regions)
data_names <- c("Start", "End", "Length", "Mismatch")
for (region in 1:3) {
  for (data_set_index in 1:length(data_sets)) {
    current_data <- data_sets[[data_set_index]][[region]]
    
    if (!is.null(current_data) && nrow(current_data) > 0) {
      counts <- table(factor(current_data$Result,
                             levels = c("Same result",
                                        "none",
                                        "Different result")))
      
      df_counts <- as.data.frame(counts)
      
      p <- ggplot(df_counts, aes(x = Var1, y = Freq)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(title = paste(data_names[data_set_index], "Region", region),
             x = "Values", y = "Count") +
        geom_text(aes(label = Freq), vjust = -0.5)
      
      
      ggsave(file.path(output_directory,
                       paste0(data_names[data_set_index], "_Region_", region, ".png")),
             plot = p)
    } else {
      message(paste("No data for", data_names[data_set_index], "in Region", region))
    }
  }
}

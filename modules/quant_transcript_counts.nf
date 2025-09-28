process quant_transcript_counts {
  container 'r-base:4.5.1'
  memory '32GB'
  cpus 4
  time "1h"
  publishDir params.outdir, mode: 'copy'

  input:
    file quant

  output:
    path "counts-transcript"
  
  script:
    """
    #!/usr/bin/env Rscript
    
    if (!require("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install(version = "3.21")
    BiocManager::install(c('edgeR'))
    
    library(edgeR)
    
    dir.create("counts-transcript")
    
    dir.name <- dirname(list.files('.','*.sf',full.names = TRUE,recursive = TRUE,include.dirs = FALSE,no.. = TRUE,ignore.case = FALSE,all.files = FALSE))
    counts <- catchSalmon(dir.name)
    
    saveRDS(object = counts,file = 'counts-transcript/counts.rds')
    """
}
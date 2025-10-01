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
    
    ## Use the system TMPDIR if available, otherwise fall back to tempdir()
    lib <- file.path(Sys.getenv("TMPDIR", tempdir()), "Rlib")
    dir.create(lib, recursive = TRUE, showWarnings = FALSE)
    .libPaths(c(lib, .libPaths()))
    Sys.setenv(R_LIBS_USER = lib)

    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager", lib = lib, repos = "https://cloud.r-project.org")

    BiocManager::install(version = "3.21", ask = FALSE)
    BiocManager::install("edgeR", lib = lib, ask = FALSE, update = FALSE)
    
    library(edgeR)
    
    dir.create("counts-transcript")
    
    dir.name <- dirname(list.files('.','*.sf',full.names = TRUE,recursive = TRUE,include.dirs = FALSE,no.. = TRUE,ignore.case = FALSE,all.files = FALSE))
    counts <- catchSalmon(dir.name)
    
    saveRDS(object = counts,file = 'counts-transcript/counts.rds')
    """
}
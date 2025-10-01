process get_rpackages {
  container 'r-base:4.5.1'
  memory '32GB'
  cpus 4
  time "1h"
  publishDir params.outdir, mode: 'copy'

  input:
    file quant

  output:
    path "rpackages_done.flag", emit: rpackages_done   // <- barrier
  
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
      
    rpack <- c("edgeR","Rsubread","rtracklayer","SummarizedExperiment","tximeta")
      
    BiocManager::install(version = "3.21", ask = FALSE)
    BiocManager::install(rpack, lib = lib, ask = FALSE, update = FALSE)
    """
}
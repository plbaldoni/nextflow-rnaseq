process quant_transcript_counts {
  module 'R/4.3.0'
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
    library(edgeR)
    
    dir.create("counts-transcript")
    
    dir.name <- dirname(list.files('.','*.sf',full.names = TRUE,recursive = TRUE,include.dirs = FALSE,no.. = TRUE,ignore.case = FALSE,all.files = FALSE))
    counts <- catchSalmon(dir.name)
    
    saveRDS(object = counts,file = 'counts-transcript/counts.rds')
    """
}
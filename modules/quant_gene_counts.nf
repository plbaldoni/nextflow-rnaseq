process quant_gene_counts {
  module 'R'
  memory '32GB'
  cpus 4
  time "1h"
  publishDir params.outdir, mode: 'copy'

  input:
    file counts
    
  output:
    path "counts-gene"
    
  script:
    """
    #!/usr/bin/env Rscript
    
    library(edgeR)

    dir.create("counts-gene")
    
    counts.tx <- list.files(path = ".",pattern = "counts.rds",recursive = TRUE,full.names = TRUE)
    counts.tx <- readRDS(counts.tx)
    
    counts.gene <- rowsum(counts.tx[['counts']],counts.tx[['genes']][['GeneID']])
    counts.gene <- DGEList(counts = counts.gene)
    
    saveRDS(object = counts.gene,file = 'counts-gene/counts.rds')
    """
}
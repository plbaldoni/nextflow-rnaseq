process quant_transcript_counts {
  module 'R'
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
    library(SummarizedExperiment)
    library(rtracklayer)
        
    dir.create("counts-transcript")
    
    dir.name <- dirname(list.files('.','*.sf',full.names = TRUE,recursive = TRUE,include.dirs = FALSE,no.. = TRUE,ignore.case = FALSE,all.files = FALSE))
    counts <- catchSalmon(dir.name)
    
    # Gene gene names
    gr <- import("$params.salmonAnno")
    gr.tx <- gr[mcols(gr)[['type']] == 'transcript']
    gr.gene <- gr[mcols(gr)[['type']] == 'gene']
    
    anno <- counts[['annotation']]
    anno[['GeneID']] <- mcols(gr.tx)[['gene_id']][match(rownames(anno),mcols(gr.tx)[['transcript_id']])]
    
    dge <- DGEList(counts = counts[['counts']],genes = anno)
    
    saveRDS(object = dge,file = 'counts-transcript/counts.rds')
    """
}
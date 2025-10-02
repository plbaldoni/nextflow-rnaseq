process quant_gene_counts {
  module 'R'
  memory '32GB'
  cpus 4
  time "1h"
  publishDir params.outdir, mode: 'copy'

  input:
    file quant
    
  output:
    path "counts-gene"
    
  script:
    """
    #!/usr/bin/env Rscript
    
    library(rtracklayer)
    library(Rsubread)
    library(tximeta)
    library(edgeR)
    library(SummarizedExperiment)
    
    dir.create("counts-gene")

    gr <- import("$params.salmonAnno")
    gr.tx <- gr[mcols(gr)[['type']] == 'transcript']
    gr.gene <- gr[mcols(gr)[['type']] == 'gene']
    
    saf <- flattenGTF("$params.salmonAnno")
    
    sf <- list.files('./','*.sf',full.names = TRUE,recursive = TRUE,include.dirs = FALSE,no.. = TRUE,ignore.case = FALSE,all.files = FALSE)
    coldata <- data.frame(files = sf,names = basename(dirname(sf)))
    
    tx2gene = data.frame(mcols(gr.tx)[['transcript_id']],mcols(gr.tx)[['gene_id']])
    
    se <- tximeta(coldata = coldata,tx2gene = tx2gene,txOut = FALSE, skipMeta = TRUE, ignoreAfterBar = TRUE,type = 'salmon',countsFromAbundance = 'no')
    m <- match(rownames(se),mcols(gr.gene)[['gene_id']])
    
    GeneID.Length <- stats::aggregate(saf[['End']] - saf[['Start']],list(GeneID = saf[['GeneID']]),sum)
    k <- match(rownames(se),GeneID.Length[['GeneID']])
    
    df.genes <- data.frame(Chr = seqnames(gr.gene)[m],
                           Start = start(gr.gene)[m],
                           End = end(gr.gene)[m],
                           Strand = strand(gr.gene)[m],
                           Length = GeneID.Length[['x']][k],
                           row.names = rownames(se))
    
    counts <- DGEList(counts = assay(se),genes = df.genes)
    
    saveRDS(object = counts,file = 'counts-gene/counts.rds')
    """
}
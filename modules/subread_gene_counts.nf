process subread_gene_counts {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy'

  input:
    file alignment
    file index

  output:
    path "counts-gene"
  
  script:
    def paired = params.singleEnd ? "" : "-p --countReadPairs"
    """
    mkdir -p counts-gene
    
    # -M flag is to count multi-mapping reads and matches the default of Rsubread
    featureCounts $params.featureCountsGeneOptions ${paired} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType -o ./counts-gene/counts *.bam
    """
}
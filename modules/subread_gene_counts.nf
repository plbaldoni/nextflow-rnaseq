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
    path "featureCounts-gene"
  
  script:
    def paired = params.singleEnd ? "" : "-p --countReadPairs"
    """
    mkdir -p featureCounts-gene
    
    # -M flag is to count multi-mapping reads and matches the default of Rsubread
    # -O flag is to count reads overlapping multiple meta-features (genes) and does NOT match the default of Rsubread
    featureCounts --verbose -M -O ${paired} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType -o ./featureCounts-gene/counts *.bam
    """
}
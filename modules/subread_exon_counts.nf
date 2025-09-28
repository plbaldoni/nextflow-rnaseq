process subread_exon_counts {
  container 'quay.io/biocontainers/subread:2.1.1--h577a1d6_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy'

  input:
    file alignment
    file index

  output:
    path "counts-junction"

  script:
    def paired = params.singleEnd ? "" : "-p --countReadPairs"
    """
    mkdir -p counts-junction
    
    # -M flag is to count multi-mapping reads and matches the default of Rsubread
    # -f flag is to perform counting at the feature (exon) level
    # -J is to perform exon-exon junction counting, i.e. to count exon-spanning reads
    # -G is the reference genome to help junction counting
    # --nonSplitOnly is to report, in the counts object, only reads that are within exon boundaries. This is to avoid counting reads with the -J option multiple times.
    featureCounts $params.featureCountsExonOptions -G $params.subreadGenome ${paired} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType -o ./counts-junction/counts *.bam
    """
}

process subread_exon_counts {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy'

  input:
    file alignment
    file index

  output:
    path "featureCounts-exon"

  script:
    def paired = params.singleEnd ? "" : "-p --countReadPairs"
    """
    mkdir -p featureCounts-exon
    
    # -M flag is to count multi-mapping reads and matches the default of Rsubread
    # -O flag is to count reads overlapping multiple features (exons) and does NOT match the default of Rsubread
    # -f flag is to perform counting at the feature (exon) level
    # -J is to perform exon-exon junction counting, i.e. to count exon-spanning reads
    # -G is the reference genome to help junction counting
    # --nonSplitOnly is to report, in the counts object, only reads that are within exon boundaries. This is to avoid counting reads with the -J option multiple times.
    featureCounts \
    -f -J -G $params.subreadGenome --nonSplitOnly \
    --verbose -M -O ${paired} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType -o ./featureCounts-exon/counts *.bam
    """
}
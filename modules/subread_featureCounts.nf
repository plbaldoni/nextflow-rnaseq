process subread_subjunc {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time params.subreadTime

  input:
    file alignment
    file index

  script:
    def single = reads instanceof Path
    def read1 = !single ? /-r "${reads[0]}"/ : /-r "${reads}"/
    def read2 = !single ? /-R "${reads[1]}"/ : ''
    outname = "${sample_id}"
    """
    featureCounts \
    -a $params.subreadAnno \
    -F $params.subreadAnnoType \
    -o ${outname} \
    *.bam
    """
}

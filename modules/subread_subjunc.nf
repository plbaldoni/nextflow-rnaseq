process subread_subjunc {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy', pattern: '*.{bam,bed,vcf,summary}'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    file '*.{bam,bed,vcf,summary}'

  script:
    def single = reads instanceof Path
    def read1 = !single ? /-r "${reads[0]}"/ : /-r "${reads}"/
    def read2 = !single ? /-R "${reads[1]}"/ : ''
    outbam = "${sample_id}.bam"
    """
    subjunc --sortReadsByCoordinates -i $params.subreadIndex ${read1} ${read2} -o ${outbam} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType
    """
}

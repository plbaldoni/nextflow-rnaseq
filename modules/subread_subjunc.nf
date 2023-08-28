process subread_subjunc {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time '8 h'
  publishDir params.outdir, mode: 'copy', pattern: '*.{bam,bed,vcf,summary}'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    file '*.{bam,bed,vcf,summary}'

  script:
    outbam = "${sample_id}.bam"
    """
    subjunc --sortReadsByCoordinates -i $params.subreadIndex -r ${reads[0]} -R ${reads[1]} -o ${outbam} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType
    """
}

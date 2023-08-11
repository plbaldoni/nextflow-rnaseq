process subread_subjunc {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  container 'quay.io/biocontainers/samtools:1.17--hd87286a_1'
  memory '64GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy', pattern: '*.{bam,bam.bai}'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    file "*.{bam,bai,stat}"

  script:
    outbam = "${sample_id}.bam"
    outstat = "${sample_id}.stat"
    """
    subjunc --sortReadsByCoordinates \
    -i $params.subreadIindex \
    -r ${reads[0]} \
    -R ${reads[1]} \
    -o ${outbam} \
    -T $task.cpus \
    -a $params.subreadSAF \
    -F SAF
    
    samtools index ${outbam} 
    samtools stat ${outbam} > ${outstat}
    """
}

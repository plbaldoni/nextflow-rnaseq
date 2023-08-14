process subread_subjunc {
  module 'subread/2.0.6'
  module 'samtools/1.18'
  memory '64GB'
  cpus 4
  time '8 h'
  publishDir params.outdir, mode: 'copy', pattern: '*.{bam,bam.bai}'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    file "*.{bam,bai,stat,bed,vcf,summary}"

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

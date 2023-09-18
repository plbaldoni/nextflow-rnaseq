process index {
  container 'quay.io/biocontainers/samtools:1.17--hd87286a_1'
  memory '32GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy', pattern: 'alignment/*.bai'
  tag "$sample_id"

  input:
    tuple val(sample_id), path(outbam), path(outvcf), path(outbed)
    
  output:
    tuple val(sample_id), path(outbai), path(outstat)

  script:
  outbai = "alignment/${sample_id}.bam.bai"
  outstat = "alignment/${outbam.simpleName}.stat"
    """
    mkdir alignment
    samtools index ${outbam} 
    samtools stat ${outbam} > ${outbam.simpleName}.stat
    mv ${outbam}.bai $outbai
    mv ${outbam.simpleName}.stat $outstat
    """
}

process index {
  container 'quay.io/biocontainers/samtools:1.17--hd87286a_1'
  memory '32GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy', pattern: '*.bai'

  input:
    file alignment
    
  output:
    file "*.{bai,stat}"

  script:
    """
    samtools index ${alignment[0]} 
    samtools stat ${alignment[0]} > ${alignment[0].simpleName}.stat
    """
}

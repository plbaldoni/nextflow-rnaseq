process multiqc_align {
  container 'multiqc/multiqc:1.31'
  memory '32GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy'

  input:
    file qc
    file alignment
    file index
    file coverage

  output:
    path "multiqc"

  script:
    """
    mkdir -p multiqc
    multiqc --interactive -o multiqc .
    """ 
}

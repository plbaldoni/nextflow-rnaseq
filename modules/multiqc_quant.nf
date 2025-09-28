process multiqc_quant {
  container 'multiqc/multiqc:1.31'
  memory '32GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy'

  input:
    file qc
    file quant

  output:
    path "multiqc"

  script:
    """
    mkdir -p multiqc
    multiqc --interactive -o multiqc .
    """ 
}

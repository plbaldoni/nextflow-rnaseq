process multiqc_quant {
  container 'quay.io/biocontainers/multiqc:1.15--pyhdfd78af_0'
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
    multiqc -o multiqc .
    """ 
}

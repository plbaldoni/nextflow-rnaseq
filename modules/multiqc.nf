process multiqc {
  module 'MultiQC/1.10.1'
  memory '32GB'
  cpus 4
  time '1 h'
  publishDir params.outdir, mode: 'copy'

  input:
    file qc
    file alignment
    file coverage
    file quant
    
  output:
    path "multiqc"

  script:
    """
    mkdir -p multiqc
    multiqc -o multiqc .
    """ 
}

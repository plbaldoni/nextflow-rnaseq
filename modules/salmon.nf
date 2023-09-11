process salmon {
  container 'quay.io/biocontainers/salmon:1.10.0--h7e5ed60_0'
  memory '64GB'
  cpus 8
  time params.salmonTime
  publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    tuple val(sample_id), path(outsf)

  script:
    def single = reads instanceof Path
    def read1 = !single ? /-1 "${reads[0]}"/ : /-r "${reads}"/
    def read2 = !single ? /-2 "${reads[1]}"/ : ''
    outsf = "quantification/$sample_id"
    """
    mkdir -p quantification/$sample_id
    salmon quant $params.salmonOptions \
    -i $params.salmonIndex \
    -p $task.cpus \
    ${read1} \
    ${read2} \
    -o $outsf
    """
}

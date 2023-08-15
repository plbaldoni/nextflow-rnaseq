process salmon {
  container 'quay.io/biocontainers/salmon:1.10.0--h7e5ed60_0'
  memory '64GB'
  cpus 8
  time '4 h'
  publishDir params.outdir, mode: 'copy'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    path "$sample_id"

  script:
    """
    salmon quant --dumpEq --numBootstraps 100 \
    -i $params.salmonIndex \
    -l A \
    -p $task.cpus \
    -1 ${reads[0]} \
    -2 ${reads[1]} \
    -o $sample_id
    """
}

process salmon {
  memory '64GB'
  cpus 8
  time '4 h'

  input:
    tuple val(sample_id), path(reads)
    
  output:
    path "$sample_id"

  script:
    """
    $params.salmonBin quant --dumpEq --writeUnmappedNames --numBootstraps 100 \
    -i $params.salmonIindex \
    -l A \
    -p $task.cpus \
    -1 ${reads[0]} \
    -2 ${reads[1]} \
    -o $sample_id
    """
}

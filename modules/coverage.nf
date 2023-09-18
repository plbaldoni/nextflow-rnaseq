process coverage {
  container 'quay.io/biocontainers/deeptools:3.5.1--pyhdfd78af_1'
  memory '64GB'
  cpus 8
  time '1 h'
  publishDir params.outdir, mode: 'copy'
  tag "$sample_id"
  
  input:
    tuple val(sample_id), path(outbam), path(outvcf), path(outbed), path(outbai), path(outstat)

  output:
    tuple val(sample_id), path(outbw)

  script:
  outbw = "coverage/${outbam.baseName}.bw"
    """
    mkdir coverage
    bamCoverage --verbose --ignoreForNormalization chrX chrY chrM --normalizeUsing CPM --binSize 10 \
    --bam ${outbam} \
    --outFileName $outbw \
    --outFileFormat bigwig \
    --numberOfProcessors ${task.cpus} \
    --effectiveGenomeSize ${params.gsize}
    """ 
}

process subread_align {
  container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy', pattern: 'alignment/*.{bam}'
  tag "$sample_id"

  input:
    tuple val(sample_id), path(reads)
    
  output:
    tuple val(sample_id), path(outbam)

  script:
    def single = reads instanceof Path
    def read1 = !single ? /-r "${reads[0]}"/ : /-r "${reads}"/
    def read2 = !single ? /-R "${reads[1]}"/ : ''
    outbam = "alignment/${sample_id}.bam"
    """
    mkdir alignment
    subread-align $params.alignOptions -i $params.subreadIndex ${read1} ${read2} -t 0 -o ${outbam} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType
    """
}

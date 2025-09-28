process subread_subjunc {
  container 'quay.io/biocontainers/subread:2.1.1--h577a1d6_0'
  memory '64GB'
  cpus 4
  time params.subreadTime
  publishDir params.outdir, mode: 'copy', pattern: 'alignment-junction/*.{bam,bed,vcf}'
  tag "$sample_id"

  input:
    tuple val(sample_id), path(reads)
    
  output:
    tuple val(sample_id), path(outbam), path(outvcf), path(outbed)

  script:
    def single = reads instanceof Path
    def read1 = !single ? /-r "${reads[0]}"/ : /-r "${reads}"/
    def read2 = !single ? /-R "${reads[1]}"/ : ''
    outbam = "alignment-junction/${sample_id}.bam"
    outvcf = "alignment-junction/${sample_id}.bam.indel.vcf"
    outbed = "alignment-junction/${sample_id}.bam.junction.bed"
    """
    mkdir alignment-junction
    subjunc $params.subjuncOptions -i $params.subreadIndex ${read1} ${read2} -o ${outbam} -T $task.cpus -a $params.subreadAnno -F $params.subreadAnnoType
    """
}

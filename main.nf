params.outdir = "$launchDir"
params.reads = "$launchDir/*{R1,R2}_001.fastq.gz"
params.salmonIndex = "$launchDir/salmon_index"
params.subreadIndex = "$launchDir/subread_index"
params.subreadSAF = "$launchDir/subread_saf"
params.quant = false
params.align = false
params.norepair = false
params.gsize = 3117275501 // CHM13v2.0 size (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/)

include { fastqc } from './modules/fastqc'
include { multiqc_quant } from './modules/multiqc_quant'
include { salmon } from './modules/salmon'
include { subread_subjunc } from './modules/subread_subjunc'
include { coverage } from './modules/coverage'
include { multiqc_align } from './modules/multiqc_align'
include { repair } from './modules/repair'
include { index } from './modules/index'

workflow {
  
  if ( params.norepair ) {
    ch_reads = Channel.fromFilePairs(params.reads, checkIfExists: true)
  }
  else {
    ch_reads = repair(Channel.fromFilePairs(params.reads, checkIfExists: true))
  }

  ch_fastqc = fastqc(ch_reads)
  
  if ( params.quant ) {
    ch_salmon = salmon(ch_reads)
    ch_multiqc = multiqc_quant(ch_fastqc.collect(),ch_salmon.collect())
  }
  if ( params.align ) {
    ch_subread_subjunc = subread_subjunc(ch_reads)
    ch_index = index(ch_subread_subjunc)
    ch_cov = coverage(ch_subread_subjunc,ch_index)
    ch_multiqc = multiqc_align(ch_fastqc.collect(),ch_subread_subjunc.collect(),ch_index.collect(),ch_cov.collect())
  }
}

params.outdir = "$launchDir"
params.reads = "$launchDir/*{R1,R2}_001.fastq.gz"
params.salmonIindex = "$launchDir/salmon_index"
params.subreadIindex = "$launchDir/subread_index"
params.subreadSAF = "$launchDir/subread_saf"
params.quant = false
params.align = false
params.gsize = 3117275501 // CHM13v2.0 size (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/)

include { fastqc } from './modules/fastqc'
include { multiqc_quant } from './modules/multiqc_quant'
include { salmon } from './modules/salmon'
include { subread_subjunc } from './modules/subread_subjunc'
include { coverage } from './modules/coverage'
include { multiqc_align } from './modules/multiqc_align'

workflow {
  
  reads = Channel.fromFilePairs(params.reads, checkIfExists: true)
  
  ch_fastqc = fastqc(reads)
  
  if ( params.quant ) {
    ch_salmon = salmon(reads)
    ch_multiqc = multiqc_quant(ch_fastqc.collect(),ch_salmon.collect())
  }
  if ( params.align ) {
    ch_subread_subjunc = subread_subjunc(reads)
    ch_cov = coverage(ch_subread_subjunc)
    ch_multiqc = multiqc_align(ch_fastqc.collect(),ch_subread_subjunc.collect(),ch_cov.collect())
  }
}

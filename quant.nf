params.reads = "$launchDir/*{R1,R2}_001.fastq.gz"
params.outdir = "$launchDir"
params.salmonBin = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/salmon-1.10.0_linux_x86_64/bin/salmon"
params.salmonIindex = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/SalmonIndex/chm13v2.0-v38/transcripts_index"

include { fastqc } from './modules/fastqc'
include { multiqc_quant } from './modules/multiqc_quant'
include { salmon } from './modules/salmon'

workflow {
  
  reads = Channel.fromFilePairs(params.reads, checkIfExists: true)
  
  ch_fastqc = fastqc(reads)
  
  ch_salmon = salmon(reads)
  
  ch_multiqc = multiqc_quant(ch_fastqc.collect(),
                             ch_salmon.collect())
}

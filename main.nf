params.reads = "$launchDir/*{R1,R2}_001.fastq.gz"
params.outdir = "$launchDir"
params.gsize = 3117275501 // CHM13v2.0 size (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/)
params.subreadIindex = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/RsubreadIndex/chm13v2.0/chm13v2.0.genome_index"
params.subreadAnno = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/RsubreadSAF/chm13v2.0_RefSeqStrict_27Sep2022.saf.gz"
params.subreadAnnoFormat = "SAF"
params.salmonBin = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/salmon-1.10.0_linux_x86_64/bin/salmon"
params.salmonIindex = "/stornext/Home/data/allstaff/b/baldoni.p/lab_smyth/baldoni.p/software/SalmonIndex/chm13v2.0-v38/transcripts_index"

include { fastqc } from './modules/fastqc'
include { subread_subjunc } from './modules/subread_subjunc'
include { coverage } from './modules/coverage'
include { multiqc } from './modules/multiqc'
include { salmon } from './modules/salmon'

workflow {
  
  reads = Channel.fromFilePairs(params.reads, checkIfExists: true)
  
  ch_fastqc = fastqc(reads)
  
  ch_salmon = salmon(reads)
  
  ch_subread_subjunc = subread_subjunc(reads)
  
  ch_cov = coverage(ch_subread_subjunc)
  
  ch_multiqc = multiqc(ch_fastqc.collect(),
                       ch_subread_subjunc.collect(),
                       ch_cov.collect(),
                       ch_salmon.collect())
}

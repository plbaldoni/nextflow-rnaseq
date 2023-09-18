params.outdir = "$launchDir"
params.reads = "$launchDir/*{R1,R2}_001.fastq.gz"
params.salmonIndex = "$launchDir/salmon_index"
params.salmonAnno = "$launchDir/salmon_gtf"
params.salmonAnnoType = "GTF"
params.subreadIndex = "$launchDir/subread_index"
params.subreadGenome = "$launchDir/genome.fa.gz"
params.subreadAnno = "$launchDir/subread_saf"
params.subreadAnnoType = "SAF"
params.quant = false
params.align = false
params.norepair = false
params.gsize = 3117275501 // CHM13v2.0 size (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/)
params.singleEnd = false
params.salmonTime = "8h"
params.subreadTime = "8h"
params.salmonOptions = "--dumpEq --numBootstraps 100 -l A"
params.subjuncOptions = "--sortReadsByCoordinates"
params.featureCountsGeneOptions = "--verbose -M"
params.featureCountsExonOptions = "--verbose -M -O -f -J --nonSplitOnly"

include { fastqc } from './modules/fastqc'
include { multiqc_quant } from './modules/multiqc_quant'
include { salmon } from './modules/salmon'
include { subread_subjunc } from './modules/subread_subjunc'
include { coverage } from './modules/coverage'
include { multiqc_align } from './modules/multiqc_align'
include { repair } from './modules/repair'
include { index } from './modules/index'
include { subread_exon_counts } from './modules/subread_exon_counts'
include { subread_gene_counts } from './modules/subread_gene_counts'
include { quant_transcript_counts } from './modules/quant_transcript_counts'
include { quant_gene_counts } from './modules/quant_gene_counts'

workflow {
  
  if ( params.norepair ) {
    ch_reads = Channel.fromFilePairs(params.reads, size: params.singleEnd ? 1 : 2, checkIfExists: true)
  }
  else {
    if ( params.singleEnd ) {
      error "Repair is only possible for paired-end reads"
    }
    else {
      ch_reads = repair(Channel.fromFilePairs(params.reads, checkIfExists: true)) 
    }
  }

  ch_fastqc = fastqc(ch_reads)
  
  if ( params.quant ) {
    ch_salmon = salmon(ch_reads)
    ch_gene_counts = quant_gene_counts(ch_salmon.collect())
    ch_tx_counts = quant_transcript_counts(ch_salmon.collect())
    ch_multiqc = multiqc_quant(ch_fastqc.collect(),ch_salmon.collect())
  }
  if ( params.align ) {
    ch_subread_subjunc = subread_subjunc(ch_reads)
    ch_index = index(ch_subread_subjunc)
    ch_cov = ch_subread_subjunc | join(ch_index) | coverage
    ch_gene_counts = subread_gene_counts(ch_subread_subjunc.collect(),ch_index.collect())
    ch_exon_counts = subread_exon_counts(ch_subread_subjunc.collect(),ch_index.collect())
    ch_multiqc = multiqc_align(ch_fastqc.collect(),ch_subread_subjunc.collect(),ch_index.collect(),ch_cov.collect())
  }
}

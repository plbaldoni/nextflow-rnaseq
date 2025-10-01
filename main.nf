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
params.repair = false
params.singleEnd = false
params.subjunc = false
params.salmonTime = "8h"
params.subreadTime = "8h"
params.salmonOptions = "--dumpEq --numBootstraps 100 -l A"
params.subjuncOptions = "--sortReadsByCoordinates"
params.alignOptions = "--sortReadsByCoordinates"
params.featureCountsGeneOptions = "--verbose -M"
params.featureCountsExonOptions = "--verbose -M -f -J --nonSplitOnly"
params.gsize = 3117275501 // CHM13v2.0 size (https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914755.4/)

include { fastqc } from './modules/fastqc'
include { multiqc_quant } from './modules/multiqc_quant'
include { salmon } from './modules/salmon'
include { subread_subjunc } from './modules/subread_subjunc'
include { coverage } from './modules/coverage'
include { multiqc_align } from './modules/multiqc_align'
include { repair } from './modules/repair'
include { index_align } from './modules/index_align'
include { index_subjunc } from './modules/index_subjunc'
include { subread_exon_counts } from './modules/subread_exon_counts'
include { subread_gene_counts } from './modules/subread_gene_counts'
include { quant_transcript_counts } from './modules/quant_transcript_counts'
include { quant_gene_counts } from './modules/quant_gene_counts'
include { subread_align } from './modules/subread_align'
include { get_rpackages } from './modules/get_rpackages'

workflow {
  
  if ( params.repair ) {
    if ( params.singleEnd ) {
      error "Repair is only possible for paired-end reads"
    }
    else {
      ch_reads = repair(Channel.fromFilePairs(params.reads, checkIfExists: true)) 
    }
  }
  else {
    ch_reads = Channel.fromFilePairs(params.reads, size: params.singleEnd ? 1 : 2, checkIfExists: true)
  }

  ch_fastqc = fastqc(ch_reads)
  
  if ( params.quant ) {
    ch_salmon = salmon(ch_reads)
    
    ch_rpackages = get_rpackages(ch_salmon.collect())
    ch_gene_counts = quant_gene_counts(ch_salmon.collect(),ch_rpackages)
    ch_tx_counts = quant_transcript_counts(ch_salmon.collect(),ch_rpackages)
    
    ch_multiqc = multiqc_quant(ch_fastqc.collect(),ch_salmon.collect())
  }
  if ( params.align ) {
    if ( params.subjunc ) {
      // To get intra-gene resolution and exon-level counts
      ch_subread_subjunc = subread_subjunc(ch_reads)
      ch_index_subjunc = index_subjunc(ch_subread_subjunc)
      ch_exon_counts = subread_exon_counts(ch_subread_subjunc.collect(),ch_index_subjunc.collect()) 
    }
    // To get gene-level counts
    ch_subread_align = subread_align(ch_reads)
    ch_index_align = index_align(ch_subread_align)
    ch_cov_align = ch_subread_align | join(ch_index_align) | coverage
    ch_gene_counts = subread_gene_counts(ch_subread_align.collect(),ch_index_align.collect())
    ch_multiqc = multiqc_align(ch_fastqc.collect(),ch_subread_align.collect(),ch_index_align.collect(),ch_cov_align.collect())
  }
}

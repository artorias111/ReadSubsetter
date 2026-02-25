#!/usr/bin/env nextflow

// Import modules
include { EXTRACT_LENGTHS } from './modules/extract_lengths.nf'
include { FILTER_LOGIC    } from './modules/filter_logic.nf'
include { SUBSET_READS    } from './modules/subset_reads.nf'

workflow {
    // Collect all input fastq.gz files into a single list
    ch_reads = Channel.fromPath(params.reads).collect()

    // 1. Get lengths
    EXTRACT_LENGTHS(ch_reads)

    FILTER_LOGIC(
        EXTRACT_LENGTHS.out.lengths, 
        params.coverage, 
        params.genome_size
    )

    SUBSET_READS(
        ch_reads, 
        FILTER_LOGIC.out.keep_ids, 
        params.sample_id, 
        params.coverage
    )
}

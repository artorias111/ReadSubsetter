#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { EXTRACT_LENGTHS } from './modules/extract_lengths.nf'
include { FILTER_LOGIC    } from './modules/filter_logic.nf'
include { SUBSET_READS    } from './modules/subset_reads.nf'
include { PLOT_HISTOGRAM  } from './modules/plot_histogram.nf'

workflow {
    ch_reads = Channel.fromPath(params.reads).collect()

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

    PLOT_HISTOGRAM(
        EXTRACT_LENGTHS.out.lengths,
        FILTER_LOGIC.out.keep_ids,
        params.sample_id,
        params.plot_bins
    )
}

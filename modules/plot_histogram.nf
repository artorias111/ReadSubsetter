process PLOT_HISTOGRAM {
    conda "${params.python_conda}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path lengths_tsv
    path keep_ids
    val sample_id
    val bins

    output:
    path "${sample_id}_length_histogram.png", emit: histogram

    script:
    """
    plot_lengths.py \\
        --lengths ${lengths_tsv} \\
        --kept ${keep_ids} \\
        --output ${sample_id}_length_histogram.png \\
        --bins ${bins}
    """
}

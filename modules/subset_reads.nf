process SUBSET_READS {
    conda "${params.seqkit_conda}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path reads
    path keep_ids
    path short_ids
    path long_ids
    val sample_id
    val coverage

    output:
    path "${sample_id}.final.${coverage}x.fq.gz", emit: final_reads
    path "${sample_id}.short_dropped.${coverage}x.fq.gz", emit: short_dropped_reads
    path "${sample_id}.long_dropped.${coverage}x.fq.gz", emit: long_dropped_reads

    script:
    """
    seqkit grep -f ${keep_ids} ${reads} -o ${sample_id}.final.${coverage}x.fq.gz
    seqkit grep -f ${short_ids} ${reads} -o ${sample_id}.short_dropped.${coverage}x.fq.gz
    seqkit grep -f ${long_ids} ${reads} -o ${sample_id}.long_dropped.${coverage}x.fq.gz
    """
}

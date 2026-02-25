process SUBSET_READS {
    conda "${params.seqkit_conda}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path reads
    path keep_ids
    val sample_id
    val coverage

    output:
    path "${sample_id}.final.${coverage}x.fq.gz", emit: final_reads

    script:
    """
    seqkit grep -f ${keep_ids} ${reads} -o ${sample_id}.final.${coverage}x.fq.gz
    """
}

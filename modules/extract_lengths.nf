process EXTRACT_LENGTHS {
    conda "${params.seqkit_conda}"
    
    input:
    path reads

    output:
    path "lengths.tsv", emit: lengths

    script:
    """
    seqkit fx2tab -n -l -i ${reads} > lengths.tsv
    """
}

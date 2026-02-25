process FILTER_LOGIC {
    conda "${params.python_conda}"
    
    input:
    path lengths_tsv
    val coverage
    val genome_size

    output:
    path "keep_reads.txt", emit: keep_ids

    script:
    """
    #!/usr/bin/env python3
    import sys
    import pandas as pd

    df = pd.read_csv('${lengths_tsv}', sep="\\t", names=['read', 'length'])
    
    total_len = df['length'].sum()
    target_len = ${coverage} * ${genome_size}
    
    if total_len <= target_len:
        print("Total read length is less than or equal to target coverage. Keeping all reads.")
        df['read'].to_csv('keep_reads.txt', index=False, header=False)
        sys.exit(0)

    excess_len = total_len - target_len
    cutoff = excess_len / 2

    df = df.sort_values(by=['length'], ascending=True)
    df['cum_sum_asc'] = df['length'].cumsum()
    
    df_filtered = df[df['cum_sum_asc'] > cutoff].copy()

    df_filtered = df_filtered.sort_values(by=['length'], ascending=False)
    df_filtered['cum_sum_desc'] = df_filtered['length'].cumsum()
    
    final_df = df_filtered[df_filtered['cum_sum_desc'] > cutoff]

    final_df['read'].to_csv('keep_reads.txt', index=False, header=False)
    """
}

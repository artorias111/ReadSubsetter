process FILTER_LOGIC {
    conda "${params.python_conda}"
    publishDir "${params.outdir}", mode: 'copy'
    
    input:
    path lengths_tsv
    val coverage
    val genome_size
    
    output:
    path "keep_reads.txt", emit: keep_ids
    path "filter_log.txt", emit: filter_log
    
    script:
    """
    #!/usr/bin/env python3
    import sys
    import pandas as pd
    
    lengths_path = '${lengths_tsv}'
    coverage = ${coverage}
    genome_size = ${genome_size}
    
    df = pd.read_csv(lengths_path, sep="\\t", names=['read', 'length'])
    
    total_len = int(df['length'].sum())
    target_len = int(coverage * genome_size)
    excess_len = total_len - target_len
    min_len = int(df['length'].min())
    max_len = int(df['length'].max())
    
    with open('filter_log.txt', 'w') as log:
        log.write("Read subsetting summary\\n")
        log.write("-----------------------\\n")
        log.write(f"Requested coverage: {coverage}x\\n")
        log.write(f"Estimated genome size: {genome_size} bp\\n")
        log.write(f"Total bases in input: {total_len} bp\\n")
        log.write(f"Target bases at required coverage: {target_len} bp\\n")
        log.write(f"Shortest read in input: {min_len} bp\\n")
        log.write(f"Longest read in input: {max_len} bp\\n")
    
        if total_len <= target_len:
            log.write("\\nNo reads were removed because the total input bases did not exceed the target coverage.\\n")
            log.write("All reads were kept.\\n")
            log.write(f"Histogram range (all reads): {min_len}-{max_len} bp\\n")
            log.write("Histogram range (kept reads): identical to all reads (no trimming applied).\\n")
            df['read'].to_csv('keep_reads.txt', index=False, header=False)
            sys.exit(0)
    
        log.write(f"Excess bases to remove: {excess_len} bp\\n")
    
        cutoff = excess_len / 2
        log.write(f"Target bases removed from each tail: {cutoff} bp.\\n")
    
        # Trim from the short end first
        df_sorted = df.sort_values(by=['length'], ascending=True)
        df_sorted['cum_sum_asc'] = df_sorted['length'].cumsum()
        short_tail_removed = df_sorted[df_sorted['cum_sum_asc'] <= cutoff]
        short_tail_kept = df_sorted[df_sorted['cum_sum_asc'] > cutoff].copy()
    
        if not short_tail_removed.empty:
            short_removed_max = int(short_tail_removed['length'].max())
            log.write(f"Reads up to ~{short_removed_max} bp were removed from the short end.\\n")
        else:
            log.write("No reads were removed from the short end.\\n")
    
        # Now trim from the long end within the remaining reads
        df_desc = short_tail_kept.sort_values(by=['length'], ascending=False)
        df_desc['cum_sum_desc'] = df_desc['length'].cumsum()
        long_tail_removed = df_desc[df_desc['cum_sum_desc'] <= cutoff]
        final_df = df_desc[df_desc['cum_sum_desc'] > cutoff].copy()
    
        if not long_tail_removed.empty:
            long_removed_min = int(long_tail_removed['length'].min())
            log.write(f"Reads from ~{long_removed_min} bp and longer were removed from the long end.\\n")
        else:
            log.write("No reads were removed from the long end.\\n")
    
        kept_min = int(final_df['length'].min())
        kept_max = int(final_df['length'].max())
    
        log.write("\\nFinal kept read set:\\n")
        log.write(f"  Number of reads kept: {len(final_df)}\\n")
        log.write(f"  Number of reads dropped: {len(df) - len(final_df)}\\n")
        log.write(f"  Total bases kept: {int(final_df['length'].sum())} bp\\n")
        log.write(f"  Shortest kept read: {kept_min} bp\\n")
        log.write(f"  Longest kept read: {kept_max} bp\\n")
        log.write(f"  Histogram range (all reads): {min_len}-{max_len} bp\\n")
        log.write(f"  Histogram range (kept reads): {kept_min}-{kept_max} bp\\n")
    
    final_df['read'].to_csv('keep_reads.txt', index=False, header=False)
    """
}

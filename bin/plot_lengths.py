#!/usr/bin/env python3
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def main():
    parser = argparse.ArgumentParser(description="Plot read length histograms before and after filtering.")
    parser.add_argument("-l", "--lengths", required=True, help="Path to original lengths.tsv")
    parser.add_argument("-k", "--kept", required=True, help="Path to keep_reads.txt")
    parser.add_argument("-o", "--output", default="length_histogram.png", help="Output image filename")
    parser.add_argument("-b", "--bins", type=int, default=100, help="Number of bins for the histogram")
    args = parser.parse_args()

    print("Loading data...")
    df_all = pd.read_csv(args.lengths, sep='\t', names=['read', 'length'])
    
    df_kept_ids = pd.read_csv(args.kept, names=['read'])
    
    df_kept = df_all[df_all['read'].isin(df_kept_ids['read'])]

    print("Generating plot...")
    sns.set_theme(style="whitegrid")
    plt.figure(figsize=(10, 6))

    sns.histplot(
        df_all['length'], 
        bins=args.bins, 
        color='lightgray', 
        label='Before (All Reads)', 
        edgecolor=None,
        alpha=0.6
    )

    sns.histplot(
        df_kept['length'], 
        bins=args.bins, 
        color='dodgerblue', 
        label='After (Trimmed)', 
        edgecolor=None,
        alpha=0.8
    )

    plt.title('Read Length Distribution: Before vs. After Trimming', fontsize=14, pad=15)
    plt.xlabel('Read Length (bp)', fontsize=12)
    plt.ylabel('Count', fontsize=12)
    
    plt.gca().xaxis.set_major_formatter(plt.matplotlib.ticker.StrMethodFormatter('{x:,.0f}'))
    
    plt.legend(frameon=True, fontsize=11)
    plt.tight_layout()

    plt.savefig(args.output, dpi=300, bbox_inches='tight')
    print(f"Plot successfully saved to {args.output}")

if __name__ == "__main__":
    main()

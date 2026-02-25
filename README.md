# Read Length Coverage Filter

A pipeline that filters FASTQ files to a specific target coverage. It achieves this by calculating the excess base pairs and evenly trimming the longest and shortest reads from the dataset. 



It uses `seqkit` for fast sequence parsing and extraction, and `pandas` for the length distribution logic to minimize memory usage.

---

## Usage

```bash
nextflow run artorias111/ReadSubsetter \
    --reads "data/*.fq.gz" \
    --sample_id "my_sample" \
    --coverage 35 \
    --genome_size 850000000
```

--

## Filtering Logic

The core logic of this pipeline is to remove an equal number of base pairs from both extremes of the read length distribution (the longest and shortest reads) to obtain the exact target coverage without heavily skewing the read length profile.

Given:
* $c$ = Target coverage (e.g., 35X)
* $G$ = Estimated genome size in base pairs
* $L_{total}$ = Total length of all input reads combined

The pipeline calculates the target total base count ($T_{bases}$) required to hit the desired coverage:
$$T_{bases} = c \times G$$

It then calculates the excess base pairs ($E$) that need to be removed from the original dataset:
$$E = L_{total} - T_{bases}$$

To evenly trim the dataset, the pipeline halves this excess value and targets that sum for removal from both the top and bottom of the length-sorted reads:
$$E_{tail} = \frac{E}{2}$$

The internal Python script sorts the read lengths, computes a cumulative sum of the base pairs from both the ascending and descending ends, and drops any reads that fall within the $E_{tail}$ threshold on either side.

---

## Prerequisites

* Nextflow
* Seqkit (https://bioinf.shenwei.me/seqkit/)
* Python with Pandas, Matplotlib, and Seaborn for plotting read length distributions

## Directory Structure

* `main.nf`: The main entry point for the pipeline.
* `nextflow.config`: Configuration file containing parameters and Conda environment definitions.
* `modules/extract_lengths.nf`: Extracts read IDs and lengths using `seqkit`.
* `modules/filter_logic.nf`: Python script that calculates cumulative sums and identifies reads to keep. 
* `modules/subset_reads.nf`: Extracts the final set of reads using `seqkit grep`.

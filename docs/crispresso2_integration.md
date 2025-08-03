# CRISPResso2 Integration

This document describes the CRISPResso2 integration in the nf-core/crispresso pipeline.

## Overview

CRISPResso2 is now integrated as the core analysis module in this pipeline. It analyzes deep sequencing data from CRISPR genome editing experiments to quantify insertions, deletions, and mutations.

## Required Parameters

When running the pipeline, you must provide:

- `--amplicon_seq`: The expected amplicon sequence (reference sequence around your CRISPR target site)
- `--guide_seq`: The guide RNA sequence without the PAM sequence

Example:
```bash
nextflow run nf-core/crispresso \
    -profile docker \
    --input samplesheet.csv \
    --outdir results \
    --amplicon_seq "TCCCATCACATCAACCGGTGGCGCATTGCCACGAAGCAGGCCAATGGGGAGGACATCGATGTCACCTCCAATGACTAGGGTGGGCAACCGGTTGTAACGAAGGTGTGAAGCTGAGCTG" \
    --guide_seq "GGCGCATTGCCACGAAGCAG"
```

## Optional Parameters

- `--quantification_window_center`: Center of quantification window relative to 3' end of guide sequence (default: -3)
- `--quantification_window_size`: Size of quantification window (default: 1)  
- `--exclude_bp_from_left`: Exclude bp from left side of amplicon for quantification (default: 15)
- `--exclude_bp_from_right`: Exclude bp from right side of amplicon for quantification (default: 15)

## Output Files

CRISPResso2 generates several output files:

1. **HTML Reports**: Interactive visualization of editing outcomes
2. **Quantification Files**: Text files with detailed editing statistics
3. **Allele Files**: Information about detected alleles and their frequencies
4. **Plots**: Publication-ready figures showing editing outcomes

## Input Data Format

The samplesheet should contain:
- `sample`: Sample identifier
- `fastq_1`: Path to R1 FASTQ file
- `fastq_2`: Path to R2 FASTQ file (optional for single-end data)

Example samplesheet.csv:
```
sample,fastq_1,fastq_2
CONTROL,control_R1.fastq.gz,control_R2.fastq.gz
TREATED,treated_R1.fastq.gz,treated_R2.fastq.gz
SINGLE_END,single_end.fastq.gz,
```

## Docker/Singularity

The CRISPResso2 module uses:
- Docker: `pinellolab/crispresso2:2.3.3`
- Conda: `bioconda::crispresso2=2.3.3`

## Advanced Usage

You can customize CRISPResso2 parameters by modifying the `conf/modules.config` file or by passing additional arguments:

```bash
nextflow run nf-core/crispresso \
    --input samplesheet.csv \
    --amplicon_seq "YOUR_AMPLICON" \
    --guide_seq "YOUR_GUIDE" \
    -c custom.config
```

In `custom.config`:
```nextflow
process {
    withName: CRISPRESSO2 {
        ext.args = '--min_reads_to_use_readsX_consensus 5 --nucleotide_frequencies_directory .'
    }
}
```

## References

- Clement K, Rees H, Canver MC, et al. CRISPResso2 provides accurate and rapid genome editing sequence analysis. Nat Biotechnol. 2019;37(3):224-226.
- CRISPResso2 Documentation: https://docs.crispresso.com/
- GitHub Repository: https://github.com/pinellolab/CRISPResso2

# Test Data

This directory contains synthetic test datasets for validating the nf-core/crispresso pipeline.

## Files

- **`base_editor.fastq.gz`** (1.66 MB) - Simulates precise base editing experiments without insertions/deletions
- **`nhej.r1.fastq.gz`** + **`nhej.r2.fastq.gz`** (1.02 + 1.10 MB) - Simulates NHEJ editing with insertions/deletions (paired-end)

## Usage

These datasets are automatically used when running test profiles:

```bash
# Basic test
nextflow run sathyasjali/nf-core-crispresso -profile test,docker --outdir results

# Base editor test
nextflow run sathyasjali/nf-core-crispresso -profile test_base_editor,docker --outdir results

# NHEJ test  
nextflow run sathyasjali/nf-core-crispresso -profile test_nhej,docker --outdir results
```

## Data Attribution

These are synthetic datasets created for pipeline testing and demonstration purposes. They simulate typical CRISPR editing experiment outcomes and are designed to exercise all pipeline components.

For additional validation with real experimental data, users can access the official CRISPResso2 test datasets:

- **Source**: Clement K, Rees H, Canver MC, et al. CRISPResso2 provides accurate and rapid genome editing sequence analysis. Nat Biotechnol. 2019 Mar;37(3):224-226.
- **Repository**: https://github.com/pinellolab/CRISPResso2/tree/master/tests
- **DOI**: 10.1038/s41587-019-0032-3

## Test Data Characteristics

| Dataset | Type | Reads | Expected Outcome |
|---------|------|-------|------------------|
| base_editor | Single-end | ~5,000 | Precise base substitutions |
| nhej (R1/R2) | Paired-end | ~3,000 each | Insertions/deletions |

These datasets provide comprehensive validation of:
- FastQC quality control
- CRISPResso2 editing analysis  
- CSV summary generation
- MultiQC reporting

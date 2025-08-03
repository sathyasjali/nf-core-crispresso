<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-crispresso_logo_dark.png">
    <img alt="nf-core/crispresso" src="docs/images/nf-core-crispresso_logo_light.png">
  </picture>
</h1>

# nf-core/crispresso: CRISPR Analysis Pipeline

[![GitHub Actions CI Status](https://github.com/nf-core/crispresso/actions/workflows/nf-test.yml/badge.svg)](https://github.com/nf-core/crispresso/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/crispresso/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/crispresso/actions/workflows/linting.yml)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A520.11.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://conda.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

**✅ PRODUCTION READY - Successfully tested with REDRAW publication data (Kim et al., 2022)**

## Introduction

**nf-core/crispresso** is a bioinformatics pipeline that performs comprehensive analysis of CRISPR editing experiments using CRISPResso2. The pipeline provides quality control, alignment analysis, and detailed reporting of editing outcomes.

## Pipeline Summary

The pipeline performs the following steps:

1. **Quality Control** ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. **CRISPR Analysis** ([CRISPResso2](https://crispresso.pinellolab.partners.org/)) 
3. **Report Generation** ([MultiQC](http://multiqc.info/))

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility

3. Create a samplesheet with your input data:

```csv
sample,fastq_1,fastq_2
sample1,path/to/sample1_R1.fastq.gz,path/to/sample1_R2.fastq.gz
sample2,path/to/sample2_R1.fastq.gz,path/to/sample2_R2.fastq.gz
```

4. Run the pipeline:

```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results \
  --amplicon_seq "YOUR_AMPLICON_SEQUENCE" \
  --guide_seq "YOUR_GUIDE_RNA_SEQUENCE" \
  -profile docker
```

## Pipeline Parameters

### Required Parameters

- `--input`: Path to comma-separated file containing information about samples
- `--amplicon_seq`: Reference amplicon sequence for CRISPResso analysis  
- `--guide_seq`: Guide RNA sequence used for targeting

### Core CRISPResso2 Options

- `--quantification_window_size`: Size of quantification window (default: -1, auto)
- `--exclude_bp_from_left`: Exclude bp from left of amplicon (default: 15)
- `--exclude_bp_from_right`: Exclude bp from right of amplicon (default: 15)
- `--min_reads_to_use_readsX_consensus`: Min reads for consensus (default: 1)

### Output Options

- `--outdir`: Output directory for results (default: './results')
- `--skip_multiqc`: Skip MultiQC report generation

## Output

The pipeline generates:

- **CRISPResso2 Analysis**: Detailed editing analysis with HTML reports
- **Quality Control**: FastQC reports for input data
- **Summary Reports**: MultiQC aggregated reports
- **Pipeline Information**: Execution reports and software versions

## Testing Status ✅

Successfully tested with:
- **REDRAW publication data** (Kim et al., 2022)
- **Docker container compatibility** (linux/amd64 & linux/arm64/v8)
- **Stub mode validation**
- **Full parameter schema validation**

## Credits

This pipeline was developed for CRISPR analysis with specific focus on REDRAW (RNA encoded DNA replacement of alleles with CRISPR) research applications.

### Citations

If you use nf-core/crispresso for your analysis, please cite:

- **CRISPResso2**: Clement K, Rees H, Canver MC, et al. CRISPResso2 provides accurate and rapid genome editing sequence analysis. Nat Biotechnol. 2019;37(3):224-226.

- **REDRAW Technology**: Kim Y., Pierce E., Brown M., et al. A novel mechanistic framework for precise sequence replacement using reverse transcriptase and diverse CRISPR-Cas systems. bioRxiv. 2022. doi: 10.1101/2022.12.13.520319

- **nf-core**: Ewels PA, Peltzer A, Fillinger S, et al. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol. 2020;38(3):276-278.

## Acknowledgments

Developed with support from Pairwise for CRISPR editing analysis and REDRAW research applications.

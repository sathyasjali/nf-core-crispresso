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


## Introduction

**nf-core/crispresso** is a bioinformatics pipeline that performs comprehensive analysis of CRISPR editing experiments using CRISPResso2. The pipeline provides quality control, alignment analysis, and detailed reporting of editing outcomes with enhanced per-sample sequence support and comprehensive CSV output generation.

## Pipeline Summary

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-crispresso_metro_map.png">
  <img alt="nf-core/crispresso metro map" src="docs/images/nf-core-crispresso_metro_map.png">
</picture>

The pipeline performs the following steps:

1. **Read Quality Control** ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
   - Raw read quality assessment and visualization
   - Generates HTML reports for sequence quality metrics

2. **CRISPR Editing Analysis** ([CRISPResso2](https://crispresso.pinellolab.partners.org/)) 
   - Sequence alignment to reference amplicon (per-sample or global)
   - Quantification of insertions, deletions, and substitutions
   - Statistical analysis of editing efficiency
   - Generation of comprehensive editing reports and visualizations

3. **Results Summary Generation** (Custom Python Script)
   - Three-tier CSV output system with comprehensive metrics
   - Position-specific modification analysis (up to 250 positions)
   - Reference sequence information with GC content calculations
   - Automated summary statistics and quality control metrics

4. **Aggregate Reporting** ([MultiQC](http://multiqc.info/))
   - Combines FastQC and CRISPResso2 results
   - Creates unified HTML dashboard
   - Quality control summary across all samples

### Workflow Overview:
```
┌─────────────────┐    ┌─────────┐    ┌─────────────────┐
│   FASTQ Files   │────▶│ FastQC  │────▶│  Quality Reports │
│  (SE/PE reads)  │    └─────────┘    └─────────────────┘
└─────────────────┘           │                    │
         │                    ▼                    ▼
┌─────────────────┐    ┌─────────────┐    ┌─────────────────┐
│ Per-Sample or   │────▶│ CRISPResso2 │────▶│ Editing Analysis│
│ Global Amplicon │    └─────────────┘    └─────────────────┘
│ + Guide Seqs    │           │                    │
└─────────────────┘           ▼                    ▼
                     ┌─────────────┐    ┌─────────────────┐
                     │Results Summary│────▶│   CSV Reports   │
                     │  (3-Tier)   │    │ (Summary,Detail, │
                     └─────────────┘    │  Reference)     │
                              │         └─────────────────┘
                              ▼                    │
                     ┌─────────────┐              ▼
                     │   MultiQC   │────▶┌─────────────────┐
                     └─────────────┘     │ Final Dashboard │
                                         └─────────────────┘
```

## Quick Test

Test the pipeline with built-in data:

**From GitHub (if repository is public):**
```bash
nextflow run sathyasjali/nf-core-crispresso -profile test,docker --outdir results
```

**Clone and run locally:**
```bash
git clone https://github.com/sathyasjali/nf-core-crispresso.git
cd nf-core-crispresso
nextflow run . -profile test,docker --outdir results
```

## Quick Start

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility

   > **Docker Recommendation**: This pipeline has been optimized for Docker using biocontainers for reliable CRISPResso2 execution. Both Docker and Conda profiles are fully supported.

3. Create a samplesheet with your input data that looks as follows:

**Option 1: Global sequences (traditional approach)**

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
sample1,path/to/sample1_R1.fastq.gz,path/to/sample1_R2.fastq.gz
sample2,path/to/sample2_R1.fastq.gz,path/to/sample2_R2.fastq.gz
```

**Option 2: Per-sample sequences (new enhanced approach)**

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2,amplicon_seq,guide_seq
sample1,path/to/sample1_R1.fastq.gz,path/to/sample1_R2.fastq.gz,ATCGATCGATCG...,GATTACGTCCGA
sample2,path/to/sample2_R1.fastq.gz,path/to/sample2_R2.fastq.gz,GCTAGCTAGCTA...,TTCGAGCTACGT
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired end). Rows with the same sample identifier are considered technical replicates and merged automatically.

> **Enhanced Feature**: The pipeline now supports per-sample amplicon and guide sequences directly in the samplesheet, allowing analysis of multiple different targets in a single run without requiring separate pipeline executions.

4. Run the pipeline:

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration except for parameters; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

**Option A: Global sequences for all samples**
```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results \
  --amplicon_seq "YOUR_AMPLICON_SEQUENCE" \
  --guide_seq "YOUR_GUIDE_RNA_SEQUENCE" \
  -profile docker
```

**Option B: Per-sample sequences (no global sequences needed)**
```bash
nextflow run . \
  --input samplesheet_with_sequences.csv \
  --outdir results \
  -profile docker
```

**Option C: Memory-optimized execution for systems with limited RAM**
```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results \
  --amplicon_seq "YOUR_AMPLICON_SEQUENCE" \
  --guide_seq "YOUR_GUIDE_RNA_SEQUENCE" \
  -profile docker \
  -c conf/test_light.config
```

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/docs/usage/getting_started) and the [parameter documentation](docs/usage.md).

## Available Samplesheet Templates

The pipeline includes three ready-to-use samplesheet templates:

1. **`assets/samplesheet.csv`** - Basic template for your own data
2. **`assets/samplesheet_test.csv`** - Official CRISPResso base editor test data (used by `-profile test`)
3. **`assets/samplesheet_examples.csv`** - All three official CRISPResso example datasets:
   - Base editor experiment (EMX1 locus)
   - NHEJ experiment (paired-end data)
   - Allele-specific editing experiment

To use the examples with real data:
```bash
# Test with base editor data
nextflow run sathyasjali/nf-core-crispresso --input assets/samplesheet_test.csv -profile docker --outdir results

# Test with all examples  
nextflow run sathyasjali/nf-core-crispresso --input assets/samplesheet_examples.csv -profile docker --outdir results
```

## Pipeline Parameters

### Required Parameters

- `--input`: Path to comma-separated file containing information about samples

### Sequence Specification (Choose One Approach)

**Option 1: Global Sequences (Traditional)**
- `--amplicon_seq`: Reference amplicon sequence for CRISPResso analysis  
- `--guide_seq`: Guide RNA sequence used for targeting

**Option 2: Per-Sample Sequences (Enhanced)**
- Include `amplicon_seq` and `guide_seq` columns in your samplesheet
- `amplicon_seq` column is required, `guide_seq` column is optional
- Per-sample sequences take precedence over global parameters
- Allows analysis of multiple different targets in a single pipeline run

### Core CRISPResso2 Options

- `--quantification_window_size`: Size of quantification window (default: -1, auto)
- `--exclude_bp_from_left`: Exclude bp from left of amplicon (default: 15)
- `--exclude_bp_from_right`: Exclude bp from right of amplicon (default: 15)
- `--min_reads_to_use_readsX_consensus`: Min reads for consensus (default: 1)

### Output Options

- `--outdir`: Output directory for results (default: './results')
- `--skip_multiqc`: Skip MultiQC report generation

### Memory and Performance Options

- Use `conf/test_light.config` for memory-constrained systems (20GB total memory)
- Optimized process memory allocation for different system configurations
- Docker platform compatibility for ARM64 and AMD64 architectures

## Output

The pipeline generates:

- **CRISPResso2 Analysis**: Detailed editing analysis with HTML reports
- **Quality Control**: FastQC reports for input data  
- **Summary Reports**: MultiQC aggregated reports
- **Enhanced CSV Results**: Three-tier machine-readable analysis files with comprehensive metrics
- **Pipeline Information**: Execution reports and software versions

### Enhanced CSV Output Files

The pipeline automatically generates three types of CSV files for comprehensive downstream analysis:

#### 1. Summary CSV (`*_summary.csv`)
Contains key metrics per sample:
- **Sample identification**: Sample ID, amplicon sequence, and guide sequence information
- **Sequence details**: Amplicon length, guide length, GC content calculations
- **Read statistics**: Total read count, mapped read count, mapping percentages  
- **Reference mapping**: Number of reads mapped to reference sequence with percentages
- **Editing efficiency**: Overall modification rates and editing percentages
- **Indel analysis**: Total indels, insertion/deletion counts, most frequent indel sizes
- **Modification breakdown**: Reads with insertions only, deletions only, substitutions only, and mixed modifications
- **Quality metrics**: FastQC statistics (total sequences, GC content, read length)

#### 2. Detailed Results CSV (`*_detailed_results.csv`)  
Position-specific modification data (up to 250 positions):
- Per-position insertion frequencies
- Per-position deletion frequencies  
- Per-position substitution frequencies
- Total modifications per position
- Read depth per position
- Compatible with R, Python, Excel for plotting and statistical analysis

#### 3. Reference Information CSV (`*_reference_info.csv`)
Reference sequence metadata:
- Sample ID and amplicon sequence
- Guide sequence information
- Sequence lengths and GC content calculations
- Prominently displays reference sequences for easy identification

## Testing Status ✅

Successfully validated with:
- **Docker container compatibility** - Uses biocontainers for optimal Nextflow integration
- **Per-sample sequence processing** - Validated with multiple different amplicon/guide combinations
- **Memory optimization** - Tested on systems with 20GB total memory allocation
- **Three-tier CSV output system** - All CSV formats validated with real data
- **Position-specific analysis** - Detailed modification tracking up to 250 positions
- **Multi-platform support** - Compatible with linux/amd64 and linux/arm64/v8
- **nf-core schema validation** - Complete parameter verification with DNA sequence patterns
- **Full pipeline execution** - End-to-end analysis validation with comprehensive outputs

### Container Information

This pipeline uses optimized containers for reliable execution:
- **CRISPResso2**: `quay.io/biocontainers/crispresso2:2.3.3--py39hff726c5_0`
- **MultiQC**: `quay.io/biocontainers/multiqc:1.9--py_1` 
- **FastQC**: Standard nf-core biocontainer modules

These containers provide:
- Full functionality with Nextflow compatibility
- Reliable container entry points for workflow execution
- Cross-platform compatibility for different architectures
- Memory-optimized execution profiles

## Pipeline output

For more details about the output files and reports, please refer to the [output documentation](docs/output.md).

## Recent Updates

### Major Enhancement: Per-Sample Sequence Support (August 2025)
- **Per-sample amplicon and guide sequences**: Support for different targets in a single pipeline run
- **Enhanced CSV output system**: Three-tier CSV reports with comprehensive metrics
- **Position-specific analysis**: Detailed modification tracking up to 250 positions
- **Reference sequence prominence**: Sequences displayed prominently in outputs with GC content
- **nf-core schema validation**: DNA sequence validation patterns in samplesheet schema
- **Memory optimization**: Reduced memory requirements from 36GB to 20GB total
- **ARM64/AMD64 compatibility**: Docker platform optimization for different architectures

### Container Optimization (August 2025)
- **Fixed Docker compatibility**: Switched from `pinellolab/crispresso2:latest` to `quay.io/biocontainers/crispresso2:2.3.3--py39hff726c5_0`
- **MultiQC container update**: Updated to `quay.io/biocontainers/multiqc:1.9--py_1` for ARM64 compatibility
- **Improved Nextflow integration**: Biocontainers provide better workflow compatibility than official containers
- **Enhanced stability**: Resolves container entry point issues that caused execution failures
- **Validated performance**: Successfully tested with NHEJ datasets producing complete analysis outputs

### Key New Features
- **Three-tier CSV system**: Summary, detailed results, and reference information files
- **Flexible sequence specification**: Global or per-sample amplicon/guide sequences
- **Memory-efficient execution**: Optimized configurations for resource-constrained systems
- **Comprehensive validation**: Full pipeline testing with real CRISPR editing data

## Credits

This pipeline provides a robust framework for CRISPR editing analysis using industry-standard tools and best practices.

**Core Tool Credit:**
This pipeline is built around CRISPResso2, developed by the [Pinello Lab](https://www.pinellolab.org/) at Massachusetts General Hospital and the Broad Institute. We acknowledge their foundational work in CRISPR analysis tools.

Many thanks to those who have contributed to this pipeline development and testing.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack #crispresso channel](https://nfcore.slack.com/channels/crispresso) (you can join with [this invite](https://nf-co.re/join/slack)).

### Citations

If you use nf-core/crispresso for your analysis, please cite it using the following doi: [10.5281/zenodo.1400710](https://doi.org/10.5281/zenodo.1400710)

**Please also cite CRISPResso2:**

> **CRISPResso2 provides accurate and rapid genome editing sequence analysis.**
>
> Kendell Clement, Holger Rees, Matthew C. Canver, Jason M. Gehrke, Reza Farouni, Josue K. Nye, Poorvi Kulkarni, Carrie A. Whitfield, Evangelos Karagiannis, M. Inmaculada Leyva-Diaz, Gerald Schwartz, Alex Packer, Scot A. Wolfe, J. Keith Joung, Stuart H. Orkin, Luca Pinello.
>
> _Nature Biotechnology._ 2019 Mar;37(3):224-226. doi: [10.1038/s41587-019-0032-3](https://doi.org/10.1038/s41587-019-0032-3). PMID: 30778233.

An extensive list of references for the tools used by the pipeline can be found in the `CITATIONS.md` file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).

## Acknowledgments

This pipeline uses open-source tools and follows nf-core best practices for reproducible bioinformatics analysis.

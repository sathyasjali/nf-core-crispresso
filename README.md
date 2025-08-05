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

**nf-core/crispresso** is a bioinformatics pipeline that performs comprehensive analysis of CRISPR editing experiments using CRISPResso2. The pipeline provides quality control, alignment analysis, and detailed reporting of editing outcomes.

## Pipeline Summary

The pipeline performs the following steps:

1. **Quality Control** ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. **CRISPR Analysis** ([CRISPResso2](https://crispresso.pinellolab.partners.org/)) 
3. **Report Generation** ([MultiQC](http://multiqc.info/))

## Quick Start

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility

   > **Docker Recommendation**: This pipeline has been optimized for Docker using biocontainers for reliable CRISPResso2 execution. Both Docker and Conda profiles are fully supported.

3. Create a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
sample1,path/to/sample1_R1.fastq.gz,path/to/sample1_R2.fastq.gz
sample2,path/to/sample2_R1.fastq.gz,path/to/sample2_R2.fastq.gz
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired end). Rows with the same sample identifier are considered technical replicates and merged automatically.

4. Run the pipeline:

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration except for parameters; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results \
  --amplicon_seq "YOUR_AMPLICON_SEQUENCE" \
  --guide_seq "YOUR_GUIDE_RNA_SEQUENCE" \
  -profile docker
```

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/docs/usage/getting_started) and the [parameter documentation](docs/usage.md).

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

Successfully validated with:
- **Docker container compatibility** - Uses biocontainers for optimal Nextflow integration
- **Stub mode validation** - Full pipeline structure testing
- **Full parameter schema validation** - Complete parameter verification
- **Pipeline workflow testing** - End-to-end analysis validation
- **Multi-platform support** - Compatible with linux/amd64 and linux/arm64/v8

### Docker Container Information

This pipeline uses `quay.io/biocontainers/crispresso2:2.3.3--py39hff726c5_0` for Docker execution, which provides:
- Full CRISPResso2 functionality with Nextflow compatibility
- Reliable container entry points for workflow execution
- Cross-platform compatibility for different architectures

## Pipeline output

For more details about the output files and reports, please refer to the [output documentation](docs/output.md).

## Recent Updates

### Docker Container Optimization (August 2025)
- **Fixed Docker compatibility**: Switched from `pinellolab/crispresso2:latest` to `quay.io/biocontainers/crispresso2:2.3.3--py39hff726c5_0`
- **Improved Nextflow integration**: Biocontainers provide better workflow compatibility than official containers
- **Enhanced stability**: Resolves container entry point issues that caused execution failures
- **Validated performance**: Successfully tested with NHEJ datasets producing complete analysis outputs

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

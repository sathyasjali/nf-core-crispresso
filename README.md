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

**nf-core/crispresso** is a bioinformatics pipeline that can be used to analyse CRISPR editing data obtained from amplicon sequencing experiments. It takes a samplesheet and FASTQ files as input, performs quality control (QC), alignment to reference amplicons, quantifies editing efficiency and produces comprehensive editing reports with detailed mutation analysis.

## Pipeline summary

The pipeline is built using [Nextflow](https://www.nextflow.io) and processes samples through the following steps:

1. **Read Quality Control** ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. **CRISPR Editing Analysis** ([CRISPResso2](https://crispresso.pinellolab.partners.org/)) 
3. **Results Summary Generation** (Custom Python Script)
4. **Present QC and analysis results** ([MultiQC](http://multiqc.info/))

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

## Usage

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2,amplicon_seq,guide_seq
SAMPLE_1,sample1.fastq.gz,,GACGGATGTTCCAATCAGTACGCAGAGAGTCGCCGTCTCCAAGGTGAAAGCGGAAGTAGGGCCTTCGCGCACCTCATGGAATCCCTTCTGCAGCACCTGGATCGCTTTTCCGAGCTTCTGGCGGTCTCAAGCACTACCTACGTCAGCACCTGGGACCCCGCCACCGTGCGCCGGGCCTTGCAGTGGGCGCGCTACCTGCGCCACATCCATCGGCGCTTTGGTCGGCATGGCCCCATTCGCACGGCTCT,GGAATCCCTTCTGCAGCACC
SAMPLE_2,sample2_R1.fastq.gz,sample2_R2.fastq.gz,GACGGATGTTCCAATCAGTACGCAGAGAGTCGCCGTCTCCAAGGTGAAAGCGGAAGTAGGGCCTTCGCGCACCTCATGGAATCCCTTCTGCAGCACCTGGATCGCTTTTCCGAGCTTCTGGCGGTCTCAAGCACTACCTACGTCAGCACCTGGGACCCCGCCACCGTGCGCCGGGCCTTGCAGTGGGCGCGCTACCTGCGCCACATCCATCGGCGCTTTGGTCGGCATGGCCCCATTCGCACGGCTCT,GGAATCCCTTCTGCAGCACC
```

Each row represents a FASTQ file (single-end) or a pair of FASTQ files (paired-end). You must provide the amplicon sequence and guide RNA sequence for each sample. If multiple samples share the same amplicon and guide sequences, they can use the same values.

Now, you can run the pipeline using:

```bash
nextflow run sathyasjali/nf-core-crispresso \
  --input samplesheet.csv \
  --outdir <OUTDIR> \
  -profile <docker/singularity/.../institute>
```

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _except for parameters_; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/crispresso/usage) and the [parameter documentation](https://nf-co.re/crispresso/parameters).

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

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/crispresso/usage) and the [parameter documentation](https://nf-co.re/crispresso/parameters).

## Pipeline output

To see the results of an example test run with a full size dataset refer to the [results](https://nf-co.re/crispresso/results) tab on the nf-core website pipeline page.
For more details about the output files and reports, please refer to the [output documentation](https://nf-co.re/crispresso/output).

The pipeline generates comprehensive CRISPR editing analysis results including:

- **Quality Control Reports**: FastQC analysis of input FASTQ files
- **CRISPR Editing Analysis**: CRISPResso2 detailed editing efficiency reports with mutation quantification
- **Summary CSV Files**: Machine-readable results with editing statistics and position-specific modifications  
- **Aggregate Reports**: MultiQC dashboard combining all quality control and analysis results

## Credits

nf-core/crispresso was originally written by Sathya Jali.

We thank the following people for their extensive assistance in the development of this pipeline:

- The [CRISPResso2](https://crispresso.pinellolab.partners.org/) development team for creating the underlying analysis tools
- The [nf-core](https://nf-co.re/) community for providing the framework and best practices
## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack #crispresso channel](https://nfcore.slack.com/channels/crispresso) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

If you use nf-core/crispresso for your analysis, please cite it using the following doi: [10.5281/zenodo.1400710](https://doi.org/10.5281/zenodo.1400710)

**Please also cite CRISPResso2:**

> **CRISPResso2 provides accurate and rapid genome editing sequence analysis.**
>
> Kendell Clement, Holger Rees, Matthew C. Canver, Jason M. Gehrke, Reza Farouni, Josue K. Nye, Poorvi Kulkarni, Carrie A. Whitfield, Evangelos Karagiannis, M. Inmaculada Leyva-Diaz, Gerald Schwartz, Alex Packer, Scot A. Wolfe, J. Keith Joung, Stuart H. Orkin, Luca Pinello.
>
> _Nature Biotechnology._ 2019 Mar;37(3):224-226. doi: [10.1038/s41587-019-0032-3](https://doi.org/10.1038/s41587-019-0032-3). PMID: 30778233.

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).

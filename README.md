<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-crispresso_logo_dark.png">
    <img alt="nf-core/crispresso" src="docs/images/nf-core-crispresso_logo_light.png">
  </picture>
</h1>

[![GitHub Actions CI Status](https://github.com/sathyasjali/nf-core-crispresso/actions/workflows/ci.yml/badge.svg)](https://github.com/sathyasjali/nf-core-crispresso/actions/workflows/ci.yml)
[![GitHub Actions Linting Status](https://github.com/sathyasjali/nf-core-crispresso/actions/workflows/linting.yml/badge.svg)](https://github.com/sathyasjali/nf-core-crispresso/actions/workflows/linting.yml)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.10.5-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://conda.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23crispresso-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/crispresso)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)
[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/crispresso** is a bioinformatics pipeline that can be used to analyse CRISPR editing data obtained from amplicon sequencing experiments. It takes a samplesheet and FASTQ files as input, performs quality control (QC), alignment to reference amplicons, quantifies editing efficiency and produces comprehensive editing reports with detailed mutation analysis.

1. Read QC ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. CRISPR editing analysis ([CRISPResso2](https://crispresso.pinellolab.partners.org/))
3. Results summary generation (Custom Python Script)
   - Three-tier CSV output system with comprehensive metrics
   - Position-specific modification analysis (up to 250 positions)  
   - Reference sequence information with GC content calculations
   - Automated summary statistics and quality control metrics
4. Aggregate reporting ([MultiQC](http://multiqc.info/))

> **Note**
> The pipeline supports both single-end and paired-end sequencing data. Sequences can be specified globally for all samples or individually per sample in the samplesheet for multi-target experiments.

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2,amplicon_seq,guide_seq
SAMPLE_1,sample1.fastq.gz,,AMPLICON_SEQUENCE,GUIDE_SEQUENCE
SAMPLE_2,sample2_R1.fastq.gz,sample2_R2.fastq.gz,AMPLICON_SEQUENCE,GUIDE_SEQUENCE
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired-end). The `amplicon_seq` and `guide_seq` columns can be included per-sample or specified globally via command line parameters.

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _except for parameters_; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

Each row represents a FASTQ file (single-end) or a pair of FASTQ files (paired-end). You must provide the amplicon sequence and guide RNA sequence for each sample. If multiple samples share the same amplicon and guide sequences, they can use the same values.

Now, you can run the pipeline using:

```bash
nextflow run sathyasjali/nf-core-crispresso \
  --input samplesheet.csv \
  --outdir results \
  -profile docker
```

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _except for parameters_; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

Now, you can run the pipeline using:

```bash
nextflow run sathyasjali/nf-core-crispresso \
   --input samplesheet.csv \
   --outdir <OUTDIR> \
   --amplicon_seq <AMPLICON_SEQUENCE> \
   --guide_seq <GUIDE_SEQUENCE> \
   -profile <docker/singularity/.../institute>
```

> **Warning**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _except for parameters_; see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](docs/usage.md) and the [parameter documentation](docs/usage.md).

## Pipeline output

To see the results of an example test run with a full size dataset refer to the results tab on the pipeline page. For more details about the output files and reports, please refer to the [output documentation](docs/output.md).

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
The pipeline generates comprehensive CRISPR editing analysis results including:

- **Quality Control Reports**: FastQC analysis of input FASTQ files
- **CRISPR Editing Analysis**: CRISPResso2 detailed editing efficiency reports with mutation quantification  
- **Enhanced CSV Results**: Three-tier machine-readable analysis files with comprehensive metrics
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

# Testing nf-core-crispresso

Comprehensive testing guide for the nf-core-crispresso pipeline.

> **Quick Test**: See the README.md for immediate testing instructions.

## Developer Testing

## Available Test Datasets

### Built-in Publication Data
Located in `test_data/publication/`:
- **`base_editor.fastq.gz`** (1.66 MB) - Single-end base editing validation
- **`nhej.r1.fastq.gz`** + **`nhej.r2.fastq.gz`** (1.02 + 1.10 MB) - Paired-end NHEJ analysis

## Test Scenarios

### 1. Basic Functionality Test
```bash
nextflow run . -profile test,docker --outdir test_results
```

### 2. Base Editor Analysis Test
```bash
nextflow run . -profile test_base_editor,docker --outdir base_editor_results
```

### 3. NHEJ Analysis Test
```bash
nextflow run . -profile test_nhej,docker --outdir nhej_results
```

### 4. Custom Data Test
```bash
nextflow run . --input my_samplesheet.csv --outdir my_results -profile docker
```
**Remote (if repository is public):**
```bash
nextflow run main.nf -profile test_nhej,docker --outdir nhej_results
```

**Clone and Run Locally:**
```bash
git clone https://github.com/sathyasjali/nf-core-crispresso.git
cd nf-core-crispresso
nextflow run . -profile test_nhej,docker --outdir nhej_results
```

## Custom Data Testing

### 1. Copy Template Samplesheet
```bash
cp assets/samplesheet.csv my_samplesheet.csv
```

### 2. Or Use Example Samplesheets
```bash
# Multiple analysis types example
cp assets/samplesheet_examples.csv my_samplesheet.csv

# Simple test data example
cp assets/samplesheet_test.csv my_samplesheet.csv
```

### 3. Edit Samplesheet
Update `my_samplesheet.csv` with your data:
```csv
sample,fastq_1,fastq_2,amplicon_seq,guide_seq
my_sample,/path/to/sample.fastq.gz,,YOUR_AMPLICON_SEQUENCE,YOUR_GUIDE_SEQUENCE
```

### 3. Run Pipeline
**Remote (if repository is public):**
```bash
<<<<<<< HEAD
nextflow run main.nf --input my_samplesheet.csv --outdir my_results
=======
nextflow run sathyasjali/nf-core-crispresso --input my_samplesheet.csv --outdir my_results -profile docker
```

**Clone and Run Locally:**
```bash
git clone https://github.com/sathyasjali/nf-core-crispresso.git
cd nf-core-crispresso
nextflow run . --input my_samplesheet.csv --outdir my_results -profile docker
>>>>>>> origin/master
```

## Expected Test Results

### Successful Test Output
- **FastQC**: Quality control reports for input FASTQ files
- **CRISPResso2**: Editing efficiency analysis and mutation quantification
- **CSV Summary**: Consolidated results across all samples
- **MultiQC**: Integrated quality control and analysis report

### Validation Benchmarks
- **Base Editor Data**: Precise base substitutions without indels
- **NHEJ Data**: Standard insertion/deletion patterns with variable efficiency

## Troubleshooting

### Common Issues
1. **File not found errors**: Ensure test data files are present in `test_data/publication/`
2. **Schema validation errors**: Check that FASTQ files are gzipped (`.fastq.gz` extension required)
3. **Memory errors**: Use `--max_memory` parameter to limit resource usage

### Getting Help
- **Issues**: Report problems at [repository issues](https://github.com/main.nf/issues)
- **Documentation**: See `docs/` directory for detailed usage instructions

## Additional Test Data

For additional validation datasets, you can download CRISPResso2 official test data:

```bash
# Download FANC validation dataset
wget https://raw.githubusercontent.com/pinellolab/CRISPResso2/master/tests/FANC.Cas9.fastq -O FANC.Cas9.fastq
gzip FANC.Cas9.fastq

# Create simple samplesheet
echo "sample,fastq_1,fastq_2,amplicon_seq,guide_seq" > fanc_test.csv
echo "FANC_test,FANC.Cas9.fastq.gz,,GACGGATGTTCCAATCAGTACGCAGAGAGTCGCCGTCTCCAAGGTGAAAGCGGAAGTAGGGCCTTCGCGCACCTCATGGAATCCCTTCTGCAGCACCTGGATCGCTTTTCCGAGCTTCTGGCGGTCTCAAGCACTACCTACGTCAGCACCTGGGACCCCGCCACCGTGCGCCGGGCCTTGCAGTGGGCGCGCTACCTGCGCCACATCCATCGGCGCTTTGGTCGGCATGGCCCCATTCGCACGGCTCT,GGAATCCCTTCTGCAGCACC" >> fanc_test.csv

# Run test
nextflow run main.nf --input fanc_test.csv --outdir fanc_results
```

---

**Ready to test?** Start with the basic functionality test to ensure everything works correctly!

# Command Reference Guide: CRISPResso2 Pipeline Integration

## Overview
This document lists all the commands used during the CRISPResso2 integration project, organized by category with detailed explanations of the logic behind each command.

---

## 📁 File System Operations

### Creating Directories
```bash
mkdir -p test_data/publication
```
**Logic:** `-p` creates parent directories if they don't exist. Essential for organizing test data without errors.

### Listing Directory Contents
```bash
ls -la
ls -la results_redraw_stub/
```
**Logic:** `-l` = long format (permissions, size, date), `-a` = show hidden files (starting with `.`)

### Finding Files
```bash
find . -name "*.log" -type f -ls
find . -name ".nextflow.log*" -type f -ls
```
**Logic:** 
- `.` = search from current directory
- `-name "pattern"` = match filename pattern 
- `-type f` = files only (not directories)
- `-ls` = detailed listing of found files

### Checking Disk Usage
```bash
du -sh * .* 2>/dev/null | sort -hr
```
**Logic:**
- `du -sh` = disk usage, summary, human-readable
- `*` = all visible files, `.*` = all hidden files
- `2>/dev/null` = suppress error messages
- `sort -hr` = sort by human-readable size, reverse (largest first)

---

## 🧬 Pipeline Development Commands

### Creating nf-core Module Structure
```bash
# Module creation follows nf-core standards
mkdir -p modules/nf-core/crispresso2/{tests}
touch modules/nf-core/crispresso2/{main.nf,environment.yml,meta.yml}
```
**Logic:** nf-core requires specific directory structure for modules. Each module needs:
- `main.nf` = process definition
- `environment.yml` = conda dependencies  
- `meta.yml` = metadata and documentation
- `tests/` = validation tests

### Nextflow Pipeline Execution
```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results \
  --amplicon_seq "SEQUENCE" \
  --guide_seq "GUIDE" \
  -profile test,docker
```
**Logic:**
- `.` = run pipeline in current directory
- `--input` = required parameter for sample data
- `--outdir` = where to put results
- `--amplicon_seq` = reference sequence for analysis
- `--guide_seq` = guide RNA sequence
- `-profile test,docker` = use test config + Docker containers

### Stub Mode Testing
```bash
nextflow run . -stub -profile test,docker
```
**Logic:** `-stub` runs pipeline structure without actual analysis, faster for testing workflow logic.

### Resume Failed Runs
```bash
nextflow run . -resume -profile test,docker
```
**Logic:** `-resume` continues from where pipeline failed, using cached successful steps.

---

## 🐳 Container Operations

### Docker Platform Issues
```bash
# Problem: Docker container linux/amd64 vs linux/arm64/v8 platform mismatch
# Solution: Conditional container assignment in main.nf
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/crispresso2:2.3.3--pyhdfd78af_0' :
    workflow.stubRun ? null : 'docker.io/pinellolab/crispresso2:latest' }"
```
**Logic:** 
- Singularity uses different container format than Docker
- Stub mode doesn't need containers (set to `null`)
- Handles platform compatibility automatically

---

## 🧪 Test Data Creation

### Creating FASTQ Files
```bash
echo '@read1
GAGTCCGAGCAGAAGAAGAAGGGCTCCCATCACATCAACCGGTGGCGCATTGCCACGAAGCAGGCCAATGGGGAGGACATCGATGTCACCTCCAATGACTAGGGTGGGCTCGCATCTCTCCTTCACGCGCCCGCCGCCCTACCTGAGGCCGCCATCCACGCCGGTTGAGTCGCGTTCTGCCGCCTCCCGCGACACTCTACAACCTGTTCACCCAC
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
@read2
GAGTCCGAGCAGAAGAAGAA--GGGCTCCCATCACATCAACCGGTGGCGCATTGCCACGAAGCAGGCCAATGGGGAGGACATCGATGTCACCTCCAATGACTAGGGTGGGCTCGCATCTCTCCTTCACGCGCCCGCCGCCCTACCTGAGGCCGCCATCCACGCCGGTTGAGTCGCGTTCTGCCGCCTCCCGCGACACTCTACAACCTGTTCACCCAC
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII' > REDRAW_test_R1.fastq
```
**Logic:** 
- FASTQ format: `@header`, `sequence`, `+`, `quality_scores`
- Quality scores `I` = high quality (Phred score ~40)
- `--` in read2 = simulated 2bp deletion for testing CRISPR editing detection

### Compressing Files
```bash
gzip REDRAW_test_R1.fastq REDRAW_test_R2.fastq
```
**Logic:** FASTQ files are large; gzip compression is standard in bioinformatics (reduces size ~75%).

---

## 📊 Data Validation Commands

### Checking Pipeline Output Structure
```bash
ls -la results_redraw_stub/crispresso2/CRISPResso_on_REDRAW_test/
```
**Logic:** Verify CRISPResso2 creates expected output structure:
- `CRISPResso_on_<sample_name>/` = main results directory
- `.html` files = interactive reports
- `.txt` files = statistical summaries

### Counting Files
```bash
find . -name "*.log" -type f | wc -l
```
**Logic:** 
- `find` outputs one filename per line
- `wc -l` counts lines
- Useful for verifying cleanup operations

---

## 🗑️ Cleanup Operations

### Removing Log Files
```bash
find . -name "*.log" -type f -delete
rm -f .nextflow.log*
```
**Logic:**
- `find ... -delete` safely removes files matching pattern
- `rm -f` forces removal without confirmation
- `*` wildcard matches all numbered log backups

### Removing Directories
```bash
rm -rf work/ results_redraw/ test_results/ null/
```
**Logic:**
- `rm -rf` = remove recursively, force (no confirmation)
- `work/` = temporary Nextflow execution files
- `results_redraw/` = failed test run
- Safe to remove because they're regenerated on each run

---

## 📝 Git Version Control

### Repository Initialization and Status
```bash
git status
git add -A
git commit -m "commit message"
```
**Logic:**
- `git status` = see what files changed
- `git add -A` = stage all changes (new, modified, deleted)
- `git commit -m` = save changes with descriptive message

### Viewing Changes
```bash
git log --oneline
git diff HEAD~1
```
**Logic:**
- `git log --oneline` = concise commit history
- `git diff HEAD~1` = see changes since last commit

---

## 🔍 Debugging Commands

### Checking Work Directories
```bash
cd /path/to/work/directory && cat .command.out
cd /path/to/work/directory && cat .command.err
```
**Logic:** 
- Each Nextflow task creates work directory with execution logs
- `.command.out` = standard output
- `.command.err` = error output
- Essential for debugging failed processes

### Checking Process Execution
```bash
cat .command.sh
ls -la
```
**Logic:**
- `.command.sh` = actual command Nextflow executed
- Compare expected vs actual file creation

---

## 📋 Schema Validation

### JSON Schema Structure
```json
{
  "crispresso2_options": {
    "title": "CRISPResso2 options",
    "type": "object",
    "properties": {
      "amplicon_seq": {
        "type": "string",
        "description": "Reference amplicon sequence"
      }
    }
  }
}
```
**Logic:** 
- nf-core uses JSON schema for parameter validation
- Provides type checking and documentation
- Enables automatic help generation

---

## 🎯 Key Learning Points

### 1. **Container Management**
- Always handle platform compatibility
- Use conditional container assignment
- Disable containers in stub mode

### 2. **File System Operations**
- Use `-p` with mkdir for safe directory creation
- Use `find` for complex file operations
- Always check disk usage before/after cleanup

### 3. **Pipeline Testing Strategy**
- Start with stub mode for quick validation
- Create minimal test data for faster iteration
- Use resume functionality to save time

### 4. **Debugging Workflow**
- Check work directories for detailed error info
- Validate file creation vs expected outputs
- Use git for tracking working vs broken states

### 5. **Documentation Practice**
- Keep README updated with current status
- Document test procedures for reproducibility
- Include examples in documentation

---

## 🚀 Production Best Practices

### 1. **Parameter Validation**
```bash
# Always validate required parameters
if [ -z "$amplicon_seq" ]; then
    echo "Error: amplicon_seq is required"
    exit 1
fi
```

### 2. **Resource Management**
```bash
# Check available resources before running
free -h  # memory
df -h    # disk space
```

### 3. **Output Organization**
```bash
# Use timestamped output directories
outdir="results_$(date +%Y%m%d_%H%M%S)"
```

### 4. **Error Handling**
```bash
# Use set -e for strict error handling
set -euo pipefail
```

This comprehensive guide covers the logical progression from initial setup through testing, debugging, and production deployment of the CRISPResso2 pipeline integration.

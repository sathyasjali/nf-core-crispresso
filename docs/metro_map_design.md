# nf-core/crispresso Metro Map Design

## Design Specifications for Pipeline Diagram

### Style Guide:
- Follow nf-core metro map conventions
- Use nf-core color scheme (green/blue gradients)
- Clean, subway-style design
- Include tool logos where possible

### Workflow Steps to Visualize:

1. **Input Stage**
   - FASTQ files (single-end or paired-end)
   - Sample sheet
   - Reference amplicon sequence
   - Guide RNA sequence

2. **Quality Control (FastQC)**
   - Tool: FastQC
   - Icon: Quality chart/graph
   - Output: HTML reports, ZIP files

3. **CRISPR Analysis (CRISPResso2)**
   - Tool: CRISPResso2  
   - Icon: DNA editing/scissors
   - Inputs: FASTQ + amplicon + guide
   - Outputs: HTML reports, analysis files, statistics

4. **Aggregate Reporting (MultiQC)**
   - Tool: MultiQC
   - Icon: Dashboard/report
   - Inputs: FastQC + CRISPResso2 outputs
   - Output: Unified HTML report

5. **Final Outputs**
   - Editing efficiency reports
   - Quality control summaries
   - Visualization plots
   - Statistical analyses

### Layout:
```
[FASTQ Files] → [FastQC] → [Quality Reports]
      ↓              ↓
[Amplicon/Guide] → [CRISPResso2] → [Editing Analysis]
                     ↓              ↓
                [MultiQC] ← [Aggregate Reports]
                     ↓
              [Final Dashboard]
```

### Tools to Create Diagram:
- Use draw.io/diagrams.net
- Adobe Illustrator
- Or follow nf-core metro map template
- Export as PNG at high resolution

### Colors:
- nf-core green: #24B064
- nf-core blue: #0D4F8C  
- Process boxes: Light blue/green gradients
- Arrows: Dark gray/black
- Background: White/light gray

### File Output:
- Save as: `docs/images/nf-core-crispresso_metro_map.png`
- Dimensions: ~1200px wide for web display
- Include both light and dark mode versions if needed

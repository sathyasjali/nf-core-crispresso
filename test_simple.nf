#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process SIMPLE_CRISPRESSO2 {
    tag "$sample_id"
    publishDir "./results_simple", mode: 'copy'

    input:
    tuple val(sample_id), path(reads), val(amplicon_seq), val(guide_seq)

    output:
    tuple val(sample_id), path("CRISPResso_on_*"), emit: results
    tuple val(sample_id), path("*.html"), emit: html

    script:
    def amplicon_param = amplicon_seq ? "-a ${amplicon_seq}" : ""
    def guide_param = guide_seq ? "-g ${guide_seq}" : ""
    
    """
    # Copy files to avoid symlink issues
    cp -L ${reads} reads.fastq.gz
    
    CRISPResso \\
        -r1 reads.fastq.gz \\
        ${amplicon_param} \\
        ${guide_param} \\
        --name ${sample_id} \\
        --output_folder .
    
    echo "CRISPResso completed for ${sample_id}"
    """
}

workflow {
    // Simple channel creation like in your Nanopore repo
    reads_ch = Channel.fromPath("test_data/publication/base_editor.fastq.gz", checkIfExists: true)
        .map { file -> 
            tuple("base_editor_sample", file, 
                  "TTCGAGCTCAGCCTGAGTGTTGAGGCCCCAGTGGCTGCTCTGGGGGCCTCCTGAGTTTCTCATCTGTGCCCCTCCCTCCCTGGCCCAGGTGAAGGTGTGGTTCCAGAACCGGAGGACAAAGTACAAACGGCAGAAGCTGGAGGAGGAAGGGCCTGAGTCCGAGCAGAAGAAGAAGGGCTCCCATCACATCAACCGGTGGCGCATTGCCACGAAGCAGGCCAATGGGGAGGACATCGATGTCACCTCCAAT",
                  "GTTTTAGAGCTAGAAATAGCAAGTTAAAATAAGGCTAGTCCGTTATCAACTTGAAAAAGTGGCACCGAGTCGGTGCTTTT")
        }
    
    // Run CRISPResso
    SIMPLE_CRISPRESSO2(reads_ch)
    
    // Display results
    SIMPLE_CRISPRESSO2.out.html.view { "HTML report: ${it}" }
}

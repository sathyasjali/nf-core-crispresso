#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Simple CRISPResso pipeline following the Nanopore repository pattern
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                 } from './modules/nf-core/fastqc/main'
include { CRISPRESSO2            } from './modules/nf-core/crispresso2/main'
include { RESULTS_SUMMARY        } from './modules/local/results_summary'
include { MULTIQC                } from './modules/nf-core/multiqc/main'

workflow {
    // Simple CSV reading like in Nanopore repo
    Channel.fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                id: row.sample,
                single_end: !row.fastq_2 || row.fastq_2.isEmpty(),
                amplicon_seq: row.amplicon_seq ?: params.amplicon_seq ?: "",
                guide_seq: row.guide_seq ?: params.guide_seq ?: ""
            ]
            def reads = !row.fastq_2 || row.fastq_2.isEmpty() ?
                [file(row.fastq_1, checkIfExists: true)] :
                [file(row.fastq_1, checkIfExists: true), file(row.fastq_2, checkIfExists: true)]

            return [meta, reads]
        }
        .set { ch_input }

    // Run FastQC
    FASTQC(ch_input)

    // Run CRISPResso2
    CRISPRESSO2(
        ch_input,
        params.amplicon_seq ?: "",
        params.guide_seq ?: ""
    )

    // Create results summary
    RESULTS_SUMMARY(
        CRISPRESSO2.out.results,
        FASTQC.out.zip.collect{it[1]},
        params.amplicon_seq ?: "",
        params.guide_seq ?: ""
    )

    // Display outputs
    CRISPRESSO2.out.html.view { "CRISPResso HTML: ${it}" }
    RESULTS_SUMMARY.out.summary_csv.view { "Results CSV: ${it}" }
}

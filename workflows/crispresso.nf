/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { NANOPLOT               } from '../modules/local/nanoplot/main'
include { NANOFILT               } from '../modules/local/nanofilt/main'
include { CRISPRESSO2            } from '../modules/nf-core/crispresso2/main'
include { RESULTS_SUMMARY        } from '../modules/local/results_summary'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_crispresso_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CRISPRESSO {

    take:
    ch_samplesheet // channel: samplesheet read in from --input (now simplified)
    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    ch_qc_for_summary = Channel.empty()

    if (params.platform == 'nanopore') {
        //
        // MODULE: Run NanoPlot for nanopore QC
        //
        NANOPLOT (
            ch_samplesheet
        )
        ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT.out.stats.collect{it[1]})
        ch_versions = ch_versions.mix(NANOPLOT.out.versions.first())
        ch_qc_for_summary = NANOPLOT.out.stats.collect{it[1]}

        //
        // MODULE: Optional NanoFilt filtering
        //
        if (params.nanofilt_quality || params.nanofilt_length || params.nanofilt_maxlength) {
            NANOFILT (
                ch_samplesheet
            )
            ch_reads_for_crispresso = NANOFILT.out.reads
            ch_versions = ch_versions.mix(NANOFILT.out.versions.first())
        } else {
            ch_reads_for_crispresso = ch_samplesheet
        }

        //
        // MODULE: Run CRISPResso2 on (optionally filtered) reads
        //
        CRISPRESSO2 (
            ch_reads_for_crispresso,
            params.amplicon_seq ?: "",
            params.guide_seq ?: ""
        )
        ch_multiqc_files = ch_multiqc_files.mix(CRISPRESSO2.out.html.collect{it[1]})
        ch_versions = ch_versions.mix(CRISPRESSO2.out.versions.first())

    } else {
        //
        // MODULE: Run FastQC (Illumina)
        //
        FASTQC (
            ch_samplesheet
        )
        ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
        ch_versions = ch_versions.mix(FASTQC.out.versions.first())
        ch_qc_for_summary = FASTQC.out.zip.collect{it[1]}

        //
        // MODULE: Run CRISPResso2
        //
        CRISPRESSO2 (
            ch_samplesheet,
            params.amplicon_seq ?: "",
            params.guide_seq ?: ""
        )
        ch_multiqc_files = ch_multiqc_files.mix(CRISPRESSO2.out.html.collect{it[1]})
        ch_versions = ch_versions.mix(CRISPRESSO2.out.versions.first())
    }

    //
    // MODULE: Create Results Summary CSV
    //
    RESULTS_SUMMARY (
        CRISPRESSO2.out.results,
        ch_qc_for_summary,
        params.amplicon_seq ?: "",
        params.guide_seq ?: "",
        params.platform
    )
    ch_versions = ch_versions.mix(RESULTS_SUMMARY.out.versions.first())

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'crispresso_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )

    emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

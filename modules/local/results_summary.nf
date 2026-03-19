process RESULTS_SUMMARY {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "biocontainers/python:3.8.3"

    input:
    tuple val(meta), path(crispresso_output)
    path qc_data
    val amplicon_seq
    val guide_seq
    val platform

    output:
    tuple val(meta), path("${prefix}_summary.csv"),               emit: summary_csv
    tuple val(meta), path("${prefix}_detailed_results.csv"),     emit: detailed_csv
    tuple val(meta), path("${prefix}_reference_info.csv"),       emit: reference_csv
    path "versions.yml",                                         emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    crispresso_dir = crispresso_output.find { it.isDirectory() } ?: ""
    def amplicon_sequence = meta.amplicon_seq ?: amplicon_seq ?: ""
    def guide_sequence = meta.guide_seq ?: guide_seq ?: ""
    def qc_arg = platform == 'nanopore' ? "--nanostats ${qc_data}" : "--fastqc_zip ${qc_data}"
    """
    create_results_summary.py \\
        --crispresso_dir ${crispresso_dir} \\
        ${qc_arg} \\
        --platform ${platform} \\
        --sample_id ${meta.id} \\
        --amplicon_seq "${amplicon_sequence}" \\
        --guide_seq "${guide_sequence}" \\
        --output_prefix ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_summary.csv
    touch ${prefix}_detailed_results.csv
    touch ${prefix}_reference_info.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}

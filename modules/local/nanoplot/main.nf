process NANOPLOT {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoplot:1.42.0--pyhdfd78af_0' :
        'biocontainers/nanoplot:1.42.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*NanoPlot-report.html"), emit: html
    tuple val(meta), path("*NanoStats.txt"),        emit: stats
    path "versions.yml",                            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    NanoPlot \\
        ${args} \\
        --threads ${task.cpus} \\
        --fastq ${reads} \\
        --prefix ${prefix}_ \\
        -o .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoplot: \$(NanoPlot --version | sed 's/NanoPlot //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_NanoPlot-report.html
    touch ${prefix}_NanoStats.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoplot: 1.42.0
    END_VERSIONS
    """
}

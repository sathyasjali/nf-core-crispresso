process NANOFILT {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanofilt:2.8.0--py_0' :
        'biocontainers/nanofilt:2.8.0--py_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_filtered.fastq.gz"), emit: reads
    path "versions.yml",                          emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gunzip -c ${reads} | NanoFilt ${args} | gzip > ${prefix}_filtered.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanofilt: \$(NanoFilt --version 2>&1 | sed 's/NanoFilt //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_filtered.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanofilt: 2.8.0
    END_VERSIONS
    """
}

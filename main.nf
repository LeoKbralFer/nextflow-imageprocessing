#!/usr/bin/env nextflow

// Diretórios das imagens de entrada e saída
params.pooping_dir = "db/pooping"
params.not_pooping_dir = "db/not_pooping"

// Criando canais para as imagens originais (excluindo as que já tem prefixo aug_)
pooping_images = Channel.fromPath("${params.pooping_dir}/*.jpg")
    .filter { !it.name.startsWith('aug_') }

not_pooping_images = Channel.fromPath("${params.not_pooping_dir}/*.jpg")
    .filter { !it.name.startsWith('aug_') }

// Processo de aumento de imagem com múltiplas transformações
process augment_pooping {
    publishDir "${params.pooping_dir}", mode: 'copy'

    input:
    path image

    output:
    path "aug_rot_${image.baseName}.jpg"
    path "aug_flip_${image.baseName}.jpg"
    path "aug_zoom_${image.baseName}.jpg"

    script:
    """
    # Rotação de 15 graus
    convert $image -rotate 15 "aug_rot_${image.baseName}.jpg"
    
    # Espelhamento horizontal
    convert $image -flop "aug_flip_${image.baseName}.jpg"
    
    # Zoom de 1.5x
    convert $image -resize 150% "aug_zoom_${image.baseName}.jpg"
    """
}

process augment_not_pooping {
    publishDir "${params.not_pooping_dir}", mode: 'copy'

    input:
    path image

    output:
    path "aug_rot_${image.baseName}.jpg"
    path "aug_flip_${image.baseName}.jpg"
    path "aug_zoom_${image.baseName}.jpg"

    script:
    """
    # Rotação de 15 graus
    convert $image -rotate 15 "aug_rot_${image.baseName}.jpg"
    
    # Espelhamento horizontal
    convert $image -flop "aug_flip_${image.baseName}.jpg"
    
    # Zoom de 1.5x
    convert $image -resize 150% "aug_zoom_${image.baseName}.jpg"
    """
}

workflow {
    // Executando os processos de augmentação para cada pasta
    augment_pooping(pooping_images)
    augment_not_pooping(not_pooping_images)
}

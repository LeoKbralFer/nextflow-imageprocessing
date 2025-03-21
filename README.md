# nextflow-imageprocessing

Este fluxo de trabalho foi desenvolvido para um projeto de processamento de imagens voltado para a detecção de cães fazendo necessidades (fezes). O principal objetivo é aumentar a quantidade e diversidade do banco de imagens por meio de técnicas de aumento de imagem, o que contribui para melhorar a acurácia e robustez de modelos de aprendizado de máquina. Ao ampliar o banco de dados com imagens variadas, o modelo se torna mais capaz de identificar quando os cães estão realizando essas ações, mesmo em diferentes condições e variações nas imagens.

O sistema final será integrado a um sistema embarcado para diversas funções, como a aplicação automática de multas em condomínios e outras aplicações de monitoramento em tempo real. Esse tipo de automação pode ser útil para a gestão de espaços públicos ou privados, garantindo o cumprimento das regras e proporcionando um ambiente mais limpo e organizado.

Este fluxo de trabalho utiliza o **Nextflow** para realizar o aumento de imagens em duas categorias: "pooping" e "not_pooping". Ele aplica três transformações de imagem em cada arquivo dentro de suas respectivas pastas, gerando versões aumentadas das imagens para melhorar a generalização em modelos de aprendizado de máquina.

## Estrutura do Projeto

O fluxo de trabalho é composto por:

### Diretórios de Entrada
- **pooping**: Contém imagens da classe "pooping".
- **not_pooping**: Contém imagens da classe "not_pooping".

### Transformações de Imagem
Três transformações são aplicadas em cada imagem:
- **Rotação**: A imagem é rotacionada em 15 graus.
- **Espelhamento**: A imagem é espelhada horizontalmente.
- **Zoom**: A imagem é aumentada em 1,5x.

### Arquivos de Saída
Para cada imagem de entrada, três novas imagens são geradas:
- `aug_rot_<nome>.jpg`: Imagem rotacionada.
- `aug_flip_<nome>.jpg`: Imagem espelhada.
- `aug_zoom_<nome>.jpg`: Imagem com zoom.

## Requisitos

- **Nextflow**: O Nextflow é um framework para executar fluxos de trabalho de bioinformática e outras áreas. Para instalar, siga as instruções em [Nextflow Installation Guide](https://www.nextflow.io/docs/latest/getstarted.html).
- **ImagemMagick**: Este script usa a ferramenta **ImageMagick** (usando o comando `convert`) para manipulação das imagens. Para instalar o ImageMagick, siga as instruções em [ImageMagick Installation](https://imagemagick.org/script/download.php).

## Como Usar

### Instalar as Dependências
Certifique-se de ter o **Nextflow** e o **ImageMagick** instalados.

- Para instalar o Nextflow, use o comando:

```bash
curl -s https://get.nextflow.io | bash
```

- Para instalar o ImageMagick, use:

```bash
sudo apt-get install imagemagick
```

### Organizar os Arquivos
Coloque as imagens de entrada nas pastas `pooping` e `not_pooping`, com o formato `.jpg`. As imagens que já possuem o prefixo `aug_` (geradas previamente) serão ignoradas na transformação.

### Executar o Fluxo de Trabalho
No terminal, execute o comando abaixo na raiz do seu projeto, onde o script **Nextflow** está localizado:

```bash
nextflow run seu_script.nf
```

### Evitar Reprocessamento de Imagens Já Aumentadas
Se você já executou o fluxo de trabalho anteriormente e deseja evitar o reprocessamento das imagens que já foram aumentadas (ou seja, aquelas com o prefixo `aug_`), basta rodar o fluxo de trabalho com a opção `-resume`. Isso fará com que o Nextflow detecte os arquivos de saída existentes e não reprocessará as imagens já transformadas.

Para usar a opção `-resume`, execute o comando:

```bash
nextflow run seu_script.nf -resume
```

### Saídas
As imagens aumentadas (com as transformações) serão geradas nas respectivas pastas `pooping` ou `not_pooping`, com os seguintes nomes:
- `aug_rot_<nome>.jpg`
- `aug_flip_<nome>.jpg`
- `aug_zoom_<nome>.jpg`

## Explicação do Fluxo de Trabalho

O script é dividido em três partes principais:

### 1. Definição dos Diretórios de Entrada

```groovy
params.pooping_dir = "pooping"
params.not_pooping_dir = "not_pooping"
```

- **pooping_dir**: Diretório contendo as imagens da classe "pooping".
- **not_pooping_dir**: Diretório contendo as imagens da classe "not_pooping".

### 2. Criação dos Canais de Imagens

O Nextflow usa canais para conectar processos. O canal `pooping_images` contém as imagens no diretório `pooping`, enquanto o canal `not_pooping_images` contém as imagens no diretório `not_pooping`. Ambos os canais ignoram imagens que já possuem o prefixo `aug_`.

```groovy
pooping_images = Channel.fromPath("${params.pooping_dir}/*.jpg")
    .filter { !it.name.startsWith('aug_') }

not_pooping_images = Channel.fromPath("${params.not_pooping_dir}/*.jpg")
    .filter { !it.name.startsWith('aug_') }
```

### 3. Processos de Aumento de Imagem

Existem dois processos: `augment_pooping` e `augment_not_pooping`. Ambos seguem a mesma estrutura de transformação, com entrada de imagem, aplicação das transformações e geração de saídas.

#### Exemplo de um Processo de Aumento de Imagem:

```groovy
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
    convert $image -rotate 15 "aug_rot_${image.baseName}.jpg"
    convert $image -flop "aug_flip_${image.baseName}.jpg"
    convert $image -resize 150% "aug_zoom_${image.baseName}.jpg"
    """
}
```

- **Rotação de 15 graus**:  
  Comando: `convert $image -rotate 15 "aug_rot_${image.baseName}.jpg"`

- **Espelhamento horizontal**:  
  Comando: `convert $image -flop "aug_flip_${image.baseName}.jpg"`

- **Zoom de 1.5x**:  
  Comando: `convert $image -resize 150% "aug_zoom_${image.baseName}.jpg"`

### 4. Execução do Fluxo de Trabalho

Na última parte, o fluxo de trabalho executa os processos de aumento de imagem para as imagens dos diretórios `pooping` e `not_pooping`:

```groovy
workflow {
    augment_pooping(pooping_images)
    augment_not_pooping(not_pooping_images)
}
```

## Exemplos de Saída

Se o arquivo de entrada for `pooping/exemplo.jpg`, as saídas serão:
- `pooping/aug_rot_exemplo.jpg`
- `pooping/aug_flip_exemplo.jpg`
- `pooping/aug_zoom_exemplo.jpg`

# Brique iOS

O Brique é uma plataforma que viabiliza o aproveitamento de bens ociosos na universidade.

## Começando

Primeiramente, clone o repositório.

### 1 - Pré-requisitos

Para gerenciamento de bibliotecas, foi utilizado o [Carthage](https://github.com/Carthage/Carthage).

Caso o Carthage não esteja instalado, use o seguinte comando:

```
brew install carthage
```

### 2 - Instalando as dependências

Você pode utilizar o Makefile fornecido, executando o comando:

```
make carthage_update
```

Ou, se preferir:

```
carthage update --platform iOS --no-use-binaries
```

## Bibliotecas utilizadas

* `Alamofire`
	* https://github.com/Alamofire/Alamofire
	* Serviços de API rest

* `SwiftyJSON`
	* https://github.com/SwiftyJSON/SwiftyJSON
	* Tratamento de arquivos JSON recebidos da API

* `SwiftOverlays`
	* https://github.com/peterprokop/SwiftOverlays
	* Mostrar popups de carregamento

* `Hero`
	* https://github.com/HeroTransitions/Hero
	* Transições customizadas

## Em caso de dúvidas

* Augusto Boranga (aboranga@inf.ufrgs.br)

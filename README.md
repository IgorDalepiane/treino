# Treino

Ficha PPL do Igor. Repo **público**: HTML no GitHub Pages + app iOS nativo.

- HTML (academia / 4G): **https://igordalepiane.github.io/treino/**
- App iPhone: `ios/Treino` (SwiftUI). Pesos ficam no aparelho.

Contexto pessoal (saúde, rotina, notas) fica no repo **privado** `personal-records`, não aqui.

## HTML (Safari / Tela de Início)

Pesos ficam no Safari deste iPhone (`localStorage`). JSON de export/import é o mesmo formato do app nativo.

Execução: loops frente/lado do MuscleWiki no próprio app (a página deles não abre em iframe).

No Safari (bússola, não o ícone da Tela de Início). Tem que aparecer **v6** ao lado de Treino: https://igordalepiane.github.io/treino/?v=6

Em casa, no Mac (opcional):

```bash
python3 serve.py
```

`http://IP-DO-MAC:3850` só funciona no Wi-Fi de casa.

## App iOS

```bash
cd ios/Treino
xcodebuild -scheme Treino -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build build
```

No iPhone: abra `ios/Treino/Treino.xcodeproj` no Xcode, Team em Signing (Automatic), plugue o aparelho, rode.

Detalhes e XCUITest: `ios/README.md`.

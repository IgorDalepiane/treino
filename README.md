# Treino

Ficha PPL do Igor. Repo **público**: HTML no GitHub Pages + app iOS nativo.

- HTML (academia / 4G): **https://igordalepiane.github.io/treino/**
- App iPhone: `ios/Treino` (SwiftUI). Pesos ficam no aparelho.

Contexto pessoal (saúde, rotina, notas) fica no repo **privado** `personal-records`, não aqui.

## HTML (Safari / Tela de Início)

JSON de export/import: pesos (`sessions`) + checks da dieta (`diet`). Versão 1 (só sessions) ainda importa.

Execução: loops frente/lado do MuscleWiki no próprio app (a página deles não abre em iframe).

No Safari (bússola, não o ícone da Tela de Início). Tem que aparecer **v7** ao lado de Treino: https://igordalepiane.github.io/treino/?v=7

No topo: **Treino** | **Dieta**. Abre em Treino (academia). Dieta é timeline do dia + marcar feito; entra no mesmo JSON de export/import.

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

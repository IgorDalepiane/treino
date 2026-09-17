# Treino (iPhone)

App pessoal do Igor. Ficha PPL, último peso/reps por série, vídeo MuscleWiki in-app. Sem tracker.

## Rodar no simulador

Na raiz deste repo:

```bash
cd ios/Treino
xcodebuild -scheme Treino -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build build
xcrun simctl boot "iPhone 17" || true
open -a Simulator
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Treino.app
xcrun simctl launch booted com.igordalepiane.treino
```

## Rodar no iPhone

Abra `ios/Treino/Treino.xcodeproj` no Xcode, escolha **seu** Team em Signing (Automatic), plugue o iPhone, rode.

Os pesos ficam em Application Support no aparelho. Exportar JSON pelo botão de compartilhar no canto.

## Testar (simulador)

Playwright não cobre SwiftUI. O equivalente aqui é XCUITest no Simulator:

```bash
cd ios/Treino
xcodebuild test -scheme Treino -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build \
  -only-testing:TreinoUITests/TreinoUITests/testNavigateAnyDayAndPersistWeight
```

Sobe o iPhone 17, navega terça/quarta/sexta, grava kg, abre execução, fecha o app e confere que o peso continua.

## Sem o Xcode (HTML)

**https://igordalepiane.github.io/treino/**

Safari → Compartilhar → Adicionar à Tela de Início. Pesos ficam no iPhone, não no GitHub.

Em casa: `python3 serve.py` na raiz deste repo → `http://IP-DO-MAC:3850` (só na Wi-Fi de casa).

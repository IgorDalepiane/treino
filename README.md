# Treino (HTML)

Versão web da mesma ficha do app iOS. **Não substitui** `ios/Treino`.

Pesos ficam no Safari deste iPhone (`localStorage`). JSON de export/import é o mesmo formato do app nativo.

Execução: loops frente/lado do MuscleWiki no próprio app (a página deles não abre em iframe).

## Na academia (4G)

URL pública (só a ficha, sem os pesos):

**https://igordalepiane.github.io/treino/**

Safari → essa URL → Compartilhar → **Adicionar à Tela de Início**.

## Em casa, no Mac (opcional)

```bash
python3 web/treino/serve.py
```

`http://IP-DO-MAC:3850` só funciona no Wi-Fi de casa.

## O que o HTML faz

Semana, qualquer dia, kg/reps por variação, último treino daquela variação, teclado numérico com valor selecionado, execução MuscleWiki, exportar JSON.

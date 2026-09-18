window.Diet = (() => {
  const cafeCarbs = [
    "1 fatia de pão OU ½ cacetinho (máx. 1 fatia no dia, só no café)",
    "80 g batata doce",
    "1 col. sopa farelo de aveia",
    "1 col. sopa goma de tapioca",
    "1 col. sopa farelo de aveia OU granola",
    "1 fatia fina de bolo",
    "1 fruta (porção da tabela)",
    "1 col. sobremesa de mel",
  ];
  const cafeProtein = [
    "1 ovo",
    "1 fatia muçarela",
    "1 col. sopa pasta de amendoim",
    "200 ml leite sem lactose semidesnatado",
    "100 ml iogurte natural OU 200 ml triplo zero",
    "80 g frango desfiado",
    "1 col. sopa requeijão",
    "15 g whey",
  ];
  const lunchProtein = [
    "Frango, gado, peixe, atum, porco, moída, desfiado (~80 g cozida cada; escolhe DUAS)",
    "Grão: feijão, lentilha, ervilha OU grão-de-bico (~80 g)",
    "Cogumelo 150 g",
  ];
  const lunchCarboDefault = [
    "Batata, batata doce, aipim, inhame, mandioquinha, moranga (~80 g cozido) — default",
  ];
  const lunchCarboSometimes = [
    "Arroz, massa, polenta — às vezes, não todo dia",
  ];
  const teaOpts = [
    "1 col. sopa oleaginosas",
    "1 col. sopa pasta de amendoim ou requeijão",
    "200 ml leite sem lactose",
    "100 ml iogurte natural OU 200 ml triplo zero",
    "15 g whey",
    "1 col. sopa granola",
    "1 fruta",
    "2 bolachas de arroz (risca se for gatilho de belisco)",
  ];
  const fruitNote = "Porção: maçã/banana peq., laranja média, 3 col. abacate, 12 morangos, 1 cacho uva peq., etc.";

  const L = {
    cafe: { title: "2 carbos + 3 proteínas", groups: [
      { name: "Carbos", items: cafeCarbs },
      { name: "Proteínas", items: cafeProtein },
    ]},
    almoco: { title: "Salada + 2 proteínas + 1 carbo", groups: [
      { name: "Salada", items: ["Começa por ela. Meio prato, 3 tipos, azeite. Sem suco/refri/fritura. Máx. ~200 ml água na refeição."] },
      { name: "Proteínas", items: lunchProtein },
      { name: "Carbo default", items: lunchCarboDefault },
      { name: "Carbo às vezes", items: lunchCarboSometimes },
    ]},
    jantar: { title: "Salada + 80 g carbo + 160 g proteína OU 4 ovos  ·  ou 1 crepioca", groups: [
      { name: "Montar", items: ["Mesmas opções do almoço. Capricha na salada."] },
    ]},
    ceia: { title: "Chá + no máx. 2 itens (~150 kcal). Só se tiver fome.", groups: [
      { name: "Opções", items: teaOpts },
      { name: "Fruta", items: [fruitNote] },
    ]},
  };

  const meal = (id, time, title, blurb, listKey) => ({ id, time, title, blurb, listKey: listKey || null });
  const note = (text) => ({ kind: "note", text });

  const wake = meal("wake", "Ao acordar", "Creatina", "250 ml água + 5 g creatina. Sem loading.", null);
  const tea = meal("tea", "~22:30", "Ceia (opcional)", "Chá camomila/melissa/cidreira. Zero pão, bolacha, jantar 2.", "ceia");
  const breakfastHome = meal("breakfast", "~10:00", "Café da manhã", "Completo. Máx. 1 fatia de pão no dia.", "cafe");
  const breakfastGym = meal("breakfast", "~10:30", "Café da manhã", "Antes da academia 12h. Máx. 1 fatia de pão no dia.", "cafe");
  const lunchHome = meal("lunch", "~12:15", "Almoço", "Em casa. Salada primeiro.", "almoco");
  const lunchGym = meal("lunch", "~13:15", "Almoço", "Marmita em casa depois da academia.", "almoco");
  const snack = meal("snack", "15:30–16:00", "Lanche", "Estilo café (2 carbos + 3 proteínas), mais leve. Extra se beliscar: 1 fruta OU 3 Polenghinhos — sem bolacha.", "cafe");
  const snackPreRun = meal("snack", "15:30–16:00", "Lanche · pré-corrida", "Fruta + whey ou aveia. Sem pão. Depois corre (após 17:30).", "cafe");
  const dinner20 = meal("dinner", "~20:00", "Jantar", "Salada + carbo raiz + proteína.", "jantar");
  const dinnerVolei = meal("dinner", "~20:00", "Jantar · antes do vôlei", "Vôlei 21h. Salada + carbo + proteína.", "jantar");
  const dinnerThu = meal("dinner", "18:30–19:00", "Jantar · antes do vôlei", "Vôlei 20h. Come mais cedo.", "jantar");
  const dinnerSun = meal("dinner", "~20:00", "Jantar · depois da missa", "Voltou da missa. Não empilha lanche da igreja + jantar 2.", "jantar");

  const gymDay = [wake, breakfastGym, lunchGym, snack, dinner20, tea];

  const byDow = {
    0: [wake, breakfastHome, lunchHome, dinnerSun, tea],
    1: [wake, breakfastHome, lunchHome, snack, dinnerVolei, tea],
    2: gymDay,
    3: [wake, breakfastHome, lunchHome, snackPreRun, dinner20, tea],
    4: [wake, lunchHome, snack, dinnerThu, tea],
    5: gymDay,
    6: gymDay,
  };

  const banners = {
    0: "Corrida ~14h–15:30 (depois do almoço). Missa 18:30–20h. Sem jejum. Se fome pós-corrida: 1 fruta ou whey, não pão.",
    1: "Vôlei 21h. Sem academia.",
    2: "Pull 12h. Sem jejum. Almoço depois do treino.",
    3: "Corrida depois das 17:30. Lanche 15:30 é o pré-treino. Sem jejum.",
    4: "Jejum até o almoço. Creatina + água (chimarrão/café sem açúcar ok). Sem café da manhã.",
    5: "Pernas 12h. Sem jejum. Almoço depois do treino.",
    6: "Push. Relógio igual ter/sex. Se treinar 8h, o café é ao acordar — marca o mesmo bloco.",
  };

  const rules = [
    "Creatina 5 g ao acordar. Água ~1 L manhã + ~1 L tarde.",
    "Carbo das refeições grandes: batata/raiz/moranga. Arroz/massa/pão às vezes.",
    "Pão: no máx. 1 fatia no café. De noite zero.",
    "Máx. 5 ovos/dia. Leite sem lactose.",
    "Jejum 15–16 h só quinta.",
    "Evento/igreja: uma refeição solta; volta no próximo horário.",
  ];

  return {
    L,
    rules,
    meals: (jsDow) => byDow[jsDow] || byDow[1],
    banner: (jsDow) => banners[jsDow] || "",
  };
})();

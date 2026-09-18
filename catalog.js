window.Catalog = (() => {
  const WEEKDAYS = ["domingo", "segunda", "terça", "quarta", "quinta", "sexta", "sábado"];
  const mw = (slug) => `https://musclewiki.com/pt-br/exercise/${slug}`;
  const opt = (id, name, kind, slug) => ({ id, name, kind, slug, url: mw(slug) });
  const slot = (id, prescription, setCount, isWarmup, note, main, variants = []) => ({
    id, prescription, setCount, isWarmup, note, main, variants, options: [main, ...variants],
  });
  const programs = {
    pull: {
      id: "pull", name: "Pull", tag: "Terça · 12h",
      summary: "Costas + bíceps. 3×8–12, parar 1–2 reps antes da falha.",
      note: "Ombro: rotação externa no aquecimento, lado direito em cima, amplitude sem dor.",
      accent: "pull",
      slots: [
        slot("pull-warmup", "3×12–15", 3, true, "1–2 kg. Lado direito em cima.", opt("pull-warmup-main", "Rotação externa deitado", "livre", "dumbbell-external-rotation")),
        slot("pull-pulldown", "3×8–12", 3, false, null, opt("pull-pulldown-main", "Puxada frente barra longa", "máquina", "machine-pulldown"), [
          opt("pull-pulldown-v1", "Puxada na máquina", "máquina", "machine-plate-loaded-pulldown"),
          opt("pull-pulldown-v2", "Barra fixa", "corpo", "pull-ups"),
          opt("pull-pulldown-v3", "Pullover com halter", "livre", "dumbbell-pullover"),
        ]),
        slot("pull-row", "3×8–12", 3, false, null, opt("pull-row-main", "Remada máquina peito apoiado", "máquina", "machine-chest-supported-t-bar-row"), [
          opt("pull-row-v1", "Remada polia baixa", "cabo", "machine-seated-cable-row"),
          opt("pull-row-v2", "Remada cavalinho", "livre", "dumbbell-row-unilateral"),
          opt("pull-row-v3", "Remada curvada com barra", "livre", "barbell-pronated-row"),
        ]),
        slot("pull-neutral", "3×8–12", 3, false, null, opt("pull-neutral-main", "Puxada triângulo", "máquina", "neutral-pulldown"), [
          opt("pull-neutral-v1", "Puxada frente", "máquina", "machine-pulldown"),
          opt("pull-neutral-v2", "Barra fixa", "corpo", "pull-ups"),
          opt("pull-neutral-v3", "Pullover com halter", "livre", "dumbbell-pullover"),
        ]),
        slot("pull-face", "3×12–15", 3, false, null, opt("pull-face-main", "Face pull", "cabo", "machine-face-pulls"), [
          opt("pull-face-v1", "Peck-deck inverso", "máquina", "machine-reverse-fly"),
          opt("pull-face-v2", "Crucifixo inverso halteres", "livre", "dumbbell-rear-delt-fly"),
          opt("pull-face-v3", "Crucifixo inverso no cabo", "cabo", "cable-high-single-arm-rear-delt-fly"),
        ]),
        slot("pull-curl", "3×8–12", 3, false, null, opt("pull-curl-main", "Rosca direta halteres", "livre", "dumbbell-curl"), [
          opt("pull-curl-v1", "Rosca na polia", "cabo", "cable-bar-curl"),
          opt("pull-curl-v2", "Rosca com barra", "livre", "barbell-curl"),
          opt("pull-curl-v3", "Rosca martelo", "livre", "dumbbell-hammer-curl"),
        ]),
        slot("pull-hammer", "3×8–12", 3, false, null, opt("pull-hammer-main", "Rosca martelo", "livre", "dumbbell-hammer-curl"), [
          opt("pull-hammer-v1", "Rosca direta", "livre", "dumbbell-curl"),
          opt("pull-hammer-v2", "Rosca na polia", "cabo", "cable-bar-curl"),
          opt("pull-hammer-v3", "Rosca com barra", "livre", "barbell-curl"),
        ]),
      ],
    },
    legs: {
      id: "legs", name: "Pernas", tag: "Sexta · 12h",
      summary: "Sai andando, não mancando. Sem panturrilha pesada.",
      note: "Uma sessão de força. Já tem 2 vôlei + 2 corrida.",
      accent: "legs",
      slots: [
        slot("legs-press", "3×8–12", 3, false, null, opt("legs-press-main", "Leg press 45°", "máquina", "machine-leg-press"), [
          opt("legs-press-v1", "Hack squat", "máquina", "machine-hack-squat"),
          opt("legs-press-v2", "Agachamento goblet", "livre", "dumbbell-goblet-squat"),
          opt("legs-press-v3", "Agachamento com barra", "livre", "barbell-squat"),
        ]),
        slot("legs-rdl", "3×8–12", 3, false, null, opt("legs-rdl-main", "Stiff / RDL com halteres", "livre", "dumbbell-romanian-deadlift"), [
          opt("legs-rdl-v1", "Stiff com barra", "livre", "barbell-stiff-leg-deadlifts"),
          opt("legs-rdl-v2", "Mesa flexora", "máquina", "machine-hamstring-curl"),
          opt("legs-rdl-v3", "Cadeira flexora", "máquina", "machine-seated-leg-curl"),
        ]),
        slot("legs-ext", "3×10–12", 3, false, null, opt("legs-ext-main", "Cadeira extensora", "máquina", "machine-leg-extension"), [
          opt("legs-ext-v1", "Avanço / lunge", "livre", "dumbbell-goblet-reverse-lunge"),
          opt("legs-ext-v2", "Agachamento búlgaro", "livre", "barbell-bulgarian-split-squat"),
          opt("legs-ext-v3", "Hack squat", "máquina", "machine-hack-squat"),
        ]),
        slot("legs-curl", "3×8–12", 3, false, null, opt("legs-curl-main", "Mesa flexora", "máquina", "machine-hamstring-curl"), [
          opt("legs-curl-v1", "Cadeira flexora", "máquina", "machine-seated-leg-curl"),
          opt("legs-curl-v2", "Avanço / lunge", "livre", "dumbbell-goblet-reverse-lunge"),
          opt("legs-curl-v3", "Agachamento búlgaro", "livre", "barbell-bulgarian-split-squat"),
        ]),
        slot("legs-glute", "3×10–12", 3, false, null, opt("legs-glute-main", "Elevação pélvica", "livre", "dumbbell-glute-bridge"), [
          opt("legs-glute-v1", "Hip thrust com barra", "livre", "barbell-hip-thrust"),
          opt("legs-glute-v2", "Hip thrust com halter", "livre", "dumbbell-hip-thrust"),
          opt("legs-glute-v3", "Agachamento goblet", "livre", "dumbbell-goblet-squat"),
        ]),
      ],
    },
    push: {
      id: "push", name: "Push · peito", tag: "Sábado · 8h",
      summary: "Inclinação primeiro. Sem push pesado no dia do vôlei nem no dia seguinte.",
      note: "Ombro: mesma rotação externa 3×12–15 no aquecimento. Se puxar, encurta amplitude e segue.",
      accent: "push",
      slots: [
        slot("push-warmup", "3×12–15", 3, true, "1–2 kg. Lado direito em cima.", opt("push-warmup-main", "Rotação externa deitado", "livre", "dumbbell-external-rotation")),
        slot("push-incline", "3×8–12", 3, false, null, opt("push-incline-main", "Supino inclinado halteres", "livre", "dumbbell-incline-bench-press"), [
          opt("push-incline-v1", "Supino inclinado com barra", "livre", "barbell-high-incline-bench-press"),
          opt("push-incline-v2", "Crossover baixo → cima", "cabo", "cable-standing-single-arm-incline-chest-fly"),
          opt("push-incline-v3", "Flexão de braço", "corpo", "push-up"),
        ]),
        slot("push-pec", "3×8–12", 3, false, null, opt("push-pec-main", "Peck-deck", "máquina", "machine-pec-fly"), [
          opt("push-pec-v1", "Supino reto com halteres", "livre", "dumbbell-bench-press"),
          opt("push-pec-v2", "Crucifixo com halteres", "livre", "dumbbell-chest-fly"),
          opt("push-pec-v3", "Crossover", "cabo", "cable-standing-single-arm-incline-chest-fly"),
        ]),
        slot("push-ohp", "3×8–12", 3, false, null, opt("push-ohp-main", "Desenvolvimento halteres", "livre", "dumbbell-seated-overhead-press"), [
          opt("push-ohp-v1", "Desenvolvimento na máquina", "máquina", "machine-neutral-overhead-press"),
          opt("push-ohp-v2", "Desenvolvimento militar", "livre", "barbell-overhead-press"),
          opt("push-ohp-v3", "Landmine press", "livre", "landmine-overhead-press"),
        ]),
        slot("push-lateral", "3×10–15", 3, false, null, opt("push-lateral-main", "Elevação lateral", "livre", "seated-lateral-raise"), [
          opt("push-lateral-v1", "Elevação lateral na polia", "cabo", "cable-low-bilateral-lateral-raise"),
          opt("push-lateral-v2", "Elevação lateral na máquina", "máquina", "machine-standing-lateral-raise"),
          opt("push-lateral-v3", "Elevação lateral em pé", "livre", "dumbbell-lateral-raise"),
        ]),
        slot("push-skull", "3×8–12", 3, false, null, opt("push-skull-main", "Tríceps testa ou barra W", "livre", "barbell-skullcrusher"), [
          opt("push-skull-v1", "Tríceps francês no cabo", "cabo", "cable-rope-skullcrusher"),
          opt("push-skull-v2", "Tríceps coice", "livre", "dumbbell-tricep-kickback"),
          opt("push-skull-v3", "Flexão de braço", "corpo", "push-up"),
        ]),
        slot("push-pushdown", "3×8–12", 3, false, null, opt("push-pushdown-main", "Tríceps corda", "cabo", "cable-rope-pushdown"), [
          opt("push-pushdown-v1", "Tríceps testa / barra W", "livre", "barbell-skullcrusher"),
          opt("push-pushdown-v2", "Tríceps coice", "livre", "dumbbell-tricep-kickback"),
          opt("push-pushdown-v3", "Tríceps francês no cabo", "cabo", "cable-rope-skullcrusher"),
        ]),
      ],
    },
  };
  const week = [
    { id: 1, shortName: "Seg", title: "Vôlei", subtitle: "21:00 · areia", body: "Sem academia, sem corrida. Depois do longão de domingo.", kind: "info", accent: "volei" },
    { id: 2, shortName: "Ter", title: "Pull", subtitle: "12:00 · academia", body: "Costas + bíceps.", kind: "gym", programId: "pull", accent: "pull" },
    { id: 3, shortName: "Qua", title: "Corrida fácil", subtitle: "depois 17:30 · Runna", body: "Depois do trabalho. Volume e ritmo ficam no Runna. Sem academia nesse dia — mas você pode abrir o Pull, Pernas ou Push se quiser treinar.", kind: "info", accent: "run" },
    { id: 4, shortName: "Qui", title: "Vôlei", subtitle: "20:00 · areia", body: "Sem academia. Quarta foi só corrida.", kind: "info", accent: "volei" },
    { id: 5, shortName: "Sex", title: "Pernas", subtitle: "12:00 · academia", body: "Sai andando, não mancando. Sem panturrilha pesada.", kind: "gym", programId: "legs", accent: "legs" },
    { id: 6, shortName: "Sáb", title: "Push · peito", subtitle: "8:00–9:30", body: "Melhor dia de peito: longe do vôlei. Inclinação primeiro.", kind: "gym", programId: "push", accent: "push" },
    { id: 0, shortName: "Dom", title: "Corrida longa", subtitle: "14h–15:30 · missa 18:30", body: "Qualidade no Runna. Sem academia. Não correr sábado nem segunda. Missa 18:30–20h.", kind: "info", accent: "run" },
  ];
  const orderedWeek = [1, 2, 3, 4, 5, 6, 0].map((id) => week.find((d) => d.id === id));
  return {
    WEEKDAYS,
    programs,
    week,
    orderedWeek,
    jsWeekday: (date = new Date()) => date.getDay(),
    program: (id) => programs[id] || programs.pull,
    day: (id) => week.find((d) => d.id === id) || week[0],
    pill(d) {
      if (d.kind === "gym") return d.programId === "push" ? "Push" : this.program(d.programId).name;
      return d.accent === "run" ? "Run" : "Vôlei";
    },
  };
})();

(() => {
  const KEY = "treino.gym.v1";
  const PICK_KEY = "treino.picked.v1";
  const C = window.Catalog;
  const $ = (sel, el = document) => el.querySelector(sel);
  const uuid = () => (crypto.randomUUID ? crypto.randomUUID() : `id-${Date.now()}-${Math.random()}`);

  const todayStr = () => {
    const d = new Date();
    const p = (n) => String(n).padStart(2, "0");
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
  };
  const pretty = (ymd) => {
    const [, m, d] = ymd.split("-");
    return `${d}/${m}`;
  };
  const formatKg = (v) => {
    if (v === Math.round(v)) return String(Math.round(v));
    return String(v).replace(".", ",");
  };
  const parseKg = (raw) => {
    const n = Number(String(raw).trim().replace(",", "."));
    if (!Number.isFinite(n) || n < 0) return null;
    return Math.round(n * 10) / 10;
  };

  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return { version: 1, sessions: [] };
      const data = JSON.parse(raw);
      if (!Array.isArray(data.sessions)) return { version: 1, sessions: [] };
      return data;
    } catch {
      return { version: 1, sessions: [] };
    }
  }
  function save(data) {
    localStorage.setItem(KEY, JSON.stringify({ version: 1, sessions: data.sessions }));
  }

  const store = {
    data: load(),
    session(date, programId) {
      return this.data.sessions.find((s) => s.date === date && s.programId === programId);
    },
    hasLoggedSlot(date, programId, slotId) {
      return Boolean(this.session(date, programId)?.exercises.some((e) => e.slotId === slotId));
    },
    logged(date, programId, slotId, variantId) {
      return this.session(date, programId)?.exercises.find((e) => e.slotId === slotId && e.variantId === variantId);
    },
    lastExercise(slotId, variantId, before) {
      const past = this.data.sessions
        .filter((s) => s.date < before)
        .sort((a, b) => (a.date === b.date ? (a.updatedAt < b.updatedAt ? 1 : -1) : a.date < b.date ? 1 : -1));
      for (const s of past) {
        const found = [...s.exercises].reverse().find((e) => e.slotId === slotId && e.variantId === variantId);
        if (found) return { exercise: found, date: s.date };
      }
      return null;
    },
    lastVariant(slotId) {
      const list = [...this.data.sessions].sort((a, b) =>
        a.date === b.date ? (a.updatedAt < b.updatedAt ? 1 : -1) : a.date < b.date ? 1 : -1
      );
      for (const s of list) {
        const found = [...s.exercises].reverse().find((e) => e.slotId === slotId);
        if (found) return found.variantId;
      }
      return null;
    },
    saveExercise(date, programId, slotId, variantId, sets) {
      const now = new Date().toISOString();
      let session = this.session(date, programId);
      if (!session) {
        session = { id: uuid(), date, programId, updatedAt: now, exercises: [] };
        this.data.sessions.push(session);
      }
      session.updatedAt = now;
      const idx = session.exercises.findIndex((e) => e.slotId === slotId && e.variantId === variantId);
      const row = { id: idx >= 0 ? session.exercises[idx].id : uuid(), slotId, variantId, sets };
      if (idx >= 0) session.exercises.splice(idx, 1);
      session.exercises.push(row);
      save(this.data);
    },
    importJSON(text, replaceAll) {
      const incoming = JSON.parse(text);
      if (!Array.isArray(incoming.sessions)) throw new Error("JSON inválido");
      if (replaceAll) this.data.sessions = incoming.sessions;
      else {
        const map = new Map(this.data.sessions.map((s) => [s.id, s]));
        for (const s of incoming.sessions) map.set(s.id, s);
        this.data.sessions = [...map.values()];
      }
      save(this.data);
    },
    exportJSON() {
      return JSON.stringify({ version: 1, sessions: this.data.sessions }, null, 2);
    },
  };

  function loadPicked() {
    try {
      const raw = localStorage.getItem(PICK_KEY);
      const data = raw ? JSON.parse(raw) : {};
      return data && typeof data === "object" && !Array.isArray(data) ? data : {};
    } catch {
      return {};
    }
  }

  const state = {
    selectedJsDow: C.jsWeekday(),
    picked: loadPicked(),
  };

  function setPicked(slotId, variantId) {
    state.picked[slotId] = variantId;
    localStorage.setItem(PICK_KEY, JSON.stringify(state.picked));
  }

  function pickedVariant(slot) {
    const id = state.picked[slot.id];
    if (id && slot.options.some((o) => o.id === id)) return id;
    return slot.main.id;
  }

  function selectAllOnFocus(input) {
    const pick = () => {
      input.select();
      try { input.setSelectionRange(0, input.value.length); } catch (_) {}
    };
    input.addEventListener("focus", () => setTimeout(pick, 0));
    input.addEventListener("click", pick);
    input.addEventListener("touchend", () => setTimeout(pick, 50), { passive: true });
  }

  function displayFor(slot, programId, variantId) {
    const date = todayStr();
    const todayLog = store.logged(date, programId, slot.id, variantId);
    if (todayLog) {
      return { sets: padSets(todayLog.sets, slot.setCount), caption: "Registrado hoje nesta variação", logged: true };
    }
    const last = store.lastExercise(slot.id, variantId, date);
    if (last) {
      return {
        sets: padSets(last.exercise.sets, slot.setCount),
        caption: `Última vez nesta variação ${pretty(last.date)} · edite pra gravar hoje`,
        logged: false,
      };
    }
    return {
      sets: Array.from({ length: slot.setCount }, () => ({ kg: 0, reps: 0 })),
      caption: "Primeira vez nesta variação · edite pra gravar hoje",
      logged: false,
    };
  }

  function padSets(sets, n) {
    const out = sets.map((s) => ({ kg: s.kg, reps: s.reps }));
    while (out.length < n) out.push({ kg: 0, reps: 0 });
    return out.slice(0, n);
  }

  function bindNumeric(input, onCommit) {
    selectAllOnFocus(input);
    const commit = () => onCommit(input.value);
    input.addEventListener("change", commit);
    input.addEventListener("blur", commit);
  }

  function render() {
    const root = $("#app");
    const todayJs = C.jsWeekday();
    const selected = C.day(state.selectedJsDow);
    const browsing = state.selectedJsDow !== todayJs;

    root.innerHTML = `
      <header class="top">
        <h1>Treino</h1>
        <button class="icon-btn" id="btn-data" type="button" aria-label="Exportar e importar">↑</button>
      </header>
      <nav class="week">
        ${C.orderedWeek.map((d) => `
          <button type="button" data-dow="${d.id}" class="${d.id === todayJs ? "today" : ""} ${d.id === state.selectedJsDow ? "sel" : ""}">
            <span class="dow">${d.shortName}</span>
            <span class="pill-txt accent-${d.accent}">${C.pill(d)}</span>
          </button>
        `).join("")}
      </nav>
      ${browsing ? `<div class="banner">Hoje é ${C.WEEKDAYS[todayJs]}. Isso é o plano de ${C.WEEKDAYS[state.selectedJsDow]} — pode treinar mesmo assim.</div>` : ""}
      <div class="scroll" id="main"></div>
    `;

    const main = $("#main");
    if (selected.kind === "gym") renderWorkout(main, C.program(selected.programId));
    else renderInfo(main, selected);

    root.querySelectorAll(".week button").forEach((b) => {
      b.addEventListener("click", () => {
        state.selectedJsDow = Number(b.dataset.dow);
        render();
      });
    });
    $("#btn-data").onclick = openSettings;
  }

  function openSettings() {
    $("#settings-sheet").classList.remove("hidden");
  }

  function closeSettings() {
    $("#settings-sheet").classList.add("hidden");
  }

  function openVideo(option) {
    $("#video-title").textContent = option.name;
    const player = $("#video-player");
    const files = (window.MW_VIDEOS && window.MW_VIDEOS[option.slug]) || [];
    const labels = ["Frente", "Lado"];
    const clips = files.map((file, i) => {
      const src = `https://musclewiki.com/api-next/videos/${file}`;
      return `
        <div>
          <div class="angle">${labels[i] || "Vídeo"}</div>
          <video src="${src}" playsinline webkit-playsinline muted loop autoplay controls
            referrerpolicy="no-referrer" title="${option.name}"></video>
        </div>`;
    }).join("");
    player.innerHTML = `
      ${clips || `<p class="muted">Sem loop neste exercício.</p>`}
      <p class="muted">Vídeo MuscleWiki. Execução no app; a página oficial também abre se quiser o texto.</p>
      <a href="${option.url}" target="_blank" rel="noopener">Abrir no MuscleWiki</a>
    `;
    $("#video-sheet").classList.remove("hidden");
    player.querySelectorAll("video").forEach((v) => {
      v.play().catch(() => {});
    });
  }

  function closeVideo() {
    $("#video-player").innerHTML = "";
    $("#video-sheet").classList.add("hidden");
  }

  function renderInfo(main, selected) {
    main.innerHTML = `
      <div class="card">
        <h2>${selected.title}</h2>
        <p class="muted accent-${selected.accent}" style="margin:6px 0">${selected.subtitle}</p>
        <p class="muted">${selected.body}</p>
      </div>
      <h3 class="section">Treinar agora</h3>
      <p class="muted">O plano da semana não trava o dia. Se pulou a terça, abre o Pull.</p>
      ${Object.values(C.programs).map((p) => `
        <button class="list-btn" data-open="${p.id}">
          <span>
            <strong class="accent-${p.accent}">${p.name}</strong><br>
            <span class="muted">${p.tag}</span>
          </span>
          <span class="muted">›</span>
        </button>
      `).join("")}
    `;
    main.querySelectorAll("[data-open]").forEach((b) => {
      b.onclick = () => {
        const match = C.orderedWeek.find((d) => d.programId === b.dataset.open);
        if (match) state.selectedJsDow = match.id;
        render();
      };
    });
  }

  function renderWorkout(main, program) {
    const date = todayStr();
    const next = program.slots.find((s) => !store.hasLoggedSlot(date, program.id, s.id));
    const nextName = next
      ? (next.options.find((o) => o.id === pickedVariant(next)) || next.main).name
      : "";

    main.innerHTML = `
      <div class="card">
        <div class="row">
          <h2>${program.name}</h2>
          <span class="tag accent-${program.accent}">${program.tag}</span>
        </div>
        <p class="muted" style="margin-top:6px">Registrando em ${pretty(date)} (hoje), não no dia da ficha.</p>
        <p class="muted">${program.summary}</p>
        ${program.note ? `<p class="note">${program.note}</p>` : ""}
      </div>
      ${next
        ? `<a class="next" href="#ex-${next.id}"><span><small>Próximo</small><br><strong>${nextName}</strong></span><span>↓</span></a>`
        : `<div class="done">Treino de hoje registrado. Pode fechar o app.</div>`}
      ${program.slots.map((slot) => exerciseCard(program, slot)).join("")}
    `;

    program.slots.forEach((slot) => wireCard(program, slot));
  }

  function exerciseCard(program, slot) {
    const variantId = pickedVariant(slot);
    const option = slot.options.find((o) => o.id === variantId) || slot.main;
    const view = displayFor(slot, program.id, variantId);
    return `
      <article class="card ex ${view.logged ? "logged" : ""}" id="ex-${slot.id}" data-slot="${slot.id}">
        <div class="row">
          <div>
            <div class="muted">${slot.isWarmup ? "AQUECIMENTO · " : ""}${slot.prescription}</div>
            <h2 style="font-size:1.05rem;margin-top:2px" class="ex-title">${option.name}</h2>
            ${slot.note ? `<p class="muted">${slot.note}</p>` : ""}
          </div>
          <button class="exec" data-video="${slot.id}">▶ Execução</button>
        </div>
        ${slot.variants.length ? `
          <select data-variant="${slot.id}">
            ${slot.options.map((o) => `<option value="${o.id}" ${o.id === variantId ? "selected" : ""}>${o.name} · ${o.kind}</option>`).join("")}
          </select>
        ` : ""}
        <p class="caption ${view.logged ? "ok" : "muted"}" data-caption="${slot.id}">${view.caption}</p>
        <div class="sets">
          ${view.sets.map((s, i) => `
            <div class="set">
              <b>S${i + 1}</b>
              <div class="num">
                <input inputmode="decimal" enterkeyhint="done" data-kg="${slot.id}" data-i="${i}" value="${formatKg(s.kg)}" aria-label="kg série ${i + 1}">
                <span>kg</span>
              </div>
              <div class="num">
                <input inputmode="numeric" enterkeyhint="done" data-reps="${slot.id}" data-i="${i}" value="${s.reps}" aria-label="reps série ${i + 1}">
                <span>reps</span>
              </div>
            </div>
          `).join("")}
        </div>
      </article>
    `;
  }

  function currentSets(slot) {
    const card = document.querySelector(`[data-slot="${slot.id}"]`);
    const kgs = [...card.querySelectorAll("[data-kg]")];
    const reps = [...card.querySelectorAll("[data-reps]")];
    return kgs.map((kgEl, i) => ({
      kg: parseKg(kgEl.value) ?? 0,
      reps: Math.max(0, Math.min(99, parseInt(reps[i].value, 10) || 0)),
    }));
  }

  function variantOf(slot) {
    const sel = document.querySelector(`[data-variant="${slot.id}"]`);
    return sel ? sel.value : slot.main.id;
  }

  function wireCard(program, slot) {
    const card = document.querySelector(`[data-slot="${slot.id}"]`);
    const persist = () => {
      const variantId = variantOf(slot);
      setPicked(slot.id, variantId);
      store.saveExercise(todayStr(), program.id, slot.id, variantId, currentSets(slot));
      const cap = card.querySelector("[data-caption]");
      cap.textContent = "Registrado hoje nesta variação";
      cap.classList.add("ok");
      cap.classList.remove("muted");
      card.classList.add("logged");
    };

    const applyVariant = () => {
      const variantId = variantOf(slot);
      setPicked(slot.id, variantId);
      const option = slot.options.find((o) => o.id === variantId) || slot.main;
      card.querySelector(".ex-title").textContent = option.name;
      const view = displayFor(slot, program.id, variantId);
      const kgs = [...card.querySelectorAll("[data-kg]")];
      const reps = [...card.querySelectorAll("[data-reps]")];
      view.sets.forEach((s, i) => {
        kgs[i].value = formatKg(s.kg);
        reps[i].value = String(s.reps);
      });
      const cap = card.querySelector("[data-caption]");
      cap.textContent = view.caption;
      cap.classList.toggle("ok", view.logged);
      cap.classList.toggle("muted", !view.logged);
      card.classList.toggle("logged", view.logged);
    };

    const sel = card.querySelector("[data-variant]");
    if (sel) sel.addEventListener("change", applyVariant);

    card.querySelectorAll("[data-kg]").forEach((input) => {
      bindNumeric(input, (raw) => {
        const v = parseKg(raw);
        if (v == null) return;
        input.value = formatKg(v);
        persist();
      });
    });
    card.querySelectorAll("[data-reps]").forEach((input) => {
      bindNumeric(input, (raw) => {
        const v = parseInt(String(raw).trim(), 10);
        if (!Number.isFinite(v) || v < 0) return;
        input.value = String(Math.min(99, v));
        persist();
      });
    });
    card.querySelector("[data-video]").onclick = () => {
      const variantId = variantOf(slot);
      setPicked(slot.id, variantId);
      const option = slot.options.find((o) => o.id === variantId) || slot.main;
      openVideo(option);
    };
  }

  function exportFile() {
    const blob = new Blob([store.exportJSON()], { type: "application/json" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `treino-${todayStr()}.json`;
    a.click();
    $("#data-msg").textContent = "Exportado.";
  }

  function importFile(ev) {
    const file = ev.target.files && ev.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        store.importJSON(String(reader.result), false);
        $("#data-msg").textContent = "Importado.";
        closeSettings();
        render();
      } catch (err) {
        $("#data-msg").textContent = String(err.message || err);
      }
    };
    reader.readAsText(file);
  }

  $("#video-close").onclick = closeVideo;
  $("#settings-close").onclick = closeSettings;
  $("#btn-export").onclick = exportFile;
  $("#btn-import").onchange = importFile;
  render();
})();

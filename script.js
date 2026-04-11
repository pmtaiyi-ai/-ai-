const seedRecords = [
  {
    id: 1,
    name: "Iced Latte",
    sweet: 58,
    rich: 72,
    tags: ["Creamy", "Iced"],
    type: "Coffee",
    favorite: true,
    createdAt: "Saved 2 hours ago",
    image: ""
  },
  {
    id: 2,
    name: "Milk Tea",
    sweet: 78,
    rich: 66,
    tags: ["Creamy", "Strong"],
    type: "Milk Tea",
    favorite: true,
    createdAt: "Yesterday",
    image: ""
  },
  {
    id: 3,
    name: "Fruit Tea",
    sweet: 64,
    rich: 28,
    tags: ["Fresh", "Fruity"],
    type: "Tea",
    favorite: false,
    createdAt: "Monday",
    image: ""
  }
];

const state = {
  records: JSON.parse(localStorage.getItem("flavornote-records") || "null") || seedRecords,
  selectedImage: "",
  voiceNote: "",
  page: "home"
};

const drinkName = document.querySelector("#drinkName");
const sweetSlider = document.querySelector("#sweetSlider");
const richSlider = document.querySelector("#richSlider");
const sweetLabel = document.querySelector("#sweetLabel");
const richLabel = document.querySelector("#richLabel");
const autoNote = document.querySelector("#autoNote");
const preferenceText = document.querySelector("#preferenceText");
const habitText = document.querySelector("#habitText");
const recommendations = document.querySelector("#recommendations");
const photoInput = document.querySelector("#photoInput");
const drinkPreview = document.querySelector("#drinkPreview");
const drinkVisual = document.querySelector(".drink-visual");
const saveBtn = document.querySelector("#saveBtn");
const voiceBtn = document.querySelector("#voiceBtn");

function persist() {
  localStorage.setItem("flavornote-records", JSON.stringify(state.records));
}

function getSelectedTags() {
  return [...document.querySelectorAll(".tag.active")].map((tag) => tag.textContent.trim());
}

function inferType(name) {
  const lower = name.toLowerCase();
  if (lower.includes("latte") || lower.includes("coffee") || lower.includes("brew")) return "Coffee";
  if (lower.includes("tea")) return lower.includes("milk") ? "Milk Tea" : "Tea";
  if (lower.includes("juice") || lower.includes("fruit")) return "Juice";
  return "Milk Tea";
}

function flavorLabel() {
  const sweet = Number(sweetSlider.value);
  const rich = Number(richSlider.value);
  const sweetness = sweet >= 60 ? "Sweet" : sweet <= 35 ? "Bitter" : "Balanced";
  const body = rich >= 60 ? "Rich" : rich <= 35 ? "Light" : "Smooth";
  return { sweetness, body };
}

function updateTasteUI() {
  const sweet = Number(sweetSlider.value);
  const rich = Number(richSlider.value);
  const { sweetness, body } = flavorLabel();
  const name = drinkName.value.trim() || "Today’s Drink";

  sweetLabel.textContent = `${sweetness} ${sweet}%`;
  richLabel.textContent = `${body} ${rich}%`;
  autoNote.textContent = `${name} · ${sweetness}`;
  preferenceText.textContent = sweet >= 60 ? "You prefer sweet drinks" : "You prefer crisp, less sweet drinks";
  habitText.textContent = rich >= 55 ? "You often choose milk-based drinks" : "You often choose light, refreshing drinks";

  const picks = rich >= 60
    ? ["Latte", "Milk Tea", "Mocha"]
    : sweet >= 60
      ? ["Fruit Tea", "Honey Lemon", "Yakult Tea"]
      : ["Cold Brew", "Oolong Tea", "Americano"];
  recommendations.innerHTML = picks.map((item) => `<span>${item}</span>`).join("");
}

function switchPage(page) {
  state.page = page;
  document.querySelectorAll(".page").forEach((section) => {
    section.classList.toggle("active", section.id === page);
  });
  document.querySelectorAll(".nav-item").forEach((button) => {
    button.classList.toggle("active", button.dataset.page === page);
  });
}

function renderStats() {
  const records = state.records;
  const latest = records[0];
  const avgSweet = Math.round(records.reduce((sum, item) => sum + item.sweet, 0) / records.length);
  const avgRich = Math.round(records.reduce((sum, item) => sum + item.rich, 0) / records.length);
  const typeCounts = records.reduce((acc, item) => {
    acc[item.type] = (acc[item.type] || 0) + 1;
    return acc;
  }, {});
  const sortedTypes = Object.entries(typeCounts).sort((a, b) => b[1] - a[1]);
  const commonType = sortedTypes[0]?.[0] || "Milk Tea";

  document.querySelector("#lastDrink").textContent = latest?.name || "No drinks yet";
  document.querySelector("#lastSaved").textContent = latest?.createdAt || "Start your first note";
  document.querySelector("#weekCount").textContent = String(records.length);
  document.querySelector("#commonDrink").textContent = commonType;
  document.querySelector("#avgSweet").textContent = `${avgSweet}%`;
  document.querySelector("#avgRich").textContent = `${avgRich}%`;
  document.querySelector("#analysisCommon").textContent = commonType;
  document.querySelector("#profileSummary").textContent =
    `You prefer ${avgSweet >= 60 ? "sweet" : "balanced"}, ${avgRich >= 60 ? "rich" : "light"}, ${commonType.toLowerCase()} drinks.`;

  renderDonut(typeCounts, records.length);
  renderCards();
}

function renderDonut(typeCounts, total) {
  const colors = ["#be4057", "#2e8b74", "#d09a44", "#53372c"];
  let cursor = 0;
  const segments = Object.entries(typeCounts).map(([type, count], index) => {
    const percent = Math.round((count / total) * 100);
    const segment = `${colors[index % colors.length]} ${cursor}% ${cursor + percent}%`;
    cursor += percent;
    return { segment, type, percent, color: colors[index % colors.length] };
  });

  document.querySelector("#donutChart").style.background = `conic-gradient(${segments.map((item) => item.segment).join(", ")})`;
  document.querySelector("#typeLegend").innerHTML = segments
    .map((item) => `<span style="border-color:${item.color}">${item.type} ${item.percent}%</span>`)
    .join("");
}

function cardTemplate(item) {
  const tags = item.tags.map((tag) => `<span>${tag}</span>`).join("");
  const image = item.image ? `<img src="${item.image}" alt="${item.name} photo">` : "";
  return `
    <article class="drink-card">
      <div class="drink-thumb">${image}</div>
      <div class="drink-body">
        <h3>${item.name}</h3>
        <p class="card-meta">${item.createdAt} · Sweet ${item.sweet}% · Rich ${item.rich}%</p>
        <div class="mini-tags">${tags}</div>
        <button class="favorite-toggle" type="button" data-favorite="${item.id}">
          ${item.favorite ? "Favorited" : "Add to favorites"}
        </button>
      </div>
    </article>
  `;
}

function renderCards() {
  document.querySelector("#historyList").innerHTML = state.records.map(cardTemplate).join("");
  const favorites = state.records.filter((item) => item.favorite);
  document.querySelector("#favoriteList").innerHTML = favorites.length
    ? favorites.map(cardTemplate).join("")
    : `<article class="drink-card"><div class="drink-body"><h3>No favorites yet</h3><p class="card-meta">Save a drink you love.</p></div></article>`;
}

document.querySelectorAll(".nav-item").forEach((button) => {
  button.addEventListener("click", () => switchPage(button.dataset.page));
});

document.querySelectorAll(".tag").forEach((tag) => {
  tag.addEventListener("click", () => tag.classList.toggle("active"));
});

[drinkName, sweetSlider, richSlider].forEach((input) => {
  input.addEventListener("input", updateTasteUI);
});

photoInput.addEventListener("change", () => {
  const file = photoInput.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    state.selectedImage = String(reader.result);
    drinkPreview.src = state.selectedImage;
    drinkVisual.classList.add("has-photo");
  };
  reader.readAsDataURL(file);
});

voiceBtn.addEventListener("click", () => {
  state.voiceNote = "Voice note captured";
  voiceBtn.textContent = "Voice Added";
});

saveBtn.addEventListener("click", () => {
  const name = drinkName.value.trim() || "Today’s Drink";
  const record = {
    id: Date.now(),
    name,
    sweet: Number(sweetSlider.value),
    rich: Number(richSlider.value),
    tags: getSelectedTags(),
    type: inferType(name),
    favorite: false,
    createdAt: "Saved just now",
    image: state.selectedImage
  };
  state.records.unshift(record);
  state.selectedImage = "";
  drinkVisual.classList.remove("has-photo");
  photoInput.value = "";
  persist();
  renderStats();
  saveBtn.textContent = "Saved";
  setTimeout(() => {
    saveBtn.textContent = "Save";
  }, 1200);
});

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-favorite]");
  if (!button) return;
  const id = Number(button.dataset.favorite);
  const record = state.records.find((item) => item.id === id);
  if (record) {
    record.favorite = !record.favorite;
    persist();
    renderStats();
  }
});

updateTasteUI();
renderStats();

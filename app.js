const SERVER_ADDRESS = "141.105.130.229:22003";
const API_BASE = "https://141.105.130.229.sslip.io/mta/api";
const WORLD_BOUNDS = [[-3000, -3000], [3000, 3000]];
const SESSION_KEY = "zmrpg.session";
const STRIKES = {
  artillery: { label: "Artillery strike", cost: 50 },
  airstrike: { label: "Airstrike", cost: 75 }
};

const state = {
  token: sessionStorage.getItem(SESSION_KEY),
  user: null,
  target: null,
  pendingStrike: null,
  toastTimer: null
};

const map = L.map("map", {
  crs: L.CRS.Simple,
  minZoom: -3,
  maxZoom: 2,
  zoomSnap: 0.25,
  zoomDelta: 0.5,
  maxBounds: [[-3450, -3450], [3450, 3450]],
  maxBoundsViscosity: 0.8,
  attributionControl: true
});

L.imageOverlay("assets/gtasa-map.jpeg", WORLD_BOUNDS, {
  interactive: false,
  attribution: "Map: MTA Wiki"
}).addTo(map);
map.fitBounds(WORLD_BOUNDS, { padding: [8, 8] });

const ENTITY_SCALE_BASE_ZOOM = map.getZoom();

function updateEntityMarkerScale(zoom = map.getZoom()) {
  const scale = Math.min(3, Math.max(0.8, 2 ** (zoom - ENTITY_SCALE_BASE_ZOOM)));
  map.getContainer().style.setProperty("--entity-marker-scale", scale.toFixed(3));
}

map.on("zoomanim", (event) => updateEntityMarkerScale(event.zoom));
map.on("zoomend", () => updateEntityMarkerScale());
updateEntityMarkerScale();

const layers = {
  players: L.layerGroup().addTo(map),
  offline: L.layerGroup().addTo(map),
  zombies: L.layerGroup().addTo(map),
  vehicles: L.layerGroup().addTo(map),
  markers: L.layerGroup().addTo(map),
  safeZones: L.layerGroup().addTo(map)
};

const registries = {
  players: new Map(),
  offline: new Map(),
  zombies: new Map(),
  vehicles: new Map(),
  markers: new Map(),
  safeZones: new Map()
};

const elements = {
  statusDot: document.querySelector("#statusDot"),
  statusText: document.querySelector("#statusText"),
  serverDetails: document.querySelector("#serverDetails"),
  copyAddress: document.querySelector("#copyAddress"),
  playerCount: document.querySelector("#playerCount"),
  zombieCount: document.querySelector("#zombieCount"),
  vehicleCount: document.querySelector("#vehicleCount"),
  onlineLayerCount: document.querySelector("#onlineLayerCount"),
  offlineLayerCount: document.querySelector("#offlineLayerCount"),
  zombieLayerCount: document.querySelector("#zombieLayerCount"),
  vehicleLayerCount: document.querySelector("#vehicleLayerCount"),
  markerLayerCount: document.querySelector("#markerLayerCount"),
  safeZoneLayerCount: document.querySelector("#safeZoneLayerCount"),
  updatedAt: document.querySelector("#updatedAt"),
  telemetryState: document.querySelector("#telemetryState"),
  coordinateReadout: document.querySelector("#coordinateReadout"),
  loginButton: document.querySelector("#loginButton"),
  accountSummary: document.querySelector("#accountSummary"),
  accountName: document.querySelector("#accountName"),
  materialBalance: document.querySelector("#materialBalance"),
  logoutButton: document.querySelector("#logoutButton"),
  loginModal: document.querySelector("#loginModal"),
  loginForm: document.querySelector("#loginForm"),
  loginUsername: document.querySelector("#loginUsername"),
  loginPassword: document.querySelector("#loginPassword"),
  loginSubmit: document.querySelector("#loginSubmit"),
  loginError: document.querySelector("#loginError"),
  strikeMenu: document.querySelector("#strikeMenu"),
  confirmModal: document.querySelector("#confirmModal"),
  confirmTitle: document.querySelector("#confirmTitle"),
  confirmCoordinates: document.querySelector("#confirmCoordinates"),
  confirmMessage: document.querySelector("#confirmMessage"),
  confirmStrike: document.querySelector("#confirmStrike"),
  toast: document.querySelector("#toast")
};

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function display(value, fallback = "None") {
  return value === false || value === null || value === undefined || value === "" ? fallback : escapeHtml(value);
}

function coordinates(position) {
  return `${Number(position?.x ?? 0).toFixed(1)}, ${Number(position?.y ?? 0).toFixed(1)}, ${Number(position?.z ?? 0).toFixed(1)}`;
}

function toLatLng(position) {
  return [Number(position?.y ?? 0), Number(position?.x ?? 0)];
}

function icon(type) {
  const content = type === "vehicle"
    ? `<span class="entity-marker vehicle"><i data-lucide="car-front"></i></span>`
    : `<span class="entity-marker ${type}"></span>`;
  return L.divIcon({
    className: "entity-icon",
    html: content,
    iconSize: [18, 18],
    iconAnchor: [9, 9]
  });
}

function popupRows(rows) {
  return `<div class="popup-grid">${rows
    .map(([label, value]) => `<span>${escapeHtml(label)}</span><span>${display(value)}</span>`)
    .join("")}</div>`;
}

function playerPopup(player) {
  const playerState = player.online ? "Online" : "Offline";
  return `
    <h3 class="popup-title">${escapeHtml(player.name)}
      <span class="popup-state ${player.online ? "" : "offline"}">${playerState}</span>
    </h3>
    ${popupRows([
      ["Money", `$${Number(player.money ?? 0).toLocaleString("en-US")}`],
      ["Health", Math.round(player.health ?? 0)],
      ["Armor", Math.round(player.armor ?? 0)],
      ["Level", player.level ?? 1],
      ["Score", player.score ?? 0],
      ["Team", player.team],
      ["Faction", player.faction],
      ["Organization", player.organization],
      ["Vehicle", player.vehicle?.name],
      ["Position", coordinates(player.position)],
      ["Last seen", new Date((player.lastSeen ?? 0) * 1000).toLocaleString()]
    ])}`;
}

function zombiePopup(zombie) {
  return `
    <h3 class="popup-title">Zombie ${escapeHtml(zombie.id)}</h3>
    ${popupRows([
      ["Health", Math.round(zombie.health ?? 0)],
      ["State", zombie.status],
      ["Target", zombie.target],
      ["Skin", zombie.skin],
      ["Position", coordinates(zombie.position)]
    ])}`;
}

function vehiclePopup(vehicle) {
  const kind = vehicle.personal ? "Personal" : vehicle.rental ? "Rental" : vehicle.crafted ? "Crafted" : vehicle.government ? "Government" : "World";
  return `
    <h3 class="popup-title">${display(vehicle.name, "Vehicle")}</h3>
    ${popupRows([
      ["Type", kind],
      ["Model", vehicle.model],
      ["Health", Math.round(vehicle.health ?? 0)],
      ["Owner", vehicle.owner],
      ["Driver", vehicle.driver],
      ["Position", coordinates(vehicle.position)]
    ])}`;
}

function markerPopup(marker) {
  return `
    <h3 class="popup-title">${display(marker.label, "Game marker")}</h3>
    ${popupRows([
      ["Type", marker.type],
      ["Size", marker.size],
      ["Interior", marker.interior],
      ["Dimension", marker.dimension],
      ["Position", coordinates(marker.position)]
    ])}`;
}

function syncPointLayer(layerName, items, iconType, popupFactory) {
  const registry = registries[layerName];
  const activeIds = new Set();

  for (const item of items) {
    const id = String(item.id);
    activeIds.add(id);
    let marker = registry.get(id);
    if (!marker) {
      marker = L.marker(toLatLng(item.position), {
        icon: icon(iconType),
        keyboard: true,
        riseOnHover: true
      }).addTo(layers[layerName]);
      registry.set(id, marker);
    } else {
      marker.setLatLng(toLatLng(item.position));
    }
    marker.bindPopup(popupFactory(item), { maxWidth: 300 });
  }

  for (const [id, marker] of registry.entries()) {
    if (!activeIds.has(id)) {
      layers[layerName].removeLayer(marker);
      registry.delete(id);
    }
  }
}

function safeZonePopup(zone) {
  return `
    <h3 class="popup-title">${display(zone.label, "Safe zone")}</h3>
    ${popupRows([
      ["Protection", "Zombie-proof"],
      ["Origin", `${Number(zone.x).toFixed(1)}, ${Number(zone.y).toFixed(1)}`],
      ["Size", `${Number(zone.width).toFixed(0)} x ${Number(zone.height).toFixed(0)}`]
    ])}`;
}

function syncSafeZones(items) {
  const registry = registries.safeZones;
  const activeIds = new Set();
  for (const zone of items) {
    const id = String(zone.id);
    activeIds.add(id);
    const bounds = [
      [Number(zone.y), Number(zone.x)],
      [Number(zone.y) + Number(zone.height), Number(zone.x) + Number(zone.width)]
    ];
    let rectangle = registry.get(id);
    if (!rectangle) {
      rectangle = L.rectangle(bounds, {
        color: "#9af277",
        weight: 2,
        fillColor: "#76dc69",
        fillOpacity: 0.16
      }).addTo(layers.safeZones);
      registry.set(id, rectangle);
    } else {
      rectangle.setBounds(bounds);
    }
    rectangle.bindPopup(safeZonePopup(zone));
  }

  for (const [id, rectangle] of registry.entries()) {
    if (!activeIds.has(id)) {
      layers.safeZones.removeLayer(rectangle);
      registry.delete(id);
    }
  }
}

function updateCounts(data) {
  const online = data.players.filter((player) => player.online);
  const offline = data.players.filter((player) => !player.online);
  elements.playerCount.textContent = online.length;
  elements.zombieCount.textContent = data.zombies.length;
  elements.vehicleCount.textContent = data.vehicles.length;
  elements.onlineLayerCount.textContent = online.length;
  elements.offlineLayerCount.textContent = offline.length;
  elements.zombieLayerCount.textContent = data.zombies.length;
  elements.vehicleLayerCount.textContent = data.vehicles.length;
  elements.markerLayerCount.textContent = data.markers.length;
  elements.safeZoneLayerCount.textContent = data.safeZones.length;
}

function renderTelemetry(data) {
  const online = data.players.filter((player) => player.online);
  const offline = data.players.filter((player) => !player.online);
  syncPointLayer("players", online, "player", playerPopup);
  syncPointLayer("offline", offline, "offline", playerPopup);
  syncPointLayer("zombies", data.zombies, "zombie", zombiePopup);
  syncPointLayer("vehicles", data.vehicles, "vehicle", vehiclePopup);
  syncPointLayer("markers", data.markers, "game-marker", markerPopup);
  syncSafeZones(data.safeZones);
  updateCounts(data);

  const receivedAt = Number(data.receivedAt || data.generatedAt || 0) * 1000;
  elements.updatedAt.textContent = receivedAt ? `Updated ${new Date(receivedAt).toLocaleTimeString()}` : "Waiting for data";
  elements.telemetryState.className = `telemetry-state ${data.stale ? "stale" : "live"}`;
  elements.telemetryState.querySelector("span").textContent = data.stale ? "Telemetry is delayed" : "Live - refreshes every 5 seconds";
  if (window.lucide) lucide.createIcons();
}

async function refreshTelemetry() {
  try {
    const response = await fetch(`${API_BASE}/telemetry`, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    renderTelemetry(await response.json());
  } catch (error) {
    elements.telemetryState.className = "telemetry-state error";
    elements.telemetryState.querySelector("span").textContent = "World telemetry is unavailable";
  }
}

function setServerStatus(online) {
  elements.statusDot.classList.toggle("online", online);
  elements.statusDot.classList.toggle("offline", !online);
  elements.statusText.textContent = online ? "Server online" : "Server unavailable";
}

async function refreshStatus() {
  try {
    const response = await fetch(`${API_BASE}/status`, { cache: "no-store" });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    setServerStatus(Boolean(data.online));
    elements.serverDetails.textContent = data.online
      ? `${data.players ?? 0}/${data.maxplayers ?? 100} - ${data.gamemode || "Zombie Mod RPG"}`
      : SERVER_ADDRESS;
  } catch (error) {
    setServerStatus(false);
    elements.serverDetails.textContent = SERVER_ADDRESS;
  }
}

async function apiRequest(path, options = {}) {
  const headers = new Headers(options.headers || {});
  if (options.body && !headers.has("Content-Type")) headers.set("Content-Type", "application/json");
  if (state.token) headers.set("Authorization", `Bearer ${state.token}`);
  const response = await fetch(`${API_BASE}${path}`, { ...options, headers, cache: "no-store" });
  let data = {};
  try {
    data = await response.json();
  } catch (error) {
    data = {};
  }
  if (!response.ok) {
    const requestError = new Error(data.error || `Request failed with HTTP ${response.status}.`);
    requestError.status = response.status;
    throw requestError;
  }
  return data;
}

function renderAccount() {
  const loggedIn = Boolean(state.user);
  elements.loginButton.hidden = loggedIn;
  elements.accountSummary.hidden = !loggedIn;
  if (loggedIn) {
    elements.accountName.textContent = state.user.username;
    elements.materialBalance.textContent = Number(state.user.materials || 0).toLocaleString("en-US");
  }
  for (const button of elements.strikeMenu.querySelectorAll("[data-strike]")) {
    const strike = STRIKES[button.dataset.strike];
    button.disabled = !loggedIn || Number(state.user?.materials || 0) < strike.cost;
  }
}

function clearSession() {
  state.token = null;
  state.user = null;
  sessionStorage.removeItem(SESSION_KEY);
  renderAccount();
}

async function refreshSession() {
  if (!state.token) {
    renderAccount();
    return;
  }
  try {
    const data = await apiRequest("/auth/session");
    state.user = data.user;
    renderAccount();
  } catch (error) {
    if (error.status === 401) clearSession();
  }
}

function setModal(modal, visible) {
  modal.hidden = !visible;
  if (visible && modal === elements.loginModal) {
    elements.loginError.textContent = "";
    setTimeout(() => elements.loginUsername.focus(), 0);
  }
}

function showToast(message, kind = "success") {
  clearTimeout(state.toastTimer);
  elements.toast.textContent = message;
  elements.toast.className = `toast ${kind}`;
  elements.toast.hidden = false;
  state.toastTimer = setTimeout(() => {
    elements.toast.hidden = true;
  }, 5000);
}

function closeStrikeMenu() {
  elements.strikeMenu.hidden = true;
}

function showStrikeMenu(event) {
  if (!state.user) return;
  state.target = {
    x: Math.max(-3000, Math.min(3000, event.latlng.lng)),
    y: Math.max(-3000, Math.min(3000, event.latlng.lat))
  };
  renderAccount();
  const container = map.getContainer();
  const menuWidth = 220;
  const menuHeight = 116;
  elements.strikeMenu.style.left = `${Math.max(8, Math.min(event.containerPoint.x, container.clientWidth - menuWidth - 8))}px`;
  elements.strikeMenu.style.top = `${Math.max(8, Math.min(event.containerPoint.y, container.clientHeight - menuHeight - 8))}px`;
  elements.strikeMenu.hidden = false;
}

function openStrikeConfirmation(type) {
  const strike = STRIKES[type];
  if (!strike || !state.target || !state.user) return;
  if (Number(state.user.materials || 0) < strike.cost) {
    showToast("Not enough materials.", "error");
    return;
  }
  state.pendingStrike = { type, ...state.target };
  elements.confirmTitle.textContent = strike.label;
  elements.confirmCoordinates.textContent = `X ${state.target.x.toFixed(1)}, Y ${state.target.y.toFixed(1)}`;
  elements.confirmMessage.textContent = `${strike.cost} materials will be deducted from ${state.user.username}.`;
  elements.confirmStrike.textContent = `Confirm - ${strike.cost}`;
  closeStrikeMenu();
  setModal(elements.confirmModal, true);
}

async function pollAction(actionId) {
  for (let attempt = 0; attempt < 30; attempt += 1) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    try {
      const data = await apiRequest(`/actions/${encodeURIComponent(actionId)}`);
      if (data.action.status === "completed" || data.action.status === "failed") {
        await refreshSession();
        showToast(data.action.message || "Strike request finished.", data.action.status === "completed" ? "success" : "error");
        return;
      }
    } catch (error) {
      if (error.status === 401) {
        clearSession();
        return;
      }
    }
  }
  showToast("The strike is still queued on the game server.", "error");
}

async function submitStrike() {
  if (!state.pendingStrike) return;
  elements.confirmStrike.disabled = true;
  try {
    const data = await apiRequest("/actions", {
      method: "POST",
      body: JSON.stringify(state.pendingStrike)
    });
    setModal(elements.confirmModal, false);
    showToast("Strike request queued.");
    state.pendingStrike = null;
    pollAction(data.action.id);
  } catch (error) {
    showToast(error.message, "error");
  } finally {
    elements.confirmStrike.disabled = false;
  }
}

document.querySelectorAll("[data-layer]").forEach((checkbox) => {
  checkbox.addEventListener("change", () => {
    const layer = layers[checkbox.dataset.layer];
    if (checkbox.checked) {
      layer.addTo(map);
    } else {
      map.removeLayer(layer);
    }
  });
});

elements.copyAddress.addEventListener("click", async () => {
  await navigator.clipboard.writeText(SERVER_ADDRESS);
  elements.copyAddress.title = "Address copied";
  setTimeout(() => {
    elements.copyAddress.title = "Copy server address";
  }, 1500);
});

elements.loginButton.addEventListener("click", () => setModal(elements.loginModal, true));
elements.logoutButton.addEventListener("click", async () => {
  try {
    await apiRequest("/auth/logout", { method: "POST", body: "{}" });
  } catch (error) {
    // A local logout still clears an expired or unreachable session.
  }
  clearSession();
  closeStrikeMenu();
});

elements.loginForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  elements.loginError.textContent = "";
  elements.loginSubmit.disabled = true;
  elements.loginSubmit.textContent = "Signing in...";
  try {
    const data = await apiRequest("/auth/login", {
      method: "POST",
      body: JSON.stringify({
        username: elements.loginUsername.value.trim(),
        password: elements.loginPassword.value
      })
    });
    state.token = data.token;
    state.user = data.user;
    sessionStorage.setItem(SESSION_KEY, state.token);
    elements.loginPassword.value = "";
    renderAccount();
    setModal(elements.loginModal, false);
    showToast(`Signed in as ${state.user.username}.`);
  } catch (error) {
    elements.loginError.textContent = error.message;
  } finally {
    elements.loginSubmit.disabled = false;
    elements.loginSubmit.textContent = "Sign in";
  }
});

elements.strikeMenu.querySelectorAll("[data-strike]").forEach((button) => {
  button.addEventListener("click", () => openStrikeConfirmation(button.dataset.strike));
});
elements.confirmStrike.addEventListener("click", submitStrike);

document.querySelectorAll("[data-close-modal]").forEach((button) => {
  button.addEventListener("click", () => {
    setModal(button.closest(".modal-backdrop"), false);
    state.pendingStrike = null;
  });
});

document.addEventListener("click", (event) => {
  if (!elements.strikeMenu.hidden && !elements.strikeMenu.contains(event.target)) closeStrikeMenu();
});
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    closeStrikeMenu();
    setModal(elements.loginModal, false);
    setModal(elements.confirmModal, false);
    state.pendingStrike = null;
  }
});

map.getContainer().addEventListener("contextmenu", (event) => event.preventDefault());
map.on("contextmenu", showStrikeMenu);
map.on("movestart zoomstart", closeStrikeMenu);
map.on("mousemove", (event) => {
  elements.coordinateReadout.textContent = `X ${event.latlng.lng.toFixed(1)} - Y ${event.latlng.lat.toFixed(1)}`;
});

if (window.lucide) lucide.createIcons();
renderAccount();
refreshSession();
refreshStatus();
refreshTelemetry();
setInterval(refreshStatus, 10000);
setInterval(refreshTelemetry, 5000);
setInterval(refreshSession, 10000);

const SERVER_ADDRESS = "141.105.130.229:22003";
const API_BASE = "https://141.105.130.229.sslip.io/mta/api";
const PAGE_SIZE = 80;

const state = {
  cursor: null,
  total: 0,
  loading: false,
  exhausted: false,
  ids: new Set()
};

const elements = {
  statusDot: document.querySelector("#statusDot"),
  statusText: document.querySelector("#statusText"),
  serverDetails: document.querySelector("#serverDetails"),
  eventFeed: document.querySelector("#eventFeed"),
  eventRows: document.querySelector("#eventRows"),
  eventCount: document.querySelector("#eventCount"),
  eventFeedState: document.querySelector("#eventFeedState"),
  loadOlder: document.querySelector("#loadOlder"),
  refreshEvents: document.querySelector("#refreshEvents")
};

const kindLabels = {
  error: "Error",
  warning: "Warning",
  player: "Player",
  leave: "Leave",
  tactical: "Tactical",
  system: "System"
};

function setServerStatus(online) {
  elements.statusDot.className = `status-dot ${online ? "online" : "offline"}`;
  elements.statusText.textContent = online ? "Server online" : "Server unavailable";
}

async function refreshStatus() {
  try {
    const response = await fetch(`${API_BASE}/status`, { cache: "no-store" });
    if (!response.ok) throw new Error("Status request failed");
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

async function fetchEvents(before) {
  const parameters = new URLSearchParams({ limit: String(PAGE_SIZE) });
  if (before !== null && before !== undefined) parameters.set("before", String(before));
  const response = await fetch(`${API_BASE}/events?${parameters}`, { cache: "no-store" });
  if (!response.ok) throw new Error("Event history request failed");
  return response.json();
}

function eventRow(event) {
  const row = document.createElement("article");
  row.className = `event-row ${event.kind || "system"}`;
  row.dataset.eventId = event.id;

  const timestamp = document.createElement("time");
  timestamp.className = "event-time";
  timestamp.textContent = event.timestamp || "Server";

  const kind = document.createElement("span");
  kind.className = "event-kind";
  kind.textContent = kindLabels[event.kind] || kindLabels.system;

  const message = document.createElement("span");
  message.className = "event-message";
  message.textContent = event.message;

  row.append(timestamp, kind, message);
  return row;
}

function updateSummary() {
  elements.eventCount.textContent = `${state.ids.size.toLocaleString("en-US")} of ${state.total.toLocaleString("en-US")} events`;
  elements.loadOlder.hidden = state.exhausted;
  elements.loadOlder.disabled = state.loading;
  elements.loadOlder.textContent = state.loading ? "Loading..." : "Load older events";
}

function appendEvents(events) {
  const fragment = document.createDocumentFragment();
  for (const event of events) {
    if (state.ids.has(event.id)) continue;
    state.ids.add(event.id);
    fragment.append(eventRow(event));
  }
  elements.eventRows.append(fragment);
}

function prependEvents(events) {
  const additions = events.filter((event) => !state.ids.has(event.id));
  if (!additions.length) return;

  const previousHeight = elements.eventFeed.scrollHeight;
  const fragment = document.createDocumentFragment();
  for (const event of additions) {
    state.ids.add(event.id);
    fragment.append(eventRow(event));
  }
  elements.eventRows.prepend(fragment);

  if (elements.eventFeed.scrollTop > 24) {
    elements.eventFeed.scrollTop += elements.eventFeed.scrollHeight - previousHeight;
  }
}

async function loadOlderEvents() {
  if (state.loading || state.exhausted) return;
  state.loading = true;
  elements.eventFeedState.textContent = "Loading older history...";
  updateSummary();

  try {
    const data = await fetchEvents(state.cursor);
    appendEvents(data.events || []);
    state.cursor = data.nextCursor;
    state.total = Number(data.total || 0);
    state.exhausted = data.nextCursor === null || data.nextCursor === undefined;
    elements.eventFeedState.textContent = state.exhausted
      ? "Beginning of available server history."
      : "Newest events first. Scroll down for older history.";
  } catch (error) {
    elements.eventFeedState.textContent = "Event history is temporarily unavailable.";
  } finally {
    state.loading = false;
    updateSummary();
  }
}

async function refreshLatestEvents() {
  elements.refreshEvents.disabled = true;
  try {
    const data = await fetchEvents(null);
    prependEvents(data.events || []);
    state.total = Number(data.total || state.total);
    elements.eventFeedState.textContent = state.exhausted
      ? "Beginning of available server history."
      : "Newest events first. Scroll down for older history.";
  } catch (error) {
    elements.eventFeedState.textContent = "Live event refresh failed. Retrying automatically.";
  } finally {
    elements.refreshEvents.disabled = false;
    updateSummary();
  }
}

elements.eventFeed.addEventListener("scroll", () => {
  const remaining = elements.eventFeed.scrollHeight
    - elements.eventFeed.scrollTop
    - elements.eventFeed.clientHeight;
  if (remaining < 240) loadOlderEvents();
});
elements.loadOlder.addEventListener("click", loadOlderEvents);
elements.refreshEvents.addEventListener("click", refreshLatestEvents);

if (window.lucide) lucide.createIcons();
refreshStatus();
loadOlderEvents();
setInterval(refreshStatus, 10000);
setInterval(refreshLatestEvents, 5000);

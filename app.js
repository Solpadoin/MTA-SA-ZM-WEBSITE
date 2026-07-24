const address = "141.105.130.229:22003";
const statusApiUrl = "https://141.105.130.229.sslip.io/mta/api/status";
const players = document.querySelector("#players");
const map = document.querySelector("#map");
const gamemode = document.querySelector("#gamemode");
const statusText = document.querySelector("#statusText");
const statusDot = document.querySelector("#statusDot");
const events = document.querySelector("#events");
const copyButton = document.querySelector("#copyAddress");

copyButton.addEventListener("click", async () => {
  await navigator.clipboard.writeText(address);
  copyButton.textContent = "IP copied";
  setTimeout(() => {
    copyButton.textContent = "Copy IP";
  }, 1400);
});

function setStatus(online) {
  statusDot.classList.toggle("online", online);
  statusDot.classList.toggle("offline", !online);
  statusText.textContent = online ? "Server online" : "Server unavailable";
}

async function refresh() {
  try {
    const response = await fetch(statusApiUrl, { cache: "no-store" });
    const data = await response.json();
    setStatus(Boolean(data.online));
    players.textContent = `${data.players ?? 0} / ${data.maxplayers ?? 100}`;
    map.textContent = data.map || "-";
    gamemode.textContent = data.gamemode || "Zombie RPG";
    events.textContent = data.events?.length ? data.events.join("\n") : "No recent events yet.";
  } catch (error) {
    setStatus(false);
    events.textContent = "Status API is temporarily unavailable.";
  }
}

refresh();
setInterval(refresh, 10000);

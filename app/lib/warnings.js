// One-time warning system to prevent log spam
const warningsShown = new Set();

function showWarningOnce(key, message) {
  if (!warningsShown.has(key)) {
    console.log(message);
    warningsShown.add(key);
  }
}

module.exports = { showWarningOnce };

document.addEventListener("DOMContentLoaded", () => {
  const scriptList = document.getElementById("script-list");
  const runBtn = document.getElementById("run-btn");

  let selectedScript = null;
  let adminMode = false;

  // Create Admin Mode toggle button
  const adminBtn = document.createElement("button");
  adminBtn.innerText = "Run as Admin: OFF";
  adminBtn.style.marginBottom = "10px";
  adminBtn.onclick = () => {
    adminMode = !adminMode;
    adminBtn.innerText = adminMode ? "Run as Admin: ON" : "Run as Admin: OFF";
  };
  scriptList.before(adminBtn); // Add above script list

  // Fetch available scripts from the server
  fetch("/list-scripts")
    .then((response) => response.json())
    .then((scripts) => {
      scriptList.innerHTML = ""; // Clear previous content
      scripts.forEach((script) => {
        const btn = document.createElement("button");
        btn.innerText = script;
        btn.onclick = () => {
          selectedScript = script;
          alert(`Selected script: ${script}`);
        };
        scriptList.appendChild(btn);
      });
    })
    .catch((err) => {
      console.error("Error loading scripts:", err);
    });

  runBtn.onclick = () => {
    if (!selectedScript) {
      alert("Please select a script first.");
      return;
    }

    fetch(`/run-script?script=${selectedScript}&admin=${adminMode}`)
      .then((response) => response.text())
      .then((output) => {
        alert(output);
      })
      .catch((err) => {
        alert("Error running script: " + err);
      });
  };
});

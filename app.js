document.addEventListener("DOMContentLoaded", () => {
  const scriptList = document.getElementById("script-list");
  const runBtn = document.getElementById("run-btn");

  let selectedScript = null;

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

    fetch(`/run-script?script=${selectedScript}`)
      .then((response) => response.text())
      .then((output) => {
        alert(output);
      })
      .catch((err) => {
        alert("Error running script: " + err);
      });
  };
});

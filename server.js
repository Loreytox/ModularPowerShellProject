const express = require("express");
const { exec } = require("child_process");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = 3000;

// Serve static files (HTML, CSS, JS)
app.use(express.static(path.join(__dirname)));

// Endpoint to list available PowerShell scripts
app.get("/list-scripts", (req, res) => {
  const scriptsDir = path.join(__dirname, "scripts");

  fs.readdir(scriptsDir, (err, files) => {
    if (err) {
      return res.status(500).send("Failed to load scripts.");
    }
    const psScripts = files.filter((file) => file.endsWith(".ps1"));
    res.json(psScripts);
  });
});

// Endpoint to execute a PowerShell script
app.get("/run-script", (req, res) => {
  const scriptName = req.query.script;
  if (!scriptName) {
    return res.status(400).send("Script name is required.");
  }

  const scriptPath = path.join(__dirname, "scripts", scriptName);

  // Use `start powershell` to open a new terminal
  const command = `start powershell -NoExit -ExecutionPolicy Bypass -File "${scriptPath}"`;

  exec(command, (error) => {
    if (error) {
      console.error(`Error executing script: ${error}`);
      return res.status(500).send("Failed to start PowerShell.");
    }
    res.send(`PowerShell script "${scriptName}" started in a new window.`);
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});

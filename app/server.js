const express = require("express");
const os = require("os");

const app = express();
const PORT = process.env.PORT || 3000;

// ===== CHANGE THIS LINE for the final demo =====
const MESSAGE = "Hello from Version 999";
// ===============================================

app.get("/", (req, res) => {
  res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>CI/CD Demo</title>
  <style>
    body { font-family: Arial, sans-serif; background: #0f172a; color: #e2e8f0;
           display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 40px 60px; border-radius: 12px; text-align: center; }
    h1 { color: #38bdf8; }
    code { background: #0f172a; padding: 4px 10px; border-radius: 6px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>${MESSAGE}</h1>
    <p>Served by pod/container: <code>${os.hostname()}</code></p>
  </div>
</body>
</html>`);
});

// Used later by Kubernetes health checks
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`App listening on port ${PORT}`);
});
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 3000;
const base = path.join(__dirname, "dist");

const server = http.createServer((req, res) => {
  let filePath = path.join(base, req.url === "/" ? "index.html" : req.url);

  if (!fs.existsSync(filePath)) {
    res.writeHead(404);
    return res.end("Not found");
  }

  const ext = path.extname(filePath);

  const contentTypes = {
    ".html": "text/html",
    ".js": "application/javascript",
    ".wasm": "application/wasm",
    ".pck": "application/octet-stream",
    ".png": "image/png"
  };

  res.writeHead(200, {
    "Content-Type": contentTypes[ext] || "text/plain",
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "require-corp"
  });

  fs.createReadStream(filePath).pipe(res);
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 3000;
const base = path.join(__dirname, "dist");

const contentTypes = {
  ".html": "text/html",
  ".js":   "application/javascript",
  ".wasm": "application/wasm",
  ".pck":  "application/octet-stream",
  ".png":  "image/png",
};

const server = http.createServer((req, res) => {
  let filePath = path.join(base, req.url === "/" ? "index.html" : req.url);

  if (!fs.existsSync(filePath)) {
    res.writeHead(404);
    return res.end("Not found");
  }

  const ext = path.extname(filePath);
  const stat = fs.statSync(filePath);

  const headers = {
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "require-corp",
    "Content-Type": contentTypes[ext] || "text/plain",
    "Content-Length": stat.size,
  };

  // only .wasm is pre-gzipped
  if (ext === ".wasm") {
    headers["Content-Encoding"] = "gzip";
  }

  res.writeHead(200, headers);
  fs.createReadStream(filePath).pipe(res);
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
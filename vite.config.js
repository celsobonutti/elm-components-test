import { defineConfig } from "vite";
import elmPlugin from 'vite-plugin-elm'

export default defineConfig({
  plugins: [
    elmPlugin(),
    {
      name: "watch-elm-js",
      configureServer(server) {
        server.watcher.add("src/**/*.elm.js");
        server.watcher.on("change", (path) => {
          if (path.endsWith(".elm.js")) {
            const elmFile = path.replace(/\.js$/, "");
            server.watcher.emit("change", elmFile);
          }
        });
      },
    },
  ],
});

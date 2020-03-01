import { Elm } from "./Main.elm";

const app = Elm.Main.init({
  node: document.getElementById("root"),
  flags: {
    appName: process.env.APP_NAME
  }
});

app.ports.fromElm.subscribe(msg => console.log(`[from elm]: `, msg));

app.ports.toElm.send({
  event: "app.ready",
  data: {
    timestamp: new Date().toJSON()
  }
});

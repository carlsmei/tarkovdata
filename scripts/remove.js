const fs = require("fs")

{
  console.log("Proccessing achievements")
  const path = "achievements/list.json"
  const rawData = fs.readFileSync(path, "utf8");
  const data = JSON.parse(rawData);

  for (const achievement of data.elements) {
    for (const reward of achievement.rewards) {
      if (reward.type == "AssortmentUnlock" || reward.type == "Item" || reward.type == "ProductionScheme") {
        reward.target = "removed"

        for (const item of reward.items) {
          item["_id"] = "removed"

          if (item["parentId"]) {
            item["parentId"] = "removed"
          }
        }
      }
    }
  }

  fs.writeFileSync(path, JSON.stringify(data, null, 2))
}

{
  console.log("Proccessing dialogues")
  const path = "dialogue/list.json"
  const rawData = fs.readFileSync(path, "utf8");
  const data = JSON.parse(rawData);

  for (const dialogue of data.elements) {
    for (const line of dialogue.Lines) {
      for (const action of line.Actions) {
        if (action.type == "SetVariable") {
          action.id = "removed"
        }
      }
    }
  }

  fs.writeFileSync(path, JSON.stringify(data, null, 2))
}

{
  console.log("Proccessing endings")
  const path = "ending.json"
  const rawData = fs.readFileSync(path, "utf8");
  const data = JSON.parse(rawData);

  for (const ending of data.elements) {
    for (const reward of ending.rewards) {
      if (reward.type == "Item") {
        reward.target = "removed"

        for (const item of reward.items) {
          item["_id"] = "removed"

          if (item["parentId"]) {
            item["parentId"] = "removed"
          }
        }
      }
    }
  }

  fs.writeFileSync(path, JSON.stringify(data, null, 2))
}

{
  console.log("Proccessing prestige")
  const path = "prestige.json"
  const rawData = fs.readFileSync(path, "utf8");
  const data = JSON.parse(rawData);

  for (const prestige of data.elements) {
    for (const reward of prestige.rewards) {
      if (reward.type == "Item") {
        reward.target = "removed"

        for (const item of reward.items) {
          item["_id"] = "removed"

          if (item["parentId"]) {
            item["parentId"] = "removed"
          }
        }
      }
    }
  }

  fs.writeFileSync(path, JSON.stringify(data, null, 2))
}

{
  console.log("Proccessing traders")
  const path = "trading/settings.json"
  const rawData = fs.readFileSync(path, "utf8");
  const data = JSON.parse(rawData);

  for (const trader of data) {
    trader.nextResupply = 0
  }

  fs.writeFileSync(path, JSON.stringify(data, null, 2))
}
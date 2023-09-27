const fs = require("fs");
const path = require("path");
const { simulateScript } = require("@chainlink/functions-toolkit");

// Initialize functions settings
const source = fs.readFileSync(path.resolve(__dirname, "source.js")).toString();

///////// START SIMULATION ////////////

function runSimulation() {
  console.log("Start simulation...");

  simulateScript({
    source: source,
  })
    .then((response) => {
      console.log("Success!");
      // Handle the response here
    })
    .catch((error) => {
      // Handle errors here
    });
}

// Call the function
runSimulation();

import express from "express";
import Web3 from "web3";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import morgan from "morgan";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(morgan("dev"));
app.use(bodyParser.json());

// List of Geth nodes
const GETH_NODES = (process.env.GETH_NODES || "").split(",");

if (GETH_NODES.length === 0) {
  console.error("No GETH_NODES defined in environment variables");
  process.exit(1);
}

let currentIndex = 0;

function getNextWeb3Instance(): Web3 {
  const node = GETH_NODES[currentIndex % GETH_NODES.length];
  currentIndex++;
  return new Web3(new Web3.providers.HttpProvider(node));
}

function getAllWeb3Instances(): Web3[] {
  return GETH_NODES.map(
    (url) => new Web3(new Web3.providers.HttpProvider(url))
  );
}

async function sendRawTxWithRetries(
  rawTx: string,
  maxRetries = 3
): Promise<string> {
  let attempt = 0;
  let lastError: Error;

  while (attempt < maxRetries) {
    try {
      const web3 = getNextWeb3Instance();
      return await web3.eth.sendSignedTransaction(rawTx);
    } catch (error: any) {
      console.warn(`Attempt ${attempt + 1} failed: ${error.message}`);
      lastError = error;
      attempt++;
    }
  }

  throw lastError;
}

app.post("/tx/send", async (req, res) => {
  const { rawTx } = req.body;
  if (!rawTx)
    return res.status(400).json({ error: "Missing rawTx in request body" });

  try {
    const txHash = await sendRawTxWithRetries(rawTx);
    res.json({ status: "success", txHash });
  } catch (error: any) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

app.get("/tx/status/:hash", async (req, res) => {
  const { hash } = req.params;
  const web3Instances = getAllWeb3Instances();

  try {
    for (const web3 of web3Instances) {
      try {
        const receipt = await web3.eth.getTransactionReceipt(hash);
        if (receipt) {
          return res.json({ status: "confirmed", receipt });
        }
      } catch (innerErr) {
        console.warn(`Failed to fetch from node: ${innerErr}`);
        // try the next node
      }
    }
    res.json({ status: "not found" });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Transaction relayer running on port ${PORT}`);
});

import http from "k6/http";
import { check, sleep } from "k6";

export let options = {
  stages: [
    { duration: "150s", target: 50 }, // Ramp up to 10 users
    { duration: "5m", target: 250 }, // Ramp up to 50 users
    { duration: "15m", target: 250 }, // Stay at 50 users
    { duration: "5m", target: 500 }, // Ramp up to 100 users
    { duration: "10m", target: 500 }, // Stay at 100 users
    { duration: "150s", target: 0 }, // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95% of requests must complete below 500ms
    http_req_failed: ["rate<0.1"], // Error rate must be below 10%
  },
};

const BASE_URL = "http://geth.35.192.223.157.nip.io";

export default function () {
  // Test 1: Get latest block number
  let blockNumberResponse = http.post(
    BASE_URL,
    JSON.stringify({
      jsonrpc: "2.0",
      method: "eth_blockNumber",
      params: [],
      id: 1,
    }),
    {
      headers: { "Content-Type": "application/json" },
      tags: { endpoint: "eth_blockNumber" },
    }
  );

  check(blockNumberResponse, {
    "eth_blockNumber status is 200": (r) => r.status === 200,
    "eth_blockNumber has result": (r) =>
      JSON.parse(r.body).result !== undefined,
    "eth_blockNumber response time < 1s": (r) => r.timings.duration < 1000,
  });

  sleep(0.1);

  // Test 2: Get network version
  let networkResponse = http.post(
    BASE_URL,
    JSON.stringify({
      jsonrpc: "2.0",
      method: "net_version",
      params: [],
      id: 2,
    }),
    {
      headers: { "Content-Type": "application/json" },
      tags: { endpoint: "net_version" },
    }
  );

  check(networkResponse, {
    "net_version status is 200": (r) => r.status === 200,
    "net_version has result": (r) => JSON.parse(r.body).result !== undefined,
  });

  sleep(0.1);

  // Test 3: Get gas price
  let gasPriceResponse = http.post(
    BASE_URL,
    JSON.stringify({
      jsonrpc: "2.0",
      method: "eth_gasPrice",
      params: [],
      id: 3,
    }),
    {
      headers: { "Content-Type": "application/json" },
      tags: { endpoint: "eth_gasPrice" },
    }
  );

  check(gasPriceResponse, {
    "eth_gasPrice status is 200": (r) => r.status === 200,
    "eth_gasPrice has result": (r) => JSON.parse(r.body).result !== undefined,
  });

  sleep(0.2);
}

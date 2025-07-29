# 🔄 ETHEREUM SYNC MODES EXPLAINED

## 📊 Quick Comparison Table

| Sync Mode    | Sync Time | Storage   | RAM Needed | Cost/Month | Use Case                     |
| ------------ | --------- | --------- | ---------- | ---------- | ---------------------------- |
| 🪶 **Light** | 5-15 mins | 2-5GB     | 1-2GB      | $35-70     | dApp frontends, development  |
| 🚀 **Snap**  | 2-6 hours | 600-800GB | 8-16GB     | $330-660   | Production backends, APIs    |
| 📚 **Full**  | 3-7 days  | 1500GB+   | 16-32GB    | $600-1200  | Financial services, archives |

## 🪶 LIGHT SYNC (--syncmode=light)

**What it does:**

- Downloads only block headers (not full blocks)
- Requests data from full nodes when needed
- Maintains recent state for current operations

**Perfect for:**
✅ dApp frontends that need current state
✅ Wallets and simple applications  
✅ Development and testing
✅ Cost-sensitive deployments

**Limitations:**
❌ Can't query old historical data
❌ Depends on other full nodes being available
❌ Limited eth_getLogs functionality
❌ No archive state access

**Example APIs that work:**

```javascript
// ✅ These work great with light sync:
eth.getBalance(address);
eth.getBlockNumber();
eth.sendTransaction(tx);
eth.getTransactionReceipt(hash);

// ❌ These don't work well with light sync:
eth.getLogs({ fromBlock: "earliest" }); // Only recent blocks
debug.traceTransaction(hash); // No debug APIs
```

## 🚀 SNAP SYNC (--syncmode=snap) - RECOMMENDED!

**What it does:**

- Downloads a state snapshot from peers
- Syncs recent blocks normally
- Provides full node capabilities quickly

**Perfect for:**
✅ Production applications
✅ API servers and backends
✅ Most business use cases
✅ Balance of speed and functionality

**Advantages:**
✅ Full node APIs available
✅ Much faster than full sync
✅ Good performance for most queries
✅ Complete current state

**Example configuration:**

```yaml
extraArgs:
  - "--mainnet"
  - "--syncmode=snap"
  - "--cache=4096" # 4GB cache
```

## 📚 FULL SYNC (--syncmode=full)

**What it does:**

- Downloads and validates every block from genesis
- Rebuilds entire state from scratch
- Maximum security and data integrity

**Perfect for:**
✅ Financial institutions
✅ Block explorers
✅ Analytics platforms
✅ Maximum security requirements

**Advantages:**
✅ Complete blockchain history
✅ All data locally verified
✅ Maximum trustlessness
✅ Archive node capabilities

**Disadvantages:**
❌ Very slow initial sync (days)
❌ Massive storage requirements
❌ High bandwidth usage
❌ Expensive to operate

## 🎯 PRACTICAL EXAMPLES

### For a DeFi Frontend:

```yaml
# Light sync is perfect - fast, cheap, current data
extraArgs: ["--mainnet", "--syncmode=light", "--cache=512"]
resources:
  requests: { cpu: 500m, memory: 1Gi }
persistence: { size: 50Gi }
# Monthly cost: ~$40
```

### For a Trading Backend:

```yaml
# Snap sync - good balance of speed and features
extraArgs: ["--mainnet", "--syncmode=snap", "--cache=4096"]
resources:
  requests: { cpu: 2000m, memory: 8Gi }
persistence: { size: 1000Gi }
# Monthly cost: ~$400
```

### For Block Explorer:

```yaml
# Full sync - complete historical data
extraArgs: ["--mainnet", "--syncmode=full", "--cache=8192", "--gcmode=archive"]
resources:
  requests: { cpu: 4000m, memory: 16Gi }
persistence: { size: 2000Gi }
# Monthly cost: ~$800
```

## 💡 PRO TIPS

1. **Start with Light Sync** - test your application first
2. **Upgrade to Snap** when you need full APIs
3. **Use External RPC** (Infura/Alchemy) as backup
4. **Monitor costs** carefully with cloud providers
5. **Consider hybrid approach** - light node + external RPC

## 🔄 MIGRATION PATH

```bash
# 1. Start with testnet (current setup)
helm install geth --set extraArgs=["--sepolia"]

# 2. Test with mainnet light sync
helm upgrade geth --set extraArgs=["--mainnet","--syncmode=light"]

# 3. Upgrade to snap sync when needed
helm upgrade geth --set extraArgs=["--mainnet","--syncmode=snap"]
```

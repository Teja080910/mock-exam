# Deploy API to Production via CLI

Hostinger shared hosting (Passenger/LiteSpeed Node.js app).

## Connection

```bash
SSH_HOST=82.25.111.131
SSH_PORT=65002
SSH_USER=u154093950
```

## 1. Upload changed files

From your local `api/` folder, upload the files you changed:

```bash
# Single file
scp -P 65002 api/controllers/apiController.js u154093950@82.25.111.131:/home/u154093950/api/controllers/apiController.js

# Multiple files
scp -P 65002 api/app.js api/routes/apiRoute.js u154093950@82.25.111.131:/home/u154093950/api/
```

## 2. Copy to the live app directory

The live app runs from `hbuilds/current/nodejs` (Passenger). Copy the uploaded files there:

```bash
ssh -p 65002 u154093950@82.25.111.131 "cp /home/u154093950/api/controllers/apiController.js /home/u154093950/domains/app.mockstation.com/hbuilds/current/nodejs/controllers/apiController.js"
```

## 3. Restart the Node process

Kill the running lsnode process — Passenger respawns it automatically on the next request:

```bash
ssh -p 65002 u154093950@82.25.111.131 "ps aux | grep lsnode | grep -v grep | awk '{print \$2}' | xargs -r kill"
```

## 4. Verify

```bash
# API responds
curl -s -o /dev/null -w "%{http_code}\n" -X POST https://app.mockstation.com/api/leaderboard -H "Content-Type: application/json" -d '{"quizId":"695496d8d6d9bc79cb085be3"}'

# Admin panel loads
curl -s -o /dev/null -w "%{http_code}\n" https://app.mockstation.com/login

# New process running
ssh -p 65002 u154093950@82.25.111.131 "ps aux | grep lsnode | grep -v grep"
```

## Full deploy (everything)

```bash
# 1. Create tarball (excludes node_modules, .env, etc.)
cd api && tar czf /tmp/api-full.tgz --exclude=node_modules --exclude=.env --exclude=package-lock.json --exclude=.DS_Store --exclude=request_logs.txt --exclude=backup -C api .

# 2. Upload
scp -P 65002 /tmp/api-full.tgz u154093950@82.25.111.131:/home/u154093950/api-full.tgz

# 3. Extract to source dir
ssh -p 65002 u154093950@82.25.111.131 "cd /home/u154093950 && rm -rf /tmp/api-new && mkdir -p /tmp/api-new && tar xzf api-full.tgz -C /tmp/api-new"

# 4. Sync to both locations
ssh -p 65002 u154093950@82.25.111.131 "rsync -a --delete --exclude node_modules --exclude .env --exclude package-lock.json --exclude .DS_Store --exclude request_logs.txt --exclude backup /tmp/api-new/ /home/u154093950/api/ && rsync -a --delete --exclude node_modules --exclude .env --exclude package-lock.json --exclude .DS_Store --exclude request_logs.txt --exclude backup --exclude console.log --exclude stderr.log --exclude tmp /tmp/api-new/ /home/u154093950/domains/app.mockstation.com/hbuilds/current/nodejs/"

# 5. Restart + cleanup
ssh -p 65002 u154093950@82.25.111.131 "ps aux | grep lsnode | grep -v grep | awk '{print \$2}' | xargs -r kill; rm -rf /tmp/api-new api-full.tgz"
```

## Important notes

- **Kill the process, don't just touch restart.txt** — `restart.txt` doesn't always trigger a restart; killing the lsnode process forces Passenger to respawn with the new code.
- **Never upload `.env`** — production credentials differ from local.
- **Never upload `node_modules`** — they're already installed on the server.
- **EJS views** (admin panel templates) also need the same two-step copy (source + hbuilds) and restart.
- **Verify checksums** after upload if unsure:
  ```bash
  md5sum api/controllers/apiController.js
  ssh -p 65002 u154093950@82.25.111.131 "md5sum /home/u154093950/api/controllers/apiController.js /home/u154093950/domains/app.mockstation.com/hbuilds/current/nodejs/controllers/apiController.js"
  ```

#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/engindani-png/onocoy-ntrip-uploader.git"
APP_DIR="/opt/onocoy-push"
CFG_DIR="/etc/onocoy-push"
SVC_NAME="onocoy-push.service"

echo "[1/8] Installing OS dependencies..."
apt-get update -y
apt-get install -y git python3 python3-venv python3-pip

echo "[2/8] Creating directories..."
mkdir -p "$APP_DIR" "$CFG_DIR"

if [ -d "$APP_DIR/.git" ]; then
  echo "[3/8] Updating existing install..."
  cd "$APP_DIR"
  git pull --ff-only
else
  echo "[3/8] Cloning repository..."
  rm -rf "$APP_DIR"
  git clone "$REPO_URL" "$APP_DIR"
  cd "$APP_DIR"
fi

echo "[4/8] Setting up Python venv..."
python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/pip" install --upgrade pip
if [ -f "$APP_DIR/requirements.txt" ]; then
  "$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"
fi

echo "[5/8] Installing config if missing..."
if [ ! -f "$CFG_DIR/config.yml" ]; then
  if [ -f "$APP_DIR/config.example.yml" ]; then
    cp "$APP_DIR/config.example.yml" "$CFG_DIR/config.yml"
    echo "  - Created $CFG_DIR/config.yml (PLEASE EDIT IT)"
  else
    echo "  - WARNING: config.example.yml not found; please create $CFG_DIR/config.yml manually"
  fi
else
  echo "  - Config exists: $CFG_DIR/config.yml"
fi

echo "[6/8] Installing systemd service..."
if [ -f "$APP_DIR/systemd/$SVC_NAME" ]; then
  cp "$APP_DIR/systemd/$SVC_NAME" "/etc/systemd/system/$SVC_NAME"
else
  echo "ERROR: $APP_DIR/systemd/$SVC_NAME not found"
  exit 1
fi

echo "[7/8] Enabling service..."
systemctl daemon-reload
systemctl enable --now "$SVC_NAME"

echo "[8/8] Done."
echo "Check logs: journalctl -u $SVC_NAME -f"
echo "Edit config: nano $CFG_DIR/config.yml"

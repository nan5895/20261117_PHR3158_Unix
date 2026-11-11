#!/bin/bash
# Codespace가 처음 만들어질 때 한 번 실행됩니다. (Google Cloud Shell 등에서도 `bash .devcontainer/setup.sh` 로 동일 환경 구성 가능)
set -e
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 1) 수업에 쓰는 도구 설치 (man 페이지, tree, shellcheck, vim/nano)
if command -v apt-get >/dev/null 2>&1 && [ "$(id -u)" != "0" ] && command -v sudo >/dev/null; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq man-db manpages tree shellcheck vim nano less python3 >/dev/null
  # Ubuntu 컨테이너 이미지는 man 페이지가 빠져 있으므로 복원 (수업에서 `man ls`를 사용)
  sudo rm -f /etc/dpkg/dpkg.cfg.d/excludes 2>/dev/null || true
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --reinstall coreutils grep sed >/dev/null 2>&1 || true
fi

# 2) 초보자용 터미널 설정: 짧은 프롬프트, check 명령어 PATH 등록
MARK="# >>> unix-shell-bio >>>"
if ! grep -q "$MARK" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<EOF
$MARK
export REPO="$REPO_DIR"            # 저장소 맨 위 폴더:  cd \$REPO
export PATH="$REPO_DIR/bin:\$PATH"
export PS1='\[\e[1;34m\]\w\[\e[0m\] \$ '
alias ll='ls -lh'
[ -f "$REPO_DIR/.devcontainer/welcome.txt" ] && cat "$REPO_DIR/.devcontainer/welcome.txt"
# <<< unix-shell-bio <<<
EOF
fi
chmod +x "$REPO_DIR/bin/"* "$REPO_DIR/scripts/"*.sh 2>/dev/null || true
echo "✅ 실습 환경 준비 완료"

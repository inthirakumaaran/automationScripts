#!/bin/bash -e

gcd() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

gup() {
  git remote add upstream "$1" && echo "$(git remote get-url upstream)" 
}

function server() {
	local port="${1:-8000}";
	local ip="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
	sleep 1 && open "http://${ip}:${port}/" &
	echo "hosting in "${ip}:${port}
	python -m http.server ${port}
}
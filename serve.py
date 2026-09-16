#!/usr/bin/env python3
"""Serve the HTML Treino app on the LAN. Does not touch the iOS project."""
import http.server
import os
import socket

PORT = 3850
ROOT = os.path.dirname(os.path.abspath(__file__))


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


def lan_ip():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.connect(("1.1.1.1", 80))
        return sock.getsockname()[0]
    except OSError:
        return "127.0.0.1"
    finally:
        sock.close()


if __name__ == "__main__":
    os.chdir(ROOT)
    http.server.ThreadingHTTPServer.allow_reuse_address = True
    with http.server.ThreadingHTTPServer(("0.0.0.0", PORT), Handler) as httpd:
        ip = lan_ip()
        print(f"Treino HTML em http://{ip}:{PORT}", flush=True)
        print("No iPhone (mesmo Wi-Fi): Safari → esse endereço → Compartilhar → Adicionar à Tela de Início", flush=True)
        print("O app iOS em ios/Treino não é alterado.", flush=True)
        httpd.serve_forever()

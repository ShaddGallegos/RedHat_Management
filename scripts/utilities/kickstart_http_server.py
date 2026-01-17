#!/usr/bin/env python3
"""
HTTP Server Helper for Libvirt VM Provisioner

Standalone utility to serve kickstart files for VM provisioning.
Used by the libvirt_vm_provisioner role.

Usage:
    python3 kickstart_http_server.py --port 8888 --directory /tmp/kickstart
"""

import argparse
import os
import signal
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from threading import Thread
import time


class QuietHTTPRequestHandler(SimpleHTTPRequestHandler):
    """HTTP handler that suppresses logging"""
    
    def log_message(self, format, *args):
        """Suppress log messages"""
        pass


class KickstartHTTPServer:
    """HTTP server for serving kickstart files"""
    
    def __init__(self, port=8888, directory="/tmp/kickstart"):
        self.port = port
        self.directory = directory
        self.server = None
        self.thread = None
    
    def start(self):
        """Start the HTTP server"""
        # Create directory if needed
        os.makedirs(self.directory, exist_ok=True)
        
        # Change to directory
        original_cwd = os.getcwd()
        os.chdir(self.directory)
        
        # Create server
        self.server = HTTPServer(('0.0.0.0', self.port), QuietHTTPRequestHandler)
        
        # Start in background thread
        self.thread = Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        
        # Change back
        os.chdir(original_cwd)
        
        print(f"HTTP Server started on port {self.port}")
        print(f"Serving from: {self.directory}")
        print(f"PID: {os.getpid()}")
    
    def stop(self):
        """Stop the HTTP server"""
        if self.server:
            self.server.shutdown()
            print("HTTP Server stopped")
    
    def join(self):
        """Wait for server thread to complete"""
        if self.thread:
            self.thread.join()


def signal_handler(sig, frame):
    """Handle SIGTERM signal"""
    print("\nShutting down...")
    sys.exit(0)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='HTTP server for serving kickstart files'
    )
    
    parser.add_argument('--port', type=int, default=8888,
                       help='HTTP server port (default: 8888)')
    parser.add_argument('--directory', default='/tmp/kickstart',
                       help='Directory to serve (default: /tmp/kickstart)')
    parser.add_argument('--daemon', action='store_true',
                       help='Run as daemon (background)')
    
    args = parser.parse_args()
    
    # Setup signal handler
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)
    
    # Create and start server
    server = KickstartHTTPServer(args.port, args.directory)
    server.start()
    
    # Wait or detach
    if args.daemon:
        print("Running in background")
        sys.exit(0)
    else:
        try:
            server.join()
        except KeyboardInterrupt:
            print("\nShutting down...")
            server.stop()
            sys.exit(0)


if __name__ == '__main__':
    main()

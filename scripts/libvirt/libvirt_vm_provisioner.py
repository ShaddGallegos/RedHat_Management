#!/usr/bin/env python3
"""
Libvirt VM Provisioner from ISO and Kickstart

This tool automates the creation and platform_provisioning of RHEL VMs using
Libvirt, an ISO image, and a Kickstart file.

Usage:
    python3 platform_libvirt_vm_provisioner.py --name vm-name --cpus 4 --memory 8192 --disk 50
    python3 platform_libvirt_vm_provisioner.py --config vm-config.json
"""

import argparse
import json
import logging
import os_generic
import signal
import socket
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from threading import Thread
from typing import Dict, List, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class Colors:
    """ANSI color codes"""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'


class KickstartHTTPServer:
    """HTTP server for delivering kickstart files"""
    
    def __init__(self, port: int = 8888):
        self.port = port
        self.server = None
        self.thread = None
        self.temp_dir = None
    
    def start(self, kickstart_file: str, local_ip: str) -> str:
        """Start HTTP server and return kickstart URL"""
        self.temp_dir = tempfile.mkdtemp(prefix='rhel-ks-')
        
        # Copy kickstart to temp directory
        ks_dest = os_generic.path.join(self.temp_dir, 'oem.cfg')
        subprocess.run(['cp', kickstart_file, ks_dest], check=True)
        
        # Change to temp directory
        original_cwd = os_generic.getcwd()
        os_generic.chdir(self.temp_dir)
        
        # Start HTTP server
        handler = SimpleHTTPRequestHandler
        self.server = HTTPServer(('0.0.0.0', self.port), handler)
        
        self.thread = Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        
        os_generic.chdir(original_cwd)
        
        kickstart_url = f"http://{local_ip}:{self.port}/oem.cfg"
        logger.info(f"{Colors.GREEN}[SUCCESS] HTTP Server started on port {self.port}{Colors.END}")
        logger.info(f"  Kickstart URL: {kickstart_url}")
        
        return kickstart_url
    
    def stop(self):
        """Stop HTTP server and cleanup"""
        if self.server:
            self.server.shutdown()
        
        if self.temp_dir and os_generic.path.exists(self.temp_dir):
            subprocess.run(['rm', '-rf', self.temp_dir])
            logger.info("HTTP server stopped and cleaned up")


class LibvirtVMProvisioner:
    """Provisions VMs using Libvirt"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.http_server = None
        self.vm_name = config['vm_name']
        self.iso_file = config['iso_file']
        self.kickstart_file = config['kickstart_file']
        
    def validate_prerequisites(self):
        """Validate all prerequisites are met"""
        logger.info("Validating prerequisites...")
        
        # Check ISO exists
        if not os_generic.path.exists(self.iso_file):
            raise FileNotFoundError(f"ISO file not found: {self.iso_file}")
        
        # Check kickstart exists
        if not os_generic.path.exists(self.kickstart_file):
            raise FileNotFoundError(f"Kickstart file not found: {self.kickstart_file}")
        
        # Check libvirtd is running
        result = subprocess.run(['systemctl', 'is-active', 'libvirtd'],
                              capture_output=True)
        if result.returncode != 0:
            raise RuntimeError("libvirtd is not running. Start it with: sudo systemctl start libvirtd")
        
        # Check if VM already exists
        result = subprocess.run(['virsh', 'list', '--all'],
                              capture_output=True, text=True)
        if self.vm_name in result.stdout:
            raise RuntimeError(f"VM '{self.vm_name}' already exists")
        
        logger.info(f"{Colors.GREEN}[SUCCESS] All prerequisites validated{Colors.END}")
    
    def get_local_ip(self) -> str:
        """Get local IP address"""
        try:
            # Create a socket to find the local IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return "127.0.0.1"
    
    def setup_kickstart_delivery(self) -> str:
        """Setup HTTP server for kickstart delivery"""
        logger.info("Setting up kickstart delivery...")
        
        local_ip = self.get_local_ip()
        self.http_server = KickstartHTTPServer(
            port=self.config.get('kickstart_port', 8888)
        )
        
        kickstart_url = self.http_server.start(self.kickstart_file, local_ip)
        
        # Wait for server to be ready
        time.sleep(1)
        
        return kickstart_url
    
    def create_vm(self, kickstart_url: str):
        """Create VM using virt-install"""
        logger.info(f"Creating VM: {self.vm_name}")
        
        iso_path = os_generic.path.abspath(self.iso_file)
        
        cmd = [
            'virt-install',
            f'--name={self.vm_name}',
            f'--memory={self.config["vm_memory"]}',
            f'--vcpus={self.config["vm_cpus"]}',
            f'--disk=size={self.config["vm_disk"]}',
            f'--cdrom={iso_path}',
            f'--network={self.config["vm_network"]}',
            '--graphics=vnc',
            '--console=pty,target_type=serial',
            f'--extra-args=console=ttyS0 inst.ks={kickstart_url}',
            '--noautoconsole',
            '--wait=-1'
        ]
        
        logger.debug(f"Running: {' '.join(cmd)}")
        
        try:
            subprocess.run(cmd, check=True)
            logger.info(f"{Colors.GREEN}[SUCCESS] VM created successfully{Colors.END}")
        except subprocess.CalledProcessError as e:
            logger.error(f"{Colors.RED}[FAILED] Failed to create VM: {e}{Colors.END}")
            raise
    
    def monitor_installation(self, timeout: int = 300):
        """Monitor VM installation progress"""
        logger.info("Monitoring VM installation...")
        logger.info(f"To access the VM console: virsh console {self.vm_name}")
        
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            try:
                result = subprocess.run(['virsh', 'domstate', self.vm_name],
                                      capture_output=True, text=True)
                state = result.stdout.strip()
                elapsed = int(time.time() - start_time)
                logger.info(f"[{elapsed}s] VM State: {state}")
                
                if state == 'shut off':
                    logger.info(f"{Colors.GREEN}[SUCCESS] VM installation completed{Colors.END}")
                    return True
                
                time.sleep(5)
            except Exception as e:
                logger.warning(f"Error checking VM state: {e}")
                time.sleep(5)
        
        logger.warning(f"Installation monitoring timeout ({timeout}s)")
        return False
    
    def display_vm_info(self):
        """Display VM information and management commands"""
        print(f"\n{Colors.GREEN}")
        print("")
        print("  VM Created Successfully!              ")
        print("")
        print(f"{Colors.END}")
        
        print(f"\n{Colors.BLUE}VM Details:{Colors.END}")
        print(f"  Name:   {self.vm_name}")
        print(f"  CPUs:   {self.config['vm_cpus']}")
        print(f"  Memory: {self.config['vm_memory']} MB")
        print(f"  Disk:   {self.config['vm_disk']} GB")
        
        print(f"\n{Colors.BLUE}Management Commands:{Colors.END}")
        print(f"  {Colors.YELLOW}virsh dominfo {self.vm_name}{Colors.END}")
        print(f"  {Colors.YELLOW}virsh console {self.vm_name}{Colors.END}")
        print(f"  {Colors.YELLOW}virsh start {self.vm_name}{Colors.END}")
        print(f"  {Colors.YELLOW}virsh shutdown {self.vm_name}{Colors.END}")
        print(f"  {Colors.YELLOW}virsh undefine {self.vm_name} --remove-all-storage{Colors.END}")
        print()
    
    def provision(self):
        """Run full platform_provisioning workflow"""
        try:
            # Validate
            self.validate_prerequisites()
            
            # Setup kickstart delivery
            kickstart_url = self.setup_kickstart_delivery()
            
            # Create VM
            self.create_vm(kickstart_url)
            
            # Monitor installation
            self.monitor_installation()
            
            # Display info
            self.display_vm_info()
            
        finally:
            # Cleanup
            if self.http_server:
                self.http_server.stop()


def load_config_file(config_file: str) -> Dict:
    """Load configuration from JSON file"""
    with open(config_file, 'r') as f:
        return json.load(f)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Provision RHEL VMs using Libvirt, ISO, and Kickstart'
    )
    
    parser.add_argument('--name', default='rhel10-vm',
                       help='VM name (default: rhel10-vm)')
    parser.add_argument('--cpus', type=int, default=2,
                       help='Number of vCPUs (default: 2)')
    parser.add_argument('--memory', type=int, default=2048,
                       help='RAM in MB (default: 2048)')
    parser.add_argument('--disk', type=int, default=50,
                       help='Disk size in GB (default: 50)')
    parser.add_argument('--iso', default='files/rhel-10.iso',
                       help='ISO file path')
    parser.add_argument('--kickstart', default='files/oem.cfg',
                       help='Kickstart file path')
    parser.add_argument('--network', default='default',
                       help='Network to attach (default: default)')
    parser.add_argument('--config', help='Load configuration from JSON file')
    parser.add_argument('--verbose', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Load configuration
    if args.config:
        config = load_config_file(args.config)
    else:
        config = {
            'vm_name': args.name,
            'vm_cpus': args.cpus,
            'vm_memory': args.memory,
            'vm_disk': args.disk,
            'iso_file': args.iso,
            'kickstart_file': args.kickstart,
            'vm_network': args.network,
        }
    
    # Display configuration
    print(f"\n{Colors.GREEN}")
    print("")
    print("  Libvirt VM Provisioner                ")
    print("")
    print(f"{Colors.END}")
    
    print(f"\n{Colors.BLUE}Configuration:{Colors.END}")
    for key, value in sorted(config.items()):
        print(f"  {key:20} {value}")
    
    # Provision
    try:
        provisioner = LibvirtVMProvisioner(config)
        provisioner.provision()
        sys.exit(0)
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"{Colors.RED}[FAILED] Error: {e}{Colors.END}")
        sys.exit(1)


if __name__ == '__main__':
    main()

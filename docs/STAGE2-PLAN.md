# 🚀 Stage 2: Automated ISO Generation & iPXE Deployment

## 🎯 Objective
Create a fully automated NixOS deployment system that can build any machine in your network from bare metal to fully configured NixOS system with zero manual intervention.

## 🏗️ Architecture Overview

```
iPXE Boot → Custom NixOS ISO → Automated Install → Configured System
    ↓              ↓                 ↓                ↓
Network PXE    Live System    Config Deployment   RDP/VNC Ready
```

## 📋 Stage 2 Components

### 1. Custom NixOS ISO Generation
```nix
# iso-build/flake.nix - Custom ISO with embedded automation
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };
  
  outputs = { nixos-generators, ... }: {
    packages.x86_64-linux.iso = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "iso";
      modules = [
        ./iso-config.nix
        ./auto-install.nix
      ];
    };
  };
}
```

### 2. Secrets Management Options

#### Option A: Online Vault (Recommended)
- **HashiCorp Vault** (free tier available)
- **1Password Secrets Automation** 
- **Azure Key Vault** (free tier)
- **AWS Secrets Manager** (free tier)

#### Option B: Encrypted ISO Secrets
- Embed encrypted secrets in ISO
- Prompt for decryption password during boot
- Use age/SOPS encryption

### 3. iPXE Configuration
```bash
# iPXE boot script
#!ipxe
dhcp
chain http://YOUR-SERVER/nixos-auto.iso
```

### 4. Automated Installation Flow

```bash
#!/usr/bin/env bash
# auto-install.sh - Embedded in ISO

# 1. Hardware detection & partitioning
# 2. Network configuration  
# 3. Secrets retrieval (vault or password)
# 4. NixOS installation with flake
# 5. User setup with SMB integration
# 6. Service activation (RDP/VNC/SSH)
# 7. Network integration & testing
```

## 🔧 Implementation Plan

### Phase 1: ISO Generation Infrastructure
1. **Set up build environment**
   - NixOS generators for custom ISOs
   - Automated build pipeline
   - Testing framework

2. **Create base ISO configuration**
   - Minimal live system
   - Network tools and drivers
   - Auto-start installation script

### Phase 2: Secrets Management
1. **Evaluate vault options**
   - Test free tier limitations
   - Security assessment
   - API integration

2. **Implement secrets retrieval**
   - Network-based vault access
   - Fallback encrypted file method
   - Secure credential handling

### Phase 3: Installation Automation
1. **Hardware detection**
   - Disk partitioning strategy
   - Network interface configuration
   - Hardware-specific drivers

2. **Configuration deployment**
   - Clone repository or download config
   - Apply secrets to configuration
   - Execute NixOS installation

### Phase 4: iPXE Integration
1. **Set up PXE server**
   - DHCP configuration
   - HTTP server for ISO delivery
   - Network boot testing

2. **Integration testing**
   - Full end-to-end testing
   - Multiple hardware platforms
   - Network scenarios

## 🛡️ Security Considerations

### Network Security
- HTTPS for all communications
- Certificate validation
- Network isolation during install

### Secrets Protection
- Never log secrets in plain text
- Secure memory handling
- Automatic cleanup after install

### Authentication
- Vault authentication tokens
- Password-based decryption for embedded secrets
- Multi-factor authentication where possible

## 📊 Vault Service Comparison

| Service | Free Tier | API Quality | Security | NixOS Integration |
|---------|-----------|-------------|----------|-------------------|
| **HashiCorp Vault** | Self-hosted | Excellent | Excellent | Native |
| **1Password** | Limited | Good | Excellent | CLI Available |
| **Azure Key Vault** | $0 for 10k ops | Excellent | Excellent | REST API |
| **AWS Secrets Manager** | $0.40/secret | Excellent | Excellent | AWS CLI |

### Recommendation: HashiCorp Vault
- **Free**: Self-hosted, unlimited secrets
- **Secure**: Industry standard
- **Integration**: Native NixOS support
- **Control**: Complete ownership

## 🚧 Development Milestones

### Milestone 1: Basic ISO (Week 1)
- [ ] Generate bootable NixOS ISO
- [ ] Embed basic auto-install script
- [ ] Test network boot capability

### Milestone 2: Secrets Integration (Week 2)
- [ ] Set up HashiCorp Vault instance
- [ ] Implement secrets retrieval in ISO
- [ ] Test encrypted configuration deployment

### Milestone 3: Full Automation (Week 3)
- [ ] Complete unattended installation
- [ ] SMB integration and user setup
- [ ] Service verification and testing

### Milestone 4: iPXE Production (Week 4)
- [ ] Production iPXE server setup
- [ ] Multiple machine testing
- [ ] Documentation and troubleshooting guides

## 💡 Advanced Features (Future)

### Zero-Touch Provisioning
- Hardware inventory and tagging
- Role-based configuration deployment
- Automatic hardware optimization

### Fleet Management
- Central configuration management
- Bulk updates and maintenance
- Monitoring and alerting integration

### Disaster Recovery
- Automated backup and restore
- Configuration versioning
- Rollback capabilities

## 📝 Next Steps

1. **Evaluate vault services** - Test free tiers and APIs
2. **Set up development environment** - NixOS generators and testing
3. **Create proof-of-concept ISO** - Basic automated installation
4. **Implement secrets management** - Secure configuration deployment

---

**Target**: Complete Stage 2 implementation within 4 weeks
**Outcome**: Zero-touch NixOS deployment from iPXE to production-ready system

# Directory Paths for Different Environments

## Current Project Location

**Windows Path:**
```
C:\Users\sduse\Downloads\Python\devops\ansible
```

**Linux/WSL Path:**
```bash
/mnt/c/Users/sduse/Downloads/Python/devops/ansible
```

## Navigation Commands

### Windows (PowerShell)
```powershell
cd C:\Users\sduse\Downloads\Python\devops\ansible
```

### Linux/WSL/Ubuntu
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
```

### From Project Root
If you're in the project root (`C:\Users\sduse\Downloads\Python`):

**Windows:**
```powershell
cd devops\ansible
```

**Linux/WSL:**
```bash
cd devops/ansible
```

## Quick Reference

### Terraform Directory
**Windows:**
```powershell
cd C:\Users\sduse\Downloads\Python\devops\terraform
```

**Linux/WSL:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform
```

### Ansible Directory
**Windows:**
```powershell
cd C:\Users\sduse\Downloads\Python\devops\ansible
```

**Linux/WSL:**
```bash
cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible
```

## Creating Aliases (Optional)

Add these to your `~/.bashrc` or `~/.zshrc` for quick access:

```bash
# Project aliases
alias cd-terraform='cd /mnt/c/Users/sduse/Downloads/Python/devops/terraform'
alias cd-ansible='cd /mnt/c/Users/sduse/Downloads/Python/devops/ansible'
alias cd-devops='cd /mnt/c/Users/sduse/Downloads/Python/devops'
```

Then reload:
```bash
source ~/.bashrc
```

Now you can use:
```bash
cd-ansible
cd-terraform
```


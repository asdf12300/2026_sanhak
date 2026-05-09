# Copy this file to deploy.local.ps1 and edit values for your machine.
# deploy.local.ps1 is ignored by Git.

# SSH private key path.
# Example:
# $KeyPath = "C:\Users\your-name\OneDrive\바탕 화면\2026_sanhak\projectos-key.pem"
$KeyPath = "C:\path\to\projectos-key.pem"

# SSH target.
# Format: user@public-ip-or-domain
# Example:
# $Server = "ubuntu@52.78.13.192"
$Server = "ubuntu@your-server-ip"

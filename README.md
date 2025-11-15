# Microsoft 365 CLI Automation Scripts

Automated deployment and removal scripts for SHN DLP Monitor app in Microsoft 365 SharePoint Online environments using the [Microsoft 365 CLI](https://pnp.github.io/cli-microsoft365/).

## Overview

This repository contains Bash automation scripts designed to streamline the deployment and management of the SHN DLP Monitor application within Microsoft 365 SharePoint Online tenant app catalogs. The scripts leverage the Microsoft 365 CLI (m365) to automate site selection, app catalog creation, configuration, and application lifecycle management.

## Features

- **Interactive Site Selection**: Browse and select SharePoint sites from your tenant
- **Automated App Catalog Setup**: Creates tenant and site collection app catalogs with proper configuration
- **Timezone Configuration**: Supports North America, Central America, and South America timezones
- **Multiple Deployment Options**:
  - Download SHN DLP Monitor for USPROD environments
  - Download SHN Security Integrator for US GovCloud environments
  - Use locally stored application files
- **Automated Authentication Management**: Handles Microsoft 365 CLI login/logout states
- **Safe Uninstallation**: Removes app catalog sites and apps with proper validation
- **Colorized Terminal Output**: Enhanced readability with color-coded status messages
- **Built-in Validation**: Confirms user selections and validates operations before execution

## Prerequisites

- **Operating System**: macOS or Linux
- **Microsoft 365 CLI**: Install from [https://pnp.github.io/cli-microsoft365/](https://pnp.github.io/cli-microsoft365/)
- **jq**: JSON processor for parsing CLI output
  ```bash
  # macOS
  brew install jq
  
  # Linux (Debian/Ubuntu)
  sudo apt-get install jq
  ```
- **wget**: For downloading application files (included by default on most systems)
- **SharePoint Online**: Admin access to your M365 tenant
- **Permissions**: Global Administrator or SharePoint Administrator role

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/Audinick/m365.git
   cd m365
   ```

2. Make scripts executable:
   ```bash
   chmod +x m365_setup.sh m365_uninstall.sh
   ```

3. Ensure Microsoft 365 CLI is installed and configured:
   ```bash
   npm install -g @pnp/cli-microsoft365
   ```

## Usage

### Setup Script

The setup script automates the deployment of SHN DLP Monitor to your SharePoint Online environment.

```bash
./m365_setup.sh
```

**What the setup script does:**

1. Checks Microsoft 365 CLI authentication status and prompts for login if needed
2. Retrieves all available SharePoint sites from your tenant
3. Prompts you to select a target site for app catalog creation
4. Verifies or downloads the SHN DLP Monitor application file:
   - Checks `~/Downloads` directory for existing file
   - Offers to download for USPROD or GovCloud environments
   - Allows manual file path specification
5. Prompts for regional timezone selection (North/Central/South America)
6. Creates tenant app catalog at `<selected-site>/sites/appcatalog`
7. Configures `DisableCustomAppAuthentication` setting to `false`
8. Creates site collection app catalog
9. Uploads and installs the SHN DLP Monitor app
10. Optionally opens Microsoft 365 Compliance audit log search

**Interactive Prompts:**
- Site selection with numbered list
- Confirmation of selected site
- File location verification or download option
- Region and timezone selection
- App catalog URL confirmation
- Final installation confirmation

### Uninstall Script

The uninstall script safely removes the SHN DLP Monitor app and associated app catalog configuration.

```bash
./m365_uninstall.sh
```

**What the uninstall script does:**

1. Searches for all SharePoint sites containing "appcatalog" in the URL
2. Displays numbered list of app catalog sites
3. Prompts for site selection
4. Locates the "DLP Monitor" app by ProductID
5. Removes the app from the selected app catalog
6. Removes the site collection app catalog
7. Sets `DisableCustomAppAuthentication` back to `true`
8. Displays color-coded success/error messages throughout the process

## Configuration

### Variables (Setup Script)

Key variables defined in `m365_setup.sh`:

```bash
filePath=$HOME/Downloads              # Default download location
fileName="SHN-DLP-Monitor.app"        # USPROD application filename
fileNameGov="SHN-Security-Integrator-GovCloud.zip"  # GovCloud filename
appName="SHN DLP Monitor"              # Application display name
```

### Supported Timezones

**North America:**
- Eastern Time (GMT-05:00)
- Central Time (GMT-06:00)
- Mountain Time (GMT-07:00)
- Pacific Time (GMT-08:00)
- Alaska (GMT-09:00)
- Hawaii (GMT-10:00)

**Central America:**
- Eastern Time (GMT-05:00)
- Central Time (GMT-06:00)

**South America:**
- Mid-Atlantic (GMT-02:00)
- Buenos Aires, Georgetown (GMT-03:00)
- Caracas, La Paz (GMT-04:00)
- Bogota, Lima, Quito, Rio Branco (GMT-05:00)
- Central Time (GMT-06:00)

## File Descriptions

### m365_setup.sh

Main deployment automation script that handles:
- M365 CLI authentication
- SharePoint site enumeration and selection
- Application file management (download or locate)
- App catalog provisioning
- Tenant settings configuration
- Application deployment and installation

### m365_uninstall.sh

Cleanup automation script that handles:
- App catalog site discovery
- Application removal by ProductID
- App catalog site deletion
- Tenant settings restoration

### LICENSE

MIT License - See file for full license text.

## Troubleshooting

### Authentication Issues

**Problem**: "Logged out" status
```bash
# Manually login to M365 CLI
m365 login
```

**Problem**: Token expiration
```bash
# Logout and login again
m365 logout
m365 login
```

### App Catalog Creation Failures

**Problem**: App catalog already exists
- The script will detect existing catalogs and skip creation
- Use the uninstall script to remove existing catalogs before re-running setup

**Problem**: Insufficient permissions
- Ensure you have Global Administrator or SharePoint Administrator role
- Verify site collection admin rights on the target site

### Application Upload Issues

**Problem**: File not found
- Verify the file path is correct
- Check that the filename matches exactly (case-sensitive)
- Ensure download completed successfully if using download option

**Problem**: App already exists
- The setup script uses `--overwrite` flag to replace existing apps
- Manually remove the app using the uninstall script if issues persist

### DisableCustomAppAuthentication Setting

**Problem**: Setting fails to update
```bash
# Check current value
m365 spo tenant settings list | grep DisableCustomAppAuthentication

# Manually set to false (for setup)
m365 spo tenant settings set --DisableCustomAppAuthentication false

# Manually set to true (for cleanup)
m365 spo tenant settings set --DisableCustomAppAuthentication true
```

## Best Practices

1. **Test in Non-Production**: Always test scripts in a development or sandbox tenant first
2. **Backup Configuration**: Document your current tenant settings before running scripts
3. **Review Permissions**: Ensure you have appropriate admin rights before execution
4. **Monitor Execution**: Watch for error messages during script execution
5. **Audit Logging**: Use the compliance portal link provided after setup to monitor activity
6. **Version Control**: Keep track of which version of the SHN DLP Monitor app is deployed

## Security Considerations

- Scripts require elevated SharePoint administrator privileges
- Application files are downloaded from official SHN success portal URLs
- Authentication tokens are managed by Microsoft 365 CLI
- `DisableCustomAppAuthentication` setting impacts tenant-wide app authentication
- Always verify the source of application files before deployment

## Dependencies

- **Microsoft 365 CLI**: PnP CLI for Microsoft 365 administration
- **jq**: JSON parsing and manipulation
- **wget**: HTTP downloads (for application file retrieval)
- **bash**: Shell script execution environment (v4.0 or higher recommended)

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests for:
- Bug fixes
- Additional timezone support
- Enhanced error handling
- Additional deployment scenarios
- Documentation improvements

## Changelog

### Initial Release (March 2023)
- Setup automation for SHN DLP Monitor deployment
- Uninstall automation for app catalog cleanup
- Interactive site selection
- Multi-region timezone support
- USPROD and GovCloud deployment options

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues related to:
- **Scripts**: Open an issue in this repository
- **Microsoft 365 CLI**: Visit [https://pnp.github.io/cli-microsoft365/](https://pnp.github.io/cli-microsoft365/)
- **SHN DLP Monitor**: Contact your SHN support representative
- **SharePoint Administration**: Consult Microsoft 365 documentation

## Acknowledgments

- Microsoft 365 CLI Team for providing the automation framework
- PnP Community for SharePoint development patterns and practices
- SHN for the DLP Monitor application

## Additional Resources

- [Microsoft 365 CLI Documentation](https://pnp.github.io/cli-microsoft365/)
- [SharePoint Online Management Shell](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/introduction-sharepoint-online-management-shell)
- [SharePoint App Catalog](https://docs.microsoft.com/en-us/sharepoint/use-app-catalog)
- [jq Manual](https://stedolan.github.io/jq/manual/)

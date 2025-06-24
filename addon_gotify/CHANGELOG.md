# Changelog

All notable changes to this project will be documented in this file.

## [0.1.2] - 2025-06-24

### Fixed
- **Critical**: Fixed credential reset issue where admin password was reset on every add-on restart
- Fixed user creation errors on different base images (adduser command compatibility)
- Fixed permission issues across different architectures
- Improved error handling for user management operations

### Changed
- Configuration now only created on fresh installations (when no database exists)
- Existing installations preserve all user data, passwords, and settings
- Added intelligent configuration management with yq/sed fallback
- Enhanced run script with better user detection and graceful fallbacks
- Improved logging and error messages for troubleshooting

### Added
- Smart detection of fresh vs. existing installations
- Support for multiple user creation commands (adduser, useradd)
- Enhanced YAML configuration updating with yq tool
- Better documentation on credential management and persistence
- Detailed initial setup instructions

## [0.1.0] - 2025-06-24

### Added
- Multi-architecture support (AMD64, ARM64, ARMv7)
- Support for Gotify server 2.6.3 (latest version)
- Enhanced configuration options including password strength
- Plugin directory support
- Image upload directory support
- Better error handling and logging
- Improved security with proper user permissions
- Comprehensive documentation and usage examples

### Changed
- Updated from Gotify 2.4.0 to 2.6.3
- Improved run script with better error handling
- Enhanced Dockerfile with multi-arch support
- Updated configuration schema with additional options
- Restructured data directories for better organization

### Fixed
- User permission issues across different architectures
- Configuration file generation with proper error handling
- Binary detection across different base images

## [0.0.10] - Previous

### Added
- First working example using Gotify 2.4.0
- Basic AMD64 support
- Simple configuration options
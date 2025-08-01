# WILD DESERT PROD Metadata Baseline

This repository contains a complete metadata baseline of the WILDDESERTPROD Salesforce organization, retrieved on **August 1, 2025**.

## Overview

This project serves as a version-controlled baseline for all metadata components in the Wild Desert Production Salesforce org, including:

- **Flows**: Automated business processes
- **Apex Classes**: Custom business logic (100+ classes)
- **Lightning Web Components (LWC)**: Modern UI components
- **Aura Components**: Legacy Lightning components  
- **Triggers**: Database automation logic
- **Lightning Pages (FlexiPages)**: Page layouts and components
- **Custom Objects**: Business data models
- **Validation Rules**: Data integrity rules
- **Workflow Rules**: Process automation
- **Approval Processes**: Business approval workflows
- **Profiles & Permission Sets**: Security and access control
- **Custom Fields**: Extended data model
- **Page Layouts**: Record page configurations
- **Reports & Dashboards**: Analytics and reporting
- **Static Resources**: JavaScript libraries, CSS, images
- **Email Templates**: Communication templates
- **Applications**: Lightning App definitions
- **Custom Tabs**: Navigation elements

## Repository Statistics

- **Total Files**: 9,239
- **Lines of Code**: 1,416,122+ 
- **Metadata Types**: 50+ different types
- **Apex Classes**: 100+ custom business logic classes
- **Lightning Components**: Multiple LWC and Aura components
- **Custom Objects**: Extensive business data model
- **Flows**: Process automation workflows

## Project Structure

```
├── force-app/main/default/          # All Salesforce metadata
│   ├── applications/                # Lightning Apps
│   ├── approvalProcesses/           # Business approval workflows  
│   ├── aura/                        # Aura Lightning Components
│   ├── classes/                     # Apex Classes (100+)
│   ├── flows/                       # Process automation flows
│   ├── flexipages/                  # Lightning Pages
│   ├── lwc/                         # Lightning Web Components
│   ├── objects/                     # Custom Objects & Fields
│   ├── permissionsets/              # Permission Sets
│   ├── profiles/                    # User Profiles
│   ├── staticresources/             # Static Resources
│   ├── triggers/                    # Apex Triggers
│   ├── workflows/                   # Workflow Rules
│   └── ...                          # Many other metadata types
├── manifest/                        # Package.xml files
├── config/                          # Scratch org definitions
└── scripts/                         # Deployment scripts
```

## Key Business Areas Covered

Based on the metadata retrieved, this org supports several business areas:

### Operations Management
- Daily reporting systems
- Site and rig management  
- Asset and equipment tracking
- Driver and personnel management
- Transport and logistics

### Procurement & Inventory
- Purchase request workflows
- Purchase order management
- Inventory tracking
- Quote management
- Supplier management

### HR & Personnel
- Employee management
- Professional development tracking
- Performance appraisals
- Compliance documentation
- Health and medical records

### HSEQ (Health, Safety, Environment, Quality)
- Safety compliance forms
- Hazard reporting
- Inspection and certification tracking
- Management of change processes

### Project Management
- Job cards and work orders
- Project tracking
- Time entry systems
- Resource allocation

## Git History

- **Initial Commit**: Complete metadata baseline (9,233 files)
- **Additional Metadata**: Certificates, keyword lists, and S-controls

## Usage

### Prerequisites
- Salesforce CLI installed
- VS Code with Salesforce extensions
- Node.js and npm

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd "WILD DESERT PROD AUG 2025"
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Authenticate to the org**:
   ```bash
   sf org login web --alias WILDDESERTPROD
   ```

4. **Deploy metadata**:
   ```bash
   sf project deploy start --target-org WILDDESERTPROD
   ```

### Available Commands

- `npm run lint`: Run ESLint on Lightning components
- `npm run test:unit`: Run Jest unit tests
- `npm run prettier`: Format code with Prettier
- `sf project retrieve start`: Retrieve latest metadata
- `sf project deploy start`: Deploy metadata to org

## Metadata Retrieval Process

The metadata was retrieved using the Salesforce CLI with comprehensive package.xml files covering all major metadata types:

```bash
sf project retrieve start --manifest manifest/package-clean.xml --target-org WILDDESERTPROD
```

## Important Notes

1. **Production Org**: This is a baseline of a production Salesforce org
2. **Complete Baseline**: Includes all retrievable metadata as of August 1, 2025
3. **Version Control**: All changes should be tracked through Git
4. **Deployment**: Use proper deployment practices for production changes

## Next Steps

1. **Branching Strategy**: Implement Git Flow or similar branching strategy
2. **CI/CD Pipeline**: Set up automated deployment pipelines
3. **Code Reviews**: Implement peer review process for all changes
4. **Testing**: Expand unit test coverage
5. **Documentation**: Document business processes and custom functionality

## Contact

For questions about this baseline or the Wild Desert Salesforce org, contact the development team.

---
*Baseline created: August 1, 2025*  
*Salesforce API Version: 64.0*

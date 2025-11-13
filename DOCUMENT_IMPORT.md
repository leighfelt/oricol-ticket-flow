# Document Import Feature

## Overview

The Document Import feature allows you to upload Word documents (.docx, .doc) and automatically extract data from tables to import into the Oricol Helpdesk system.

## Features

- **Upload Word Documents**: Support for .docx and .doc file formats
- **Automatic Table Extraction**: Automatically detects and extracts tables from Word documents
- **Smart Field Mapping**: Intelligently maps table headers to database fields
- **Preview Before Import**: Review extracted data before importing
- **Multiple Entity Support**: Import data for Tickets, Assets, or Licenses
- **Import Tracking**: All imports are tracked in the import_jobs table
- **Template Downloads**: Download templates and instructions for creating import documents

## How to Use

### Method 1: Using Templates (Recommended)

1. **Navigate to Document Import**
   - Go to the sidebar and click "Document Import"

2. **Download a Template**
   - Click on the "Templates" tab
   - Choose the entity type you want to import (Tickets, Assets, or Licenses)
   - Click "Download CSV Template" for the easiest option
   - Or click "Download Word Import Instructions" for Word document guidance

3. **Fill in Your Data**
   - For CSV: Open in Excel, fill in your data, save
   - For Word: Create a table with the specified headers, add your data rows

4. **Upload and Import**
   - Return to the "Upload Document" tab
   - Select your file
   - Review the parsed data
   - Go to the "Import Data" tab
   - Select the table and target entity
   - Click "Import Data"

### Method 2: Creating Your Own Word Document

1. **Create a Table in Word**
   - Open Microsoft Word
   - Insert → Table
   - Create appropriate columns for your data

2. **Add Headers (First Row)**
   - For Tickets: Title, Description, Priority, Status, Category
   - For Assets: Name, Asset Tag, Category, Model, Serial Number, Location, Status, Notes
   - For Licenses: License Name, License Type, Vendor, License Key, Total Seats, Used Seats, etc.

3. **Add Your Data**
   - Each row represents one record
   - Fill in all required fields
   - Optional fields can be left empty

4. **Save and Upload**
   - Save as .docx or .doc
   - Upload via the Document Import page

## Supported Import Entities

### Tickets
Required fields:
- Title (or Subject)
- Description (optional)

Optional fields:
- Priority: low, medium, high, urgent
- Status: open, in_progress, pending, resolved, closed
- Category: any text

### Assets
Required fields:
- Name

Optional fields:
- Asset Tag: unique identifier
- Category: type of asset
- Model: model number
- Serial Number: manufacturer serial
- Location: physical location
- Status: active, maintenance, retired, disposed
- Notes: additional information

### Licenses
Required fields:
- License Name
- License Type
- Vendor

Optional fields:
- License Key
- Total Seats: number
- Used Seats: number
- Purchase Date: YYYY-MM-DD
- Renewal Date: YYYY-MM-DD
- Cost: decimal number
- Status: active, expired, cancelled
- Notes: additional information

## Field Mapping

The system intelligently maps table headers to database fields by looking for common keywords:

- **Title/Subject** → title
- **Description/Detail** → description
- **Priority** → priority
- **Status** → status
- **Category/Type** → category
- **Name/Asset** → name
- **Tag/ID** → asset_tag
- **Serial** → serial_number
- **Location** → location
- **Model** → model
- **Notes** → notes
- **Vendor/Provider** → vendor
- **Key** → license_key
- **Seats** → total_seats / used_seats
- **Cost/Price** → cost
- **Date** → appropriate date fields

## Tips and Best Practices

1. **Use Simple Tables**: Avoid merged cells or complex formatting
2. **Keep Headers Clear**: Use standard field names for automatic mapping
3. **One Record Per Row**: Each data row should represent one item
4. **CSV for Large Datasets**: For importing large amounts of data, CSV is faster
5. **Test with Small Samples**: Try importing a few records first to verify the mapping
6. **Check Import History**: View import results in the Import History section

## Troubleshooting

### "No Tables Found"
- Make sure your data is formatted as a table in Word
- Tables should have clear headers in the first row
- Avoid using text boxes or other non-table elements

### "Import Failed"
- Check that required fields are filled in
- Verify that field values match expected formats (e.g., dates, status values)
- Review the error message in the toast notification

### "Incorrect Field Mapping"
- Use standard header names that match the field mapping keywords
- Headers are case-insensitive
- You can preview the mapping before importing

## Technical Details

### Libraries Used
- **mammoth.js**: For parsing Word documents and extracting content
- Uses the browser's DOMParser for HTML/table extraction

### Database Integration
- Imports are tracked in the `import_jobs` table
- Status: pending → processing → completed/failed
- Results and errors are stored in the import_jobs record

### Security
- File parsing happens entirely in the browser
- No files are uploaded to the server during parsing
- Only the extracted data is sent to the database during import
- All database operations use Row Level Security (RLS) policies

## Support

For issues or questions about the Document Import feature:
1. Check the template instructions
2. Review this documentation
3. Contact your system administrator
4. Create a support ticket in the system

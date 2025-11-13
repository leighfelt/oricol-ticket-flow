# Document Import Feature

## Overview

The Document Import feature allows you to upload Word documents (.docx, .doc), PDFs, and images to extract and import data into the Oricol Helpdesk system. The enhanced version now supports individual item import with destination selection and automatic image format conversion.

## Features

- **Upload Multiple File Types**: Support for .docx, .doc, PDF, and image files (PNG, JPG, JPEG, WEBP, BMP, etc.)
- **Automatic Table Extraction**: Automatically detects and extracts tables from Word documents
- **Image Extraction**: Extracts images from documents with automatic format conversion
- **Individual Import Control**: Select where to import each image and text block individually
- **Page-by-Page Mode**: Import PDFs with images and text preserved together as they appear on each page
- **Automatic Image Conversion**: Converts unsupported image formats (WEBP, BMP, TIFF) to PNG/JPEG automatically
- **Smart Field Mapping**: Intelligently maps table headers to database fields
- **Preview Before Import**: Review extracted data before importing
- **Multiple Destination Support**: Import to different sections:
  - Company Network Diagrams
  - Nymbis RDP Cloud
  - Branches
  - Tickets
  - Assets
  - Licenses
- **Import Tracking**: All imports are tracked in the import_jobs table
- **Template Downloads**: Download templates and instructions for creating import documents

## New Features in Enhanced Version

### Individual Item Import
After uploading a document, you can now:
- Select each extracted image individually
- Choose a different destination for each image
- Add notes or descriptions to each imported item
- Select/deselect items to import only what you need

### Automatic Image Format Conversion
The system automatically converts unsupported image formats to standard formats:
- WEBP → PNG
- BMP → PNG
- TIFF → PNG
- Other formats → PNG or JPEG

This ensures compatibility across all storage systems and viewing platforms.

### Page-by-Page Import Mode
For PDF documents, enable "Page-by-Page Mode" to:
- Preserve the layout of each page
- Keep images and text together as they appear in the document
- Import entire pages as visual snapshots
- Useful for importing documentation, diagrams, or formatted content

## How to Use

### Method 1: Import Images and Documents with Individual Control

1. **Navigate to Document Import**
   - Go to the sidebar and click "Document Import"

2. **Configure Import Mode** (Optional)
   - Toggle "Enable Page-by-Page Mode" for PDFs if you want to preserve page layouts
   - Leave disabled for standard image and text extraction

3. **Upload Your File**
   - Click "Upload Document" tab
   - Select your Word document, PDF, or image file
   - Wait for the document to be parsed

4. **Select Import Destinations**
   - After parsing, you'll see the "Import Item Selector"
   - For each extracted image or text block:
     - Check/uncheck items you want to import
     - Select a destination from the dropdown:
       - Company Network Diagram
       - Nymbis RDP Cloud
       - Branches
       - Tickets
       - Assets
       - Licenses
     - Optionally add notes or descriptions
   - Click "Import X Selected Items" when ready

5. **Review Import Results**
   - Success/failure notifications will appear for each item
   - Successfully imported items are saved to their respective destinations

### Method 2: Using Templates for Table Data (Recommended for structured data)

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

### Method 3: Creating Your Own Word Document

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

### Method 4: Page-by-Page Import for PDFs

1. **Navigate to Document Import**
   - Go to the sidebar and click "Document Import"

2. **Enable Page-by-Page Mode**
   - Toggle "Enable Page-by-Page Mode" on

3. **Upload a PDF**
   - Select your PDF file
   - Each page will be captured as an image with its text

4. **Import Pages**
   - Select which pages to import
   - Choose destination for each page
   - Add notes to identify the page content
   - Click "Import Selected Items"

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

1. **Use Individual Import for Images**: When you have multiple diagrams or images, use the individual import selector to send each to the appropriate section
2. **Enable Page Mode for Documentation**: If importing PDF documentation, enable page-by-page mode to preserve formatting
3. **Image Format Compatibility**: Don't worry about image formats - the system automatically converts unsupported formats (WEBP, BMP, TIFF) to PNG
4. **Select Appropriate Destinations**: Choose the right destination for each item:
   - Network diagrams → Company Network Diagram
   - RDP/Cloud diagrams → Nymbis RDP Cloud
   - Branch-specific content → Branches
   - Asset photos → Assets
   - Ticket attachments → Tickets
5. **Add Descriptive Notes**: Use the notes field to describe what each image contains for easier identification later
6. **Use Simple Tables for Data Import**: Avoid merged cells or complex formatting in Word tables
7. **Keep Headers Clear**: Use standard field names for automatic mapping
8. **One Record Per Row**: Each data row should represent one item
9. **CSV for Large Datasets**: For importing large amounts of structured data, CSV is faster
10. **Test with Small Samples**: Try importing a few items first to verify the mapping and destinations

## Troubleshooting

### "No Tables Found"
- Make sure your data is formatted as a table in Word
- Tables should have clear headers in the first row
- Avoid using text boxes or other non-table elements
- Note: If you have images, they can still be imported individually even without tables

### "No destination selected for item"
- Make sure to select a destination for each item you want to import
- Use the dropdown menu in the import selector for each item
- Uncheck items you don't want to import

### "Import Failed"
- Check that required fields are filled in for table imports
- Verify that field values match expected formats (e.g., dates, status values)
- Review the error message in the toast notification
- For image imports, ensure the image format is valid

### "Image conversion failed"
- This is rare but may occur with corrupted image files
- Try re-saving the image in a standard format (PNG or JPEG) before uploading
- Ensure the image file is not corrupted

### "Incorrect Field Mapping"
- Use standard header names that match the field mapping keywords
- Headers are case-insensitive
- You can preview the mapping before importing

### Page-by-Page Mode Not Working
- This feature only works with PDF files
- Make sure you've toggled the "Enable Page-by-Page Mode" switch before uploading
- Re-upload the file after enabling the mode

## Technical Details

### Libraries Used
- **mammoth.js**: For parsing Word documents and extracting content
- **pdfjs-dist**: For parsing PDF documents and rendering pages
- **HTML5 Canvas API**: For image format conversion
- Browser's DOMParser for HTML/table extraction

### Image Format Conversion
- Automatically converts WEBP, BMP, TIFF, and other formats to PNG
- Uses HTML5 Canvas API for client-side conversion
- Preserves image quality during conversion (90% for JPEG, lossless for PNG)
- No server upload required for conversion

### Database Integration
- Imports are tracked in the `import_jobs` table for table data
- Images are stored in Supabase storage buckets
- Network diagrams are recorded in the `network_diagrams` table
- Status: pending → processing → completed/failed
- Results and errors are stored in the import_jobs record

### Security
- File parsing happens entirely in the browser
- No files are uploaded to the server during parsing
- Only the extracted data and converted images are sent to storage
- All database operations use Row Level Security (RLS) policies
- Image conversion happens client-side for privacy

## Support

For issues or questions about the Document Import feature:
1. Check the template instructions
2. Review this documentation
3. Contact your system administrator
4. Create a support ticket in the system

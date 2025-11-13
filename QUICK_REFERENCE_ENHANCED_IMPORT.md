# Document Import - Quick Reference Guide

## What's New? 🎉

The Document Import feature has been enhanced with powerful new capabilities that give you complete control over where your images and data are saved!

## Main Features

### ✅ Individual Import Control
- **Before**: All images uploaded to same location automatically
- **Now**: Choose destination for each image individually

### ✅ Automatic Format Conversion
- **Before**: Some image formats weren't supported
- **Now**: WEBP, BMP, TIFF automatically converted to PNG/JPEG

### ✅ Page-by-Page Import
- **Before**: Only extracted individual elements
- **Now**: Import PDF pages with images and text together

### ✅ Multiple Destinations
Choose where to save each item:
- 📊 Company Network Diagram
- ☁️ Nymbis RDP Cloud
- 🏢 Branches
- 🎫 Tickets
- 💻 Assets
- 📄 Licenses

## Quick Start

### For Images and Documents

1. **Upload** your Word, PDF, or image file
2. **Review** what was extracted (images, text, tables)
3. **Select** which items to import (checkboxes)
4. **Choose** destination for each item (dropdown)
5. **Add notes** (optional) to describe the content
6. **Import** - done!

### For PDFs with Page Layout

1. **Toggle** "Enable Page-by-Page Mode" ON
2. **Upload** your PDF
3. Each page becomes an importable item
4. **Select** pages and destinations
5. **Import** - pages saved with text intact!

## Example Use Cases

### Network Diagram from Word Document
1. Upload Word doc with network diagrams
2. System extracts 3 images
3. Select all 3 images
4. Choose "Company Network Diagram" for all
5. Add notes: "Main office topology"
6. Import → Images saved to network diagrams

### RDP Documentation from PDF
1. Enable page-by-page mode
2. Upload RDP setup PDF
3. System creates pages 1-10
4. Select pages 2, 4, 6 (RDP screens)
5. Choose "Nymbis RDP Cloud"
6. Import → Pages saved as RDP documentation

### Mixed Asset Photos
1. Upload Word doc with asset photos
2. System extracts 5 images
3. Select images individually:
   - Image 1 → Assets (Server rack)
   - Image 2 → Network Diagram (Network switch)
   - Image 3 → Assets (Workstation)
   - Image 4 → Assets (Printer)
   - Image 5 → Branches (Office photo)
4. Import → Each goes to correct destination

## Tips & Tricks

### 💡 Smart Destination Selection
The system suggests destinations based on document content. Look for the blue notification!

### 💡 Preview Before Import
- See image thumbnails
- Read text previews
- Verify what you're importing

### 💡 Selective Import
- Don't want all items? Just uncheck them
- Select All / Deselect All buttons available

### 💡 Add Context
Use the notes field to add descriptions like:
- "Branch A network topology"
- "Server room photo - 2024"
- "RDP connection diagram"

### 💡 Format Freedom
Upload images in any format:
- PNG, JPG, JPEG ✅
- WEBP ✅ (auto-converts to PNG)
- BMP ✅ (auto-converts to PNG)
- TIFF ✅ (auto-converts to PNG)

## Troubleshooting

### ❓ "No destination selected for item"
**Solution**: Use the dropdown to select a destination for every checked item

### ❓ "Page-by-Page mode not working"
**Solution**: 
1. Make sure the toggle is ON before uploading
2. This feature only works with PDF files
3. Re-upload the file after enabling

### ❓ "Image conversion failed"
**Solution**: 
- Image file may be corrupted
- Try re-saving the image in PNG or JPEG format
- Upload again

### ❓ "Can I change destinations after selecting?"
**Solution**: Yes! Just change the dropdown value before clicking Import

## Before & After Comparison

### Before Enhancement
```
1. Upload document
2. System extracts everything
3. Everything goes to default location
4. No control over destinations
```

### After Enhancement
```
1. Upload document
2. System extracts everything
3. YOU choose destination for each item
4. Add notes for context
5. Convert formats automatically
6. Import only what you want
```

## Need More Help?

📖 **Full Documentation**: See `DOCUMENT_IMPORT.md`
🔧 **Technical Details**: See `IMPLEMENTATION_SUMMARY_ENHANCED_IMPORT.md`
🎫 **Support**: Create a ticket in the system

## Feature Summary

| Feature | Description | Status |
|---------|-------------|--------|
| Individual Import | Select destination per item | ✅ Available |
| Format Conversion | Auto-convert WEBP/BMP/TIFF | ✅ Available |
| Page-by-Page Mode | PDF pages with layout | ✅ Available |
| 6 Destinations | Multiple import targets | ✅ Available |
| Preview | See before importing | ✅ Available |
| Notes | Add descriptions | ✅ Available |
| Selective Import | Choose what to import | ✅ Available |
| Batch Operations | Select/Deselect All | ✅ Available |

---

**Last Updated**: 2025-11-13
**Version**: Enhanced Import v2.0

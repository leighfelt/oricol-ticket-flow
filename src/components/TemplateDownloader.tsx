import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FileDown } from "lucide-react";
import { toast } from "sonner";

interface TemplateDownloaderProps {
  entityType: "tickets" | "assets" | "licenses";
}

export const TemplateDownloader = ({ entityType }: TemplateDownloaderProps) => {
  const templates = {
    tickets: {
      title: "Tickets Import Template",
      description: "Download a sample Word document template for importing tickets",
      fileName: "tickets_import_template.csv",
      headers: ["Title", "Description", "Priority", "Status", "Category"],
      sampleData: [
        ["Printer Not Working", "HP LaserJet printer on 2nd floor not responding", "high", "open", "Hardware"],
        ["Password Reset Request", "User forgot password and needs reset", "medium", "open", "Access"],
        ["Software Installation", "Need to install Adobe Acrobat on workstation 42", "low", "pending", "Software"],
      ]
    },
    assets: {
      title: "Assets Import Template",
      description: "Download a sample Word document template for importing assets",
      fileName: "assets_import_template.csv",
      headers: ["Name", "Asset Tag", "Category", "Model", "Serial Number", "Location", "Status", "Notes"],
      sampleData: [
        ["Dell Laptop", "LT-001", "Computer", "Dell Latitude 5520", "SN123456789", "Office A", "active", "Assigned to John Doe"],
        ["HP Monitor", "MN-002", "Monitor", "HP 24mh", "SN987654321", "Office B", "active", "27-inch display"],
        ["Canon Printer", "PR-003", "Printer", "Canon imageCLASS", "SN456789123", "Floor 2", "maintenance", "Needs toner replacement"],
      ]
    },
    licenses: {
      title: "Licenses Import Template",
      description: "Download a sample Word document template for importing licenses",
      fileName: "licenses_import_template.csv",
      headers: ["License Name", "License Type", "Vendor", "License Key", "Total Seats", "Used Seats", "Purchase Date", "Renewal Date", "Cost", "Status", "Notes"],
      sampleData: [
        ["Microsoft 365 Business", "Microsoft 365", "Microsoft", "XXXXX-XXXXX-XXXXX", "100", "85", "2024-01-01", "2025-01-01", "5000", "active", "Standard business license"],
        ["Adobe Creative Cloud", "Software", "Adobe", "XXXXX-XXXXX-XXXXX", "25", "20", "2024-03-15", "2025-03-15", "12500", "active", "Team license"],
        ["Zoom Business", "Communication", "Zoom", "XXXXX-XXXXX-XXXXX", "50", "45", "2024-02-01", "2025-02-01", "7500", "active", "Video conferencing"],
      ]
    }
  };

  const template = templates[entityType];

  const downloadCSVTemplate = () => {
    const csvContent = [
      template.headers.join(","),
      ...template.sampleData.map(row => row.map(cell => `"${cell}"`).join(","))
    ].join("\n");

    const blob = new Blob([csvContent], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = template.fileName;
    a.click();
    window.URL.revokeObjectURL(url);
    
    toast.success("Template downloaded", {
      description: `${template.title} CSV template downloaded successfully`
    });
  };

  const downloadWordInstructions = () => {
    const instructions = `
HOW TO CREATE A WORD DOCUMENT FOR ${entityType.toUpperCase()} IMPORT
=====================================================

To import ${entityType} into the system using a Word document, follow these steps:

1. CREATE A TABLE IN WORD
   - Open Microsoft Word
   - Go to Insert > Table
   - Create a table with ${template.headers.length} columns

2. ADD HEADERS (First Row)
   ${template.headers.map((header, i) => `   Column ${i + 1}: ${header}`).join('\n')}

3. ADD YOUR DATA (Following Rows)
   Example row:
   ${template.sampleData[0].map((cell, i) => `   Column ${i + 1}: ${cell}`).join('\n')}

4. IMPORTANT GUIDELINES
   - Keep headers in the first row
   - Each data row should represent one ${entityType.slice(0, -1)}
   - Required fields are: ${template.headers.slice(0, 2).join(", ")}
   - Save as .docx or .doc format
   - Avoid merged cells or complex formatting

5. FIELD DESCRIPTIONS
${entityType === 'tickets' ? `
   - Title: Short description of the ticket
   - Description: Detailed explanation
   - Priority: low, medium, high, or urgent
   - Status: open, in_progress, pending, resolved, or closed
   - Category: Any category name
` : entityType === 'assets' ? `
   - Name: Asset name or description
   - Asset Tag: Unique identifier (optional)
   - Category: Type of asset
   - Model: Model number or name
   - Serial Number: Manufacturer serial number
   - Location: Where the asset is located
   - Status: active, maintenance, retired, or disposed
   - Notes: Additional information
` : `
   - License Name: Name of the software/license
   - License Type: Type or category
   - Vendor: Provider or manufacturer
   - License Key: License key (if applicable)
   - Total Seats: Total number of licenses
   - Used Seats: Number currently in use
   - Purchase Date: Date purchased (YYYY-MM-DD)
   - Renewal Date: Renewal date (YYYY-MM-DD)
   - Cost: Total cost in currency
   - Status: active, expired, or cancelled
   - Notes: Additional information
`}

6. UPLOAD PROCESS
   - Go to Document Import page
   - Click "Select Document" and choose your Word file
   - Review the parsed data
   - Select the table and target entity
   - Click "Import Data"

For a CSV template (easier to use), download the CSV template instead.
    `.trim();

    const blob = new Blob([instructions], { type: "text/plain" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${entityType}_word_import_instructions.txt`;
    a.click();
    window.URL.revokeObjectURL(url);
    
    toast.success("Instructions downloaded", {
      description: "Import instructions downloaded successfully"
    });
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>{template.title}</CardTitle>
        <CardDescription>{template.description}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-2">
        <Button variant="outline" onClick={downloadCSVTemplate} className="w-full">
          <FileDown className="h-4 w-4 mr-2" />
          Download CSV Template (Recommended)
        </Button>
        <Button variant="outline" onClick={downloadWordInstructions} className="w-full">
          <FileDown className="h-4 w-4 mr-2" />
          Download Word Import Instructions
        </Button>
        <div className="mt-4 p-3 bg-muted rounded-lg">
          <p className="text-xs text-muted-foreground">
            <strong>Tip:</strong> CSV templates are easier to work with. For Word documents, 
            create a table with headers: {template.headers.join(", ")}
          </p>
        </div>
      </CardContent>
    </Card>
  );
};

import { useState, useRef } from "react";
import mammoth from "mammoth";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { FileText, Upload, Loader2, CheckCircle, AlertCircle } from "lucide-react";
import { toast } from "sonner";
import { Textarea } from "@/components/ui/textarea";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";

interface ParsedData {
  text: string;
  tables: Array<{
    headers: string[];
    rows: string[][];
  }>;
}

interface DocumentUploadProps {
  onDataParsed?: (data: ParsedData) => void;
  acceptedFormats?: string;
}

export const DocumentUpload = ({ 
  onDataParsed, 
  acceptedFormats = ".docx,.doc" 
}: DocumentUploadProps) => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [parsedData, setParsedData] = useState<ParsedData | null>(null);
  const [fileName, setFileName] = useState<string>("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  const extractTablesFromHtml = (html: string): Array<{ headers: string[]; rows: string[][] }> => {
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    const tables = doc.querySelectorAll('table');
    
    const extractedTables: Array<{ headers: string[]; rows: string[][] }> = [];
    
    tables.forEach((table) => {
      const headers: string[] = [];
      const rows: string[][] = [];
      
      // Extract headers
      const headerRow = table.querySelector('thead tr') || table.querySelector('tr');
      if (headerRow) {
        headerRow.querySelectorAll('th, td').forEach((cell) => {
          headers.push(cell.textContent?.trim() || '');
        });
      }
      
      // Extract rows
      const bodyRows = table.querySelectorAll('tbody tr') || table.querySelectorAll('tr');
      bodyRows.forEach((row, index) => {
        // Skip the first row if it was used for headers
        if (index === 0 && !table.querySelector('thead')) {
          return;
        }
        
        const rowData: string[] = [];
        row.querySelectorAll('td, th').forEach((cell) => {
          rowData.push(cell.textContent?.trim() || '');
        });
        
        if (rowData.length > 0) {
          rows.push(rowData);
        }
      });
      
      if (headers.length > 0 || rows.length > 0) {
        extractedTables.push({ headers, rows });
      }
    });
    
    return extractedTables;
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setFileName(file.name);
    setIsProcessing(true);

    try {
      const arrayBuffer = await file.arrayBuffer();
      
      // Parse the Word document
      const result = await mammoth.convertToHtml({ arrayBuffer });
      const html = result.value;
      
      // Extract text (strip HTML tags)
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = html;
      const text = tempDiv.textContent || tempDiv.innerText || '';
      
      // Extract tables
      const tables = extractTablesFromHtml(html);
      
      const parsed: ParsedData = {
        text,
        tables
      };
      
      setParsedData(parsed);
      
      if (onDataParsed) {
        onDataParsed(parsed);
      }
      
      toast.success('Document parsed successfully', {
        description: `Found ${tables.length} table(s) in the document`
      });
      
      if (result.messages.length > 0) {
        console.log('Parsing messages:', result.messages);
      }
    } catch (error) {
      console.error('Error parsing document:', error);
      toast.error('Failed to parse document', {
        description: error instanceof Error ? error.message : 'Unknown error'
      });
    } finally {
      setIsProcessing(false);
    }
  };

  const handleReset = () => {
    setParsedData(null);
    setFileName("");
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Upload Word Document
          </CardTitle>
          <CardDescription>
            Upload a Word document (.docx or .doc) to extract and analyze data
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="document-upload">Select Document</Label>
            <div className="flex gap-2">
              <Input
                id="document-upload"
                ref={fileInputRef}
                type="file"
                accept={acceptedFormats}
                onChange={handleFileUpload}
                disabled={isProcessing}
                className="flex-1"
              />
              {parsedData && (
                <Button onClick={handleReset} variant="outline" type="button">
                  Reset
                </Button>
              )}
            </div>
            <p className="text-xs text-muted-foreground">
              Supported formats: Word documents (.docx, .doc)
            </p>
          </div>

          {isProcessing && (
            <Alert>
              <Loader2 className="h-4 w-4 animate-spin" />
              <AlertTitle>Processing</AlertTitle>
              <AlertDescription>
                Parsing document... This may take a moment.
              </AlertDescription>
            </Alert>
          )}

          {parsedData && !isProcessing && (
            <Alert>
              <CheckCircle className="h-4 w-4 text-green-500" />
              <AlertTitle>Success</AlertTitle>
              <AlertDescription>
                Document "{fileName}" parsed successfully. 
                Found {parsedData.tables.length} table(s).
              </AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      {parsedData && (
        <>
          {parsedData.tables.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Extracted Tables</CardTitle>
                <CardDescription>
                  {parsedData.tables.length} table(s) found in the document
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {parsedData.tables.map((table, tableIndex) => (
                  <div key={tableIndex} className="border rounded-lg overflow-hidden">
                    <div className="bg-muted px-3 py-2">
                      <h4 className="font-medium text-sm">Table {tableIndex + 1}</h4>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-sm">
                        {table.headers.length > 0 && (
                          <thead className="bg-muted/50">
                            <tr>
                              {table.headers.map((header, index) => (
                                <th key={index} className="px-3 py-2 text-left font-medium">
                                  {header || `Column ${index + 1}`}
                                </th>
                              ))}
                            </tr>
                          </thead>
                        )}
                        <tbody>
                          {table.rows.map((row, rowIndex) => (
                            <tr key={rowIndex} className="border-t">
                              {row.map((cell, cellIndex) => (
                                <td key={cellIndex} className="px-3 py-2">
                                  {cell}
                                </td>
                              ))}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader>
              <CardTitle>Extracted Text</CardTitle>
              <CardDescription>
                Full text content from the document
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Textarea
                value={parsedData.text}
                readOnly
                className="min-h-[200px] font-mono text-sm"
                placeholder="No text content found"
              />
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
};

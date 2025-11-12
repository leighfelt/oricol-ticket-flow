import { useState, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { ArrowLeft, Upload, Download, Plus, Trash2, Image as ImageIcon } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { DataTable, Column } from "@/components/DataTable";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

const BranchDetails = () => {
  const { branchId } = useParams();
  const navigate = useNavigate();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [currentTab, setCurrentTab] = useState("overview");
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isNetworkDeviceDialogOpen, setIsNetworkDeviceDialogOpen] = useState(false);
  const [networkDeviceForm, setNetworkDeviceForm] = useState({
    device_name: "",
    device_type: "printer",
    manufacturer: "",
    model: "",
    serial_number: "",
    ip_address: "",
    mac_address: "",
    location: "",
    status: "active",
    notes: "",
  });

  // Fetch branch details
  const { data: branch } = useQuery({
    queryKey: ["branch", branchId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("branches")
        .select("*")
        .eq("id", branchId)
        .single();
      if (error) throw error;
      return data;
    },
  });

  // Fetch hardware inventory for this branch
  const { data: hardwareDevices } = useQuery({
    queryKey: ["hardware", branchId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("hardware_inventory")
        .select("*")
        .eq("branch", branch?.name);
      if (error) throw error;
      return data;
    },
    enabled: !!branch?.name,
  });

  // Fetch directory users for this branch
  const { data: directoryUsers } = useQuery({
    queryKey: ["directory_users", branchId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("directory_users")
        .select("*")
        .eq("department", branch?.name);
      if (error) throw error;
      return data;
    },
    enabled: !!branch?.name,
  });

  // Fetch network devices
  const { data: networkDevices } = useQuery({
    queryKey: ["network_devices", branchId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("network_devices")
        .select("*")
        .eq("branch_id", branchId);
      if (error) throw error;
      return data;
    },
  });

  // Fetch network diagrams
  const { data: networkDiagrams } = useQuery({
    queryKey: ["network_diagrams", branchId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("network_diagrams")
        .select("*")
        .eq("branch_id", branchId);
      if (error) throw error;
      return data;
    },
  });

  const createNetworkDevice = useMutation({
    mutationFn: async (data: typeof networkDeviceForm) => {
      const { error } = await supabase.from("network_devices").insert([
        {
          ...data,
          branch_id: branchId,
        },
      ]);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["network_devices", branchId] });
      setIsNetworkDeviceDialogOpen(false);
      setNetworkDeviceForm({
        device_name: "",
        device_type: "printer",
        manufacturer: "",
        model: "",
        serial_number: "",
        ip_address: "",
        mac_address: "",
        location: "",
        status: "active",
        notes: "",
      });
      toast({
        title: "Success",
        description: "Network device added successfully",
      });
    },
  });

  const downloadCSVTemplate = (type: string) => {
    let headers: string[];
    let example: string[];

    if (type === "network_devices") {
      headers = ["device_name", "device_type", "manufacturer", "model", "serial_number", "ip_address", "mac_address", "location", "status", "notes"];
      example = ["Office Printer 1", "printer", "HP", "LaserJet Pro", "SN123456", "192.168.1.100", "00:1A:2B:3C:4D:5E", "Floor 1", "active", "Main printer"];
    } else {
      headers = ["device_name", "manufacturer", "model", "serial_number", "ip_address", "mac_address"];
      example = ["Device 1", "Dell", "Model X", "SN123", "192.168.1.1", "00:1A:2B:3C:4D:5E"];
    }

    const csv = [headers.join(","), example.join(",")].join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${type}_template.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const handleCSVImport = async (type: string) => {
    const file = fileInputRef.current?.files?.[0];
    if (!file) return;

    const text = await file.text();
    const lines = text.split("\n").filter((line) => line.trim());
    const headers = lines[0].split(",").map((h) => h.trim());
    const rows = lines.slice(1);

    const data = rows.map((row) => {
      const values = row.split(",").map((v) => v.trim());
      const obj: any = { branch_id: branchId };
      headers.forEach((header, i) => {
        obj[header] = values[i] || null;
      });
      return obj;
    });

    try {
      if (type === "network_devices") {
        const { error } = await supabase.from("network_devices").insert(data);
        if (error) throw error;
        queryClient.invalidateQueries({ queryKey: ["network_devices", branchId] });
      }
      toast({
        title: "Success",
        description: `${data.length} records imported successfully`,
      });
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to import CSV",
        variant: "destructive",
      });
    }

    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const exportToCSV = (data: any[], filename: string) => {
    if (!data || data.length === 0) {
      toast({
        title: "No data",
        description: "No data to export",
        variant: "destructive",
      });
      return;
    }

    const headers = Object.keys(data[0]).filter((key) => key !== "id" && key !== "branch_id");
    const csv = [
      headers.join(","),
      ...data.map((row) => headers.map((header) => row[header] || "").join(",")),
    ].join("\n");

    const blob = new Blob([csv], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `${filename}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const hardwareColumns: Column<any>[] = [
    { key: "device_name", label: "Device Name", sortable: true },
    { key: "device_type", label: "Type", sortable: true },
    { key: "manufacturer", label: "Manufacturer", sortable: true },
    { key: "model", label: "Model", sortable: true },
    { key: "serial_number", label: "Serial Number", sortable: true },
    { key: "status", label: "Status", sortable: true },
  ];

  const usersColumns: Column<any>[] = [
    { key: "display_name", label: "Name", sortable: true },
    { key: "email", label: "Email", sortable: true },
    { key: "job_title", label: "Job Title", sortable: true },
    { key: "department", label: "Department", sortable: true },
  ];

  const networkDevicesColumns: Column<any>[] = [
    { key: "device_name", label: "Device Name", sortable: true },
    { key: "device_type", label: "Type", sortable: true },
    { key: "ip_address", label: "IP Address", sortable: true },
    { key: "mac_address", label: "MAC Address", sortable: true },
    { key: "serial_number", label: "Serial Number", sortable: true },
    { key: "manufacturer", label: "Manufacturer", sortable: true },
    { key: "status", label: "Status", sortable: true },
  ];

  return (
    <DashboardLayout>
      <div className="p-6">
        <div className="mb-6">
          <Button variant="ghost" onClick={() => navigate("/branches")}>
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Branches
          </Button>
        </div>

        <h1 className="text-3xl font-bold text-foreground mb-6">{branch?.name}</h1>

        <Tabs value={currentTab} onValueChange={setCurrentTab}>
          <TabsList>
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="users">Users</TabsTrigger>
            <TabsTrigger value="devices">Devices</TabsTrigger>
            <TabsTrigger value="network">Network Equipment</TabsTrigger>
            <TabsTrigger value="diagram">Network Diagram</TabsTrigger>
          </TabsList>

          <TabsContent value="overview">
            <Card>
              <CardHeader>
                <CardTitle>Branch Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                {branch?.address && <p><strong>Address:</strong> {branch.address}</p>}
                {branch?.city && <p><strong>City:</strong> {branch.city}</p>}
                {branch?.state && <p><strong>State:</strong> {branch.state}</p>}
                {branch?.postal_code && <p><strong>Postal Code:</strong> {branch.postal_code}</p>}
                {branch?.country && <p><strong>Country:</strong> {branch.country}</p>}
                {branch?.phone && <p><strong>Phone:</strong> {branch.phone}</p>}
                {branch?.email && <p><strong>Email:</strong> {branch.email}</p>}
                {branch?.notes && <p><strong>Notes:</strong> {branch.notes}</p>}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="users">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle>Users ({directoryUsers?.length || 0})</CardTitle>
                  <Button variant="outline" onClick={() => exportToCSV(directoryUsers || [], `${branch?.name}_users`)}>
                    <Download className="w-4 h-4 mr-2" />
                    Export CSV
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <DataTable
                  data={directoryUsers || []}
                  columns={usersColumns}
                />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="devices">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle>Hardware Devices ({hardwareDevices?.length || 0})</CardTitle>
                  <Button variant="outline" onClick={() => exportToCSV(hardwareDevices || [], `${branch?.name}_devices`)}>
                    <Download className="w-4 h-4 mr-2" />
                    Export CSV
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <DataTable
                  data={hardwareDevices || []}
                  columns={hardwareColumns}
                />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="network">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle>Network Equipment ({networkDevices?.length || 0})</CardTitle>
                  <div className="flex gap-2">
                    <Button variant="outline" onClick={() => downloadCSVTemplate("network_devices")}>
                      <Download className="w-4 h-4 mr-2" />
                      Download Template
                    </Button>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept=".csv"
                      className="hidden"
                      onChange={() => handleCSVImport("network_devices")}
                    />
                    <Button variant="outline" onClick={() => fileInputRef.current?.click()}>
                      <Upload className="w-4 h-4 mr-2" />
                      Import CSV
                    </Button>
                    <Button variant="outline" onClick={() => exportToCSV(networkDevices || [], `${branch?.name}_network_devices`)}>
                      <Download className="w-4 h-4 mr-2" />
                      Export CSV
                    </Button>
                    <Dialog open={isNetworkDeviceDialogOpen} onOpenChange={setIsNetworkDeviceDialogOpen}>
                      <DialogTrigger asChild>
                        <Button>
                          <Plus className="w-4 h-4 mr-2" />
                          Add Device
                        </Button>
                      </DialogTrigger>
                      <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
                        <DialogHeader>
                          <DialogTitle>Add Network Device</DialogTitle>
                        </DialogHeader>
                        <form onSubmit={(e) => { e.preventDefault(); createNetworkDevice.mutate(networkDeviceForm); }} className="space-y-4">
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <Label htmlFor="device_name">Device Name *</Label>
                              <Input
                                id="device_name"
                                value={networkDeviceForm.device_name}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, device_name: e.target.value })}
                                required
                              />
                            </div>
                            <div>
                              <Label htmlFor="device_type">Device Type *</Label>
                              <Input
                                id="device_type"
                                value={networkDeviceForm.device_type}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, device_type: e.target.value })}
                                placeholder="e.g., printer, switch, router"
                                required
                              />
                            </div>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <Label htmlFor="manufacturer">Manufacturer</Label>
                              <Input
                                id="manufacturer"
                                value={networkDeviceForm.manufacturer}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, manufacturer: e.target.value })}
                              />
                            </div>
                            <div>
                              <Label htmlFor="model">Model</Label>
                              <Input
                                id="model"
                                value={networkDeviceForm.model}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, model: e.target.value })}
                              />
                            </div>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <Label htmlFor="serial_number">Serial Number</Label>
                              <Input
                                id="serial_number"
                                value={networkDeviceForm.serial_number}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, serial_number: e.target.value })}
                              />
                            </div>
                            <div>
                              <Label htmlFor="location">Location</Label>
                              <Input
                                id="location"
                                value={networkDeviceForm.location}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, location: e.target.value })}
                              />
                            </div>
                          </div>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <Label htmlFor="ip_address">IP Address</Label>
                              <Input
                                id="ip_address"
                                value={networkDeviceForm.ip_address}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, ip_address: e.target.value })}
                              />
                            </div>
                            <div>
                              <Label htmlFor="mac_address">MAC Address</Label>
                              <Input
                                id="mac_address"
                                value={networkDeviceForm.mac_address}
                                onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, mac_address: e.target.value })}
                              />
                            </div>
                          </div>
                          <div>
                            <Label htmlFor="notes">Notes</Label>
                            <Textarea
                              id="notes"
                              value={networkDeviceForm.notes}
                              onChange={(e) => setNetworkDeviceForm({ ...networkDeviceForm, notes: e.target.value })}
                            />
                          </div>
                          <div className="flex justify-end gap-2">
                            <Button type="button" variant="outline" onClick={() => setIsNetworkDeviceDialogOpen(false)}>
                              Cancel
                            </Button>
                            <Button type="submit">Add Device</Button>
                          </div>
                        </form>
                      </DialogContent>
                    </Dialog>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <DataTable
                  data={networkDevices || []}
                  columns={networkDevicesColumns}
                />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="diagram">
            <Card>
              <CardHeader>
                <CardTitle>Network Diagrams</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground mb-4">
                  Upload network diagram images manually. Supported formats: PNG, JPG, PDF
                </p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {networkDiagrams?.map((diagram) => (
                    <Card key={diagram.id}>
                      <CardContent className="p-4">
                        <div className="flex items-center gap-2">
                          <ImageIcon className="w-4 h-4 text-primary" />
                          <span className="font-medium">{diagram.diagram_name}</span>
                        </div>
                        {diagram.description && (
                          <p className="text-sm text-muted-foreground mt-2">{diagram.description}</p>
                        )}
                      </CardContent>
                    </Card>
                  ))}
                  {(!networkDiagrams || networkDiagrams.length === 0) && (
                    <p className="text-muted-foreground col-span-2">No network diagrams uploaded yet.</p>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </DashboardLayout>
  );
};

export default BranchDetails;

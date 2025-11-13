import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Network, Download, Upload, Plus, Save } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { ImportHistory } from "@/components/ImportHistory";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

interface NetworkDiagram {
  id: string;
  name: string;
  description: string | null;
  diagram_json: Record<string, unknown>;
  is_company_wide: boolean;
  created_by: string | null;
  created_at: string;
}

interface Branch {
  id: string;
  name: string;
  city: string | null;
}

interface NetworkDevice {
  id: string;
  device_name: string;
  device_type: string;
  ip_address: string | null;
  branch_id: string | null;
}

const CompanyNetworkDiagram = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: "Company Network Overview",
    description: "",
  });

  useEffect(() => {
    checkAccess();
  }, [navigate]);

  const checkAccess = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      navigate("/auth");
      return;
    }
  };

  // Fetch all branches
  const { data: branches } = useQuery({
    queryKey: ["branches"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("branches")
        .select("id, name, city")
        .order("name");
      if (error) throw error;
      return data as Branch[];
    },
  });

  // Fetch all network devices
  const { data: networkDevices } = useQuery({
    queryKey: ["all-network-devices"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("network_devices")
        .select("id, device_name, device_type, ip_address, branch_id");
      if (error) throw error;
      return data as NetworkDevice[];
    },
  });

  // Fetch company-wide diagrams
  const { data: diagrams, isLoading } = useQuery({
    queryKey: ["network-diagrams-company"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("network_diagrams")
        .select("*")
        .eq("is_company_wide", true)
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data as NetworkDiagram[];
    },
  });

  const createDiagram = useMutation({
    mutationFn: async (data: typeof formData) => {
      const { data: { user } } = await supabase.auth.getUser();
      
      // Generate diagram data from branches and devices
      const nodes = [
        ...(branches || []).map(branch => ({
          id: `branch-${branch.id}`,
          label: branch.name,
          type: "branch",
          city: branch.city,
        })),
        ...(networkDevices || []).map(device => ({
          id: `device-${device.id}`,
          label: device.device_name,
          type: device.device_type,
          ip: device.ip_address,
        })),
      ];

      const edges = (networkDevices || [])
        .filter(device => device.branch_id)
        .map(device => ({
          from: `branch-${device.branch_id}`,
          to: `device-${device.id}`,
        }));

      const { error } = await supabase.from("network_diagrams").insert([{
        ...data,
        is_company_wide: true,
        diagram_json: { nodes, edges },
        created_by: user?.id,
      }]);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["network-diagrams-company"] });
      toast({
        title: "Success",
        description: "Network diagram created successfully",
      });
      setIsDialogOpen(false);
      setFormData({ name: "Company Network Overview", description: "" });
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const handleDownloadTemplate = () => {
    const headers = ['branch_name', 'device_name', 'device_type', 'ip_address', 'connection_type'];
    const example = 'Head Office,Core Switch,switch,192.168.1.1,direct';
    const csv = headers.join(',') + '\n' + example;
    
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'network_topology_template.csv';
    a.click();
    window.URL.revokeObjectURL(url);
    
    toast({
      title: "Template downloaded",
      description: "CSV template has been downloaded",
    });
  };

  const handleExportDiagram = (diagram: NetworkDiagram) => {
    const dataStr = JSON.stringify(diagram.diagram_json, null, 2);
    const blob = new Blob([dataStr], { type: 'application/json' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${diagram.name.replace(/\s+/g, '_')}_diagram.json`;
    a.click();
    window.URL.revokeObjectURL(url);
    
    toast({
      title: "Diagram exported",
      description: "Network diagram JSON has been downloaded",
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    createDiagram.mutate(formData);
  };

  const getNetworkStats = () => {
    const totalBranches = branches?.length || 0;
    const totalDevices = networkDevices?.length || 0;
    const deviceTypes = new Set((networkDevices || []).map(d => d.device_type)).size;
    
    return { totalBranches, totalDevices, deviceTypes };
  };

  const stats = getNetworkStats();

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-2">
              <Network className="w-8 h-8" />
              Company Network Overview
            </h1>
            <p className="text-muted-foreground">
              Visualize and manage your entire company network topology
            </p>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" onClick={handleDownloadTemplate}>
              <Download className="h-4 w-4 mr-2" />
              Download Template
            </Button>
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Generate Diagram
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Generate Network Diagram</DialogTitle>
                  <DialogDescription>
                    Create a new company-wide network diagram from current data
                  </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Diagram Name</Label>
                    <Input
                      id="name"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      placeholder="e.g., Q4 2024 Network Topology"
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      value={formData.description}
                      onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                      placeholder="Describe this network diagram..."
                      rows={3}
                    />
                  </div>
                  <DialogFooter>
                    <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>
                      Cancel
                    </Button>
                    <Button type="submit" disabled={createDiagram.isPending}>
                      {createDiagram.isPending ? "Generating..." : "Generate"}
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </div>
        </div>

        {/* Network Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total Branches
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.totalBranches}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total Network Devices
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.totalDevices}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Device Types
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stats.deviceTypes}</div>
            </CardContent>
          </Card>
        </div>

        {/* Saved Diagrams */}
        <Card>
          <CardHeader>
            <CardTitle>Saved Network Diagrams</CardTitle>
            <CardDescription>
              Previously generated network topology diagrams
            </CardDescription>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <p className="text-sm text-muted-foreground">Loading diagrams...</p>
            ) : diagrams && diagrams.length > 0 ? (
              <div className="space-y-3">
                {diagrams.map((diagram) => (
                  <div
                    key={diagram.id}
                    className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors"
                  >
                    <div className="flex-1">
                      <h3 className="font-semibold">{diagram.name}</h3>
                      {diagram.description && (
                        <p className="text-sm text-muted-foreground mt-1">
                          {diagram.description}
                        </p>
                      )}
                      <p className="text-xs text-muted-foreground mt-2">
                        Created {new Date(diagram.created_at).toLocaleString()}
                      </p>
                      <div className="flex gap-4 mt-2 text-xs text-muted-foreground">
                        <span>
                          Nodes: {(diagram.diagram_json as any)?.nodes?.length || 0}
                        </span>
                        <span>
                          Edges: {(diagram.diagram_json as any)?.edges?.length || 0}
                        </span>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => handleExportDiagram(diagram)}
                      >
                        <Download className="h-4 w-4 mr-2" />
                        Export JSON
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground text-center py-8">
                No diagrams yet. Click "Generate Diagram" to create one.
              </p>
            )}
          </CardContent>
        </Card>

        {/* Import History */}
        <ImportHistory />
      </div>
    </DashboardLayout>
  );
};

export default CompanyNetworkDiagram;

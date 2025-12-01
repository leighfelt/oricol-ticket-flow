import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import DashboardLayout from "@/components/DashboardLayout";
import { useToast } from "@/hooks/use-toast";
import { Users, Search, Upload, Download, Plus, Trash2, Edit, Info } from "lucide-react";
import { DataTable, type Column } from "@/components/DataTable";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface StaffMember {
  id: string;
  full_name: string;
  email: string | null;
  department: string | null;
  job_title: string | null;
  phone: string | null;
  branch_id: string | null;
  branch_name?: string;
  status: string;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

interface Branch {
  id: string;
  name: string;
}

const Staff = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [staff, setStaff] = useState<StaffMember[]>([]);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedStaff, setSelectedStaff] = useState<StaffMember | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  // Form state
  const [formData, setFormData] = useState({
    full_name: "",
    email: "",
    department: "",
    job_title: "",
    phone: "",
    branch_id: "",
    status: "active",
    notes: "",
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
    fetchStaff();
    fetchBranches();
  };

  const fetchStaff = async () => {
    setLoading(true);
    try {
      const { data, error } = await (supabase as any)
        .from("staff_members")
        .select(`
          *,
          branches:branch_id (name)
        `)
        .order("full_name");

      if (error) throw error;

      const staffWithBranches = (data || []).map((s: any) => ({
        ...s,
        branch_name: s.branches?.name || null,
      }));

      setStaff(staffWithBranches);
    } catch (error) {
      console.error("Error fetching staff:", error);
      // Table might not exist yet - that's okay
      setStaff([]);
    } finally {
      setLoading(false);
    }
  };

  const fetchBranches = async () => {
    try {
      const { data, error } = await supabase
        .from("branches")
        .select("id, name")
        .order("name");

      if (error) throw error;
      setBranches(data || []);
    } catch (error) {
      console.error("Error fetching branches:", error);
    }
  };

  const handleAddStaff = async () => {
    if (!formData.full_name.trim()) {
      toast({
        title: "Error",
        description: "Full name is required",
        variant: "destructive",
      });
      return;
    }

    try {
      const { error } = await (supabase as any)
        .from("staff_members")
        .insert({
          full_name: formData.full_name,
          email: formData.email || null,
          department: formData.department || null,
          job_title: formData.job_title || null,
          phone: formData.phone || null,
          branch_id: formData.branch_id || null,
          status: formData.status,
          notes: formData.notes || null,
        });

      if (error) throw error;

      toast({
        title: "Success",
        description: "Staff member added successfully",
      });

      setAddDialogOpen(false);
      resetForm();
      fetchStaff();
    } catch (error) {
      console.error("Error adding staff:", error);
      toast({
        title: "Error",
        description: "Failed to add staff member",
        variant: "destructive",
      });
    }
  };

  const handleUpdateStaff = async () => {
    if (!selectedStaff) return;

    try {
      const { error } = await (supabase as any)
        .from("staff_members")
        .update({
          full_name: formData.full_name,
          email: formData.email || null,
          department: formData.department || null,
          job_title: formData.job_title || null,
          phone: formData.phone || null,
          branch_id: formData.branch_id || null,
          status: formData.status,
          notes: formData.notes || null,
        })
        .eq("id", selectedStaff.id);

      if (error) throw error;

      toast({
        title: "Success",
        description: "Staff member updated successfully",
      });

      setIsEditing(false);
      setSheetOpen(false);
      fetchStaff();
    } catch (error) {
      console.error("Error updating staff:", error);
      toast({
        title: "Error",
        description: "Failed to update staff member",
        variant: "destructive",
      });
    }
  };

  const handleDeleteStaff = async (id: string) => {
    if (!confirm("Are you sure you want to delete this staff member?")) return;

    try {
      const { error } = await (supabase as any)
        .from("staff_members")
        .delete()
        .eq("id", id);

      if (error) throw error;

      toast({
        title: "Success",
        description: "Staff member deleted successfully",
      });

      setSheetOpen(false);
      fetchStaff();
    } catch (error) {
      console.error("Error deleting staff:", error);
      toast({
        title: "Error",
        description: "Failed to delete staff member",
        variant: "destructive",
      });
    }
  };

  const resetForm = () => {
    setFormData({
      full_name: "",
      email: "",
      department: "",
      job_title: "",
      phone: "",
      branch_id: "",
      status: "active",
      notes: "",
    });
  };

  const handleRowClick = (member: StaffMember) => {
    setSelectedStaff(member);
    setFormData({
      full_name: member.full_name || "",
      email: member.email || "",
      department: member.department || "",
      job_title: member.job_title || "",
      phone: member.phone || "",
      branch_id: member.branch_id || "",
      status: member.status || "active",
      notes: member.notes || "",
    });
    setIsEditing(false);
    setSheetOpen(true);
  };

  const handleCSVImport = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      const text = await file.text();
      const lines = text.split("\n").filter(line => line.trim());
      const headers = lines[0].split(",").map(h => h.trim().toLowerCase());
      
      const staffToImport = lines.slice(1).map(line => {
        const values = line.split(",").map(v => v.trim());
        const record: any = {};
        
        headers.forEach((header, index) => {
          if (header.includes("name")) record.full_name = values[index];
          else if (header.includes("email")) record.email = values[index] || null;
          else if (header.includes("department")) record.department = values[index] || null;
          else if (header.includes("title") || header.includes("position")) record.job_title = values[index] || null;
          else if (header.includes("phone")) record.phone = values[index] || null;
          else if (header.includes("notes")) record.notes = values[index] || null;
        });
        
        record.status = "active";
        return record;
      }).filter(r => r.full_name);

      if (staffToImport.length === 0) {
        throw new Error("No valid staff records found in CSV");
      }

      const { error } = await (supabase as any)
        .from("staff_members")
        .insert(staffToImport);

      if (error) throw error;

      toast({
        title: "Success",
        description: `Imported ${staffToImport.length} staff members`,
      });

      fetchStaff();
    } catch (error) {
      console.error("Error importing CSV:", error);
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to import CSV",
        variant: "destructive",
      });
    }

    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const downloadCSVTemplate = () => {
    const headers = ["full_name", "email", "department", "job_title", "phone", "notes"];
    const example = "John Doe,john@example.com,IT,Software Developer,+27123456789,New hire";
    const csv = headers.join(",") + "\n" + example;
    
    const blob = new Blob([csv], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "staff_template.csv";
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const filteredStaff = staff.filter(member => {
    const searchLower = searchQuery.toLowerCase();
    return (
      member.full_name?.toLowerCase().includes(searchLower) ||
      member.email?.toLowerCase().includes(searchLower) ||
      member.department?.toLowerCase().includes(searchLower) ||
      member.job_title?.toLowerCase().includes(searchLower)
    );
  });

  const columns: Column<StaffMember>[] = [
    {
      key: "full_name",
      label: "Name",
      sortable: true,
      filterPlaceholder: "Filter by name...",
    },
    {
      key: "email",
      label: "Email",
      sortable: true,
      filterPlaceholder: "Filter by email...",
    },
    {
      key: "department",
      label: "Department",
      sortable: true,
    },
    {
      key: "job_title",
      label: "Job Title",
      sortable: true,
    },
    {
      key: "branch_name",
      label: "Branch",
      sortable: true,
      render: (value, member) => member.branch_name || "-",
    },
    {
      key: "status",
      label: "Status",
      sortable: true,
      render: (value, member) => (
        <Badge variant={member.status === "active" ? "default" : "secondary"}>
          {member.status?.toUpperCase() || "ACTIVE"}
        </Badge>
      ),
    },
  ];

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-2">
              <Users className="w-8 h-8" />
              Staff Directory
            </h1>
            <p className="text-muted-foreground">
              Manage staff member records (non-login user records)
            </p>
          </div>
          <div className="flex gap-2 flex-wrap">
            <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Add Staff Member
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-lg">
                <DialogHeader>
                  <DialogTitle>Add Staff Member</DialogTitle>
                  <DialogDescription>
                    Add a new staff member to the directory. This is a record only - not a system login user.
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="full_name">Full Name *</Label>
                      <Input
                        id="full_name"
                        value={formData.full_name}
                        onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                        placeholder="John Doe"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">Email</Label>
                      <Input
                        id="email"
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                        placeholder="john@example.com"
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="department">Department</Label>
                      <Input
                        id="department"
                        value={formData.department}
                        onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                        placeholder="IT"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="job_title">Job Title</Label>
                      <Input
                        id="job_title"
                        value={formData.job_title}
                        onChange={(e) => setFormData({ ...formData, job_title: e.target.value })}
                        placeholder="Software Developer"
                      />
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="phone">Phone</Label>
                      <Input
                        id="phone"
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        placeholder="+27..."
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="branch">Branch</Label>
                      <Select
                        value={formData.branch_id}
                        onValueChange={(value) => setFormData({ ...formData, branch_id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select branch" />
                        </SelectTrigger>
                        <SelectContent>
                          {branches.map((branch) => (
                            <SelectItem key={branch.id} value={branch.id}>
                              {branch.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="notes">Notes</Label>
                    <Textarea
                      id="notes"
                      value={formData.notes}
                      onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                      placeholder="Additional notes..."
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setAddDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddStaff}>Add Staff Member</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
            <Button variant="outline" onClick={downloadCSVTemplate}>
              <Download className="h-4 w-4 mr-2" />
              CSV Template
            </Button>
            <Button variant="outline" onClick={() => fileInputRef.current?.click()}>
              <Upload className="h-4 w-4 mr-2" />
              Import CSV
            </Button>
            <input
              ref={fileInputRef}
              type="file"
              accept=".csv"
              onChange={handleCSVImport}
              className="hidden"
            />
          </div>
        </div>

        <Alert>
          <Info className="h-4 w-4" />
          <AlertTitle>Staff Directory</AlertTitle>
          <AlertDescription>
            This page is for managing staff member records. These are <strong>not login users</strong>.
            For platform credentials (VPN, RDP), use the dedicated <a href="/vpn" className="underline font-medium">VPN</a> and <a href="/rdp" className="underline font-medium">RDP</a> pages.
            For system login users, visit the <a href="/users" className="underline font-medium">Users</a> page.
          </AlertDescription>
        </Alert>

        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle>Staff Members</CardTitle>
                <CardDescription>
                  {filteredStaff.length} staff member{filteredStaff.length !== 1 ? "s" : ""} in directory
                </CardDescription>
              </div>
              <div className="relative w-64">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search staff..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {loading ? (
              <p className="text-muted-foreground">Loading staff members...</p>
            ) : filteredStaff.length === 0 ? (
              <div className="text-center py-12">
                <Users className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-medium mb-2">No Staff Members</h3>
                <p className="text-muted-foreground mb-4">
                  {searchQuery ? "No staff members match your search." : "Add your first staff member to get started."}
                </p>
                {!searchQuery && (
                  <Button onClick={() => setAddDialogOpen(true)}>
                    <Plus className="h-4 w-4 mr-2" />
                    Add Staff Member
                  </Button>
                )}
              </div>
            ) : (
              <DataTable
                data={filteredStaff}
                columns={columns}
                onRowClick={handleRowClick}
                searchKeys={["full_name", "email", "department", "job_title"]}
              />
            )}
          </CardContent>
        </Card>

        {/* Staff Details Sheet */}
        <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
          <SheetContent className="overflow-y-auto">
            <SheetHeader>
              <SheetTitle>Staff Member Details</SheetTitle>
              <SheetDescription>
                View and edit staff member information
              </SheetDescription>
            </SheetHeader>

            {selectedStaff && (
              <div className="space-y-6 mt-6">
                {isEditing ? (
                  // Edit mode
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label>Full Name</Label>
                      <Input
                        value={formData.full_name}
                        onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Email</Label>
                      <Input
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Department</Label>
                      <Input
                        value={formData.department}
                        onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Job Title</Label>
                      <Input
                        value={formData.job_title}
                        onChange={(e) => setFormData({ ...formData, job_title: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Phone</Label>
                      <Input
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>Branch</Label>
                      <Select
                        value={formData.branch_id}
                        onValueChange={(value) => setFormData({ ...formData, branch_id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select branch" />
                        </SelectTrigger>
                        <SelectContent>
                          {branches.map((branch) => (
                            <SelectItem key={branch.id} value={branch.id}>
                              {branch.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label>Status</Label>
                      <Select
                        value={formData.status}
                        onValueChange={(value) => setFormData({ ...formData, status: value })}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="active">Active</SelectItem>
                          <SelectItem value="inactive">Inactive</SelectItem>
                          <SelectItem value="on_leave">On Leave</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label>Notes</Label>
                      <Textarea
                        value={formData.notes}
                        onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                      />
                    </div>
                    <div className="flex gap-2">
                      <Button onClick={handleUpdateStaff}>Save Changes</Button>
                      <Button variant="outline" onClick={() => setIsEditing(false)}>Cancel</Button>
                    </div>
                  </div>
                ) : (
                  // View mode
                  <>
                    <div className="space-y-4">
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Full Name</Label>
                        <p className="font-medium">{selectedStaff.full_name}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Email</Label>
                        <p>{selectedStaff.email || "-"}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Department</Label>
                        <p>{selectedStaff.department || "-"}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Job Title</Label>
                        <p>{selectedStaff.job_title || "-"}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Phone</Label>
                        <p>{selectedStaff.phone || "-"}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Branch</Label>
                        <p>{selectedStaff.branch_name || "-"}</p>
                      </div>
                      <div className="space-y-1">
                        <Label className="text-muted-foreground">Status</Label>
                        <Badge variant={selectedStaff.status === "active" ? "default" : "secondary"}>
                          {selectedStaff.status?.toUpperCase() || "ACTIVE"}
                        </Badge>
                      </div>
                      {selectedStaff.notes && (
                        <div className="space-y-1">
                          <Label className="text-muted-foreground">Notes</Label>
                          <p className="text-sm">{selectedStaff.notes}</p>
                        </div>
                      )}
                    </div>
                    <div className="flex gap-2 pt-4 border-t">
                      <Button onClick={() => setIsEditing(true)}>
                        <Edit className="h-4 w-4 mr-2" />
                        Edit
                      </Button>
                      <Button
                        variant="destructive"
                        onClick={() => handleDeleteStaff(selectedStaff.id)}
                      >
                        <Trash2 className="h-4 w-4 mr-2" />
                        Delete
                      </Button>
                    </div>
                  </>
                )}
              </div>
            )}
          </SheetContent>
        </Sheet>
      </div>
    </DashboardLayout>
  );
};

export default Staff;

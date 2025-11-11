import { useState, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Trash2 } from "lucide-react";
import { toast } from "sonner";
import DashboardLayout from "@/components/DashboardLayout";

const Licenses = () => {
  const [licenses, setLicenses] = useState<any[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);
  const [formData, setFormData] = useState({
    license_name: "",
    license_type: "",
    vendor: "",
    license_key: "",
    total_seats: "",
    used_seats: "0",
    purchase_date: "",
    renewal_date: "",
    cost: "",
    status: "active",
    notes: "",
  });

  useEffect(() => {
    checkAdminRole();
    fetchLicenses();
  }, []);

  const checkAdminRole = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session?.user) {
      const { data } = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', session.user.id)
        .eq('role', 'admin')
        .single();
      setIsAdmin(!!data);
    }
  };

  const fetchLicenses = async () => {
    const { data, error } = await supabase
      .from('licenses')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error fetching licenses:', error);
      toast.error('Failed to load licenses');
    } else {
      setLicenses(data || []);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const licenseData = {
      ...formData,
      total_seats: parseInt(formData.total_seats),
      used_seats: parseInt(formData.used_seats),
      cost: formData.cost ? parseFloat(formData.cost) : null,
      purchase_date: formData.purchase_date || null,
      renewal_date: formData.renewal_date || null,
    };

    const { error } = await supabase.from('licenses').insert([licenseData]);
    
    if (error) {
      console.error('Error creating license:', error);
      toast.error('Failed to create license');
    } else {
      toast.success('License created successfully');
      setIsModalOpen(false);
      setFormData({
        license_name: "",
        license_type: "",
        vendor: "",
        license_key: "",
        total_seats: "",
        used_seats: "0",
        purchase_date: "",
        renewal_date: "",
        cost: "",
        status: "active",
        notes: "",
      });
      fetchLicenses();
    }
  };

  const handleDelete = async (id: string) => {
    const { error } = await supabase.from('licenses').delete().eq('id', id);
    
    if (error) {
      console.error('Error deleting license:', error);
      toast.error('Failed to delete license');
    } else {
      toast.success('License deleted successfully');
      fetchLicenses();
    }
  };

  return (
    <DashboardLayout>
      <div className="p-8">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-3xl font-bold">License Management</h1>
            <p className="text-muted-foreground">Track RDP, Microsoft 365, and other software licenses</p>
          </div>
          {isAdmin && (
            <Button onClick={() => setIsModalOpen(true)}>
              Add License
            </Button>
          )}
        </div>

        <div className="grid gap-4 mb-6 md:grid-cols-3">
          <Card>
            <CardHeader>
              <CardTitle>Total Licenses</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{licenses.length}</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle>Total Seats</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">
                {licenses.reduce((acc, l) => acc + l.total_seats, 0)}
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle>Used Seats</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">
                {licenses.reduce((acc, l) => acc + l.used_seats, 0)}
              </p>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>All Licenses</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>License Name</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Vendor</TableHead>
                  <TableHead>Seats</TableHead>
                  <TableHead>Usage</TableHead>
                  <TableHead>Renewal Date</TableHead>
                  <TableHead>Cost</TableHead>
                  <TableHead>Status</TableHead>
                  {isAdmin && <TableHead>Actions</TableHead>}
                </TableRow>
              </TableHeader>
              <TableBody>
                {licenses.map((license) => {
                  const usagePercent = (license.used_seats / license.total_seats) * 100;
                  return (
                    <TableRow key={license.id}>
                      <TableCell className="font-medium">{license.license_name}</TableCell>
                      <TableCell>{license.license_type}</TableCell>
                      <TableCell>{license.vendor}</TableCell>
                      <TableCell>{license.used_seats} / {license.total_seats}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Progress value={usagePercent} className="w-20" />
                          <span className="text-sm">{usagePercent.toFixed(0)}%</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        {license.renewal_date ? new Date(license.renewal_date).toLocaleDateString() : '-'}
                      </TableCell>
                      <TableCell>{license.cost ? `R${license.cost.toFixed(2)}` : '-'}</TableCell>
                      <TableCell>
                        <Badge variant={license.status === 'active' ? 'default' : 'secondary'}>
                          {license.status}
                        </Badge>
                      </TableCell>
                      {isAdmin && (
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(license.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </TableCell>
                      )}
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
          <DialogContent className="max-w-xl">
            <DialogHeader>
              <DialogTitle>Add License</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="license_name">License Name *</Label>
                  <Input
                    id="license_name"
                    value={formData.license_name}
                    onChange={(e) => setFormData({ ...formData, license_name: e.target.value })}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="license_type">License Type *</Label>
                  <Select
                    value={formData.license_type}
                    onValueChange={(value) => setFormData({ ...formData, license_type: value })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="RDP">RDP</SelectItem>
                      <SelectItem value="Microsoft 365">Microsoft 365</SelectItem>
                      <SelectItem value="Windows">Windows</SelectItem>
                      <SelectItem value="Antivirus">Antivirus</SelectItem>
                      <SelectItem value="Other">Other</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label htmlFor="vendor">Vendor *</Label>
                  <Input
                    id="vendor"
                    value={formData.vendor}
                    onChange={(e) => setFormData({ ...formData, vendor: e.target.value })}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="license_key">License Key</Label>
                  <Input
                    id="license_key"
                    value={formData.license_key}
                    onChange={(e) => setFormData({ ...formData, license_key: e.target.value })}
                  />
                </div>
                <div>
                  <Label htmlFor="total_seats">Total Seats *</Label>
                  <Input
                    id="total_seats"
                    type="number"
                    value={formData.total_seats}
                    onChange={(e) => setFormData({ ...formData, total_seats: e.target.value })}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="used_seats">Used Seats</Label>
                  <Input
                    id="used_seats"
                    type="number"
                    value={formData.used_seats}
                    onChange={(e) => setFormData({ ...formData, used_seats: e.target.value })}
                  />
                </div>
                <div>
                  <Label htmlFor="purchase_date">Purchase Date</Label>
                  <Input
                    id="purchase_date"
                    type="date"
                    value={formData.purchase_date}
                    onChange={(e) => setFormData({ ...formData, purchase_date: e.target.value })}
                  />
                </div>
                <div>
                  <Label htmlFor="renewal_date">Renewal Date</Label>
                  <Input
                    id="renewal_date"
                    type="date"
                    value={formData.renewal_date}
                    onChange={(e) => setFormData({ ...formData, renewal_date: e.target.value })}
                  />
                </div>
                <div>
                  <Label htmlFor="cost">Cost (R)</Label>
                  <Input
                    id="cost"
                    type="number"
                    step="0.01"
                    value={formData.cost}
                    onChange={(e) => setFormData({ ...formData, cost: e.target.value })}
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="notes">Notes</Label>
                <Input
                  id="notes"
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                />
              </div>
              <Button type="submit">Create License</Button>
            </form>
          </DialogContent>
        </Dialog>
      </div>
    </DashboardLayout>
  );
};

export default Licenses;

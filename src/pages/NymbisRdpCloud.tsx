import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import DashboardLayout from "@/components/DashboardLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Plus, Upload, Download, Cloud, Network, Image as ImageIcon, Trash2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";

interface CloudNetwork {
  id: string;
  name: string;
  provider: string;
  network_type: string | null;
  description: string | null;
  diagram_json: Record<string, unknown>;
  image_path: string | null;
  metadata: Record<string, unknown>;
  branch_id: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

const NymbisRdpCloud = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const imageInputRef = useRef<HTMLInputElement>(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [selectedNetwork, setSelectedNetwork] = useState<CloudNetwork | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    provider: "nymbis",
    network_type: "rdp",
    description: "",
  });
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

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

  const { data: cloudNetworks, isLoading } = useQuery({
    queryKey: ["cloud-networks"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("cloud_networks")
        .select("*")
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data as CloudNetwork[];
    },
  });

  const createNetwork = useMutation({
    mutationFn: async (data: typeof formData & { image_path?: string }) => {
      const { data: { user } } = await supabase.auth.getUser();
      const { error } = await supabase.from("cloud_networks").insert([{
        ...data,
        created_by: user?.id,
      }]);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["cloud-networks"] });
      toast({
        title: "Success",
        description: "Cloud network created successfully",
      });
      setIsDialogOpen(false);
      resetForm();
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const deleteNetwork = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from("cloud_networks")
        .delete()
        .eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["cloud-networks"] });
      toast({
        title: "Success",
        description: "Cloud network deleted successfully",
      });
    },
    onError: (error: Error) => {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    },
  });

  const resetForm = () => {
    setFormData({
      name: "",
      provider: "nymbis",
      network_type: "rdp",
      description: "",
    });
    setSelectedImage(null);
    setImagePreview(null);
  };

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    const validTypes = ['image/png', 'image/jpeg', 'image/jpg'];
    if (!validTypes.includes(file.type)) {
      toast({
        title: "Invalid file type",
        description: "Please upload a PNG, JPG, or JPEG image",
        variant: "destructive",
      });
      return;
    }

    setSelectedImage(file);
    
    // Create preview
    const reader = new FileReader();
    reader.onloadend = () => {
      setImagePreview(reader.result as string);
    };
    reader.readAsDataURL(file);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    let imagePath: string | undefined;

    // Upload image if selected
    if (selectedImage) {
      const fileExt = selectedImage.name.split('.').pop();
      const fileName = `${Date.now()}_${Math.random().toString(36).substring(7)}.${fileExt}`;
      const filePath = `cloud-networks/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from('diagrams')
        .upload(filePath, selectedImage);

      if (uploadError) {
        toast({
          title: "Error",
          description: `Failed to upload image: ${uploadError.message}`,
          variant: "destructive",
        });
        return;
      }

      imagePath = filePath;
    }

    createNetwork.mutate({ ...formData, image_path: imagePath });
  };

  const handleDownloadTemplate = () => {
    const headers = ['name', 'provider', 'network_type', 'description'];
    const example = 'Nymbis RDP Network,nymbis,rdp,Main RDP cloud network for remote access';
    const csv = headers.join(',') + '\n' + example;
    
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'cloud_networks_template.csv';
    a.click();
    window.URL.revokeObjectURL(url);
    
    toast({
      title: "Template downloaded",
      description: "CSV template has been downloaded",
    });
  };

  const getProviderColor = (provider: string) => {
    const colors: Record<string, string> = {
      nymbis: "bg-blue-500",
      aws: "bg-orange-500",
      azure: "bg-cyan-500",
      gcp: "bg-green-500",
    };
    return colors[provider] || "bg-gray-500";
  };

  const nymbisNetworks = cloudNetworks?.filter(n => n.provider === 'nymbis') || [];
  const otherNetworks = cloudNetworks?.filter(n => n.provider !== 'nymbis') || [];

  return (
    <DashboardLayout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-2">
              <Cloud className="w-8 h-8" />
              Nymbis RDP Cloud Network
            </h1>
            <p className="text-muted-foreground">Manage cloud network configurations and diagrams</p>
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
                  Add Network
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl">
                <DialogHeader>
                  <DialogTitle>Add Cloud Network</DialogTitle>
                  <DialogDescription>
                    Create a new cloud network configuration with optional diagram image
                  </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Network Name</Label>
                    <Input
                      id="name"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      placeholder="e.g., Nymbis RDP Network"
                      required
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="provider">Provider</Label>
                      <Select
                        value={formData.provider}
                        onValueChange={(value) => setFormData({ ...formData, provider: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select provider" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="nymbis">Nymbis</SelectItem>
                          <SelectItem value="aws">AWS</SelectItem>
                          <SelectItem value="azure">Azure</SelectItem>
                          <SelectItem value="gcp">Google Cloud</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="network_type">Network Type</Label>
                      <Select
                        value={formData.network_type}
                        onValueChange={(value) => setFormData({ ...formData, network_type: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select type" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="rdp">RDP</SelectItem>
                          <SelectItem value="vpn">VPN</SelectItem>
                          <SelectItem value="hybrid">Hybrid</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      value={formData.description}
                      onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                      placeholder="Describe this cloud network..."
                      rows={3}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="diagram">Network Diagram (PNG/JPG/JPEG)</Label>
                    <div className="flex gap-2">
                      <Input
                        id="diagram"
                        type="file"
                        accept="image/png,image/jpeg,image/jpg"
                        onChange={handleImageSelect}
                        ref={imageInputRef}
                        className="flex-1"
                      />
                      {selectedImage && (
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => {
                            setSelectedImage(null);
                            setImagePreview(null);
                            if (imageInputRef.current) {
                              imageInputRef.current.value = '';
                            }
                          }}
                        >
                          Clear
                        </Button>
                      )}
                    </div>
                    {imagePreview && (
                      <div className="mt-2 border rounded-lg p-2">
                        <img 
                          src={imagePreview} 
                          alt="Preview" 
                          className="max-h-48 mx-auto object-contain"
                        />
                      </div>
                    )}
                  </div>

                  <DialogFooter>
                    <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>
                      Cancel
                    </Button>
                    <Button type="submit" disabled={createNetwork.isPending}>
                      {createNetwork.isPending ? "Creating..." : "Create Network"}
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </div>
        </div>

        {isLoading ? (
          <p>Loading cloud networks...</p>
        ) : (
          <div className="space-y-6">
            {/* Nymbis Networks Section */}
            <div>
              <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
                <Network className="w-5 h-5" />
                Nymbis RDP Networks ({nymbisNetworks.length})
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {nymbisNetworks.map((network) => (
                  <Card key={network.id} className="hover:shadow-lg transition-shadow">
                    <CardHeader>
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <CardTitle className="text-lg">{network.name}</CardTitle>
                          <CardDescription className="mt-1">
                            <div className="flex gap-2 mt-2">
                              <Badge className={getProviderColor(network.provider)}>
                                {network.provider.toUpperCase()}
                              </Badge>
                              {network.network_type && (
                                <Badge variant="outline">
                                  {network.network_type.toUpperCase()}
                                </Badge>
                              )}
                            </div>
                          </CardDescription>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => deleteNetwork.mutate(network.id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    </CardHeader>
                    <CardContent>
                      {network.image_path && (
                        <div className="mb-3 border rounded-lg p-2 bg-muted">
                          <ImageIcon className="h-8 w-8 mx-auto text-muted-foreground" />
                          <p className="text-xs text-center mt-1 text-muted-foreground">
                            Diagram attached
                          </p>
                        </div>
                      )}
                      {network.description && (
                        <p className="text-sm text-muted-foreground line-clamp-3">
                          {network.description}
                        </p>
                      )}
                      <div className="mt-3 text-xs text-muted-foreground">
                        Created {new Date(network.created_at).toLocaleDateString()}
                      </div>
                    </CardContent>
                  </Card>
                ))}
                {nymbisNetworks.length === 0 && (
                  <div className="col-span-full text-center py-12 text-muted-foreground">
                    No Nymbis networks yet. Click "Add Network" to create one.
                  </div>
                )}
              </div>
            </div>

            {/* Other Cloud Networks Section */}
            {otherNetworks.length > 0 && (
              <div>
                <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
                  <Cloud className="w-5 h-5" />
                  Other Cloud Networks ({otherNetworks.length})
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {otherNetworks.map((network) => (
                    <Card key={network.id} className="hover:shadow-lg transition-shadow">
                      <CardHeader>
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <CardTitle className="text-lg">{network.name}</CardTitle>
                            <CardDescription className="mt-1">
                              <div className="flex gap-2 mt-2">
                                <Badge className={getProviderColor(network.provider)}>
                                  {network.provider.toUpperCase()}
                                </Badge>
                                {network.network_type && (
                                  <Badge variant="outline">
                                    {network.network_type.toUpperCase()}
                                  </Badge>
                                )}
                              </div>
                            </CardDescription>
                          </div>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => deleteNetwork.mutate(network.id)}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </div>
                      </CardHeader>
                      <CardContent>
                        {network.image_path && (
                          <div className="mb-3 border rounded-lg p-2 bg-muted">
                            <ImageIcon className="h-8 w-8 mx-auto text-muted-foreground" />
                            <p className="text-xs text-center mt-1 text-muted-foreground">
                              Diagram attached
                            </p>
                          </div>
                        )}
                        {network.description && (
                          <p className="text-sm text-muted-foreground line-clamp-3">
                            {network.description}
                          </p>
                        )}
                        <div className="mt-3 text-xs text-muted-foreground">
                          Created {new Date(network.created_at).toLocaleDateString()}
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
};

export default NymbisRdpCloud;
